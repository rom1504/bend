"""Run the admitted checked rule on two distinct workloads within one guard."""
import argparse
from pathlib import Path
import json
import os
import subprocess
import sys
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BUILD=ROOT/'selfhost/build/phase198'

def run(out):
    assert os.sched_getaffinity(0)=={3}
    out=out.resolve();out.mkdir()
    started=time.monotonic()
    bun='selfhost/.assets/bin/bun'
    api=BUILD/'quotient-machine-api01/report.json'
    selected=['lexer','coverage-record-aggregation-256']
    jobs=[('controls',[bun,HERE/'controls.mjs','--api',api,'--out',out/'controls']),
          ('emission',[bun,HERE.parent/'quotient/emit.mjs','--api',api,'--out',out/'emission','--cases',','.join(selected)]),
          ('timing',[sys.executable,'-B',HERE.parent/'fusion/time-products.py','--emission',out/'emission/report.json','--out',out/'timing'])]
    report=dict(complete=False,selected=selected,jobs=[])
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    for name,argv in jobs:
        before=time.monotonic()
        r=subprocess.run(list(map(str,argv)),cwd=ROOT,capture_output=True)
        (out/(name+'.stdout')).write_bytes(r.stdout);(out/(name+'.stderr')).write_bytes(r.stderr)
        report['jobs'].append(dict(name=name,argv=list(map(str,argv)),seconds=time.monotonic()-before,status=r.returncode))
        save()
        if r.returncode:
            raise ValueError(name+' failed: '+r.stderr.decode(errors='replace')[-1400:])
        evidence=json.loads((out/name/'report.json').read_text())
        assert evidence['complete']
        if name=='emission':
            assert [c['id'] for c in evidence['cases']]==selected and all(c['objectChanged'] for c in evidence['cases'])
    report.update(complete=True,seconds=time.monotonic()-started)
    save()
    print(json.dumps(report))

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',type=Path,required=True)
    run(p.parse_args().out)
