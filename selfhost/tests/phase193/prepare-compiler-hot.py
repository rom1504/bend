#!/usr/bin/env python3
"""Extract exact Phase192 helper closure plus transfer driver; execute no target."""
import argparse
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import source as S
from common import pin,verify,require,fresh_output,write_json


def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    value=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--rounds',type=int,default=1000)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    require(0<=a.rounds<=100000,'Bounded round count')
    E=module('extract147',ROOT/'experiments/phase147/tools/prepare.py')
    O=module('oracle193',Path(__file__).with_name('compiler-hot-oracle.py'))
    image_receipt=ROOT/'selfhost/build/phase192/native-self01/report.json'
    image=json.loads(image_receipt.read_text())
    require(image['complete'] and not image['changedInputs'],'Qualified source receipt incomplete')
    parent=image['imageBinding']['sourceIdentity']
    original=verify(parent).read_bytes()
    _,blocks=S.blocks(original)
    original=b''.join(r['data'] for r in blocks if r['name']!='main')
    driver=Path(__file__).with_name('compiler-hot-workload.bend')
    consumer=ROOT/'selfhost/tests/phase163/direct-runtime.bend'
    entry=('def main() -> U32:\n  p193t_run('+str(a.rounds)+')\n').encode()
    selected,inventory=E.extract([('phase192-qualified-source',original),
        (str(consumer),consumer.read_bytes()),(str(driver),driver.read_bytes()),
        ('explicit-main',entry)],['main','p193t_values'],200000)
    names={r['name'] for r in inventory}
    required={'p111v_put','p111v_get','p131i_insert','index_leaf','index_remove','index_hash','dn','atom'}
    require(required<=names,'Target helper closure incomplete')
    out=fresh_output(a.out,ROOT)
    (out/'compiler.bend').write_bytes(selected)
    (out/'expected.stdout').write_text(str(O.expected(a.rounds))+'\n')
    write_json(out/'expected-values.json',{str(i):O.expected_values(i) for i in [0,1,7]})
    write_json(out/'manifest.json',dict(kind='phase193-compiler-hot-source',complete=True,
        targetsRun=False,rounds=a.rounds,source=pin(out/'compiler.bend'),
        expectedStdout=pin(out/'expected.stdout'),expectedValues=pin(out/'expected-values.json'),
        parentSource=parent,declarations=inventory,overrides=[],
        inputs=[pin(__file__),pin(E.__file__),pin(S.__file__),pin(O.__file__),pin(O.O.__file__),
                pin(driver),pin(consumer),pin(image_receipt),parent],
        scope='Exact reachable current compiler declarations plus explicit dynamic update/read driver. '
              'Full-result digest uses retained Phase163 consumer; literal Python oracle independently '
              'specifies records. Source checking and runtime equality remain separate guarded gates.'))
    print(json.dumps(dict(source=pin(out/'compiler.bend'),declarations=len(inventory),
                          expected=O.expected(a.rounds),targetsRun=False)))


if __name__=='__main__':
    main()
