#!/usr/bin/env python3
"""Bind String identity laws to exact current safe source declarations."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
NAMES=['p88_string_eq_go','p98_eq_finish','p88_string_eq']

def pin(path):
    path=Path(path).resolve()
    return dict(file=str(path),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest())

def declaration(text,name):
    found=re.findall(r'^def '+re.escape(name)+r'\b[\s\S]*?(?=\n\n|\Z)',text,re.M)
    assert len(found)==1,(name,len(found))
    return found[0].strip()

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--source',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args(); source=a.source.resolve(); out=a.out.resolve()
assert source.is_relative_to(ROOT) and out.is_relative_to(ROOT/'selfhost/build/phase131') and not out.exists()
receipt=ROOT/'selfhost/build/phase131/laws-string-reflexivity01/report.json'
r=json.loads(receipt.read_text())
assert r['complete'] and r['independentlyChecked'] and not r['opaqueDefinitions']
assert set(r['lawNames'])=={'char_equal_reflexive','string_diagonal_preserves_flag','string_equal_reflexive','word_compare_reflexive','u32_compare_reflexive'}
assert pin(r['elaboration']['file'])==r['elaboration']
for item in r['inputs']: assert pin(item['file'])==item
for row in r['sourceClosure']:
    assert pin(row['origin']['file'])==row['origin'] and pin(row['snapshot']['file'])==row['snapshot']
proof=HERE/'string-production.bend';assert any(row['origin']==pin(proof)for row in r['sourceClosure'])
text=source.read_text();old=proof.read_text()
for name in NAMES:
    assert declaration(text,name)==declaration(old,name),name
    assert not re.search(r'^@unsafe\n(def '+re.escape(name)+r'\b)',text,re.M),name
out.mkdir(parents=True)
(out/'method.py').write_bytes(Path(__file__).read_bytes())
report=dict(complete=True,targetsRun=False,method=pin(__file__),source=pin(source),
            proofReceipt=pin(receipt),proofSource=pin(proof),exactDeclarations=NAMES,
            scope='Source theorem only: go(x,x,same)=same and held public String equality is reflexive. Full native Term identity, live immutable typed roots, reader ABI and preservation of outer ownership guards/releases remain separate runtime premises.')
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(complete=True,exactDeclarations=NAMES)))
