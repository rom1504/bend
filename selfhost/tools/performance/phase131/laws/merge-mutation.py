#!/usr/bin/env python3
"""Independently reject a type-correct merge with LT/EQ branches exchanged."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import sys
from mutation import pin, ROOT, BUILD

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--accepted',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args(); accepted=a.accepted.resolve(); out=a.out.resolve()
assert accepted.is_relative_to(BUILD) and out.is_relative_to(BUILD) and not out.exists()
prior=json.loads((accepted/'report.json').read_text())
assert prior['complete'] and prior['independentlyChecked'] and not prior['opaqueDefinitions']
assert 'merged_maximum' in prior['lawNames'] and 'merged_minimum' in prior['lawNames']
assert pin(accepted/'laws.bendtt')==prior['elaboration']
out.mkdir(parents=True)
report=dict(complete=False,accepted=pin(accepted/'report.json'),original=pin(accepted/'laws.bendtt'),
            method=pin(__file__),support=pin(Path(__file__).with_name('mutation.py')),rows={})
def save(): (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
try:
    original=(accepted/'laws.bendtt').read_text()
    blocks=original.split('\n\n')
    matches=[i for i,b in enumerate(blocks) if re.match(r'^\S+\.p131u_merge_choose :',b)]
    assert len(matches)==1
    i=matches[0]; before=blocks[i]
    exact='.EQ: λ{(): (x1 (.Unit, ()))'
    wrong='.EQ: λ{(): (x0 (.Unit, ()))'
    assert before.count(exact)==1
    less='.LT: λ{(): (x0 (.Unit, ()))'
    swapped='.LT: λ{(): (x1 (.Unit, ()))'
    assert before.count(less)==1
    blocks[i]=before.replace(exact,wrong).replace(less,swapped)
    law_bindings={name for names in prior['lawBindings'].values() for name in names}
    assert all(any(b.startswith(name+' :') for b in blocks) for name in law_bindings)
    program='\n\n'.join(b for b in blocks if not any(b.startswith(name+' :') for name in law_bindings))
    changed='\n\n'.join(blocks)
    files={'program':out/'wrong-program.bendtt','law':out/'wrong-laws.bendtt'}
    files['program'].write_text(program);files['law'].write_text(changed)
    (out/'method.py').write_bytes(Path(__file__).read_bytes())
    report.update(mutation=dict(declaration=before.split(' :',1)[0],before=[exact,less],after=[wrong,swapped],
      meaning='Exchange LT and EQ continuations, preserving affine use count. Equal keys wrongly take the LT continuation; unequal LT keys wrongly combine fields.'),
      artifacts={name:pin(path) for name,path in files.items()},removedLawBindings=sorted(law_bindings))
    kernel=ROOT/'selfhost/build/phase94/kernel'
    lean=ROOT/'selfhost/build/phase94/toolchain/lean-4.34.0-linux/bin/lean'
    guard=ROOT/'selfhost/tools/performance/phase131/laws/guard.py'
    inputs=[lean,lean.parent.parent/'lib/lean/libleanshared.so',kernel/'Run.lean',kernel/'BendTT.lean',kernel/'BendTT.olean',guard,ROOT/'selfhost/tools/performance/programs/support.py']
    previous={x['file']:x for x in prior['inputs']}
    report['inputs']=[pin(x) for x in inputs]
    for item in report['inputs']: assert item==previous[item['file']]
    for name,expected in [('program',0),('law',1)]:
        folder=out/name
        command=[sys.executable,'-B',str(guard),'--out',str(folder),'--seconds','60','--rss-mib','2048','--available-mib','16384','--cpu','4','--','env','LEAN_STACK_SIZE_KB=4096','LEAN_PATH='+str(kernel),str(lean),'-M1400','--run',str(kernel/'Run.lean'),str(files[name])]
        wrapper=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
        (out/(name+'-wrapper.stdout')).write_text(wrapper.stdout)
        (out/(name+'-wrapper.stderr')).write_text(wrapper.stderr)
        proc=json.loads((folder/'process.json').read_text())
        stdout=(folder/'stdout.log').read_text();stderr=(folder/'stderr.log').read_text()
        report['rows'][name]=dict(process=proc,stdout=stdout,stderr=stderr);save()
        assert proc['returncode']==expected and not proc.get('stoppedFor') and not stderr
        if name=='program': assert stdout=='ALL PROOFS CHECK\n'
        else: assert stdout.startswith('SOME PROOFS FAIL\nIn aligned_2d_merge_2d_laws.merge_same_key:') and 'expected:' in stdout and 'observed:' in stdout
    for item in report['inputs']: assert pin(item['file'])==item
    report.update(complete=True,wrongProgramAccepted=True,unchangedLawRejected=True)
except BaseException as error:
    report['error']=repr(error);raise
finally: save()
print(json.dumps({k:report[k] for k in ['complete','wrongProgramAccepted','unchangedLawRejected']}))
