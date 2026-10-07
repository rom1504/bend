#!/usr/bin/env python3
"""Data-only framed81 successors of the already frozen Phase61 qualification package."""
import argparse,ast,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];RAW=ROOT/'selfhost/build/phase61';HERE=Path(__file__).resolve().parent
PARENT=RAW/'methods01/methods.json';PARENT_SHA='43de57e8804e4d46468cd62ab4c617b43a8c8604ec6663f0571f25aee23ba4d3'
SETUP=HERE/'setup-frame02.mjs';SETUP_SHA='c8cc7bb20bc11486a874ee94f71395792c060d00c87e3e2f0696d37344798ac4'
def pin(file):
 file=Path(file).resolve(strict=True);return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 out=a.out.resolve();assert out.parent==RAW.resolve() and not out.exists()
 assert pin(PARENT)['sha256']==PARENT_SHA;parent=json.loads(PARENT.read_text());assert parent['complete'] and not parent['targetsExecuted']
 assert pin(SETUP)['sha256']==SETUP_SHA
 inputs=[pin(__file__),pin(PARENT),pin(SETUP)];rows=[]
 for row in parent['rows']:
  source=Path(row['output']['file']);assert pin(source)==row['output'];relative=row['relative'];edits=[]
  if relative=='bootstrap/setup.mjs':source=SETUP
  text=source.read_text();original=text
  def change(old,new):
   nonlocal text
   assert text.count(old)==1,(relative,old,text.count(old));text=text.replace(old,new);edits.append(dict(old=old,new=new))
  if relative=='qualification/self-check.mjs':
   change("report.roots=roots;assert.equal(roots.length,77);", "report.roots=roots;assert.deepEqual(roots,JSON.parse(fs.readFileSync(subject.bootstrap.file,'utf8')).exports);")
  if relative=='qualification/image-provenance.mjs':
   change("assert.equal(record.roots.length,77);", "assert.equal(new Set(record.roots).size,record.roots.length);")
   change("const subject=JSON.parse(fs.readFileSync(image.checkedSubject.file,'utf8'));assert(subject.checked);", "const subject=JSON.parse(fs.readFileSync(image.checkedSubject.file,'utf8'));assert(subject.checked);\n pin(subject.bootstrapReport);const bootstrap=JSON.parse(fs.readFileSync(subject.bootstrapReport.file,'utf8'));\n assert.deepEqual(record.roots,bootstrap.exports);\n const rootReference=JSON.parse(fs.readFileSync(binding.rootsReference.file,'utf8'));\n assert.equal(rootReference.kind,'phase61-checked-bootstrap-export-reference');assert.deepEqual(rootReference.attempt,binding.attempt);\n assert.equal(rootReference.bootstrap.sha256,subject.bootstrapReport.sha256);pin(rootReference.bootstrap);\n const added=['base_prefix_prepare','check_program_diagnostic_seed','f_fresh_prefix_prepare','f_graph_trace_from_prefix'];\n pin(rootReference.historical);const oldRoots=JSON.parse(fs.readFileSync(rootReference.historical.file,'utf8')).roots;\n assert.deepEqual(record.roots.filter(x=>!added.includes(x)),oldRoots);\n assert.deepEqual([...record.roots].sort(),[...oldRoots,...added].sort());")
  if relative=='qualification/checked-image.mjs':
   change("const c=JSON.parse(fs.readFileSync(row.file,'utf8'));", "const framed=row.file.endsWith('-frame1.json');assert(!framed||typeof D.decodeBaseCacheFrame==='function');const c=framed?D.decodeBaseCacheFrame(fs.readFileSync(row.file)):JSON.parse(fs.readFileSync(row.file,'utf8'));if(framed)assert([4,6].includes(c.version));")
  if relative=='bootstrap/reproduce.mjs':
   change('and 77-root closure.', 'and actual checked-export closure.')
  replay=original
  for edit in edits:assert edit['old'] in replay;replay=replay.replace(edit['old'],edit['new'])
  assert replay==text
  if relative.endswith('.py'):ast.parse(text,filename=relative)
  inputs.append(pin(source));rows.append(dict(relative=relative,parent=pin(source),edits=edits,text=text))
 out.mkdir(parents=True)
 for row in rows:
  dest=out/row['relative'];dest.parent.mkdir(parents=True,exist_ok=True)
  with dest.open('x')as f:f.write(row.pop('text'))
  row['output']=pin(dest)
 for item in inputs:assert pin(item['file'])==item
 result=dict(kind='phase61-framed81-validation-methods',complete=True,targetsExecuted=False,producer=inputs[0],parent=pin(PARENT),baseline=parent['baseline'],inputs=inputs,rows=rows,
  scope='Same gate commands and oracle bodies. Reviewed setup-frame02 stages actual81 images; remaining self-check/image receipts bind actual checked exports; private checked staging decodes framed caches. Final-plan-frame01 uses external reviewed bootstrap-v4; the copied old bootstrap planner/final-orchestration are unused preserved method entries.')
 for dest in [out/'methods.json',out/'qualification/b2-methods-derivation.json']:
  with dest.open('x')as f:json.dump(result,f,indent=2);f.write('\n')
 print(json.dumps(dict(methods=pin(out/'methods.json'),files=len(rows),targetsExecuted=False)))
if __name__=='__main__':main()
