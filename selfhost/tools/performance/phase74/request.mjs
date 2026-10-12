// Diagnostic requests against immutable selected images and full C oracles.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [planFile,roleName,caseName,out,override]=process.argv.slice(2);
const plan=JSON.parse(fs.readFileSync(planFile,'utf8')),role=plan.roles[roleName];
const hash=b=>createHash('sha256').update(b).digest('hex');
const pin=file=>({file,sha256:hash(fs.readFileSync(file))});
fs.mkdirSync(out,{recursive:false});
const report={complete:false,pass:false,role:roleName,case:caseName,plan:pin(planFile),
  method:pin(import.meta.filename),mode:override?'counter-only':'first-plus-five-warm',records:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
try {
  for(const p of plan.inputs)assert.equal(pin(p.file).sha256,p.sha256,p.file);
  let D,B,C;
  if(roleName==='typescript') {
    B=await import(pathToFileURL(role.bend.file));C=await import(pathToFileURL(role.compiler.file));
  } else {
    process.env.BEND_TYPED_API=override??role.api.file;
    process.env.BEND_TYPED_RUNTIME=role.runtime.file;process.env.BEND_BASE=role.base.file;
    const prep=JSON.parse(fs.readFileSync(role.preparation,'utf8'));
    assert(prep.complete&&prep.pass);report.preparation=pin(role.preparation);
    D=await import(pathToFileURL(role.driver.file));await D.loadApi();
    report.executedApi=pin(override??role.api.file);
  }
  const input=plan.cases[caseName],expected=fs.readFileSync(input.expected[roleName].file,'utf8');
  if(override)globalThis.__p74Start();
  for(let round=0;round<(override?1:6);round++) {
    const start=performance.now();let code;
    if(roleName==='typescript') {
      const book=B.book_nil();await B.book_load(book,input.input.file,'',new Map());
      B.book_valid(book);assert.equal(book.hols,0);code=C.compile_book(book);
    } else {
      const r=await D.inspect(input.input.file,{mode:'native',withReport:true});
      assert.equal(r.status,'ok');assert.equal(r.checked,true);code=r.code;
    }
    const requestMs=performance.now()-start;assert.equal(code,expected);
    report.records.push({round,requestMs,exactC:true,sha256:hash(code)});save();
  }
  if(override)report.counters=globalThis.__p74Results();
  for(const p of plan.inputs)assert.equal(pin(p.file).sha256,p.sha256,p.file);
  report.complete=report.pass=true;
} catch(e) {report.error=e.stack;process.exitCode=1;}
save();console.log(JSON.stringify({role:roleName,case:caseName,pass:report.pass,
  requestMs:report.records.map(r=>Math.round(r.requestMs)),error:report.error}));
