#!/usr/bin/env python3
"""Data-only successors for explicitly admitted candidate B2; semantic oracles stay exact."""
import hashlib,json
from pathlib import Path
here=Path(__file__).resolve().parent
def identity(p):return {'file':str(p.resolve()),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
rows=[]
def write(parent,target,edits,marker=None):
    p=here/parent;t=here/target;old=p.read_text();text=old
    for before,after in edits:
        assert before in text,before
        text=text.replace(before,after)
    row={'parent':identity(p),'edits':[{'old':a,'new':b} for a,b in edits]}
    if marker:
        assert old[old.index(marker):]==text[text.index(marker):]
        row.update(oracleTailByteIdentical=True,oracleTailSha256=hashlib.sha256(old[old.index(marker):].encode()).hexdigest())
    with t.open('x')as f:f.write(text)
    row['output']=identity(t);rows.append(row)
write('self-check.mjs','self-check-v2.mjs',[
 ("'../bootstrap/setup.mjs'","'../bootstrap/setup-v2.mjs'"),
 ('emissionFile','pinsFile'),('B2_EMISSION_REPORT','B2_IMAGE_PINS'),
 ('emissionReport:identity(pinsFile)','imagePins:identity(pinsFile)'),
 ('report.emissionReport','report.imagePins'),
 ('3019','3012')])
write('acquire.mjs','acquire-v2.mjs',[
 ("'../bootstrap/setup.mjs'","'../bootstrap/setup-v2.mjs'"),
 ('emissionFile','pinsFile'),('B2_REPORT','B2_IMAGE_PINS')])
before=""" assert.equal(image.api.sha256,'ae5abd461c24f707747f37b187cedcecd86f5d3c727950f8f8a332fd9dca4091');
 assert.equal(image.emission.sha256,'654af8869256b3a9367f2ad98b5006c7791623790a25196a8a00fe8fb730531a');
 assert.equal(image.driverQualification.sha256,'69c556e987d3cbe4812911238b244b9613dbdf0dc3d63aac1f47a77f612f4f7e');"""
after=""" pin(image.pins);const binding=JSON.parse(fs.readFileSync(image.pins.file,'utf8'));
 assert.equal(binding.kind,'phase56-direct-image-pins');
 for(const key of ['producer','plan','attempt','emission','comparison','source','b1','b2','runtime','rootsReference'])pin(binding[key]);
 assert.deepEqual(image.emission,binding.emission);assert.deepEqual(image.driverQualification,binding.comparison);
 assert.equal(image.api.sha256,binding.b2.sha256);assert.deepEqual(image.source,binding.source);
 assert.deepEqual(image.checkedSubject,binding.attempt);assert.equal(image.directRuntime.sha256,binding.runtime.sha256);
 const plan=JSON.parse(fs.readFileSync(binding.plan.file,'utf8'));assert.equal(plan.kind,'phase56-candidate-image-plan');assert.deepEqual(plan.attempt,binding.attempt);
 for(const item of [...plan.inputs,...plan.configs])pin(item);
 for(const derivative of plan.derivations){let text=fs.readFileSync(pin(derivative.parent).file,'utf8');for(const edit of derivative.edits){assert(text.includes(edit.old));text=text.split(edit.old).join(edit.new);}assert.equal(fs.readFileSync(pin(derivative.output).file,'utf8'),text);}
 const comparison=JSON.parse(fs.readFileSync(binding.comparison.file,'utf8'));assert(comparison.complete&&comparison.pass);assert.equal(comparison.kind,'phase55-direct-compiler-driver-comparison');assert.equal(comparison.observations,8);
 const driverReports=[comparison.source,comparison.direct].map(row=>JSON.parse(fs.readFileSync(pin(row).file,'utf8')));
 for(const [i,r]of driverReports.entries()){assert(r.complete&&r.pass);assert.equal(r.kind,'phase55-direct-compiler-driver');assert.equal(r.role,i?'direct':'source');assert.deepEqual(r.emission,binding.emission);assert.equal(r.api.sha256,i?binding.b2.sha256:binding.b1.sha256);assert.equal(r.observations.length,8);for(const row of r.inputs)pin(row);for(const row of r.copies){pin(row.before);pin(row.after);}for(const row of r.outputs??[])pin(row);}
 assert.deepEqual(driverReports[0].config,driverReports[1].config);assert.deepEqual(driverReports[0].observations.map(x=>({id:x.id,value:x.value})),driverReports[1].observations.map(x=>({id:x.id,value:x.value})));"""
write('image-provenance.mjs','image-provenance-v2.mjs',[(before,after),
 ("assert.deepEqual(emission.generator,record.generator);","assert.deepEqual(emission.generator,record.generator);assert.deepEqual(emission.generator.api,binding.b1);assert.deepEqual(emission.config,plan.configs[1]);assert.deepEqual(record.roots,binding.roots);assert.deepEqual(binding.roots,JSON.parse(fs.readFileSync(binding.rootsReference.file,'utf8')).roots);for(const r of driverReports){assert.deepEqual(r.subject,emission.subject);assert.deepEqual(r.generator,emission.generator);}"),
 ("'driverQualification','checkedSubject']","'driverQualification','checkedSubject','pins']")])
for kind in ['source','numeric','composition','overapplication']:
    write(kind+'-controls.mjs',kind+'-controls-v2.mjs',[("'./image-provenance.mjs'","'./image-provenance-v2.mjs'")],
          '  for(const test of c.tests){' if kind=='source' else ' function execute(')
result={'kind':'phase56-explicit-image-controller-derivation','complete':True,'targetExecuted':False,'producer':identity(Path(__file__)),'setup':identity(here.parent/'bootstrap/setup-v2.mjs'),'rows':rows,
 'scope':'Explicit candidate image pins replace fixed historical image admission; self-check keeps its exact 3012-definition candidate trust oracle. All four semantic execution/oracle tails are unchanged.'}
with (here/'controls-derivation-v2.json').open('x')as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps({'targetExecuted':False,'outputs':len(rows)}))
