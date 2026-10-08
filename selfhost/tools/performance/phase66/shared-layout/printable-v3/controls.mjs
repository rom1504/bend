// Root-supervised actual-image controls; diagnostic clocks are not clean timing.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [baselineArg,candidateArg,outArg]=process.argv.slice(2);
assert(baselineArg&&candidateArg&&outArg,'BASELINE_ATTEMPT CANDIDATE_ATTEMPT FRESH_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const inputs=new Map(),hash=x=>createHash('sha256').update(x).digest('hex');
const pin=(file,expected)=>{file=fs.realpathSync(file);const bytes=fs.readFileSync(file),x={file,sha256:hash(bytes),bytes:bytes.length};if(expected)assert.equal(x.sha256,expected);if(inputs.has(file))assert.deepEqual(inputs.get(file),x);inputs.set(file,x);return x;};
const read=file=>JSON.parse(fs.readFileSync(pin(file).file,'utf8'));
const manifestFile=path.join(import.meta.dirname,'candidate.json'),manifest=read(manifestFile);
pin(import.meta.filename);pin(process.execPath);
const attempts={baseline:read(baselineArg),candidate:read(candidateArg)};
const source='src/back/js/validate.bend';
for(const [role,attempt] of Object.entries(attempts)){
 assert.equal(attempt.checked,true);assert.equal(attempt.artifactKind,'derived-b1');
 pin(attempt.api.file,attempt.api.sha256);
 const entry=attempt.snapshot.sources.filter(x=>x.frozen.file===path.join(attempt.snapshot.root,source));assert.equal(entry.length,1);
 pin(entry[0].frozen.file,role==='baseline'?manifest.baselineSource.sha256:manifest.candidate.sha256);
}
const suffix=String.raw`
export function phase66PrintableControls(deep=false){
 const call=(f,...xs)=>run_loop(f(...xs)),nil={$:'Nil'};
 const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
 const term=(tag,name='',kids=[],id=0,quant=0)=>call($kt$,tag,name,id,quant,list(kids));
 const adt=(name,args=[])=>term('ADT',name,args),absent=term('Absent'),typ=term('Typ');
 const all=(dom,body=absent,q=1,id=0)=>call($all$,q,'x'+id,id,dom,body);
 const def=(name,kind,ctors=[],value=absent,type=typ)=>({$:'KDef',name,kind,arity:0,templates:0,typ:type,value,ctors:list(ctors),native:false,unsafe:false});
 const ctor=(name,fields,ret=absent)=>{let t=ret;for(let i=fields.length-1;i>=0;i--){const f=fields[i];t=all(f.type??f,t,f.q??1,100+i);}return {...def(name,'Ctr',[],absent,t),arity:fields.length};};
 const data=(name,rows)=>def(name,'ADT',rows.map((xs,i)=>ctor(name+'.C'+i,xs)));
 const primitives=['U32','F32','Nat','Char','String','Array'].map(name=>data(name,[]));
 const u32=adt('U32'),fun=all(u32,u32),variable=term('Var','A',[],700);
 const parameterCtor=(name,fields)=>{let t=adt(name,[variable]);for(let i=fields.length-1;i>=0;i--)t=all(fields[i],t,1,800+i);return {...def(name+'.C','Ctr',[],absent,all(typ,t,0,700)),arity:fields.length,templates:1};};
 const box=def('Box','ADT',[parameterCtor('Box',[variable])]);
 const choice=def('Choice','ADT',[{...parameterCtor('Choice',[variable]),name:'ChooseLeft'},{...parameterCtor('Choice',[variable]),name:'ChooseRight'}]);
 const nested=n=>{let t=u32;while(n--)t=adt('Choice',[t]);return t;};
 const cases=[];
 const run=(name,extra,type,expected,seen=[],fuel=0)=>{
  const book=list([...extra,...primitives]),keys=list(seen),before=JSON.stringify([book,type,keys]);
  const start=performance.now(),actual=call($j_printable$,book,type,keys,fuel);
  if(actual!==expected)throw Error(name+': expected '+expected+', got '+JSON.stringify(actual));
  if(JSON.stringify([book,type,keys])!==before)throw Error(name+': inputs mutated');
  cases.push({name,expected,actual,pass:true,diagnosticMs:performance.now()-start});
 };
 run('u32',[],u32,true);run('open-equality',[],term('Eql','',[variable,variable]),true);
 run('function',[],fun,false);run('type',[],typ,false);run('unknown-adt',[],adt('Missing'),false);
 run('io-op',[data('IO.OP',[])],adt('IO.OP'),false);
 run('array-scalar',[],adt('Array',[u32]),true);run('array-function',[],adt('Array',[fun]),false);
 run('field-function',[data('A',[[fun]])],adt('A'),false);
 run('erased-field',[data('A',[[{type:u32,q:0}]])],adt('A'),false);
 run('dependent-field',[data('A',[[u32,term('Var','x100',[],100)]])],adt('A'),false);
 run('cycle-good',[data('A',[[adt('B')]]),data('B',[[adt('A')]])],adt('A'),true);
 run('cycle-then-function',[data('A',[[adt('B'),fun]]),data('B',[[adt('A')]])],adt('A'),false);
 run('cycle-then-erased',[data('A',[[adt('B'),{type:u32,q:0}]]),data('B',[[adt('A')]])],adt('A'),false);
 run('good-first-bad-second',[data('Root',[[adt('A')],[fun]]),data('A',[[u32]])],adt('Root'),false);
 run('distinct-parameters',[box,data('Root',[[adt('Box',[u32]),adt('Box',[fun])]])],adt('Root'),false);
 run('distinct-namespace-spelling',[data('child:Box',[[u32]]),data('child.Box',[[fun]]),data('Root',[[adt('child:Box'),adt('child.Box')]])],adt('Root'),false);
 run('array-after-cycle-bad',[data('A',[[adt('Array',[adt('A')]),fun]])],adt('A'),false);
 run('normalized-alias',[def('Alias','Def',[],u32)],term('Ref','Alias'),true);
 run('incoming-seen-preserved',[data('Bad',[[fun]])],adt('Bad'),true,[call($term_key$,adt('Bad'))]);
 run('incoming-seen-does-not-admit-io',[data('IO.OP',[])],adt('IO.OP'),false,[call($term_key$,adt('IO.OP'))]);
 run('incoming-fuel-unchanged',[box],adt('Box',[u32]),true,[],4294967295);
 for(const depth of [0,1,2,4,8,10])run('shared-choice-'+depth,[choice],nested(depth),true);
 if(deep)for(const depth of [16,24,32])run('shared-choice-'+depth,[choice],nested(depth),true);
 return cases;
}
`;
const reports={};
for(const [role,attempt] of Object.entries(attempts)){
 const original=fs.readFileSync(attempt.api.file,'utf8');
 for(const name of ['$j_printable$','$kt$','$all$','$term_key$','run_loop'])assert.equal(original.split('function '+name+'(').length,2,name);
 assert(!original.includes('phase66PrintableControls'));
 const derived=path.join(out,role+'-controls-api.mjs');fs.writeFileSync(derived,original+suffix,{flag:'wx'});
 assert.equal(fs.readFileSync(derived,'utf8').slice(0,-suffix.length),original);
 const loaded=await import(pathToFileURL(derived));
 const cases=loaded.phase66PrintableControls(role==='candidate');
 reports[role]={attempt:pin(role==='baseline'?baselineArg:candidateArg),api:pin(attempt.api.file,attempt.api.sha256),derivative:pin(derived),appendOnly:true,suffixSha256:hash(suffix),cases};
}
const candidateCases=new Map(reports.candidate.cases.map(x=>[x.name,x]));
for(const row of reports.baseline.cases)assert.equal(candidateCases.get(row.name).actual,row.actual,row.name);
for(const row of inputs.values())pin(row.file,row.sha256);
const report={kind:'phase66-shared-printability-controls',complete:true,pass:true,producer:pin(import.meta.filename),candidate:pin(manifestFile),roles:reports,agreements:reports.baseline.cases.length,additionalDepths:[16,24,32],inputs:[...inputs.values()],scope:'Actual baseline and selected checked-image private Boolean predicate, exact output agreement and independent explicit oracles, no input mutation. Deep candidate graph controls complement the two original source regression fixtures; no whole-module or clean timing claim.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,pass:true,agreements:report.agreements,candidateCases:reports.candidate.cases.length}));
