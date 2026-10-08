#!/usr/bin/env python3
"""Data-only census of an already qualified frame4; not an admission validator."""
import argparse
import hashlib
import json
import struct
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
TAGS = ['Nil','Con','KTerm','KLambda','KLiteral','KDef','KIndexLeaf','KIndexNode',
        'KBasePrefixState','FFreshPrefixState','KBasePreparedWorld','FReadyPrefixState']
REFS = {0:[],2:[4,5],3:[3,4],4:[],5:[4,5,6],6:[1],7:[2,3],8:[3],9:[],10:list(range(6)),11:[0,1]}
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('frame',type=Path);parser.add_argument('output',type=Path)
a=parser.parse_args();frame=a.frame.resolve(strict=True);out=a.output.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase65') and not out.exists()
data=frame.read_bytes();cut=data.index(b'\n');header=json.loads(data[:cut])
assert header['format']=='bend-base-cache-frame-4' and len(header['segments'])==2
assert sum(header['segments'])==len(data)-cut-1
sha=lambda b:hashlib.sha256(b).hexdigest()
records=[];segments=[];root_ids=[];total_strings=0;cursor=cut+1
for segment_id,size in enumerate(header['segments']):
    chunk=data[cursor:cursor+size];cursor+=size
    assert sha(chunk)==header[['bookGraphSha256','preparedGraphSha256'][segment_id]]
    magic,bn,n,bs,ns,nf,units,nr=struct.unpack_from('<8I',chunk)
    assert magic==0x31494142 and bn==len(records) and bs==total_strings
    tags_at=32+nr*4;offsets_at=tags_at+((n+3)&~3);fields_at=offsets_at+4*(n+1)
    strings_at=fields_at+4*nf;text_at=strings_at+4*(ns+1)
    assert ((text_at+units*2+3)&~3)==len(chunk)
    roots=list(struct.unpack_from('<'+str(nr)+'I',chunk,32))
    offsets=struct.unpack_from('<'+str(n+1)+'I',chunk,offsets_at)
    fields=struct.unpack_from('<'+str(nf)+'I',chunk,fields_at)
    assert offsets[0]==0 and offsets[-1]==nf
    counts=Counter()
    for i in range(n):
        tag=chunk[tags_at+i];assert tag<len(TAGS)
        assert offsets[i]<=offsets[i+1]<=nf
        row=list(fields[offsets[i]:offsets[i+1]])
        refs=([row[1]]+([] if row[0]&0x80000000 else [row[0]])) if tag==1 else [row[j] for j in REFS[tag]]
        assert all(ref<bn+i for ref in refs)
        records.append((tag,row,refs));counts[TAGS[tag]]+=1
    segments.append(dict(bytes=size,records=n,baseRecords=bn,fields=nf,newStrings=ns,
        priorStrings=bs,utf16Bytes=units*2,rootIds=roots,constructors=dict(counts)))
    root_ids.extend(roots);total_strings+=ns
assert len(root_ids)==5

def closure(roots,skip_values=False):
    pending=list(roots);seen=set()
    while pending:
        i=pending.pop()
        if i==0xffffffff or i in seen:continue
        seen.add(i);tag,row,refs=records[i]
        pending.extend([row[j] for j in [4,6]] if skip_values and tag==5 else refs)
    return seen

def summary(ids):
    return dict(records=len(ids),constructors=dict(Counter(TAGS[records[i][0]] for i in ids)))

names=['rawBook','checkedState','freshState','preparedWorld','frontendState']
roots={name:dict(id=i,**summary(closure([i]))) for name,i in zip(names,root_ids)}
world_id=root_ids[3];world={}
if world_id!=0xffffffff:
    tag,row,_=records[world_id];assert tag==10
    for i,name in enumerate(['state','prefix','final','book','checked','seen']):world[name]=dict(id=row[i],**summary(closure([row[i]])))
    for i,name in [(6,'todos'),(7,'checkedBound')]:
        if len(row)>i:world[name]=row[i]
all_ids=closure(root_ids)
report=dict(kind='phase65-frame4-data-census',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=dict(file=str(Path(__file__).resolve()),sha256=sha(Path(__file__).read_bytes())),
    input=dict(file=str(frame),sha256=sha(data)),identity={k:header[k] for k in ['compilerSha256','baseSha256','sourcePath','termAbi','spanAbi','preparedWorldVersion']},
    totalBytes=len(data),headerBytes=cut+1,segments=segments,totalRecords=len(records),roots=roots,world=world,
    allRoots=summary(all_ids),withoutDefinitionValues=summary(closure(root_ids,True)),
    limits=['Geometry census of previously admitted input; production decoder remains authoritative.',
            'Reference closure is static representation sharing, not measured compiler demand.',
            'No compilation or latency measured; additional products require their own actual data and marginal decode clock.'])
assert sha(frame.read_bytes())==report['input']['sha256']
out.parent.mkdir(parents=True,exist_ok=True)
with out.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(dict(output=str(out),bytes=len(data),records=len(records))))
