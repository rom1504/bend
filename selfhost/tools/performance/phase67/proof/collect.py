#!/usr/bin/env python3
"""Data-only receipt for the bounded immediate-let proof pilot; no targets run."""
import argparse, hashlib, json, re
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--out',required=True,type=Path)
p.add_argument('--kernel',default='proof-kernel01')
p.add_argument('--negative')
p.add_argument('--selfhost')
a=p.parse_args()
root=Path(__file__).resolve().parents[5]; raw=root/'selfhost/build/phase67'
inputs={}
def pin(file,expected=None):
    file=Path(file).resolve(); h=hashlib.sha256()
    with file.open('rb') as fd:
        for block in iter(lambda:fd.read(1024*1024),b''):h.update(block)
    row={'file':str(file),'bytes':file.stat().st_size,'sha256':h.hexdigest()}
    if expected: assert row['sha256']==expected,str(file)
    inputs[str(file)]=row;return row
def read(file):
    pin(file);return json.loads(Path(file).read_text())
def observed(name):
    d=raw/name; result=read(d/'process.json')
    assert 'finished' in result,'Process is still open: '+name
    result.update(name=name,receipt=pin(d/'process.json'),stdout=pin(d/'stdout.log'),stderr=pin(d/'stderr.log'),stdoutText=(d/'stdout.log').read_text(),stderrText=(d/'stderr.log').read_text())
    return result
proof=pin(root/'selfhost/proofs/phase67/immediate-let.bend','bf19656db55113adbde68559167a88d08f2ba4146460039b8e56268d0850061e')
kernel=pin(root/'bend2/bendtt.lean','83cdd36e66dcd2cabcc3d10556c9c874f8d823956feab88f8bb5a81473d51be3')
elaborator=pin(root/'bend2/safe.ts','bf495d64c03caa7a2558aaae5e172cd7743b9aa5470c4d33ad86634e23d81ffc')
for f in ['bend2/bend.ts','bend2/main.ts','selfhost/proofs/phase67/README.md',str(Path(__file__).relative_to(root))]:pin(root/f)
output=pin(raw/'immediate-let01.bendtt','0e1b7e61e7b4acb849f455ff4f14f5c0498e730a02b087c923a1772974b0d589')
text=(raw/'immediate-let01.bendtt').read_text();names=re.findall(r'^([A-Za-z_][A-Za-z_0-9.]*) :',text,re.M)
assert names==['NP_Words.arms','NP_Words','NP_Frame.arms','NP_Frame','NP_Sequence.arms','NP_Sequence','np_append','np_resume','np_local','np_contract','np_framed','np_straight','np_sequence_contract']
toolchain=Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0')
for f in ['include/lean/version.h','lib/lean/libleanshared.so']:pin(toolchain/f)
source=(root/'selfhost/proofs/phase67/immediate-let.bend').read_text()
code='\n'.join(line for line in source.splitlines() if not line.lstrip().startswith('#'))
assert not re.search(r'^\s*(?:import|@unsafe|axiom)\b',code,re.M)
check=observed('proof-check03');emit=observed('proof-elaboration01');checked=observed(a.kernel)
assert check['complete'] and check['returncode']==0 and check['stdoutText']=='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
assert emit['complete'] and emit['returncode']==0 and not (emit['stdoutText']+emit['stderrText']).strip()
negative=observed(a.negative) if a.negative else None
selfhost=observed(a.selfhost) if a.selfhost else None
kernel_ok=checked['complete'] and checked['returncode']==0 and checked['stdoutText'].strip()=='ALL PROOFS CHECK'
negative_ok=negative is not None and negative['returncode']!=0 and 'stoppedFor' not in negative and 'SOME PROOFS FAIL' in (negative['stdoutText']+negative['stderrText'])
if negative:pin(root/'selfhost/proofs/phase67/reject-unequal-labels.bendtt','86d04a10c1894d05fade68fb877acda0dfd7a6932511593ef7b83826349da181')
for run in [check,emit,checked]+([negative] if negative else [])+([selfhost] if selfhost else []):
    for arg in run['command']:
        candidate=Path(arg) if arg.startswith('/') else root/arg
        if candidate.is_file():pin(candidate)
incompatible=checked['returncode']!=0 and 'Unknown identifier `ite_eq_left`' in (checked['stdoutText']+checked['stderrText'])
report={'kind':'phase67-immediate-let-proof-pilot','complete':True,'independentlyProved':kernel_ok and negative_ok,'sourceTypechecked':True,'status':'independently-checked-model' if kernel_ok and negative_ok else ('independent-validation-blocked' if incompatible else 'not-independently-validated'),'kernelAccepted':kernel_ok,'negativeControlRejected':negative_ok,'selfhostTypechecked':bool(selfhost and selfhost['complete'] and selfhost['returncode']==0 and 'ALL PROOFS CHECK' in selfhost['stdoutText']),'proof':proof,'elaboration':output,'elaboratedDefinitions':names,'kernelSource':kernel,'elaborator':elaborator,'toolchainLabel':'local Lean4.32.0; upstream automatic launcher requests4.34.0','scope':'Semantic model of sequential transport of already computed words and finite composition. Not a proof of production emitter, C/runtime, lookup, ownership, scheduler/error polling or compiler soundness.','runs':{'upstreamCheck':check,'elaboration':emit,'kernel':checked,'negative':negative,'selfhost':selfhost},'priorLauncherFailures':[observed('proof-check01'),observed('proof-check02')]}
report['inputs']=list(inputs.values())
a.out.parent.mkdir(parents=True,exist_ok=True)
with a.out.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps({k:report[k] for k in ['complete','independentlyProved','sourceTypechecked','kernelAccepted','negativeControlRejected','selfhostTypechecked']}))
