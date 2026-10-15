#!/usr/bin/env python3
"""Prepare well-typed candidate bugs while keeping representation laws frozen."""
import argparse
import hashlib
import json
from pathlib import Path

CASES = [
    ('ignore-node-children', 'k_with_children',
     'KTerm{tag, name, id, quant, newKids, removed, originBegin, originEnd}',
     'KTerm{tag, name, id, quant, oldKids, removed, originBegin, originEnd}'),
    ('erase-removed-names', 'k_with_children',
     'KTerm{tag, name, id, quant, newKids, removed, originBegin, originEnd}',
     'KTerm{tag, name, id, quant, newKids, Nil{}, originBegin, originEnd}'),
    ('ignore-span-begin', 'k_with_span',
     'KTerm{tag, name, id, quant, kids, removed, newBegin, newEnd}',
     'KTerm{tag, name, id, quant, kids, removed, oldBegin, newEnd}'),
    ('swap-literal-span', 'k_with_span',
     'KLiteral{kind, number, text, newBegin, newEnd}',
     'KLiteral{kind, number, text, newEnd, newBegin}'),
    ('lose-lambda-quantity-presence', 'k_rebuild',
     'KLambda{name, id, quant, kids, removed, begin, end, present}',
     'KLambda{name, id, quant, kids, removed, begin, end, False{}}'),
    ('wrong-literal-tag', 'tg', '      "Lit"', '      "Lam"'),
    ('zero-literal-payload', 'kl_number',
     'case KLiteral{kind, number, text, begin, end}: number',
     'case KLiteral{kind, number, text, begin, end}: 0'),
    ('wrong-node-name', 'nm',
     'case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:\n      name',
     'case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:\n      tag'),
]


def pin(path):
    data=path.read_bytes()
    return dict(file=str(path.resolve()),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--positive',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();positive=a.positive.resolve();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
    original=(positive/'production.bend').read_text();laws=(positive/'laws.bend').read_bytes()
    manifest=json.loads((positive/'manifest.json').read_text());definitions={r['name']:r['extracted'] for r in manifest['definitions']}
    rows=[]
    for name,helper,old,new in CASES:
        body=definitions[helper];assert body.count(old)==1,(name,body.count(old));assert original.count(body)==1
        changed=body.replace(old,new,1);directory=out/name;directory.mkdir()
        (directory/'production.bend').write_text(original.replace(body,changed,1))
        (directory/'laws.bend').write_bytes(laws)
        rows.append(dict(id=name,helper=helper,old=old,new=new,helperSource=pin(directory/'production.bend'),
                         lawSource=pin(directory/'laws.bend'),positiveLaw=pin(positive/'laws.bend')))
    (out/'manifest.json').write_text(json.dumps(dict(method=pin(Path(__file__)),positive=pin(positive/'manifest.json'),
                                                      rows=rows,targetsRun=False),indent=2)+'\n')
    print(json.dumps(dict(prepared=len(rows),out=str(out))))


if __name__=='__main__':main()
