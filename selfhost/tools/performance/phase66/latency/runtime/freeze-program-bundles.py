#!/usr/bin/env python3
"""Copy the exact old/current modules and HEAD TS modules into explicit mixed-target bundles."""
import argparse, hashlib, json, shutil, sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[6]
RAW=ROOT/'selfhost/build/phase66'
inputs={}
def pin(value):
    p=Path(value.get('file',value.get('path')) if isinstance(value,dict) else value).resolve(strict=True)
    data=p.read_bytes();item=dict(file=str(p),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
    if isinstance(value,dict):
        assert item['sha256']==value['sha256']
        if 'bytes' in value:assert item['bytes']==value['bytes']
    inputs[str(p)]=item;return item
def read(x):return json.loads(Path(pin(x)['file']).read_text())
def asset(root,x):return pin(dict(file=str(root/x['path']),sha256=x['sha256'],bytes=x['bytes']))
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
catalog_file=ROOT/'selfhost/tools/performance/phase37/catalog.json';catalog=read(catalog_file)
compile_catalog=read(ROOT/'selfhost/tools/performance/phase60/catalog.json')
old_file=ROOT/'selfhost/build/phase65/final-state10/checked/program45/manifest.json';old=read(old_file)
old_smoke=read(ROOT/'selfhost/build/phase65/final-state10/checked/program45-smoke/report.json')
old_equal=read(ROOT/'selfhost/build/phase65/final-state10/b2-program-equality02/report.json')
head_file=RAW/'head-ts-acquisition/manifest.json';head=read(head_file)
head_qualification=read(RAW/'head-ts-oracles01.json')
assert old['complete'] and old_smoke['complete'] and old_smoke['passed'] and old_equal['complete'] and old_equal['pass']
assert old_equal['reference']['sha256']==pin(old_file)['sha256']
assert old['roles']['candidate']['compiler']['api']['sha256']=='3a7fedb77003aecc797cd9a9ac4c6d1bd15bd21dd1230806b6719565eca10f72'
assert old_equal['image']['api']['sha256']=='239f79702c13339d1044e7fe497c4946299d36ce2d7b5eb7850d0d43514a8fae'
assert head_qualification['complete'] and head_qualification['pass'] and head_qualification['acquisition']['sha256']==pin(head_file)['sha256']
assert head_qualification['originalRuntimeCatalog']['sha256']==pin(catalog_file)['sha256']
ts_old=compile_catalog['typescript']['compiler'];ts_head=head['roles']['typescript']['compiler']
old_rows={c['id']:c for c in old['cases']};head_rows={c['id']:c for c in head['cases']}
points={c['id']:c for c in compile_catalog['points']}
assert set(old_rows)==set(head_rows)==set(points)==set(catalog['sets']['full'])
out.mkdir(parents=True)
copies=[]
def copy_module(item,destination):
    before=pin(item);destination.parent.mkdir(parents=True,exist_ok=True)
    if destination.exists():assert pin(destination)['sha256']==before['sha256']
    else:shutil.copyfile(before['file'],destination)
    after=pin(destination);assert before['sha256']==after['sha256']
    copies.append(dict(before=before,after=after))
    return dict(path=str(destination.relative_to(out)),sha256=after['sha256'],bytes=after['bytes'])
old_cases=[];head_cases=[];final_baseline=[]
for c in catalog['cases']:
    key=c['id'];o=old_rows[key];h=head_rows[key]
    assert o['point']==h['point']==c['point'] and o['sourceSha256']==h['sourceSha256']==c['source']['sha256']
    bend=copy_module(asset(old_file.parent,o['modules']['candidate']),out/'modules/old-bend'/Path(o['modules']['candidate']['path']).name)
    old_ts=copy_module(points[key]['modules']['typescript'],out/'modules/old-ts'/Path(points[key]['modules']['typescript']['file']).name)
    new_ts=copy_module(asset(head_file.parent,h['modules']['typescript']),out/'modules/head-ts'/Path(h['modules']['typescript']['path']).name)
    row=dict(id=key,sourceSha256=c['source']['sha256'],point=c['point'])
    old_cases.append(dict(**row,modules=dict(baseline=bend,typescript=old_ts)))
    head_cases.append(dict(**row,modules=dict(candidate=new_ts)))
    final_baseline.append(dict(**row,modules=dict(baseline=bend,typescript=new_ts)))
def bundle(name,roles,cases):
    value=dict(kind='phase66-mixed-target-program-bundle',schemaVersion=1,complete=True,
        sourceCorpusUpstreamCommit=catalog['upstreamCommit'],catalogSha256=pin(catalog_file)['sha256'],
        compilerTargets={k:v['compiler']['upstreamCommit'] for k,v in roles.items()},roles=roles,cases=cases,
        provenance=dict(oldB1=pin(old_file),oldB2Equality=pin(ROOT/'selfhost/build/phase65/final-state10/b2-program-equality02/report.json'),
                        headAdmission=pin(RAW/'head-ts-oracles01.json')),
        scope='Exact copied full modules; execution roles are labels, actual compiler kind/revision/Base remain explicit. '
              'Original45point source/argument/result corpus is unchanged across compiler targets.')
    (out/name).write_text(json.dumps(value,indent=2)+'\n');return pin(out/name)
bend_role={**old['roles']['candidate'],'label':'Phase65 State10 checked B1 output; actual B2 full-module equality qualified'}
old_ts_role=dict(label='Old pinned TypeScript generated programs',compiler=ts_old)
head_ts_role={**head['roles']['typescript'],'label':'HEAD pinned TypeScript generated programs'}
old_bundle=bundle('old-baseline.json',dict(baseline=bend_role,typescript=old_ts_role),old_cases)
head_bundle=bundle('head-ts-candidate.json',dict(candidate=head_ts_role),head_cases)
new_baseline=bundle('selected-baseline.json',dict(baseline=bend_role,typescript=head_ts_role),final_baseline)
result=dict(kind='phase66-program-module-snapshot',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=pin(__file__),inputs=list(inputs.values()),copies=copies,
    oldBaseline=old_bundle,headCandidate=head_bundle,selectedBaseline=new_baseline,
    counts=dict(points=45,sources=23),scope='No target execution or new speed claim; preserve old/current and HEAD TS generated modules for same-run comparisons.')
(out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(report=pin(out/'report.json'))))
