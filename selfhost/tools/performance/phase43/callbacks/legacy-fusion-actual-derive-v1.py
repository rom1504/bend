#!/usr/bin/env python3
"""Counter/diagnostic adapters only, bound to an actual checked-emission receipt."""
from pathlib import Path
import argparse,ast,hashlib,json

def identity(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def consume(row):
 got=identity(row.get('file',row.get('path')));assert got['sha256']==row['sha256'];return got

a=argparse.ArgumentParser();a.add_argument('baseline',type=Path);a.add_argument('candidate',type=Path);a.add_argument('receipt',type=Path);a.add_argument('out',type=Path);a=a.parse_args()
root=Path(__file__).resolve().parents[5];manifest=root/'selfhost/tools/performance/phase41/current/manifest.json'
m=json.loads(manifest.read_text());point=next(x for x in m['cases'] if x['id']=='coverage-list-pipeline-128')
parent=identity(a.baseline);assert parent['sha256']==point['modules']['candidate']['sha256']
r=json.loads(a.receipt.read_text());assert r['kind']=='bend-program-checked-emission' and r['complete']
assert r['observation']['status']=='ok' and r['observation']['checked'] is True and r['observation']['typeAccepted'] is True
candidate=identity(a.candidate);assert candidate['sha256']==r['output']['sha256'];assert r['input']['sha256']==point['sourceSha256']
extra=[identity(a.receipt),consume(r['input']),consume(r['attempt']),consume(r['output'])]
for key in ['api','runtime','base','driver']:extra.append(consume(r['compiler'][key]))
legacy=root/'selfhost/tools/performance/phase42/fusion';extra.append(identity(legacy/'actual-derive.py'))
helper=legacy/'derive-v2.py';parsed=ast.parse(helper.read_text());helpers=next(ast.literal_eval(n.value) for n in parsed.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='helpers' for t in n.targets))
clean=a.candidate.read_text();marker='/* private total scalar fusion */';assert clean.count(marker)==1
line=next(x for x in clean.splitlines() if x.startswith('G["bench"]=scalarCapture'))
assert marker in line and 'try{' in line and '}finally{regionProofClose($previousProof);}' in line
assert 'exactCode(function(a,$entered)' in line and 'if($entered&&regionHostGuard(true)&&' in line and 'localGuard($guards)' in line
assert 'regionProofOpen($guards);try{' in line and line.index('regionProofOpen($guards);try{')<line.index(marker)
assert 'regionHostGuard()' not in line and 'localGuard($guards,callbackU32Guard)' not in line
out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
frozen=out/'consumed-derive.py';frozen.write_bytes(Path(__file__).read_bytes());savedHelper=out/'consumed-helper.py';savedHelper.write_bytes(helper.read_bytes());extra.append(identity(savedHelper))
report=dict(kind='phase42-fusion-saved-js',complete=False,checked=True,parent=parent,manifest=identity(manifest),producer=identity(frozen),additionalInputs=extra,dependencies=['bench','p37.list','keep_gt1','keep_gt1.at','dbl','suma'],modules=[],scope='Actual checked candidate emission; diagnostic instrumentation only, clean bytes unchanged. Counter is solely inside admitted root proof try body.',guardCapability='exact-total-U32-fusion-regionHostGuard(true)',legacyProducer=identity(legacy/'actual-derive.py'))
for variant,file in [('original',a.baseline),('actual',a.candidate)]:
 s=file.read_text();counted=s.replace(marker,marker+'++$p42Counts.root;') if variant=='actual' else s
 for counters in [False,True]:
  target=out/(variant+('.mjs' if counters else '.clean.mjs'));target.write_text((counted+helpers) if counters else s)
  if not counters:assert identity(target)['sha256']==identity(file)['sha256']
  report['modules'].append(dict(variant=variant,counters=counters,**identity(target)))
report['complete']=True;(out/'derive.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(complete=True,out=str(out),modules=4)))
