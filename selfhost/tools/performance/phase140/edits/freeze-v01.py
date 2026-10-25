"""Freeze three substantive compiler-policy edits before their performance runs.

This is source-fixture packaging, not a parser or an incremental dependency rule.
The compiler computes the actual checking cut from the requested owner name.
"""
import argparse, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase140')
selection=ROOT/'implementation/phase137/candidate.json';sel=json.loads(selection.read_text());assert sel['nativeQualified']
src=Path(sel['source']['file']);assert pin(src)==sel['source'];text=src.read_text()
edits=[('inline-policy','p113i_eligible','U32.is_le(p113i_size(body),512)','U32.is_le(p113i_size(body),480)'),
 ('continuation-policy','p114h_plan','U32.is_le(p112f_size(body),512)','U32.is_le(p112f_size(body),480)'),
 ('product-policy','p131rg_width','U32.is_le(width,16)','U32.is_le(width,15)')]
out.mkdir(parents=True);rows=[]
for name,owner,needle,replacement in edits:
 start=text.index('def '+owner+'(');at=text.index(needle,start);end=text.find('\ndef ',start+1)
 assert at<end and len(needle)==len(replacement)
 changed=text[:at]+replacement+text[at+len(needle):]
 dest=out/(name+'.bend');dest.write_text(changed)
 rows.append(dict(name=name,owner=owner,source=pin(dest),needle=needle,replacement=replacement,
  declarationUtf16Offset=len(text[:start].encode('utf-16-le'))//2,
  editUtf16Offset=len(text[:at].encode('utf-16-le'))//2,
  line=text[:start].count('\n')+1,
  admittedClass='same-width numeric policy edit; parser/checker headers and binding shape still validated by compiler'))
r=dict(kind='phase140-frozen-real-compiler-edit-suite',complete=True,targetsRun=False,parent=sel['source'],cases=rows,
 scope='Frozen before candidate measurements. Changes compiler optimization policies, not benchmark repetition counts. Each B compares with its own fresh build. These are later compiler definitions; do not generalize their prefix savings to early edits.',inputs=[pin(__file__),pin(selection),sel['source']])
(out/'manifest.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(complete=True,cases=[dict(name=x['name'],line=x['line'])for x in rows])))
