"""Scaffold quantity repair only; retain refused sources and exact originals."""
from pathlib import Path
import hashlib,json
H=Path(__file__).resolve().parent

def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
replacements={
'def p131sc_bucket(ds: List<&2,KDef>, +name: String)':'def p131sc_bucket(+ds: List<&2,KDef>, +name: String)',
'def p131sc_old(tree: KDef, name: String, hash: U32)':'def p131sc_old(+tree: KDef, +name: String, +hash: U32)',
'def p131sc_query(tree: KDef, name: String, hash: U32)':'def p131sc_query(+tree: KDef, +name: String, +hash: U32)',
'def p131sc_entry(name: String, capacity: U32)':'def p131sc_entry(+name: String, +capacity: U32)',
'def p131sc_legacy(kind: String, hash: U32, mask: U32, children: List<&2,KDef>)':'def p131sc_legacy(+kind: String, +hash: U32, +mask: U32, +children: List<&2,KDef>)',
'def p131sc_entries(n: Nat)':'def p131sc_entries(+n: Nat)'}
rows=[]
for row in json.loads((H/'cases-v02.json').read_text())['cases']:
 old=Path(row['source']['file']);text=old.read_text()
 for a,b in replacements.items():assert text.count(a)==1;text=text.replace(a,b)
 new=H/(old.stem.replace('-v02','')+'-v03.bend');new.write_text(text);rows.append(dict(row,source=pin(new)))
(H/'cases-v03.json').write_text(json.dumps(dict(complete=True,cases=rows),indent=2)+'\n')
(H/'repair-v03.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(H/'cases-v02.json')],replacements=replacements,cases=rows,scope='Quantity annotations only in new scaffolding/fused functions; extracted original source bodies, fused algorithm and frozen oracle unchanged. Initial affine refusal retained.'),indent=2)+'\n')
