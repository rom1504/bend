#!/usr/bin/env python3
"""Data-only diagnostic module bundle; no checked-candidate or target claim."""
import argparse, hashlib, json, shlex, shutil, sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];PROGRAMS=HERE.parents[1]/'programs'
sys.path.insert(0,str(PROGRAMS))
from run import load_bundle
from support import identity, save
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=a.out.resolve();raw=ROOT/'selfhost/build/phase58'
assert out.is_relative_to(raw) and not out.exists()
catalog_file=HERE.parents[1]/'phase37/catalog.json';catalog=json.loads(catalog_file.read_text());ch=identity(catalog_file)['sha256']
assert ch=='33e353f51d1c90d27ff05dd2051dfccbefb23e29cfd73d7839b4cb1d42690b1c'
ids=['test-map-set-ops','editdist','test-morning-program'];selected=[next(c for c in catalog['cases'] if c['id']==n) for n in ids]
parent_file=raw/'final-shared01/checked/program45/manifest.json';baseline_file=raw/'program-performance-shared01/baseline/manifest.json'
inputs=[identity(f) for f in [__file__,catalog_file,PROGRAMS/'run.py',PROGRAMS/'support.py',PROGRAMS/'execute.mjs']]
parent=load_bundle(parent_file,catalog,ch,selected,['candidate'],inputs)
baseline=load_bundle(baseline_file,catalog,ch,selected,['baseline','typescript'],inputs)
assert parent['roles']['candidate']['compiler']['kind']=='checked-development-attempt'
assert baseline['roles']['baseline']['compiler']['sourceSha256']=='5356ec9963db7b300e8cbdf5474328b72150f582df96b01aeea29d6a07868244'
rows=[];derivations=[];out.mkdir();(out/'modules').mkdir()
for case in selected:
    source=identity(catalog_file.parent/case['source']['path']);assert source['sha256']==case['source']['sha256'];inputs.append(source)
    original=parent['points'][case['id']]['candidate'];original_file=parent_file.parent/original['path']
    sidecar_file=Path(str(original_file)+'.json');sidecar=json.loads(sidecar_file.read_text());inputs.append(identity(sidecar_file))
    assert sidecar['complete'] and sidecar['observation']['checked'] and sidecar['observation']['typeAccepted']
    assert sidecar['compiler']==parent['roles']['candidate']['compiler'] and sidecar['output']['sha256']==original['sha256']
    directory=raw/'fields-last-programs01'/case['id'];receipt_file=directory/'derivation.json';d=json.loads(receipt_file.read_text())
    inputs.append(identity(receipt_file));assert d['kind']=='phase58-data-only-last-constructor-key-diagnostic' and d['complete'] and d['pass']
    assert d['diagnosticOnly'] and not d['productionQualified'] and not d['changesRuntime'] and d['exactInverse'] and d['normalizedAstEquality']
    assert d['parent']['sha256']==original['sha256'] and Path(d['parent']['file']).resolve()==original_file.resolve()
    assert d['runtime']['sha256']==parent['roles']['candidate']['compiler']['directRuntime']['sha256']
    for key in ['parent','output','runtime','producer']:
        actual=identity(d[key]['file']);assert actual['sha256']==d[key]['sha256'] and actual['bytes']==d[key]['bytes'];inputs.append(actual)
    assert Path(d['output']['file']).resolve()==(directory/'api.mjs').resolve() and d['editCount']>0
    copied=out/'modules'/(case['id']+'.mjs');shutil.copyfile(d['output']['file'],copied);entry=identity(copied);inputs.append(entry)
    assert entry['sha256']==d['output']['sha256'];derivations.append(dict(id=case['id'],receipt=identity(receipt_file),parent=d['parent'],output=entry,edits=d['editCount']))
    rows.append(dict(id=case['id'],sourceSha256=case['source']['sha256'],point=case['point'],modules={'candidate':dict(path=str(copied.relative_to(out)),sha256=entry['sha256'],bytes=entry['bytes'])}))
role=dict(label='Saved shared01 JavaScript diagnostic: last constructor key computed',
    compiler=dict(kind='diagnostic-saved-javascript',backend='direct',callingContract='upstream-compatible-direct-v1',
        upstreamCommit=catalog['upstreamCommit'],productionQualified=False,policy='Only last ordinary quoted key of tagged constructor objects; no width or constructor-name exceptions'),
    checkedParent=dict(manifest=identity(parent_file),compiler=parent['roles']['candidate']['compiler']))
save(out/'manifest.json',dict(kind='bend-program-bundle',schemaVersion=1,complete=True,upstreamCommit=catalog['upstreamCommit'],
    catalogSha256=ch,comparisonContract='upstream-compatible-direct-v1',roles={'candidate':role},cases=rows))
load_bundle(out/'manifest.json',catalog,ch,selected,['candidate'],inputs)
command=['python3','-B',str(PROGRAMS/'run.py'),'--catalog',str(catalog_file),'--baseline',str(baseline_file),
    '--candidate',str(out/'manifest.json'),'--node','/home/ai/.nvm/versions/node/v24.18.0/bin/node','--cpu','3',
    '--rss-mib','2048','--available-mib','4096','--budget','600','--cases',','.join(ids),'--out',str(out/'timing')]
save(out/'command.json',dict(executed=False,argv=command,expected=dict(points=3,rounds=5,samples=45),
    guard='Unchanged run.py owns one guard; unpinned root parent, no outer guard.'))
(out/'README.md').write_text('# Last-key diagnostic screen\n\nBaseline is actual Phase56 String01; candidate is diagnostic saved shared01 JavaScript, not a checked compiler. Same pinned TypeScript modules. No width/name exceptions. All three original catalog oracles remain mandatory.\n\nUnchanged 600 preset: five rounds, three roles, three points = 45 fresh samples if complete. Report each median and all drift flags; no whole-corpus claim. The 600-second cap is a preset ceiling, not expected elapsed time.\n\n```sh\n'+shlex.join(command)+'\n```\n')
for row in inputs:assert identity(row['path'])==row
save(out/'report.json',dict(kind='phase58-last-key-program-screen-preparation',complete=True,dataOnly=True,targetExecuted=False,
    productionQualified=False,baseline=identity(baseline_file),checkedParent=identity(parent_file),candidate=identity(out/'manifest.json'),
    derivations=derivations,ids=ids,expectedSamples=45,inputs=inputs,inputsUnchanged=True,command=identity(out/'command.json'),
    scope='Exact diagnostic module copies and saved checked-parent lineage only; no actual compiler implementation, new checked candidate or performance result.'))
print(json.dumps(dict(complete=True,report=identity(out/'report.json'),command=command)))
