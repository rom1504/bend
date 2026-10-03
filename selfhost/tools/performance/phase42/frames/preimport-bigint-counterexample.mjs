// Root-run cheap falsifier. Each role/scenario uses a fresh process so module
// import captures the same preinstalled BigInt hook. No compiler/timing work.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';import {pathToFileURL} from 'node:url';import {createHash} from 'node:crypto';
const sha=x=>createHash('sha256').update(x).digest('hex');
if(process.argv[2]==='--child'){
 const[moduleArg,mode,outArg]=process.argv.slice(3),nativeBigInt=globalThis.BigInt;let callback=null,armed=false;
 function wrappedBigInt(...args){if(armed&&callback){armed=false;callback();}return nativeBigInt(...args);}
 for(const key of Reflect.ownKeys(nativeBigInt))Object.defineProperty(wrappedBigInt,key,Object.getOwnPropertyDescriptor(nativeBigInt,key));
 Object.setPrototypeOf(wrappedBigInt,Object.getPrototypeOf(nativeBigInt));globalThis.BigInt=wrappedBigInt;
 let mod;try{mod=await import(pathToFileURL(moduleArg));}finally{globalThis.BigInt=wrappedBigInt;}
 const initial=mod.p42HostState(),events=[],inner=[],external=[],mutations=[];let saved;
 const root=(()=>{function alien(tag,fields,label){let reads=0;return new Proxy({$:tag,a:fields},{get(target,key,receiver){external.push(label+'.'+String(key));if(key==='a'){++reads;const a=fields.slice();if(tag==='SNode'&&label==='right')a[1]=13+reads;return a;}return Reflect.get(target,key,receiver);}});}
 const l=alien('SEmpty',[],'left'),rl=alien('SEmpty',[],'right.left'),rr=alien('SEmpty',[],'right.right');return alien('SNode',[l,7,alien('SNode',[rl,13,rr],'right')],'root');})();
 callback=()=>{events.push({event:'BigInt.callback',state:mod.p42HostState()});
  if(mode==='reentry'){let value,error;try{value=mod.default['sequence.fold'](root,5);}catch(e){error=e.message;}inner.push({value,error,state:mod.p42HostState()});}
  else if(mode==='mutation'){saved=Object.getOwnPropertyDescriptor(mod.G['sequence.fold'],'code');const original=saved.value;Object.defineProperty(mod.G['sequence.fold'],'code',{...saved,value:function(...args){mutations.push({event:'mutated.fold.code',proof:mod.p42HostState().proofActive});return original.apply(this,args);}});}
  else throw Error('unknown scenario');
 };
 armed=true;let value,error;try{value=mod.default['sequence.right'](3,11);}catch(e){error=e.message;}finally{if(saved)Object.defineProperty(mod.G['sequence.fold'],'code',saved);globalThis.BigInt=nativeBigInt;}
 const result={mode,initial,value,error,events,inner,external,mutations,final:mod.p42HostState()};
 fs.writeFileSync(outArg,JSON.stringify(result,null,2)+'\n',{flag:'wx'});process.exit(0);
}
const[baselineArg,candidateArg,outArg]=process.argv.slice(2);assert(baselineArg&&candidateArg&&outArg,'usage: preimport-bigint-counterexample.mjs CHECKED07_SEQUENCE CHECKED11_SEQUENCE NEW_OUT');
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);const pm={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(pm,pm.exports);
const inputs=[],modules=[];let firstReceipt;
for(const[role,inputArg]of[['baseline',baselineArg],['candidate',candidateArg]]){
 const input=fs.realpathSync(inputArg),source=fs.readFileSync(input,'utf8'),receipt=JSON.parse(fs.readFileSync(input+'.json'));assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.output.sha256,sha(source));if(!firstReceipt)firstReceipt=receipt;else assert.equal(receipt.input.sha256,firstReceipt.input.sha256,'same frozen sequential source');
 const ast=pm.exports.parse(source,{ecmaVersion:'latest',sourceType:'module'}),workers=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.endsWith('$tree'));
 const edits=workers.map(n=>({at:n.body.start+1,text:'$p42HostWorkers['+JSON.stringify(n.id.name)+']=($p42HostWorkers['+JSON.stringify(n.id.name)+']||0)+1;'}));let diagnostic=source;
 for(const e of edits.sort((a,b)=>b.at-a.at))diagnostic=diagnostic.slice(0,e.at)+e.text+diagnostic.slice(e.at);
 diagnostic+='\nconst $p42HostWorkers=Object.create(null);export function p42HostState(){return {proofActive:regionProof!==null,hostGuard:regionHostGuard(),workers:{...$p42HostWorkers}};}\n';pm.exports.parse(diagnostic,{ecmaVersion:'latest',sourceType:'module'});
 const modulePath=path.join(out,role+'.mjs');fs.writeFileSync(modulePath,diagnostic,{flag:'wx'});modules.push({role,path:modulePath,sha256:sha(diagnostic),workers:workers.map(n=>n.id.name)});inputs.push({role,path:input,sha256:sha(source),receiptSha256:sha(fs.readFileSync(input+'.json'))});
}
const observations=[];
for(const mode of['reentry','mutation'])for(const row of modules){const file=path.join(out,row.role+'-'+mode+'.json');const r=spawnSync(process.execPath,['--max-old-space-size=512',import.meta.filename,'--child',row.path,mode,file],{timeout:4000,encoding:'utf8'});assert.equal(r.status,0,JSON.stringify({status:r.status,error:r.error?.message,stderr:r.stderr}));observations.push({role:row.role,...JSON.parse(fs.readFileSync(file))});}
const comparisons=[];for(const mode of['reentry','mutation']){const a=observations.find(x=>x.role==='baseline'&&x.mode===mode),b=observations.find(x=>x.role==='candidate'&&x.mode===mode);const semantic=x=>({value:x.value,error:x.error,inner:x.inner.map(y=>({value:y.value,error:y.error})),external:x.external,mutations:x.mutations.map(y=>y.event)});comparisons.push({mode,equal:JSON.stringify(semantic(a))===JSON.stringify(semantic(b)),baseline:semantic(a),candidate:semantic(b)});}
const viable=observations.every(x=>x.initial.hostGuard===true&&x.initial.proofActive===false&&x.events.length===1);const report={viable,kind:'phase42-preimport-BigInt-owned-reentry-falsifier',complete:true,checkedInputs:true,promotion:!viable?'harness-invalid':comparisons.every(x=>x.equal)?'not-falsified-by-these-two-scenarios':'counterexample-promotion-blocked',producerSha256:sha(fs.readFileSync(import.meta.filename)),node:process.version,inputs,modules,observations,comparisons};fs.copyFileSync(import.meta.filename,path.join(out,'consumed-counterexample.mjs'));fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:true,viable,promotion:report.promotion,comparisons:comparisons.map(x=>({mode:x.mode,equal:x.equal})),out}));
