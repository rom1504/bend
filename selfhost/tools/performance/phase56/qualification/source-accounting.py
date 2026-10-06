#!/usr/bin/env python3
"""Data-only frozen Phase55/56 source census using the unchanged Phase47 rules."""
import importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
METHOD=ROOT/'selfhost/tools/performance/phase47/measure-size.py'
spec=importlib.util.spec_from_file_location('phase47_size',METHOD)
old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
old.read(METHOD,'8e59af66ae57c32cb335bacd480404fa1c8e52105b45aab0f4028450cfcf8681')
old.read(__file__)
parent=ROOT/'selfhost/tools/performance/phase55/evidence/source-size-host02.json'
previous=json.loads(old.read(parent));roles={};runtimes={}
for role,relative in [('baseline','selfhost/build/phase55/checked-host02/attempt.json'),('candidate','selfhost/build/phase56/checked-string01/attempt.json')]:
    row,attempt,_=old.snapshot(ROOT/relative)
    frozen={old.record_path(x['frozen']):x['frozen']['sha256'] for x in attempt['snapshot']['sources']}
    snapshot=Path(attempt['snapshot']['root']);runtimes[role]={}
    for file,expected in frozen.items():
        name=str(file.relative_to(snapshot))
        if name=='src/runtime.mjs' or name.startswith('src/runtime/') or name=='tools/typed-driver.mjs':
            runtimes[role][name]=old.identity(file,old.read(file,expected))
    row['partitions']={}
    for name,prefix in [('direct','src/back/js/direct/'),('native','src/back/native/'),('common','src/back/common/')]:
        files=[x for x in row['files'] if x['module'].startswith(prefix)]
        row['partitions'][name]=dict(modules=len(files),**{k:sum(x[k] for x in files)for k in old.counts(b'')})
    roles[role]=row
b,c=(roles[x]for x in ['baseline','candidate'])
assert b['totals']==previous['roles']['candidate']['totals']
assert c['totals']['physicalLines']==26246 and c['totals']['codeLines']==21585
assert c['totals']['definitions']==3012 and c['totals']['types']==100 and c['totals']['modules']==107
left={x['module']:x for x in b['files']};right={x['module']:x for x in c['files']};assert left.keys()==right.keys()
changes=[dict(module=n,before=left[n],after=right[n],delta=old.delta({k:left[n][k]for k in old.counts(b'')},{k:right[n][k]for k in old.counts(b'')}))for n in sorted(left)if left[n]['sha256']!=right[n]['sha256']]
unchanged=[n for n in sorted(left)if left[n]['sha256']==right[n]['sha256']];assert len(unchanged)==103
native=[n for n in left if n.startswith('src/back/native/')];assert len(native)==17 and all(n in unchanged for n in native)
assert runtimes['baseline'].keys()==runtimes['candidate'].keys()
unchangedRuntime=[dict(module=n,before=runtimes['baseline'][n],after=runtimes['candidate'][n])for n in sorted(runtimes['baseline'])]
assert all(x['before']['sha256']==x['after']['sha256']for x in unchangedRuntime)
for file,row in old.INPUTS.items():assert old.identity(file,Path(file).read_bytes())==row
result=dict(kind='phase56-frozen-source-accounting',complete=True,**{'pass':True},targetExecuted=False,
    producer=old.identity(__file__,Path(__file__).read_bytes()),method=old.identity(METHOD,METHOD.read_bytes()),parentEvidence=old.identity(parent,parent.read_bytes()),
    scope='Manifest-listed frozen Bend modules; physical lines include blanks/comments, code lines exclude blank/comment-only lines; def/law/type declarations count only starts of lines. Generated API images and runtime support are separate, not source reductions or independent concept counts.',
    roles=roles,delta=old.delta(b['totals'],c['totals']),changedModules=changes,unchangedModules=unchanged,
    unchangedRuntimeAndDriver=unchangedRuntime,inputs=list(old.INPUTS.values()),inputsUnchanged=True,
    invariants=dict(originalModulesExact=103,nativeModulesExact=17,runtimeFilesAndDriverExact=len(unchangedRuntime),noManifestModuleChange=True))
out=ROOT/'selfhost/tools/performance/phase56/evidence/source-accounting.json';out.parent.mkdir(parents=True,exist_ok=True)
with out.open('x')as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps(dict(output=old.identity(out,out.read_bytes()),totals={k:v['totals']for k,v in roles.items()},delta=result['delta'],changed=[{'module':x['module'],'delta':x['delta']}for x in changes],invariants=result['invariants'])))
