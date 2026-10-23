#!/usr/bin/env python3
"""Keep an accepted law while replacing saturated sequence sum with minimum.

The law-free mutant must independently check before the kernel is asked to
reject the same program plus the unchanged theorem. This is test orchestration,
not an implementation of Bend normalization or of the optimization.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
BUILD = ROOT/'selfhost/build/phase131'

def pin(path):
    path = Path(path).resolve()
    return dict(file=str(path), bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--accepted', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    accepted = args.accepted.resolve(); out = args.out.resolve()
    assert accepted.is_relative_to(BUILD) and out.is_relative_to(BUILD) and not out.exists()
    report = json.loads((accepted/'report.json').read_text())
    assert report['complete'] and report['independentlyChecked']
    assert report['lawNames'] == ['saturated_sequence_exact'] and not report['opaqueDefinitions']
    assert pin(accepted/'laws.bendtt') == report['elaboration']
    out.mkdir(parents=True)
    result = dict(complete=False, accepted=pin(accepted/'report.json'),
                  original=pin(accepted/'laws.bendtt'), method=pin(__file__),
                  scope='Deliberate type-correct kernel-body mutation; original theorem and all other definitions unchanged.', rows={})
    def save(): (out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
    try:
        text = (accepted/'laws.bendtt').read_text()
        old = ('production.p131a_add : ∀x0 : U32 -> ∀x1 : U32 -> U32 =\n'
               '  λx0 => λx1 => (U32.min U32.lit2 (U32.add x0 x1))')
        new = ('production.p131a_add : ∀x0 : U32 -> ∀x1 : U32 -> U32 =\n'
               '  λx0 => λx1 => (U32.min x0 x1)')
        assert text.count(old) == 1
        changed = text.replace(old,new)
        pattern = r'^saturated_sequence_exact :[\s\S]*?(?=\n\n|\Z)'
        assert len(re.findall(pattern, changed, re.M)) == 1
        program = re.sub(pattern,'',changed,flags=re.M)
        files = {'program':out/'wrong-program.bendtt','law':out/'wrong-law.bendtt'}
        files['program'].write_text(program); files['law'].write_text(changed)
        result['mutation'] = dict(original=old,replacement=new,
                                  witness='Once followed by Once must be Many (2); minimum incorrectly returns Once (1).')
        result['artifacts'] = {k:pin(v) for k,v in files.items()}
        authenticated = {x['file']:x for x in report['inputs']}
        lean = ROOT/'selfhost/build/phase94/toolchain/lean-4.34.0-linux/bin/lean'
        kernel = ROOT/'selfhost/build/phase94/kernel'
        inputs = [lean,lean.parent.parent/'lib/lean/libleanshared.so',
                  kernel/'BendTT.lean',kernel/'BendTT.olean',kernel/'Run.lean',
                  ROOT/'selfhost/tools/performance/phase131/laws/guard.py',
                  ROOT/'selfhost/tools/performance/programs/support.py']
        result['inputs'] = [pin(p) for p in inputs]
        for item in result['inputs']: assert authenticated[item['file']] == item
        for name,expected in [('program',0),('law',1)]:
            folder = out/name
            command = [sys.executable,'-B',str(inputs[-2]),'--out',str(folder),
                       '--seconds','60','--rss-mib','2048','--available-mib','16384','--cpu','4','--',
                       'env','LEAN_STACK_SIZE_KB=4096','LEAN_PATH='+str(kernel),str(lean),
                       '-M1400','--run',str(kernel/'Run.lean'),str(files[name])]
            wrapper = subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
            (out/(name+'-wrapper.stdout')).write_text(wrapper.stdout)
            (out/(name+'-wrapper.stderr')).write_text(wrapper.stderr)
            process = json.loads((folder/'process.json').read_text())
            stdout = (folder/'stdout.log').read_text(); stderr = (folder/'stderr.log').read_text()
            result['rows'][name] = dict(process=process,stdout=stdout,stderr=stderr); save()
            assert process['returncode']==expected and not process.get('stoppedFor') and not stderr
            if name=='program': assert stdout=='ALL PROOFS CHECK\n'
            else:
                assert stdout.startswith('SOME PROOFS FAIL\nIn saturated_sequence_exact:')
                assert 'expected:' in stdout and 'observed:' in stdout
        for item in result['inputs']: assert pin(item['file'])==item
        result.update(complete=True,wrongProgramAccepted=True,unchangedLawRejected=True)
    except BaseException as error:
        result['error']=repr(error); raise
    finally: save()
    print(json.dumps({k:result[k] for k in ['complete','wrongProgramAccepted','unchangedLawRejected']}))

if __name__=='__main__': main()
