#!/usr/bin/env python3
"""Transfer only byte-identical retained Bun programs; otherwise request replay.
CPU0 data-only. This never executes a compiler, generated program, or judge.
"""
import collections, hashlib, json, re, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
PIN='059266225b77c8ca256ac6b25ee5c21449bab151'
ATTEMPT_SHA='2d7c525444a8ea87c18fd3d321894052639b1683186613831296b912f3d2fbaa'
API_SHA='bb6c6e2ad6f18bf54d2b5c7e4e7a8d0fe3f0f80658a260ad52256fa4351d81a6'
verified={}
def identity(file):
    p=Path(file).resolve(); h=hashlib.sha256()
    with p.open('rb') as f:
        for data in iter(lambda:f.read(1048576),b''): h.update(data)
    return dict(file=str(p),sha256=h.hexdigest(),bytes=p.stat().st_size)
def pin(row):
    p=str(Path(row['file']).resolve())
    if p not in verified: verified[p]=identity(p)
    got=verified[p]
    assert got['sha256']==row['sha256'],p
    if 'bytes' in row: assert got['bytes']==row['bytes'],p
    return got
def load(file):
    i=identity(file); pin(i); return json.loads(Path(i['file']).read_text()),i
def full_report(file):
    d,i=load(file)
    assert d['finished'] and len(d['results'])==1170 and len(d['selection']['requested'])==1170
    assert d['inventory']['revision']==PIN and d['changedInputs']==[]
    assert d['identity']['changedArtifacts']==[] and not d['identity']['adapterChangedDuringRun']
    for p,h in d['inputHashes'].items(): pin(dict(file=p,sha256=h))
    for x in d['identity']['artifacts'].values(): pin(x)
    pin(dict(file=d['options']['adapter'],sha256=d['identity']['adapterSha256']))
    rows={x['id']:x for x in d['results']}; assert len(rows)==1170
    assert all(x['lane']=='js' for x in d['results'])
    assert set(rows)=={x['id'] for x in d['selection']['requested']}
    return d,i,rows
assert len(sys.argv)==2,'Usage: bun-reuse-final07-v1.py FRESH_OUT_JSON'
out=Path(sys.argv[1]); assert not out.exists()
prior,audit_i=load(ROOT/'implementation/phase66/evidence/bun-replay01.json')
assert prior['complete'] and prior['auditPass'] and not prior['replayPass']
pin(prior['producer']); pin(prior['raw']); pin(prior['recipe']); pin(prior['supervisor'])
old,_=load(prior['raw']['file']); assert old['complete'] and old['inputsUnchanged']
for row in old['inputs']: pin(row)
recipe,recipe_i=load(ROOT/'selfhost/build/phase66/conformance-final07-direct-js01/recipe.json')
assert recipe['scope']=='full-js' and recipe['jsBackend']=='direct'
assert recipe['roles']==['bend-candidate-new-base'] and len(recipe['images'])==1
pin(recipe['producer']); pin(recipe['node'])
image=recipe['images'][0]; pin(image['attempt']); assert image['attempt']['sha256']==ATTEMPT_SHA
attempt,attempt_i=load(image['attempt']['file']); assert attempt['checked'] and attempt['artifactKind']=='derived-b1'
for k in ['api','checkedApi','bootstrapReport','derivationReport']: pin(attempt[k])
for entry in attempt['snapshot']['sources']: pin(entry['frozen'])
bootstrap,_=load(attempt['bootstrapReport']['file']); assert bootstrap['revision']==PIN
assert bootstrap['apiSha256']==attempt['checkedApi']['sha256']
derivation,_=load(attempt['derivationReport']['file']); assert derivation['complete']
assert derivation['original']['api']['sha256']==attempt['checkedApi']['sha256']
assert derivation['output']['sha256']==attempt['api']['sha256']==API_SHA
for x in derivation['original']['inputs']: pin(x)
pin(derivation['original']['source'])
pin(image['compilerImage']); pin(image['defaultCompilerImage']); assert image['compilerImage']['sha256']==API_SHA
new,new_i,newrows=full_report(recipe['commands'][0]['report'])
assert new['identity']['artifacts']['compiler']['sha256']==API_SHA
assert Path(new['identity']['artifacts']['compiler']['file']).resolve()==Path(image['compilerImage']['file']).resolve()
old_bend,_,_=full_report(old['nodeReports']['bend']['identity']['file'])
ts,ts_i,tsrows=full_report(old['nodeReports']['typescript']['identity']['file'])
assert ts_i==old['nodeReports']['typescript']['identity']
new_project=Path(new['options']['adapter']).resolve().parents[3]
old_project=Path(old_bend['options']['adapter']).resolve().parents[3]
# Runtime/provider input closure is bound to the frozen selected snapshot and
# compared as a complete inventory, in addition to exact emitted module bytes.
def closure(project):
    files=sorted((project/'src/runtime/js').rglob('*'))+[project/'src/runtime.mjs']
    return {str(p.relative_to(project)):identity(p) for p in files if p.is_file()}
a,b=closure(old_project),closure(new_project)
old_recipe,old_recipe_i=load(ROOT/'selfhost/build/phase66/conformance-final04-direct-js01/recipe.json')
old_image=next(x for x in old_recipe['images'] if x['role']=='bend-candidate-new-base')
old_copy_rows={str(Path(x['copy']['file']).resolve()):x for x in old_image['copies']}
for item in a.values():
    pair=old_copy_rows[item['file']]; pin(pair['source']); pin(pair['copy'])
    assert pair['source']['sha256']==pair['copy']['sha256']==item['sha256']
copy_rows={str(Path(x['copy']['file']).resolve()):x for x in image['copies']}
for item in b.values():
    pair=copy_rows[item['file']]; pin(pair['source']); pin(pair['copy'])
    assert pair['source']['sha256']==pair['copy']['sha256']==item['sha256']
closure_changes=[k for k in sorted(set(a)|set(b)) if k not in a or k not in b or a[k]['sha256']!=b[k]['sha256']]
for key in ['judge','inventory','manifest']:
    prior_item=old['judge'][key]; pin(prior_item)
    rel={'judge':'tools/conformance/judge.mjs','inventory':'tools/conformance/inventory.mjs','manifest':'src/compiler.json'}[key]
    got=identity(new_project/rel); assert got['sha256']==prior_item['sha256']; pin(got)
missing=re.compile(r'''(?:Cannot find (?:module|package)|No such built-in module)[^\n]*['"]?bun:ffi''')
new_ids={x['id'] for x in new['results'] if x['result'].get('phase')=='runtime' and x['result'].get('checked') is True and missing.search(str(x['result'].get('output',x['result'].get('diagnostic',''))))}
old_cases={x['id']:x for x in old['cases']}; ids=sorted(set(old_cases)|new_ids)
bookkeeping={'request.json','response.json','program.output','runtime-output.log','worker.stdout','worker.stderr'}
def retained(row,role,id):
    directory=Path(row['artifacts']); request,request_i=load(directory/'request.json')
    response,response_i=load(directory/'response.json'); assert response==row['result']
    assert request['test']['id']==id and request['lane']=='js'
    campaign=new if role=='bend' else ts
    project=Path(campaign['options']['adapter']).resolve().parents[3]
    assert Path(request['project']).resolve()==project
    fixture=next(t for t in campaign['inventory']['tests'] if t['id']==id)
    for key in ['sha256','expected','negative']: assert request['test'][key]==fixture[key]
    if role=='bend' and row['result'].get('phase')=='runtime':
        assert row['result']['hostProvenance']['driverSha256']==campaign['identity']['artifacts']['driver']['sha256']
        assert row['result']['hostProvenance']['adapterSha256']==campaign['identity']['adapterSha256']
    pin(dict(file=request['test']['file'],sha256=request['test']['sha256']))
    files={str(p.relative_to(directory)):identity(p) for p in sorted(directory.rglob('*')) if p.is_file()}
    for v in files.values(): pin(v)
    name=Path(id).stem+('.mjs' if role=='bend' else '.cjs')
    return dict(module=files.get(name),payload={k:v for k,v in files.items() if k not in bookkeeping},
        request=request_i,response=response_i,test=request['test'],checkedRuntime=row['result'].get('phase')=='runtime' and row['result'].get('checked') is True)
rows=[]; replay=[]
for id in ids:
    before=old_cases.get(id); details={}; reasons=[]
    for role,source in [('typescript',tsrows),('bend',newrows)]:
        current=retained(source[id],role,id); details[role]=current
        if before:
            old_role=before['roles'][role]
            assert current['test']['sha256']==old_role['source']['sha256'] and current['test']['expected']==old_role['expected']
            previous_payload={x['relative']:x for x in old_role['artifactFiles'] if x['relative'] not in bookkeeping}
            equal=current['module'] is not None and old_role['module'] is not None and current['module']['sha256']==old_role['module']['sha256']
            equal=equal and {k:v['sha256'] for k,v in current['payload'].items()}=={k:v['sha256'] for k,v in previous_payload.items()}
            current['equalPriorEmittedClosure']=equal
            if not equal: reasons.append(role+' emitted closure differs or missing')
        else: reasons.append('new selected row without prior Bun execution')
        if not current['checkedRuntime']: reasons.append(role+' lacks checked runtime provenance')
    if closure_changes: reasons.append('provider/runtime input closure differs')
    if before and before['status']=='deferred-environment':
        status='deferred-environment'; reused=False
    elif not reasons and before and before['status'] in ['pass','fail']:
        status=before['status']; reused=True
    else:
        status='focused-replay-required'; reused=False; replay.append(dict(id=id,roles=['typescript','bend'],reasons=sorted(set(reasons))))
    rows.append(dict(id=id,status=status,reused=reused,roles=details,reasons=sorted(set(reasons)),
        priorStatus=before['status'] if before else None))
for row in list(verified.values()):
    assert identity(row['file'])==row,'Input changed during data-only audit'
summary=dict(collections.Counter(x['status'] for x in rows))
result=dict(kind='phase66-final07-bun-byte-reuse-audit',complete=True,producer=identity(__file__),
    priorAudit=audit_i,priorReplay=prior['raw'],priorRecipe=old_recipe_i,recipe=recipe_i,attempt=attempt_i,
    compiler=attempt['api'],bootstrap=attempt['bootstrapReport'],derivation=attempt['derivationReport'],
    candidateNodeReport=new_i,typescriptNodeReport=ts_i,runtime=old['runtime'],judge=old['judge'],
    runtimeClosure=dict(before=a,after=b,changed=closure_changes),cases=rows,summary=summary,
    allPriorExecutedPairsReusable=not replay,focusedReplayRequests=replay,
    inputsUnchanged=True,identitiesRehashed=len(verified),inputs=list(verified.values()),
    scope='Only exact emitted module/payload plus runtime/provider closure equality transfers finite prior Bun observations. Shared golden failure and graphics deferral remain. Changed or missing modules require replay; no targets executed here.')
out.parent.mkdir(parents=True,exist_ok=True)
with out.open('x') as f: json.dump(result,f,indent=2); f.write('\n')
print(json.dumps(dict(output=identity(out),summary=summary,replayCases=len(replay))))
