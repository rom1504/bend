"""Compact per-function QBE variables/labels with reversible token mappings."""
import argparse,hashlib,importlib.util,json,re,resource,time
from pathlib import Path

HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('global_lex',HERE/'compact.py')
G=importlib.util.module_from_spec(spec);spec.loader.exec_module(G)
LOCAL=re.compile(rb'[%@]')

def local_tokens(line,start,end):
    pos=start
    while m:=LOCAL.search(line,pos,end):
        match=G.NAME.match(line,m.start()+1,end)
        if not match:raise ValueError('Unsupported local/label identifier')
        stop=match.end()
        if stop<end and line[stop]not in b' \t\r\n,(){}[]=+-*/:':raise ValueError('Unsupported local continuation')
        yield ('variable'if line[m.start()]==37 else'label'),m.start(),stop,match.group()
        pos=stop

def tokens(line):
    previous=0
    for token in G.tokens(line):
        yield from local_tokens(line,previous,token[1]);yield token;previous=token[2]
    yield from local_tokens(line,previous,len(line))

def changed(line,items,global_map,variables,labels):
    parts=[];previous=0
    for kind,start,end,value in items:
        mapping=global_map if kind=='global'else variables if kind=='variable'else labels if kind=='label'else{}
        if value in mapping:
            parts.extend([line[previous:start+1],mapping[value]]);previous=end
    return b''.join(parts)+line[previous:]if parts else line

def inverse_hash(path,global_map,local_map):
    digest=hashlib.sha256();global_inverse={v:k for k,v in global_map.items()};variables={};labels={};current=None;count=0
    with path.open('rb')as source,local_map.open()as maps:
        for line in source:
            items=list(tokens(line));header=G.HEADER.match(line)
            if header and header[2]==b'function':
                assert current is None
                symbol=next(x[3]for x in items if x[0]=='global');current=global_inverse.get(symbol,symbol)
                row=json.loads(next(maps));assert row['function'].encode()==current
                variables={v.encode():k.encode()for k,v in row['variables']};labels={v.encode():k.encode()for k,v in row['labels']};count+=1
            digest.update(changed(line,items,global_inverse,variables,labels))
            if current is not None and line.strip()==b'}':current=None;variables={};labels={}
        assert current is None and maps.read()==''
    return digest.hexdigest(),count

def selftest():
    line=b'%many =l add %many, %param # %many @label $global\n'
    output=changed(line,list(tokens(line)),{}, {b'many':b'v0',b'param':b'v1'}, {})
    assert output==b'%v0 =l add %v0, %v1 # %many @label $global\n'
    line=b'data $g = { b "%keep @keep $keep", l $external }\n'
    assert not any(k in ['variable','label']for k,*_ in tokens(line))
    line=b'jnz %p, @again, @done\n'
    assert changed(line,list(tokens(line)),{}, {b'p':b'v0'}, {b'again':b'b0',b'done':b'b1'})==b'jnz %v0, @b0, @b1\n'
    return dict(passed=True,checks=3,scope='Repeated non-SSA identifier, parameter, branch labels, string/comment exclusion.')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--globals',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase132')
    prior=json.loads(a.globals.read_text());assert prior['complete']
    source=Path(prior['source']['file']);assert G.pin(source)==prior['source'];tests=selftest()
    modes={};inputs=[G.pin(__file__),G.pin(HERE/'compact.py'),G.pin(a.globals),prior['source']]
    for row in prior['modes']:
        assert G.pin(row['mapping']['file'])==row['mapping'];inputs.append(row['mapping'])
        entries=json.loads(Path(row['mapping']['file']).read_text())['entries']
        modes[row['mode']]={x['original'].encode():x['compact'].encode()for x in entries}
    out.mkdir();map_path=out/'locals.jsonl';started=time.monotonic();current=None;variables={};labels={};functions=0
    counts=dict(variableOccurrences=0,labelOccurrences=0,variableBytesRemoved=0,labelBytesRemoved=0,variableDefinitions=0,labelDefinitions=0)
    paths={mode:out/(mode+'-local.ssa')for mode in modes};outputs={mode:path.open('xb')for mode,path in paths.items()}
    try:
        with source.open('rb')as stream,map_path.open('x')as maps:
            for line in stream:
                items=list(tokens(line));header=G.HEADER.match(line)
                if header and header[2]==b'function':
                    assert current is None;current=next(x[3]for x in items if x[0]=='global');variables={};labels={};functions+=1
                for kind,start,end,value in items:
                    if kind not in ['variable','label']:continue
                    assert current is not None,'Local name outside function'
                    table=variables if kind=='variable'else labels
                    if value not in table:table[value]=(b'v'if kind=='variable'else b'b')+G.base36(len(table));counts[kind+'Definitions']+=1
                    counts[kind+'Occurrences']+=1;counts[kind+'BytesRemoved']+=len(value)-len(table[value])
                for mode,mapping in modes.items():outputs[mode].write(changed(line,items,mapping,variables,labels))
                if current is not None and line.strip()==b'}':
                    maps.write(json.dumps(dict(function=current.decode(),variables=[[k.decode(),v.decode()]for k,v in variables.items()],labels=[[k.decode(),v.decode()]for k,v in labels.items()]),separators=(',',':'))+'\n')
                    current=None;variables={};labels={}
        assert current is None
    finally:
        for stream in outputs.values():stream.close()
    rewrite_seconds=time.monotonic()-started;rows=[]
    for mode,path in paths.items():
        back,n=inverse_hash(path,modes[mode],map_path);assert back==prior['source']['sha256']and n==functions
        info=G.scan(path);assert info['strings']==prior['originalStrings']and info['comments']==prior['originalComments']
        original=next(x for x in prior['modes']if x['mode']==mode)
        rows.append(dict(mode=mode+'-local',output=G.pin(path),globalMap=original['mapping'],localMap=G.pin(map_path),
            changedExportNames=original['changedExportNames'],reverseSha256=back,
            totalBytesRemoved=prior['source']['bytes']-path.stat().st_size,
            localBytesRemoved=counts['variableBytesRemoved']+counts['labelBytesRemoved'],allStringsAndCommentsExact=True))
    result=dict(complete=True,targetsRun=False,productionChange=False,source=prior['source'],inputs=inputs,selftest=tests,
        functions=functions,counts=counts,localMap=G.pin(map_path),modes=rows,rewriteSeconds=rewrite_seconds,
        totalHostSeconds=time.monotonic()-started,peakRssKiB=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
        scope='Per-function positional variable and block-label alpha-renaming, repeated non-SSA names kept consistent. '
              'Exact inverse-byte proof covers parameters, definitions, uses, data relocations, globals, strings and comments. '
              'Private-local retains all export names; closed-local changes generated segment exports. Host rewrite cost is not Bend emitter speed.')
    (out/'report.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,modes=[{k:x[k]for k in ['mode','totalBytesRemoved','localBytesRemoved']}for x in rows])))

if __name__=='__main__':main()
