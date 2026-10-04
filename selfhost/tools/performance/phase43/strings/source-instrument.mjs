// Scope-aware actual emitted-worker observations; never substitutes implementations.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
const [originalArg,candidateArg,outArg]=process.argv.slice(2);assert(originalArg&&candidateArg&&outArg);const out=path.resolve(outArg);assert(!fs.existsSync(out));
const hash=x=>createHash('sha256').update(x).digest('hex'),identity=p=>({path:fs.realpathSync(p),sha256:hash(fs.readFileSync(p))});
const parser={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(parser,parser.exports);
const dependencies=['prng','seed','salt','op.pick','op','ident','num','expand','slot.go','slot','gen.at','gen','tpl','cls.go','cls','mix','fnv','step.at','step','flush','lex','line','batch','bench','Bool.and'];
fs.mkdirSync(out);const report={kind:'phase43-source-lexer',complete:false,dependencies,inputs:[originalArg,candidateArg,import.meta.filename].map(identity),modules:[],sites:[]};
for(const [variant,input] of [['original',originalArg],['full',candidateArg]]){
 const source=fs.readFileSync(input,'utf8'),ast=parser.exports.parse(source,{ecmaVersion:'latest',sourceType:'module'}),edits=[],sites=[];
 const isFn=n=>['FunctionDeclaration','FunctionExpression','ArrowFunctionExpression'].includes(n.type);
 function visit(n,owner='module',active=null){if(!n||typeof n!=='object')return;
  if(n.type==='AssignmentExpression'&&n.left?.type==='MemberExpression'&&n.left.object?.name==='G'&&typeof n.left.property?.value==='string')owner=n.left.property.value;
  if(isFn(n)){
   const prefix=n.body.type==='BlockStatement'?source.slice(n.body.start+1,Math.min(n.body.start+180,n.body.end)):'';
   const structural=prefix.includes('/* private structural component */')||prefix.includes('/* private bounded');
   const helper=prefix.includes('/* private acyclic helper */');
   active=structural||helper?{name:n.id?.name??owner+':helper@'+n.start,node:n}:null;
   if(active){edits.push({start:n.body.start+1,end:n.body.start+1,text:`$scEnter(${JSON.stringify(active.name)});`});sites.push({kind:'function',name:active.name,start:n.start,end:n.end});}
  }
  if(n.type==='IfStatement'&&n.consequent.type==='BlockStatement'&&/localGuard(?:AfterHost)?\(\$guards\)/.test(source.slice(n.test.start,n.test.end))){edits.push({start:n.consequent.start+1,end:n.consequent.start+1,text:`$scEnter(${JSON.stringify('root:'+owner)});`});sites.push({kind:'entry',name:'root:'+owner,start:n.start,end:n.end});}
  if(active&&n.type==='ReturnStatement'&&n.argument){edits.push({start:n.argument.start,end:n.argument.start,text:`$scObserve(${JSON.stringify(active.name)},`},{start:n.argument.end,end:n.argument.end,text:')'});}
  for(const [key,value] of Object.entries(n))if(!['start','end'].includes(key)){if(Array.isArray(value))value.forEach(x=>visit(x,owner,active));else if(value&&typeof value==='object')visit(value,owner,active);}
 }
 visit(ast);let text=source;for(const edit of edits.sort((a,b)=>b.start-a.start||b.end-a.end))text=text.slice(0,edit.start)+edit.text+text.slice(edit.end);
 text+=`\nconst $scCounts={root:0,gen:0,lex:0,ident:0,num:0,cls:0,step:0,line:0,batch:0};let $scValues=[];const $scScopes={};
function $scEnter(name){$scScopes[name]=($scScopes[name]||0)+1;if(name.startsWith('root:'))$scCounts.root++;else{const base=name.split('$')[0];if(Object.hasOwn($scCounts,base))$scCounts[base]++;}}
function $scObserve(name,value){$scValues[$scValues.length]={name,value};if(Array.isArray(value)&&value.length===2&&['Gap','InId','InNm'].includes(value[0]?.$))$scCounts.step++;if(['Letter','Digit','Space','Punct'].includes(value?.$))$scCounts.cls++;return value;}
export function privateBench(d,s){return call(G.bench,[d,s]);}
export function privateStep(mode,payload,c,acc){return call(G.step,[ctor(mode,mode==='Gap'?[]:[payload]),c,acc]);}
export function privateLex(s){return call(G.lex,[s,ctor('Tuple',[ctor('Gap',[]),0])]);}
export function privateTrace(s){let r=ctor('Tuple',[ctor('Gap',[]),0]),rest=s;const trace=[];while(rest!==''){const parts=project('SCon',rest),c=project('Chr',parts[0])[0];r=call(G.step,[r[0],c,r[1]]);trace.push({c,mode:r[0],acc:r[1],tuple:Array.isArray(r)&&r.length===2});rest=parts[1];}return {trace,value:call(G.flush,[r[0],r[1]])};}
export function privateGenerate(tpl,s,k){return call(G.gen,[tpl,s,k]);}export function privateNamed(name,args){return call(G[name],args);}
export function privateCounts(){return {...$scCounts};}export function privateActive(){return regionProof!==null;}export function sourceScopes(){return {...$scScopes};}export function sourceValues(){return $scValues.slice();}export function sourceClear(){for(const k of Object.keys($scCounts))$scCounts[k]=0;for(const k of Object.keys($scScopes))delete $scScopes[k];$scValues=[];}
`;
 parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});const file=path.join(out,variant+'.mjs');fs.writeFileSync(file,text,{flag:'wx'});report.modules.push({variant,counters:true,...identity(file)});report.sites.push({variant,sites});
}
report.complete=true;fs.copyFileSync(import.meta.filename,path.join(out,'consumed-instrument.mjs'));fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:true,sites:report.sites.map(r=>({variant:r.variant,sites:r.sites.length}))}));
