"""Stage the exact arithmetic proof and the target-specific machine selector."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]

def prepare(path):
    path.mkdir(parents=True)
    plan=path/'plan.bend'
    source=(HERE.parent/'quotient/rule.bend').read_text()
    prefix,split,suffix=source.partition('@unsafe\ndef p198q_fallback(')
    assert split and 'def p198q_plan(' in prefix
    plan.write_text(prefix)
    subprocess.run([sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source','selfhost/build/phase198/selected-source01/compiler.bend',
        '--assets','selfhost/build/phase194/assets.json','--out',str(path/'api'),'--module',str(plan),'--module',str(HERE/'machine.bend'),
        '--replace','x191_ff_work','--export','p198q_plan','--export','x191_frame_forward'],cwd=ROOT,check=True)

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',required=True,type=Path)
    prepare(p.parse_args().out.resolve())
