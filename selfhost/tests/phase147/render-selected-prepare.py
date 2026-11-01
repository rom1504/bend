#!/usr/bin/env python3
"""Prepare narrow checked old/new APIs exposing the actual selected renderer."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('phase147_prepare',ROOT/'experiments/phase147/tools/prepare.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline',type=Path,required=True);p.add_argument('--candidate',type=Path,required=True)
    p.add_argument('--capture',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=P.fresh_output(a.out,ROOT)
    roots=['p111q_segment','p111q_function_ids','p111q_constructor_ids','missing'];rows=[];jobs=[]
    for role,source in [('baseline',a.baseline),('candidate',a.candidate)]:
        d=out/role;d.mkdir();body,inventory=P.extract([(role,source.read_bytes())],roots)
        (d/'compiler.bend').write_bytes(body)
        P.write_json(d/'exports.json',dict(kind='bend-hosted-api-exports',version=1,exports=roots,
            protocol='hosted-api-v1',targets=['qbe'],preparationModes=['live'],scope='Selected renderer utility API only.'))
        P.write_json(d/'manifest.json',dict(kind='phase147-selected-renderer-preparation',version=1,complete=True,
            targetsRun=False,role=role,canonicalSource=P.pin(source),source=P.pin(d/'compiler.bend'),
            exports=P.pin(d/'exports.json'),declarations=inventory,inputs=[P.pin(__file__),P.pin(P.__file__),P.pin(source)]))
        acquisition=d/'api'
        jobs.append(P.guard('checked-selected-renderer-'+role,acquisition,[ROOT/'selfhost/.assets/bin/bun',
            ROOT/'selfhost/tools/build/hosted.mjs','acquire','--source',d/'compiler.bend','--exports',d/'exports.json',
            '--upstream',ROOT/'selfhost/.bootstrap/upstream-phase66','--engine',ROOT/'selfhost/.assets/bin/bun','--out',acquisition],150))
        rows.append(dict(role=role,preparation=P.pin(d/'manifest.json'),apiReport=str(acquisition/'report.json')))
    report=dict(kind='phase147-selected-renderer-pair-preparation',version=1,complete=True,targetsRun=False,
        rows=rows,capture=P.pin(a.capture),inputs=[P.pin(__file__),P.pin(P.__file__),P.pin(a.baseline),P.pin(a.candidate),P.pin(a.capture)])
    P.write_json(out/'manifest.json',report);P.write_json(out/'jobs.json',jobs)
    controls=out/'controls'
    check=P.guard('selected-renderer-complete-functions',controls,[ROOT/'selfhost/.assets/bin/bun',
        Path(__file__).with_name('render-selected-check.mjs'),'--preparation',out/'manifest.json','--out',controls],120)
    P.write_json(out/'controls-jobs.json',[check]);print(json.dumps(dict(jobs=P.pin(out/'jobs.json'),controls=P.pin(out/'controls-jobs.json'))))


if __name__=='__main__':main()
