"""Classify exact changed instruction text; never infer semantic pointer equality."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
from collections import Counter

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('objects',HERE/'objects.py');M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
ROOT=M.ROOT;BASE=ROOT/'selfhost/build/phase132'
census=M.read(BASE/'object-change-census01/report.json')
plans=[M.read(BASE/(n+'/plan.json'))for n in ['object-baseline01','object-changed01']]
names={x['name']for x in census['declarations']['changes']if x['before']['kind']=='function'}


def bodies(source):
    result={};name=None;lines=[]
    with M.verify(source).open('rb')as stream:
        for line in stream:
            header=M.L.HEADER.match(line)
            if header and header[2]==b'function':
                name=M.L.NAME.match(line,line.index(b'$')+1).group().decode();lines=[]
            if name in names:lines.append(line)
            if name and line.strip()==b'}':
                if name in names:result[name]=lines
                name=None
    M.require(set(result)==names,'Changed body inventory differs');return result


left,right=[bodies(p['source'])for p in plans]
copy=re.compile(rb'^(.*=l copy )([0-9]+)(\r?\n)$');deltas=Counter();tags=Counter();rows=[];unclassified=[]
for name in sorted(names):
    a,b=left[name],right[name];changes=[];only=True
    if len(a)!=len(b):only=False
    for old,new in zip(a,b):
        if old==new:continue
        x,y=copy.fullmatch(old),copy.fullmatch(new)
        if not(x and y and x[1]==y[1]and x[3]==y[3]):
            only=False;unclassified.append(dict(name=name,before=old.decode(),after=new.decode()));continue
        ov,nv=int(x[2]),int(y[2]);deltas[nv-ov]+=1;tags[((ov>>56)&127,(ov>>40)&65535,(nv>>56)&127,(nv>>40)&65535)]+=1
        changes.append(dict(before=ov,after=nv,delta=nv-ov))
    rows.append(dict(name=name,onlyDecimalCopyOperandsChanged=only,changedCopyOperands=changes))
out=M.fresh(BASE/'object-literal-churn01')
result=dict(complete=True,targetsRun=False,inputs=[M.pin(__file__),M.pin(BASE/'object-change-census01/report.json'),*[p['source']for p in plans]],functions=len(rows),copyOnlyFunctions=sum(r['onlyDecimalCopyOperandsChanged']for r in rows),numericCopyChanges=sum(deltas.values()),deltas={str(k):v for k,v in deltas.items()},bitPatternGroups=[dict(beforeTag=k[0],beforeAux=k[1],afterTag=k[2],afterAux=k[3],count=v)for k,v in tags.items()],unclassified=unclassified,rows=rows,scope='Text/bit-pattern classification only. Tag-like bits and +12 deltas do not prove valid pool references or equal decoded values. No semantic literal normalization or IR rewrite is performed.')
M.save(out/'report.json',result)
print(json.dumps({k:result[k]for k in ['complete','functions','copyOnlyFunctions','numericCopyChanges','deltas','bitPatternGroups']}))
