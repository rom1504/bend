"""Validate an already emitted cached edge product against the independent trie."""
import argparse
import importlib.util
from pathlib import Path
import os

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('snaprun',HERE/'snapshot-run.py')
runner=importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


def main(out):
    assert os.sched_getaffinity(0)=={3};out=out.resolve();out.mkdir()
    root=HERE.parents[2]/'selfhost/build/phase198'
    source=runner.read(root/'map-pivot-source05/report.json')
    prev=runner.read(root/'map-pivot-edge01/report.json')['cases']['map-edges']['products']['cached']
    cached=runner.checked_tool(prev['binary']);runner.checked_tool(prev['object']);runner.checked_tool(prev['sourceCheck'])
    keys=source['edgeKeys'];row=source['cases']['map-edges']
    receipt={'complete':False,'product':prev,'oracle':'Independent full trie replay on raw U32 keys','checks':[]}
    for point in [row['inputs'],[0,0],[1,17],[4,17],[23,99],[64,0]]:
        expected=str(runner.trace(*point,key=lambda n:keys[n%len(keys)])['digest'])+'\n'
        proof=runner.oracle(out,'map-edges','cached',cached,point,int(point==row['inputs']),expected)
        receipt['checks'].append(dict(inputs=point,expected=expected,observation=proof))
        runner.save(out/'report.json',receipt)
    receipt['complete']=True;runner.save(out/'report.json',receipt)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);main(p.parse_args().out)
