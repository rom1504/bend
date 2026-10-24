#!/usr/bin/env python3
"""Bind the bucket scalar-fusion theorem to real producer and candidate bodies."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
NAMES=['KTerm','KDef','p88_string_eq_go','p98_eq_finish','p88_string_eq','kc','dn','dx','missing','index_bucket']

def pin(path):
    path=Path(path).resolve()
    return dict(file=str(path),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest())

def decl(text,name,kind='(?:def|type)'):
    found=re.findall(r'^(?:@unsafe\n)?'+kind+' '+re.escape(name)+r'\b[\s\S]*?(?=\n\n|\Z)',text,re.M)
    assert len(found)==1,(name,len(found));return found[0].strip()

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--source',type=Path,required=True)
p.add_argument('--candidate',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve();source=a.source.resolve();candidate=a.candidate.resolve()
assert source.is_relative_to(ROOT) and candidate.is_relative_to(ROOT) and out.is_relative_to(ROOT/'selfhost/build/phase131') and not out.exists()
receipt=ROOT/'selfhost/build/phase131/laws-bucket-fusion01/report.json';proof=json.loads(receipt.read_text())
assert proof['complete'] and proof['independentlyChecked'] and not proof['opaqueDefinitions']
assert proof['lawNames']==['bucket_projection_distributes','bucket_scalar_fusion']
for item in proof['inputs']:assert pin(item['file'])==item
for row in proof['sourceClosure']:
    assert pin(row['origin']['file'])==row['origin'] and pin(row['snapshot']['file'])==row['snapshot']
assert pin(proof['elaboration']['file'])==proof['elaboration']
extracted=HERE/'bucket-production.bend';assert any(row['origin']==pin(extracted)for row in proof['sourceClosure'])
s=source.read_text();c=candidate.read_text();e=extracted.read_text();changes=[]
expected_law='law index_bucket:\n  for +ds: List<&2, KDef>\n  for +name: String\n  KDef'
assert decl(s,'index_bucket','law')==expected_law and decl(c,'index_bucket','law')==expected_law
for name in NAMES:
    original=decl(s,name);assert decl(c,name)==original,name
    selected=original.removeprefix('@unsafe\n')
    if name=='index_bucket':
        selected=selected.replace('def index_bucket(ds, name):','def index_bucket(+ds: List<&2,KDef>, +name: String) -> KDef:',1)
    assert decl(e,name)==selected,name
    changes.append(dict(name=name,removedUnsafe=original.startswith('@unsafe'),explicitForwardType=name=='index_bucket'))
assert decl(c,'p131sc_bucket').removeprefix('@unsafe\n')==decl(e,'p131sc_bucket')
out.mkdir(parents=True);(out/'method.py').write_bytes(Path(__file__).read_bytes())
r=dict(complete=True,targetsRun=False,method=pin(__file__),source=pin(source),candidate=pin(candidate),
       proofReceipt=pin(receipt),proofSource=pin(extracted),exactBodyDeclarations=NAMES+['p131sc_bucket'],
       extraction=changes+[dict(name='p131sc_bucket',removedUnsafe=True,explicitForwardType=False)],
       scope='All-list/all-key value fusion for the exact KDef variants and predicate. No full index_find/tree recursion, runtime ownership, machine code or performance theorem. Native qualification remains separate.')
(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(dict(complete=True,exactBodyDeclarations=r['exactBodyDeclarations'])))
