#!/usr/bin/env python3
"""Prepare data-only complete-value fixtures; never execute compiler/programs."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / 'selfhost/build/phase166/lookup-source02/compiler.bend'
ORACLE = ROOT / 'experiments/phase166/lookup-expected-values.json'
SOURCE_SHA = '4627d3b8c7b8291277574a1fc68bdf6afc972be1e32f8d1d8620c62eb4bdf181'
OLD = b'def main() -> U32:\n  p166l_run(10000)\n'
FIELDS = {
    'KDef': ['name','kind','arity','templates','typ','value','ctors','native','unsafe'],
    'KTerm': ['tag','name','id','quant','kids','removed','originBegin','originEnd'],
}

def pin(path):
    data = path.read_bytes()
    return {'file':str(path.relative_to(ROOT)), 'bytes':len(data),
            'sha256':hashlib.sha256(data).hexdigest()}

def literal(value):
    if isinstance(value, bool): return 'True{}' if value else 'False{}'
    if isinstance(value, int):
        assert 0 <= value <= 0xffffffff
        return str(value)
    if isinstance(value, str): return json.dumps(value,ensure_ascii=False)
    assert isinstance(value, dict) and '$' in value
    tag = value['$']
    if tag in ('Con','Nil'):
        elements=[]
        while value['$']=='Con':
            elements.append(literal(value['head']));value=value['tail']
        assert value=={'$':'Nil'}
        return '['+','.join(elements)+']'
    assert tag in FIELDS,tag
    assert set(value)=={'$',*FIELDS[tag]},(tag,set(value))
    return tag+'{'+','.join(literal(value[k]) for k in FIELDS[tag])+'}'

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--i',type=int,default=0)
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args()
    source=SOURCE.read_bytes()
    assert hashlib.sha256(source).hexdigest()==SOURCE_SHA
    assert source.count(OLD)==1 and source.endswith(OLD)
    oracle=json.loads(ORACLE.read_text())
    method=ROOT/oracle['method']['file']
    assert pin(method)['sha256']==oracle['method']['sha256']
    row=next(row for row in oracle['cases'] if row['i']==args.i)
    out=args.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase171') and not out.exists()
    out.mkdir(parents=True)
    actual=b'def main() -> List<&2,KDef>:\n  p166l_values('+str(args.i).encode()+b')\n'
    expected=('def main() -> List<&2,KDef>:\n  '+literal(row['value'])+'\n').encode()
    for name,body in [('actual',actual),('expected',expected)]:
        (out/(name+'.bend')).write_bytes(source[:-len(OLD)]+body)
    (out/'literal-value.json').write_text(json.dumps(row,ensure_ascii=False,indent=2)+'\n')
    report={'kind':'phase171-complete-descendant-value-fixture','complete':True,'targetsRun':False,
        'inputs':[pin(Path(__file__).resolve()),pin(SOURCE),pin(ORACLE),pin(method)],
        'round':args.i,'recordCount':row['count'],'onlyMainChanged':True,
        'unchangedPrefix':{'bytes':len(source)-len(OLD),'sha256':hashlib.sha256(source[:-len(OLD)]).hexdigest()},
        'actual':pin(out/'actual.bend'),'expected':pin(out/'expected.bend'),
        'literalValue':pin(out/'literal-value.json'),
        'scope':'All original lookup/getter/helper bodies are exact. Expected main is the existing independent literal18-record oracle, with no lookup calls or digest. No compiler/run or native conformance claim.'}
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({'actual':report['actual'],'expected':report['expected'],'records':row['count']}))

if __name__=='__main__': main()
