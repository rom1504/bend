#!/usr/bin/env python3
"""Read-only prepared-graph census; no compiler execution or performance claim."""
import argparse, collections, hashlib, json
from pathlib import Path

SPECS = [
    ('Nil', []), ('Con', [('head','head'),('tail','ref')]),
    ('KTerm',[('tag','s'),('name','s'),('id','u'),('quant','u'),('kids','ref'),('removed','ref'),('originBegin','u'),('originEnd','u')]),
    ('KLambda',[('name','s'),('id','u'),('quant','u'),('kids','ref'),('removed','ref'),('originBegin','u'),('originEnd','u'),('quantityPresent','b')]),
    ('KLiteral',[('kind','s'),('number','u'),('text','s'),('originBegin','u'),('originEnd','u')]),
    ('KDef',[('name','s'),('kind','s'),('arity','u'),('templates','u'),('typ','ref'),('value','ref'),('ctors','ref'),('native','b'),('unsafe','b')]),
    ('KIndexLeaf',[('hash','u'),('bucket','ref')]), ('KIndexNode',[('hash','u'),('mask','u'),('left','ref'),('right','ref')]),
    ('KBasePrefixState',[('bound','u'),('delta','u'),('stamp','u'),('patches','ref'),('ready','b')]),
    ('FFreshPrefixState',[('next','u'),('ready','b')]),
    ('KBasePreparedWorld',[('state','ref'),('prefix','ref'),('final','ref'),('book','ref'),('checked','ref'),('seen','ref'),('todos','u')]),
    ('FReadyPrefixState',[('names','ref'),('ctors','ref'),('count','u'),('ready','b')]),
]
def census(frame):
    raw=Path(frame).read_bytes(); hbytes,payload=raw.split(b'\n',1); h=json.loads(hbytes)
    assert h['format']=='bend-base-cache-frame-3'
    nb,np=h['segments']; assert nb+np==len(payload)
    b,p=payload[:nb],payload[nb:]
    assert hashlib.sha256(b).hexdigest()==h['bookGraphSha256']
    assert hashlib.sha256(p).hexdigest()==h['preparedGraphSha256']
    bg,pg=json.loads(b),json.loads(p)
    assert bg[0]==pg[0]==1 and bg[1]==0 and pg[1]==len(bg[3])
    rows=bg[3]+pg[3]; edges=[]; strings=collections.Counter(); counts=collections.Counter(); field_slots=0
    for i,row in enumerate(rows):
        tag,fields=SPECS[row[0]]; assert len(row)==len(fields)+1 or (tag=='KBasePreparedWorld' and len(row)==7)
        counts[tag]+=1; field_slots+=len(row)-1; es=[]
        for (name,kind),v in zip(fields,row[1:]):
            if kind=='s' or kind=='head' and isinstance(v,str): strings[v]+=1
            elif kind in ('ref','head'):
                assert type(v) is int and 0<=v<i
                es.append((v,tag+'.'+name))
        edges.append(es)
    def closure(roots,skip=()):
        seen=set(); pending=[r for r in roots if r is not None]
        while pending:
            i=pending.pop()
            if i in seen: continue
            seen.add(i); pending.extend(j for j,key in edges[i] if key not in skip)
        return seen
    roots={'book':bg[2][0],**dict(zip(['checked','fresh','world','frontend'],pg[2]))}
    all_reached=closure(list(roots.values()))
    skeleton=closure(list(roots.values()),{'KDef.value'})
    header_only=closure(list(roots.values()),{'KDef.value','KDef.typ'})
    definitions=[]; at=roots['book']; ordinal=0
    while rows[at][0]==1:
        d=rows[at][1]; row=rows[d]; assert row[0]==5
        definitions.append({'ordinal':ordinal,'name':row[1],'kind':row[2],'valueNodes':len(closure([row[6]])),'typeNodes':len(closure([row[5]]))})
        at=rows[at][2];ordinal+=1
    assert rows[at][0]==0
    utf16=lambda s:len(s.encode('utf-16-le',errors='surrogatepass'))
    table_bytes=sum(utf16(s) for s in strings)
    binary_model={'constructorBytes':len(rows),'recordOffsetBytes':4*(len(rows)+1),'fieldBytes':4*field_slots,
                  'stringOffsetBytes':4*(len(strings)+1),'stringUtf16Bytes':table_bytes}
    return {'schema':'phase64-base-record-census-1','frame':{'file':str(Path(frame).resolve()),'sha256':hashlib.sha256(raw).hexdigest(),'bytes':len(raw)},
            'roots':roots,'nodes':len(rows),'bookNodes':len(bg[3]),'optionalNodes':len(pg[3]),'constructorCounts':dict(counts),
            'rootClosures':{k:len(closure([v])) for k,v in roots.items()},'allReachableNodes':len(all_reached),
            'withoutDefinitionValues':{'nodes':len(skeleton),'fraction':len(skeleton)/len(rows)},
            'withoutDefinitionTypesOrValues':{'nodes':len(header_only),'fraction':len(header_only)/len(rows)},
            'strings':{'occurrences':sum(strings.values()),'unique':len(strings),'expandedUtf16Bytes':sum(utf16(s)*n for s,n in strings.items()),'uniqueUtf16Bytes':table_bytes},
            'binaryModel':{**binary_model,'totalBytes':sum(binary_model.values()),'excludes':'Metadata, roots, segment hashes/alignment. This is a storage model, not a tested codec.'},
            'definitions':len(definitions),'largestDefinitionBodies':sorted(definitions,key=lambda d:d['valueNodes'],reverse=True)[:15],
            'limits':['Graph closure is potential demand, not executed demand.','Omitting body/type edges models materialization boundaries, not permission to skip mandatory validation.','Current driver TODO scan demands complete Base terms; demand must be attributed by stage after its prepared-fact replacement.']}
if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('frame');ap.add_argument('output');args=ap.parse_args()
    result=census(args.frame);out=Path(args.output);out.parent.mkdir(parents=True,exist_ok=True)
    with out.open('x') as f: json.dump(result,f,indent=2);f.write('\n')
    print(json.dumps({k:result[k] for k in ('nodes','bookNodes','optionalNodes','withoutDefinitionValues','withoutDefinitionTypesOrValues','strings','binaryModel')}))
