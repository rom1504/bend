"""Token-preserving alpha-renaming ceiling for frozen generated QBE globals.

No Bend compiler transformation occurs here. Strings/comments and all nonsymbol
bytes are copied unchanged. Private-only preserves every export; closed-image
also renames generated segment exports and therefore changes the exported ELF
symbol API. Both retain runtime/foreign references and explicit ABI/tool anchors.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import resource
import shutil
import subprocess
import time

ROOT=Path(__file__).resolve().parents[5]
SOURCE_SHA='f3ff63b04b58e5a5b92be781d0d1cba8cc574a37765cbf66d817c3d38f4b576e'
SPECIAL=re.compile(rb'[$"#]')
NAME=re.compile(rb'[A-Za-z_][A-Za-z0-9_.]*')
HEADER=re.compile(rb'^\s*(export\s+)?(function|data)\b')
ANCHORS={b'main',b'p111_program',b'p111_segments',b'bend_profile_dispatch_get'}

def pin(path):
    path=Path(path).resolve();h=hashlib.sha256()
    with path.open('rb')as f:
        for chunk in iter(lambda:f.read(1024*1024),b''):h.update(chunk)
    return dict(file=str(path),bytes=path.stat().st_size,sha256=h.hexdigest())

def tokens(line):
    """Yield only globals/strings/comments; all remaining spans are opaque bytes.

    Search markers with a regex, but consume strings and comments lexically
    before considering any `$` within them. Quoted/multiline identifiers or
    unterminated strings are rejected rather than partially rewritten.
    """
    pos=0
    while match:=SPECIAL.search(line,pos):
        start=match.start();mark=line[start]
        if mark==35:
            yield 'comment',start,len(line),line[start:];return
        if mark==34:
            end=start+1
            while True:
                quote=line.find(b'"',end)
                if quote<0:raise ValueError('Unterminated/multiline QBE string')
                back=quote-1
                while back>start and line[back]==92:back-=1
                if (quote-1-back)%2==0:
                    end=quote+1;break
                end=quote+1
            yield 'string',start,end,line[start:end];pos=end
        else:
            ident=NAME.match(line,start+1)
            if not ident:raise ValueError('Unsupported quoted/noncanonical QBE global')
            end=ident.end()
            if end<len(line) and line[end]not in b' \t\r\n,(){}[]=+-*/:':
                raise ValueError('Unsupported global identifier continuation')
            yield 'global',start,end,ident.group();pos=end

def digest_item(digest,value):
    digest.update(len(value).to_bytes(8,'little'));digest.update(value)

def scan(path):
    defs=[];names=set();uses=Counter();strings=hashlib.sha256();comments=hashlib.sha256()
    string_count=comment_count=string_bytes=0;exports=set();lines=0
    with path.open('rb')as stream:
        for line in stream:
            lines+=1;header=HEADER.match(line);first=None
            for kind,start,end,value in tokens(line):
                if kind=='global':
                    uses[value]+=1
                    if first is None:first=value
                elif kind=='string':
                    digest_item(strings,value);string_count+=1;string_bytes+=len(value)
                else:digest_item(comments,value);comment_count+=1
            if header:
                assert first is not None and first not in names,'Missing/duplicate definition'
                names.add(first);exported=bool(header[1]);kind=header[2].decode()
                defs.append(dict(name=first,kind=kind,exported=exported,line=lines))
                if exported:exports.add(first)
    return dict(definitions=defs,defined=names,uses=uses,exports=exports,lines=lines,
        strings=dict(count=string_count,bytes=string_bytes,sha256=strings.hexdigest()),
        comments=dict(count=comment_count,sha256=comments.hexdigest()))

def base36(n):
    digits=b'0123456789abcdefghijklmnopqrstuvwxyz';result=b''
    while True:
        n,d=divmod(n,36);result=bytes([digits[d]])+result
        if not n:return result

def make_map(info,mode,runtime_names):
    protected=ANCHORS|runtime_names
    if mode=='private':protected=protected|info['exports']
    else:
        # Explicitly closed-image-only: do not guess about unknown exports.
        protected=protected|{n for n in info['exports']if not n.startswith(b'p111_FID_')}
    reserved=set(info['uses'])|runtime_names|protected
    result={};next_id=0
    for row in info['definitions']:
        name=row['name']
        if name in protected:continue
        while True:
            candidate=b'q'+base36(next_id);next_id+=1
            if candidate not in reserved:break
        reserved.add(candidate);result[name]=candidate
    assert len(result)==len(set(result.values()))
    assert not set(result.values())&set(info['uses'])
    return result,protected

def rewrite_line(line,mapping):
    parts=[];previous=0
    for kind,start,end,value in tokens(line):
        if kind=='global'and value in mapping:
            parts += [line[previous:start+1],mapping[value]];previous=end
    return b''.join(parts)+line[previous:] if parts else line

def rewrite(source,target,mapping):
    with source.open('rb')as src,target.open('xb')as dst:
        for line in src:dst.write(rewrite_line(line,mapping))

def roundtrip(path,inverse):
    result=hashlib.sha256()
    with path.open('rb')as source:
        for line in source:result.update(rewrite_line(line,inverse))
    return result.hexdigest()

def selftest():
    text=(b'export function l $main() {\n@entry\n'
          b'%x =l call $private() # $private untouched\nret %x\n}\n'
          b'function l $private() {\n@entry\nret 1\n}\n'
          b'data $table = { l $private, l $external, b "$private \\\" $other", b 0 }\n')
    mapping={b'private':b'q0',b'table':b'q1'}
    changed=b''.join(rewrite_line(line,mapping)for line in text.splitlines(keepends=True))
    assert b'call $q0() # $private untouched'in changed
    assert b'b "$private \\\" $other"'in changed and b'l $external'in changed
    restored=b''.join(rewrite_line(line,{v:k for k,v in mapping.items()})for line in changed.splitlines(keepends=True))
    assert restored==text
    for bad in [b'$"quoted"',b'"unterminated\n',b'$bad?name']:
        try:list(tokens(bad))
        except ValueError:pass
        else:raise AssertionError('Malformed token was accepted')
    return dict(passed=True,checks=7,scope='Strings, escaped quote, comments, references, export retention, inverse bytes, unsupported tokens.')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--source',type=Path,required=True)
    p.add_argument('--runtime',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();source=a.source.resolve();runtime=a.runtime.resolve();out=a.out.resolve()
    assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase132')
    assert pin(source)['sha256']==SOURCE_SHA
    tests=selftest();started=time.monotonic();info=scan(source);scan_seconds=time.monotonic()-started
    nm=Path(shutil.which('nm'));nm_text=subprocess.check_output([str(nm),'-g',str(runtime)],text=True)
    runtime_names={line.split()[-1].encode()for line in nm_text.splitlines()if line.split()}
    unresolved=set(info['uses'])-info['defined'];assert not info['defined']&runtime_names
    out.mkdir(parents=True);(out/'runtime-global-symbols.txt').write_text(nm_text)
    report=dict(complete=False,targetsRun=False,productionChange=False,source=pin(source),
        inputs=[pin(__file__),pin(source),pin(runtime),pin(nm)],selftest=tests,scanSeconds=scan_seconds,
        globalDefinitions=len(info['definitions']),exports=len(info['exports']),
        externalSymbols=sorted(n.decode()for n in unresolved),runtimeSymbols=pin(out/'runtime-global-symbols.txt'),
        originalStrings=info['strings'],originalComments=info['comments'],modes=[],
        scope='Host token alpha-renaming ceiling only. Host transform time is not saved Bend emission time. '
              'Private mode preserves every QBE export; closed mode changes generated ELF segment exports '
              'and is valid only for the audited closed linked image, never a compatibility/promotion claim.')
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    for mode in ['private','closed']:
        start=time.monotonic();mapping,protected=make_map(info,mode,runtime_names)
        file=out/(mode+'.ssa');rewrite(source,file,mapping);rewrite_seconds=time.monotonic()-start
        inverse={v:k for k,v in mapping.items()};back=roundtrip(file,inverse)
        assert back==report['source']['sha256'],'Inverse must reproduce every original byte'
        transformed=scan(file)
        assert transformed['strings']==info['strings']and transformed['comments']==info['comments']
        assert {inverse.get(n,n)for n in transformed['defined']}==info['defined']
        assert {inverse.get(n,n)for n in transformed['exports']}==info['exports']
        assert set(transformed['uses'])-transformed['defined']==unresolved
        expected=Counter({mapping.get(n,n):count for n,count in info['uses'].items()})
        assert transformed['uses']==expected
        entries=[dict(original=n.decode(),compact=v.decode(),uses=info['uses'][n],
                      originallyExported=n in info['exports'])for n,v in mapping.items()]
        map_file=out/(mode+'-map.json');map_file.write_text(json.dumps(dict(mode=mode,bijection=True,entries=entries),indent=2)+'\n')
        row=dict(mode=mode,output=pin(file),mapping=pin(map_file),renamedDefinitions=len(mapping),
            renamedOccurrences=sum(info['uses'][n]for n in mapping),changedExportNames=sum(n in info['exports']for n in mapping),
            bytesRemoved=report['source']['bytes']-file.stat().st_size,
            reverseSha256=back,allStringsAndCommentsExact=True,undefinedSetExact=True,
            protectedNames=sorted(n.decode()for n in protected if n in info['uses']),
            rewriteSeconds=rewrite_seconds,totalHostSeconds=time.monotonic()-start)
        report['modes'].append(row);save()
    report.update(complete=True,totalHostSeconds=time.monotonic()-started,peakRssKiB=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss)
    save();print(json.dumps(dict(complete=True,modes=[{k:x[k]for k in ['mode','renamedDefinitions','changedExportNames','bytesRemoved']}for x in report['modes']])))

if __name__=='__main__':main()
