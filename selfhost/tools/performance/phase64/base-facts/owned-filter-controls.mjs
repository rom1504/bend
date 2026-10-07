// Root executes this only after applying the separate owned-filter candidate.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';

const [attemptArg,outArg]=process.argv.slice(2);
assert(attemptArg&&outArg);
const root=path.resolve(import.meta.dirname,'../../../..');
const out=path.resolve(outArg),allowed=path.join(root,'build/phase64')+path.sep;
assert(out.startsWith(allowed)&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});
const hash=b=>createHash('sha256').update(b).digest('hex');
const inputs=new Map(),report={kind:'phase64-owned-filter-controls',complete:false,pass:false,rows:[],inputs:[]};
const pin=(file,want)=>{const bytes=fs.readFileSync(file),r={file:fs.realpathSync(file),sha256:hash(bytes),bytes:bytes.length};if(want)assert.equal(r.sha256,want.sha256);if(inputs.has(r.file))assert.deepEqual(r,inputs.get(r.file));inputs.set(r.file,r);return r;};
const save=()=>{report.inputs=[...inputs.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};
save();
try {
  pin(import.meta.filename);pin(process.execPath);
  const attempt=fs.realpathSync(attemptArg),m=await verifyAttempt(attempt);
  assert(m.checked&&m.config.strictExact);
  pin(path.join(attempt,'attempt.json'));pin(m.api.file,m.api);pin(m.runtime.file,m.runtime);pin(m.base.file,m.base);pin(m.node.file,m.node);
  assert.equal(pin(process.execPath).sha256,m.node.sha256);
  const sourceFile=path.join(m.snapshot.root,'src/driver/api.bend');pin(sourceFile);
  assert(fs.readFileSync(sourceFile,'utf8').includes('def driver_owned_candidates('),'candidate not applied');
  const reserved=['IO','Sigma','String','Word.Con','IO.OP','Result','Maybe','Bool','Unit','Nat','U32','F32','Char','Array'];
  const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
  const original=fs.readFileSync(m.api.file,'utf8');
  for(const name of ['run_loop','$driver_emit_owned$','$driver_owned_names$','$driver_owned_candidates$','$driver_foreign_names$'])assert(original.includes('function '+name+'('),name);
  const suffix='\nexport const phase64Owned={actual:b=>run_loop($driver_emit_owned$(b)),candidates:b=>run_loop($driver_owned_candidates$(b)),original:b=>{const e=run_loop($driver_owned_names$(b,'+JSON.stringify(list(reserved))+'));return e||run_loop($driver_foreign_names$(b,b));}};\n';
  const derivative=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(derivative,original+suffix,{flag:'wx'});pin(derivative);
  assert.equal(fs.readFileSync(derivative,'utf8').slice(0,-suffix.length),original);
  const module=await import(pathToFileURL(derivative));assert.equal(module.G,undefined,'controls require checked named-layout B1');
  const Q=module.phase64Owned;
  const term=(tag,name='',kids=[])=>({$:'KTerm',tag,name,id:0,quant:0,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
  const def=(name,native=false,kind='Def',value=term('Absent'),ctors=[])=>({$:'KDef',name,kind,arity:0,templates:0,typ:term('Typ'),value,ctors:list(ctors),native,unsafe:false});
  const freeze=root=>{const todo=[root],seen=new Set();while(todo.length){const x=todo.pop();if(x===null||typeof x!=='object'||seen.has(x))continue;seen.add(x);Object.freeze(x);todo.push(...Object.values(x));}return root;};
  const owned=name=>name+' is a name the compiler encodes itself: name yours apart';
  const collision=name=>name+' names both a constructor and a foreign def: name one apart';
  const cases=[['empty',[],''],['unreserved',[def('user.fn')],'']];
  for(const name of reserved){
    cases.push(['owned-'+name,[def(name)],owned(name)],['native-'+name,[def(name,true)],'']);
    cases.push(['duplicate-native-first-'+name,[def(name,true),def(name)],owned(name)]);
    cases.push(['duplicate-native-last-'+name,[def(name),def(name,true)],owned(name)]);
  }
  cases.push(['fixed-name-precedence',reserved.toReversed().map(n=>def(n)),owned('IO')]);
  for(const kind of ['Def','ADT','Ctr','Absent','Unrecognized'])cases.push(['kind-independent-'+kind,[def('Nat',false,kind)],owned('Nat')]);
  const foreignA=def('foreign.a',true,'Def',term('Foreign','host.js'));
  const foreignB=def('foreign.b',false,'Def',term('Ann','',[term('Foreign','host.js'),term('Typ')]));
  const owner=def('User.Type',false,'ADT',term('Absent'),[def('foreign.a',false,'Ctr'),def('foreign.b',false,'Ctr')]);
  cases.push(['native-foreign-still-checked',[foreignA,owner],collision('foreign.a')]);
  cases.push(['foreign-order-a',[foreignA,foreignB,owner],collision('foreign.a')]);
  cases.push(['foreign-order-b',[foreignB,foreignA,owner],collision('foreign.b')]);
  cases.push(['owned-before-foreign',[foreignA,owner,def('Array'),def('IO')],owned('IO')]);
  cases.push(['native-prefix',[...Array.from({length:512},(_,i)=>def('native.'+i,true)),def('Array')],owned('Array')]);
  let seed=640017;
  const next=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed;};
  for(let n=0;n<512;n++){
    const ds=[],length=next()%65;
    for(let i=0;i<length;i++){const at=next()%20,name=at<reserved.length?reserved[at]:'user.'+(at-reserved.length);ds.push(def(name,(next()&3)!==0,['Def','ADT','Ctr'][next()%3]));}
    cases.push(['generated-'+n,ds,null]);
  }
  for(const [id,defs,expected] of cases){
    const book=freeze(list(defs)),before=JSON.stringify(book),actual=Q.actual(book),old=Q.original(book);
    assert.equal(actual,old,id+' original policy');if(expected!==null)assert.equal(actual,expected,id+' fixed oracle');
    assert.deepEqual(Q.candidates(book),list(defs.filter(d=>!d.native)),id+' exact filtered order/duplicates');
    assert.equal(JSON.stringify(book),before,id+' immutable input');
    report.rows.push({id,pass:true,result:actual,definitions:defs.length});
  }
  for(const r of inputs.values())pin(r.file,r);
  report.count=report.rows.length;report.complete=true;report.pass=true;save();
} catch(error) {
  report.error={name:error.name,message:error.message,stack:error.stack};save();throw error;
}
