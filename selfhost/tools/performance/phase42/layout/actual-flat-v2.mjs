// Clone an ACTUAL checked private graph. Original public bodies/workers unchanged.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
const[sourceArg,outArg]=process.argv.slice(2);assert(sourceArg&&outArg);
const sha=x=>createHash('sha256').update(x).digest('hex'),identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const source=fs.readFileSync(sourceArg,'utf8'),receipt=JSON.parse(fs.readFileSync(sourceArg+'.json')),out=path.resolve(outArg);
assert.equal(receipt.complete,true);assert.equal(receipt.observation.checked,true);assert.equal(receipt.observation.status,'ok');assert.equal(receipt.output.sha256,sha(source));assert.equal(receipt.compiler.upstreamCommit,'018751270e800bc222a93dad7f257083ee53a5f7');assert(!fs.existsSync(out));
const native=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],am={exports:{}};new Function('module','exports',native)(am,am.exports);const parse=s=>am.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function walk(n,fn){if(!n||typeof n!=='object')return;fn(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,fn));else if(v&&typeof v==='object')walk(v,fn);}}
const ast=parse(source),workers=ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name.endsWith('$tree'));assert.equal(workers.length,5);
for(const w of workers){const body=source.slice(w.start,w.end);assert(!/callOwned\(|invokeExact\(|regionProofCovers\(|get\(G|WeakSet/.test(body),'whole actual graph must be closed');}
const rootAt=source.indexOf('G["bench"]=');assert(rootAt>0);
const rootHelpers=[];walk(ast,n=>{if(n.type==='FunctionDeclaration'&&n.start>rootAt&&n.id.name.includes('115_116_97_116_95_111_117_116'))rootHelpers.push(n);});assert.equal(rootHelpers.length,1);
const statOut=rootHelpers[0],members=[...workers,statOut],names=new Map(members.map(n=>[n.id.name,'$P42flat'+n.id.name]));
const guards=['bench','bsort','warp','warp_zip','warp_leaf','Bool.xor','warp_leaf.go','flow','warp_node','key','prng','scan','stat_join','stat_join.go','stat_out'];
const encoded=name=>'$R'+Array.from(name,c=>'_'+c.codePointAt(0)).join('')+'$tree',clone=name=>names.get(encoded(name));
let constructors=0,slots=0;
function fieldStarts(fields){const token=am.exports.tokenizer(source.slice(fields.start,fields.end),{ecmaVersion:'latest'}),starts=[fields.start+1];let depth=0;for(;;){const t=token.getToken(),label=t.type.label;if(label==='eof')break;if(['[','(','{'].includes(label))++depth;else if([']',')','}'].includes(label))--depth;else if(label===','&&depth===1&&starts.length<fields.elements.length)starts.push(fields.start+t.end);}assert.equal(starts.length,fields.elements.length);return starts;}
function emitMember(n,flat){let text=source.slice(n.start,n.end),edits=[];
 walk(n,x=>{
  if(x.type==='Identifier'&&names.has(x.name))edits.push({start:x.start,end:x.end,text:names.get(x.name)});
  if(x.type==='CallExpression'&&x.callee.name==='ctor'&&['Leaf','Node','St'].includes(x.arguments[0]?.value)){
   const k=x.arguments[0].value,fields=x.arguments[1];assert.equal(fields.type,'ArrayExpression');assert(fields.elements.every(Boolean));++constructors;
   if(flat){edits.push({start:x.start,end:fields.start+1,text:'({$:'+JSON.stringify(k)+',_0:'});fieldStarts(fields).slice(1).forEach((at,i)=>edits.push({start:at,end:at,text:'_'+(i+1)+':'}));edits.push({start:fields.end-1,end:x.end,text:'})'});}
   else{edits.push({start:x.start,end:fields.start,text:'({$:'+JSON.stringify(k)+',a:'});edits.push({start:fields.end,end:x.end,text:'})'});}
  }
  if(flat&&x.type==='MemberExpression'&&x.computed&&Number.isInteger(x.property.value)&&x.object.type==='MemberExpression'&&x.object.property.name==='a'){
   assert.equal(x.object.object.type,'Identifier');edits.push({start:x.start,end:x.end,text:source.slice(x.object.object.start,x.object.object.end)+'._'+x.property.value});++slots;
  }
  if(flat&&x.type==='MemberExpression'&&x.computed&&Number.isInteger(x.property.value)&&x.object.name==='$unpack')edits.push({start:x.start,end:x.end,text:'$p0._'+x.property.value});
  if(flat&&x.type==='VariableDeclaration'&&x.declarations.length===1&&x.declarations[0].id.name==='$unpack')edits.push({start:x.start,end:x.end,text:''});
 });
 let boundary=n.end;for(const e of edits.sort((a,b)=>b.start-a.start||b.end-a.end)){assert(e.end<=boundary,'overlapping edit');text=text.slice(0,e.start-n.start)+e.text+text.slice(e.end-n.start);boundary=e.start;}return text;
}
const tryAt=source.indexOf('try{const x3534=$s0;const x3535=$s1;return ',rootAt),finallyAt=source.indexOf('}finally{regionProofClose($previousProof);}',tryAt);assert(tryAt>rootAt&&finallyAt>tryAt);
const callBody=source.slice(tryAt+'try{'.length,finallyAt).replaceAll('$s0','d').replaceAll('$s1','x');
let privateCallBody=callBody;for(const[a,b]of names)privateCallBody=privateCallBody.replaceAll(a,b);
const originalBenchPrefix=source.slice(0,tryAt),originalBenchSuffix=source.slice(finallyAt);
const basicDiagnostic=`export function p42ProofActive(){return regionProof!==null;}`;
const originalDiagnostic=basicDiagnostic+`export function p42Complete(d,x,s=false){if(!Number.isInteger(d)||d<0||d>12||!Number.isInteger(x)||x<0||x>4294967295||typeof s!=='boolean')throw Error('diagnostic domain');if(!regionHostGuard()||!localGuard(${JSON.stringify(guards)}))throw Error('diagnostic guard');const old=regionProofOpen(${JSON.stringify(guards)});try{const tree=${encoded('bsort')}(BigInt(d),s,x);return{tree,stat:${encoded('scan')}(tree)};}finally{regionProofClose(old);}}`;
function diagnostic(flat){const get=(i)=>flat?'t._'+i:'t.a['+i+']';return basicDiagnostic+`
export function p42Complete(d,x,s=false){if(!Number.isInteger(d)||d<0||d>12||!Number.isInteger(x)||x<0||x>4294967295||typeof s!=='boolean')throw Error('diagnostic domain');if(!regionHostGuard()||!localGuard(${JSON.stringify(guards)}))throw Error('diagnostic guard');const old=regionProofOpen(${JSON.stringify(guards)});try{const tree=${clone('bsort')}(BigInt(d),s,x);return{tree,stat:${clone('scan')}(tree)};}finally{regionProofClose(old);}}
function $p42DiagnosticAdapter(){const em=new WeakMap(),dm=new WeakMap();const encode=t=>{if(em.has(t))return em.get(t);const x=t.$==='Leaf'?${flat?"{$:'Leaf',_0:t.v}":"{$:'Leaf',a:[t.v]}"}:${flat?"{$:'Node',_0:encode(t.l),_1:encode(t.r)}":"{$:'Node',a:[encode(t.l),encode(t.r)]}"};em.set(t,x);dm.set(x,t);return x;};const decode=t=>{if(dm.has(t))return dm.get(t);const x=t.$==='Leaf'?{$:'Leaf',v:${get(0)}}:{$:'Node',l:decode(${get(0)}),r:decode(${get(1)})};dm.set(t,x);return x;};return{encode,decode};}
export function p42FlowOwned(n,t,s){const{encode,decode}=$p42DiagnosticAdapter();const old=regionProofOpen(${JSON.stringify(guards)});try{return decode(${clone('flow')}(BigInt(n),s,encode(t)));}finally{regionProofClose(old);}}
export function p42WarpOwned(a,b,s){const{encode,decode}=$p42DiagnosticAdapter();const old=regionProofOpen(${JSON.stringify(guards)});try{return decode(${clone('warp')}(encode(a),encode(b),s));}finally{regionProofClose(old);}}
`;}
fs.mkdirSync(out);const results=[];
for(const[variant,flat]of [['clone-array',false],['clone-flat',true]]){
 const dir=path.join(out,variant);fs.mkdirSync(dir);const graph=members.map(n=>emitMember(n,flat)).join('\n')+'\nfunction $p42Bench(d,x){'+privateCallBody+'}\n';
 const clean=originalBenchPrefix+'try{return $p42Bench($s0,$s1);'+originalBenchSuffix+'\n'+graph;
 const modules=[];for(const[file,text]of [['original.clean.mjs',source],['original.mjs',source+'\n'+originalDiagnostic],['complete.clean.mjs',clean],['complete.mjs',clean+'\n'+diagnostic(flat)]]){fs.writeFileSync(path.join(dir,file),text,{flag:'wx'});parse(text);modules.push({file,sha256:sha(text)});}
 fs.writeFileSync(path.join(dir,'derive.json'),JSON.stringify({kind:'phase42-complete-private-ceiling',complete:true,checked:false,variant,source:identity(sourceArg),checkedReceipt:identity(sourceArg+'.json'),producer:identity(import.meta.filename),modules,scope:'Exact actual checked graph clone; original public workers/fallback retained. All frames/BigInt/control unchanged; direct array vs flat construction isolates layout. No native recursion/depthcap change.'},null,2)+'\n');results.push({variant,dir,clean:identity(path.join(dir,'complete.clean.mjs'))});
}
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify({kind:'phase42-actual-flat-clone',complete:true,checked:false,source:identity(sourceArg),checkedReceipt:identity(sourceArg+'.json'),producer:identity(import.meta.filename),results,workerCount:5},null,2)+'\n');fs.copyFileSync(import.meta.filename,path.join(out,'consumed-actual-flat-v2.mjs'));console.log(JSON.stringify({complete:true,checked:false,out,results:results.map(x=>x.variant)}));
