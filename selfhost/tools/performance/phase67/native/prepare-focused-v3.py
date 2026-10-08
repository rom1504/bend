#!/usr/bin/env python3
"""Bind existing checked workflow/native fixture gates; source/data only."""
import argparse, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def pin(p):
 p=Path(p).resolve(strict=True);b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
def write(p,x):
 with p.open('x') as f:json.dump(x,f,indent=2);f.write('\n')
p=argparse.ArgumentParser();p.add_argument('--attempt',required=True,type=Path);p.add_argument('--toolchain-recipe',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--stage',choices=['atoms','scalars'],default='atoms');a=p.parse_args()
a.out=a.out.resolve();assert a.out.is_relative_to(ROOT/'selfhost/build/phase67') and not a.out.exists()
m=json.loads((a.attempt/'attempt.json').read_text());assert m['checked'] and m['config']['strictExact']
for k in ['api','base','runtime','node']:assert pin(m[k]['file'])['sha256']==m[k]['sha256']
tc=json.loads(a.toolchain_recipe.read_text());assert tc['kind']=='phase67-native-method-v2'
for i in tc['inputs']:
 q=pin(i['path']);assert q['sha256']==i['sha256'] and q['bytes']==i['bytes']
clang=Path(tc['clang']);headers=Path(tc['clangArgs'][1]);assert tc['clangArgs'][0]=='-isystem'
snapshot=Path(m['snapshot']['root']);up=Path(m['config']['upstream'])
names=['reg/array_clone_boxed','run/fork_shared_flat','compile/closure_partial_app'] if a.stage=='atoms' else ['base/u32_divmod_zero','compile/float_compare','compile/float_builtin_agreement','run/nat_overflow','compile/bang_intrinsic_closure']
a.out.mkdir(parents=True);selection=a.out/'selection.json';write(selection,{'cases':[{'id':x+'.bend','lanes':['native']} for x in names]})
inputs=[pin(up/'tests'/(x+'.bend')) for x in names]
env={'CC':str(clang),'CPATH':str(headers)}
def guarded(name,argv,seconds=600,moreenv=None):
 e={**env,**(moreenv or {})};dest=a.out/name
 return dict(name=name,command=['python3','-B',str(ROOT/'selfhost/tools/performance/phase32/bounded-run.py'),'--seconds',str(seconds),'--rss-mib','2048','--available-mib','4096',str(dest)+'-supervisor','--','taskset','-c','3','env',*[k+'='+v for k,v in e.items()],m['node']['file'],'--max-old-space-size=1024','--stack-size=4096',*map(str,argv)],report=str(dest/'report.json'))
baseline=ROOT/'selfhost/dist/typed-api.mjs'
commands=[guarded('raw',[HERE/'raw-controls-v3.mjs',a.toolchain_recipe.resolve(),baseline,m['api']['file'],a.out/'raw'],180),guarded('paired',[ROOT/'selfhost/tools/development/workflow.mjs','validate',a.attempt.resolve(),selection,a.out/'paired'])]
# Reuse the maintained native fixture runner for explicit thread counts. Its
# import/root/output substitutions only isolate snapshot and fresh destination.
parent=ROOT/'selfhost/src/back/native/fixtures.mjs';src=parent.read_text();edits=[
("from '../../../tools/typed-driver.mjs';", "from "+json.dumps((snapshot/'tools/typed-driver.mjs').as_uri())+";"),
("const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../../..');",'const root='+json.dumps(str(snapshot))+';'),
("const output=path.join(root,'build/native-fixtures');",'const output='+json.dumps(str(a.out/'threads'))+';')]
for old,new in edits:assert src.count(old)==1;src=src.replace(old,new)
runner=a.out/'threads-fixtures.mjs';runner.write_text(src)
write(a.out/'threads-derivation.json',{'parent':pin(parent),'output':pin(runner),'edits':[{'old':x,'new':y,'occurrences':1} for x,y in edits]})
thread_names=['reg/array_clone_boxed','run/fork_shared_flat'] if a.stage=='atoms' else ['run/nat_overflow','compile/bang_intrinsic_closure']
commands.append(guarded('threads',[runner,*thread_names],240,{'BEND_UPSTREAM':str(up),'BEND_BASE':m['base']['file'],'BEND_TYPED_API':m['api']['file'],'BEND_TYPED_RUNTIME':m['runtime']['file'],'BEND_TYPED_TRACE':'','NODE_OPTIONS':''}))
write(a.out/'plan.json',{'kind':'phase67-focused-native-gates','executed':False,'stage':a.stage,'attempt':pin(a.attempt/'attempt.json'),'toolchainRecipe':pin(a.toolchain_recipe),'producer':pin(__file__),'selection':pin(selection),'sourceInputs':inputs,'rawController':pin(HERE/'raw-controls-v3.mjs'),'baselineApi':pin(baseline),'threadsDerivation':pin(a.out/'threads-derivation.json'),'commands':commands,'scope':'Fresh independent TypeScript and checked candidate native source outputs via unchanged maintained validation workflow; additional generated binaries execute with explicit threads1 and4 via maintained fixture runner. This is selected conformance, not proof of arbitrary scheduling or full native conformance. Controller freezes each checked snapshot. No timing claims.'})
print(json.dumps({'plan':pin(a.out/'plan.json'),'commands':len(commands),'targetsExecuted':False}))
