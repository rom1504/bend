#!/usr/bin/env python3
"""Data-only framed-cache successor; measured request windows are unchanged."""
import argparse, ast, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];RAW=ROOT/'selfhost/build/phase61'
parent=RAW/'latency-method02'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(RAW.resolve()) and not out.exists()
def identity(file):
 file=Path(file).resolve(strict=True);b=file.read_bytes();return dict(file=str(file),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
pins={'setup.mjs':'c14cf7172a856d8b72f550de4f27e3c493058522ad6f9e5b69bc4eeb8fb4165a',
 'profile.mjs':'6bbb65cf02b47a06a3193ca595f8fcdcd0ca73c408233ac28ee1dfb183348068',
 'worker.mjs':'e3e2684cedddec4321e9f56d99e2bef299a8d9b2219e2b55ad9883c0df92d87f',
 'run.py':'f5c9fa94cf45f6d3413074ac0ad4095207411faf1de7e421561cdc15e9617df1'}
outputs={};rows=[]
for name,sha in pins.items():
 before=identity(parent/name);assert before['sha256']==sha;text=(parent/name).read_text();edits=[]
 def edit(old,new,count=1):
  global text
  assert text.count(old)==count,(name,old[:100],text.count(old),count)
  text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
 if text.count(str(parent)):edit(str(parent),str(out),text.count(str(parent)))
 if name=='setup.mjs':
  edit("      const c=JSON.parse(fs.readFileSync(item.file,'utf8'));", """      const bytes=fs.readFileSync(item.file),framed=path.basename(item.file).endsWith('-frame1.json');
      // The exact selected snapshot driver owns its new disk format. It checks
      // raw payload SHA before parsing; do not reinterpret it as a canonical JSON digest.
      if(framed)assert.equal(typeof D.decodeBaseCacheFrame,'function','Framed cache requires its matching driver decoder');
      const c=framed?D.decodeBaseCacheFrame(bytes):JSON.parse(bytes.toString('utf8'));
      assert.ok(c&&typeof c==='object'&&!Array.isArray(c));""")
  edit("      assert.equal(c.bookSha256,hash(Buffer.from(JSON.stringify(c.book))));", "      if(!framed)assert.equal(c.bookSha256,hash(Buffer.from(JSON.stringify(c.book))));")
 if name=='run.py':ast.parse(text)
 outputs[name]=text;rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in outputs.items():(out/name).write_text(text)
report=dict(kind='phase61-candidate-fast-loop-method',complete=True,dataOnly=True,targetExecuted=False,
 producer=identity(__file__),parentDerivation=identity(parent/'derivation.json'),derivations=rows,
 scope='Only excluded preparation verification decodes -frame1.json with the actual staged driver export. Legacy JSON canonical digest and compiler/Base/path/producer metadata gates remain. Invalid/malformed frame throws; no fallback to JSON. First/later/profile windows and role selection unchanged. Does not implement or qualify a cache/checkpoint optimization.')
report['pass']=True;(out/'derivation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({name:identity(out/name) for name in [*outputs,'derivation.json']}))
