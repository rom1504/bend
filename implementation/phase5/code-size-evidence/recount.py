#!/usr/bin/env python3
"""Read-only bounded source recount. No generated outputs or result archives."""
import collections, datetime, hashlib, json, pathlib, re, subprocess, sys, tempfile

ROOT=next(p for p in pathlib.Path(__file__).resolve().parents if (p/'selfhost/src/compiler.json').is_file())
BASE=sys.argv[1] if len(sys.argv)>1 else '7d69850'
OUT=pathlib.Path(sys.argv[2]).resolve() if len(sys.argv)>2 else pathlib.Path(__file__).with_name('report.json')
EXT={'.mjs','.js','.ts','.py','.sh','.bend','.c','.h'}

def git(args, data=None):
    with tempfile.TemporaryFile() as inp, tempfile.TemporaryFile() as out, tempfile.TemporaryFile() as err:
        if data is not None: inp.write(data);inp.seek(0)
        done=subprocess.run(['git','-C',str(ROOT),*args],stdin=inp,stdout=out,stderr=err)
        out.seek(0);err.seek(0)
        if done.returncode: raise RuntimeError(err.read().decode())
        return out.read()

def blobs(names):
    raw=git(['cat-file','--batch'], ''.join(BASE+':'+p+'\n' for p in names).encode())
    result={};offset=0
    for p in names:
        end=raw.index(b'\n',offset);header=raw[offset:end].decode().split();offset=end+1
        assert len(header)==3 and header[1]=='blob',(p,header)
        size=int(header[2]);result[p]=raw[offset:offset+size];offset+=size
        assert raw[offset:offset+1]==b'\n';offset+=1
    assert offset==len(raw)
    return result

baseline_names=git(['ls-tree','-r','--name-only',BASE,'selfhost/src','selfhost/tools']).decode().splitlines()
base_manifest=blobs(['selfhost/src/compiler.json'])['selfhost/src/compiler.json']
current_manifest=(ROOT/'selfhost/src/compiler.json').read_bytes()
base_modules={'selfhost/'+p for p in json.loads(base_manifest)['modules']}
current_modules={'selfhost/'+p for p in json.loads(current_manifest)['modules']}

def category(p, modules):
    if p in modules:return 'production_bend'
    if p.startswith('selfhost/src/runtime/') and pathlib.Path(p).suffix in EXT:
        return 'runtime_native' if '/native/' in p else 'runtime_js'
    if p.startswith('selfhost/src/') and pathlib.Path(p).suffix in EXT:return 'source_support_and_tests'
    if not p.startswith('selfhost/tools/') or pathlib.Path(p).suffix not in EXT:return None
    rest=p.removeprefix('selfhost/tools/')
    if '/' not in rest:return 'maintained_top_level'
    prefix=rest.split('/')[0]
    return {'conformance':'maintained_conformance','development':'maintained_development','private-compiler':'maintained_private','performance':'experimental_performance'}.get(prefix,'other_tools')

base_selected=[p for p in baseline_names if category(p,base_modules)]
baseline=blobs(base_selected)
current_selected=set(current_modules)
for folder in ['selfhost/tools','selfhost/src']:
    current_selected.update(str(p.relative_to(ROOT)) for p in (ROOT/folder).rglob('*') if p.is_file() and category(str(p.relative_to(ROOT)),current_modules))
current={p:(ROOT/p).read_bytes() for p in sorted(current_selected)}

def stats(data):
    text=data.decode();lines=text.splitlines()
    return {'bytes':len(data),'physical':len(lines),'nonblank':sum(bool(s.strip()) for s in lines),
      'defs':len(re.findall(r'^(?:@unsafe\s+)?def\s+',text,re.M)),
      'laws':len(re.findall(r'^law\s+',text,re.M)),
      'types':len(re.findall(r'^type\s+',text,re.M)),
      'sha256':hashlib.sha256(data).hexdigest()}

def snapshot(files,modules):
    rows=[{'file':p,'category':category(p,modules),**stats(data)} for p,data in sorted(files.items())]
    groups={}
    for row in rows:
        group=groups.setdefault(row['category'],dict(files=0,bytes=0,physical=0,nonblank=0,defs=0,laws=0,types=0));group['files']+=1
        for k in ['bytes','physical','nonblank','defs','laws','types']:group[k]+=row[k]
    return {'groups':groups,'files':rows,'largestProduction':sorted((r for r in rows if r['category']=='production_bend'),key=lambda r:(-r['physical'],r['file']))[:12]}

a,b=snapshot(baseline,base_modules),snapshot(current,current_modules)
changes=[]
for p in sorted(base_modules|current_modules):
    old=stats(baseline[p]) if p in baseline else None;new=stats(current[p]) if p in current else None
    if old!=new:changes.append({'file':p,'before':old,'after':new,'delta':{k:(new or {}).get(k,0)-(old or {}).get(k,0) for k in ['bytes','physical','nonblank','defs','laws','types']}})
for p,data in current.items():assert (ROOT/p).read_bytes()==data,'Changed during count: '+p
assert (ROOT/'selfhost/src/compiler.json').read_bytes()==current_manifest
report={'kind':'phase5-static-code-size','created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'baselineCommit':git(['rev-parse',BASE]).decode().strip(),
 'root':str(ROOT),'script':{'file':str(pathlib.Path(__file__).resolve()),'sha256':hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest()},
 'scope':'Small selected source trees only; generated compiler outputs, build trees, fixtures, documentation and result archives excluded. Host/tool counts provisional until final promotion.',
 'method':{'physical':'len(UTF8_text.splitlines()); a final newline does not create an extra empty line','nonblank':'physical lines with nonempty Python str.strip()','defs':'line-start def, optionally same-line @unsafe','laws':'line-start law','types':'line-start type','extensions':sorted(EXT),'productionMembership':'compiler.json modules at each revision','supportGroups':'top-level tools/conformance/development/private-compiler plus runtime JS/native and other code-extension files under src, individually reported; tests located in those directories included','experimentalMembership':'code-extension files below tools/performance, including prototype Bend drivers and test helpers','comparisonLimits':'File size and declarations only; no cyclomatic complexity, semantic complexity or runtime claim.'},
 'manifests':{'baselineSha256':hashlib.sha256(base_manifest).hexdigest(),'currentSha256':hashlib.sha256(current_manifest).hexdigest()},
 'baseline':a,'current':b,'productionChanges':changes,'currentUnchangedDuringCount':True}
OUT.parent.mkdir(parents=True,exist_ok=True);OUT.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'output':str(OUT),'baseline':a['groups'],'current':b['groups'],'productionChangedFiles':len(changes)},indent=2))
