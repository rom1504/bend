// Manual closed saved-output component; no compiler purity/admission claim.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
const [inputArg,tsArg,outArg]=process.argv.slice(2);assert(inputArg&&tsArg&&outArg);
const input=fs.realpathSync(inputArg),ts=fs.realpathSync(tsArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const hash=x=>createHash('sha256').update(x).digest('hex'),identity=p=>({path:fs.realpathSync(p),sha256:hash(fs.readFileSync(p))});
const source=fs.readFileSync(input,'utf8');assert.equal(hash(source),'5b305c6171dba4d1003437881f6f8f4564f70aebd4d6500531daea19a49628c3');
const ps=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],pm={exports:{}};new Function('module','exports',ps)(pm,pm.exports);
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});const ast=parse(source);
const names=['prng','seed','salt','op.pick','op','ident','num','expand','slot.go','slot','gen.at','gen','tpl','cls.go','cls','mix','fnv','step.at','step','flush','lex','line','batch','bench','Bool.and'];
function spine(n){if(n.type!=='CallExpression')return null;if(n.callee.name==='get'&&n.arguments[0]?.name==='G'&&n.arguments[1]?.type==='Literal')return {name:n.arguments[1].value,args:[]};
 if(!['callOwned','jump'].includes(n.callee.name)||n.arguments[1]?.type!=='ArrayExpression')return null;const s=spine(n.arguments[0]);return s&&{name:s.name,args:[...s.args,...n.arguments[1].elements]};}
const sites=[];function walk(n){if(!n||typeof n!=='object')return;if(n.type==='CallExpression'){const s=spine(n);if(s&&['cls','step','lex'].includes(s.name)&&s.args.length===({cls:1,step:3,lex:2}[s.name]))sites.push({...s,start:n.start,end:n.end});}
 for(const [k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v);}}
walk(ast);assert.equal(sites.filter(s=>s.name==='lex').length,2);assert.equal(sites.filter(s=>s.name==='step').length,1);assert.equal(sites.filter(s=>s.name==='cls').length,1);
function additions(variant,diagnostic){const fastStep=['step','complete'].includes(variant);return `
// Manual closure guard. This does not open regionProof or extend compiler JPure.
const $lxNames=${JSON.stringify(names)};let $lxActive=false;
${diagnostic?'const $lxCounts={root:0,cls:0,step:0,lex:0};':''}
const $lxOwn=Object.getOwnPropertyDescriptors,$lxKeys=Reflect.ownKeys,$lxProto=Object.getPrototypeOf;
const $lxSnapshots=$lxNames.map(name=>{const f=G[name];return {name,f,p:$lxProto(f),d:$lxOwn(f),code:f.code,cp:$lxProto(f.code),cd:$lxOwn(f.code),bound:f.bound,bp:$lxProto(f.bound),bd:$lxOwn(f.bound)};});
const $lxString=String.prototype,$lxStringParent=$lxProto($lxString),$lxStringDescriptors=$lxOwn($lxString);
function $lxSame(object,descriptors){const keys=$lxKeys(object),old=$lxKeys(descriptors);if(keys.length!==old.length)return false;
 for(let i=0;i<keys.length;i++){if(keys[i]!==old[i])return false;const a=Object.getOwnPropertyDescriptor(object,keys[i]),b=descriptors[keys[i]];
  if(a.configurable!==b.configurable||a.enumerable!==b.enumerable||a.writable!==b.writable||a.value!==b.value||a.get!==b.get||a.set!==b.set)return false;}return true;}
function $lxGuard(){if($lxActive||regionProof!==null||!regionHostGuard()||!scalarGuard([]))return false;
 if($lxProto($lxString)!==$lxStringParent||!$lxSame($lxString,$lxStringDescriptors))return false;
 for(let i=0;i<$lxSnapshots.length;i++){const s=$lxSnapshots[i],g=Object.getOwnPropertyDescriptor(G,s.name);
  if(!g||!Object.hasOwn(g,'value')||g.value!==s.f||$lxProto(s.f)!==s.p||$lxProto(s.code)!==s.cp||$lxProto(s.bound)!==s.bp||!$lxSame(s.f,s.d)||!$lxSame(s.code,s.cd)||!$lxSame(s.bound,s.bd))return false;}return true;}
function $lxCls(c){${diagnostic?'++$lxCounts.cls;':''}return ctor(c>=97&&c<=122?'Letter':c>=48&&c<=57?'Digit':c===32?'Space':'Punct',[]);}
function $lxMix(acc,kind,x){return (Math.imul(acc,2654435761)^((Math.imul(kind,40503)+x)>>>0))>>>0;}
function $lxFnv(h,c){return Math.imul((h^c)>>>0,16777619)>>>0;}
function $lxStep(m,c,acc){${diagnostic?'++$lxCounts.step;':''}const k=$lxCls(c),tag=m.$;
 let next,out=acc;
 if(tag==='Gap'){
  if(k.$==='Letter')next=ctor('InId',[$lxFnv(2166136261,c)]);
  else if(k.$==='Digit')next=ctor('InNm',[(c-48)>>>0]);
  else {next=ctor('Gap',[]);if(k.$==='Punct')out=$lxMix(acc,3,c);}
 }else if(tag==='InId'){
  const h=m.a[0];if(k.$==='Letter')next=ctor('InId',[$lxFnv(h,c)]);
  else {next=k.$==='Digit'?ctor('InNm',[(c-48)>>>0]):ctor('Gap',[]);out=$lxMix(acc,1,h);if(k.$==='Punct')out=$lxMix(out,3,c);}
 }else if(tag==='InNm'){
  const v=m.a[0];if(k.$==='Digit')next=ctor('InNm',[(Math.imul(v,10)+((c-48)>>>0))>>>0]);
  else {next=k.$==='Letter'?ctor('InId',[$lxFnv(2166136261,c)]):ctor('Gap',[]);out=$lxMix(acc,2,v);if(k.$==='Punct')out=$lxMix(out,3,c);}
 }else return bad('manual lexer mode invariant');return ctor('Tuple',[next,out]);}
function $lxFlush(m,acc){return m.$==='Gap'?acc:$lxMix(acc,m.$==='InId'?1:2,m.a[0]);}
function $lxLex(s,r){${diagnostic?'++$lxCounts.lex;':''}for(;;){
 if(fields('SNil',s)!==null){const args=project('Tuple',r);return $lxFlush(args[0],args[1]);}
 const parts=project('SCon',s),chars=project('Chr',parts[0]),pair=project('Tuple',r);
 s=parts[1];r=$lxStep(pair[0],chars[0],pair[1]);}}
export function privateBench(depth,seed){
 if(!${!['original','noise'].includes(variant)}||typeof depth!=='number'||!Number.isInteger(depth)||depth<0||depth>4294967295||typeof seed!=='number'||!Number.isInteger(seed)||seed<0||seed>4294967295||!$lxGuard())return call(G.bench,[depth,seed]);
 ${diagnostic?'++$lxCounts.root;':''}$lxActive=true;try{return call(G.bench,[depth,seed]);}finally{$lxActive=false;}}
${diagnostic?`
export function privateStep(mode,payload,c,acc){if(!['Gap','InId','InNm'].includes(mode)||![payload,c,acc].every(x=>Number.isInteger(x)&&x>=0&&x<=4294967295))throw Error('diagnostic domain');
 const m=ctor(mode,mode==='Gap'?[]:[payload]);if(!${fastStep}||!$lxGuard())return call(G.step,[m,c,acc]);$lxActive=true;try{return $lxStep(m,c,acc);}finally{$lxActive=false;}}
export function privateTrace(s){if(typeof s!=='string')throw Error('diagnostic String');let r=ctor('Tuple',[ctor('Gap',[]),0]),rest=s;const trace=[];
 if(!$lxGuard())throw Error('trace guard');$lxActive=true;try{while(rest!==''){const parts=project('SCon',rest),c=project('Chr',parts[0])[0];r=${fastStep?'$lxStep(r[0],c,r[1])':"call(G.step,[r[0],c,r[1]])"};trace.push({c,mode:r[0],acc:r[1],tuple:Array.isArray(r)&&r.length===2});rest=parts[1];}
 return {trace,value:${variant==='complete'?'$lxFlush(r[0],r[1])':"call(G.flush,[r[0],r[1]])"}};}finally{$lxActive=false;}}
export function privateLex(s){if(typeof s!=='string'||!$lxGuard())throw Error('diagnostic String guard');$lxActive=true;
 try{return ${variant==='complete'?"$lxLex(s,ctor('Tuple',[ctor('Gap',[]),0]))":"call(G.lex,[s,ctor('Tuple',[ctor('Gap',[]),0])])"};}finally{$lxActive=false;}}
export function privateCounts(){return {...$lxCounts};}export function privateActive(){return $lxActive;}
`:''}
`;}
fs.mkdirSync(out,{recursive:false});const report={kind:'phase40-manual-lexer',complete:false,checked:false,certified:false,producer:identity(import.meta.filename),parent:identity(input),typescript:identity(ts),dependencies:names,modules:[]};
for(const diagnostic of [false,true])for(const variant of ['original','noise','guard','class','step','complete']){
 const selected=sites.filter(s=>s.name==='cls'&&variant==='class'||s.name==='step'&&variant==='step'||s.name==='lex'&&variant==='complete');let text=source;
 for(const s of selected.sort((a,b)=>b.start-a.start)){const args=s.args.map(a=>source.slice(a.start,a.end)).join(','),old=source.slice(s.start,s.end);text=text.slice(0,s.start)+`($lxActive?$lx${s.name==='cls'?'Cls':s.name==='step'?'Step':'Lex'}(${args}):${old})`+text.slice(s.end);}
 text+=additions(variant,diagnostic);parse(text);const file=path.join(out,variant+(diagnostic?'.mjs':'.clean.mjs'));fs.writeFileSync(file,text,{flag:'wx'});report.modules.push({variant,counters:diagnostic,...identity(file)});
}
report.complete=true;fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const catalog=JSON.parse(fs.readFileSync('selfhost/tools/performance/phase37/catalog.json'));
const cases=catalog.cases.filter(c=>c.family==='lexer').map(c=>({id:c.id,point:{...c.point,exportName:'privateBench'},modules:Object.fromEntries(['original','noise','guard','class','step','complete'].map(v=>[v,path.join(out,v+'.clean.mjs')]))}));assert(cases.length>=2);
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),input,ts],cases},null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:true,out,modules:report.modules.length,cases:cases.map(c=>c.id)}));
