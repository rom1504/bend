// Exact core controls for the immutable constructor-telescope fact experiment.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const [beforeArg,afterArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('usage: analysis-stable-test.mjs BASELINE_API CANDIDATE_API NEW_DIRECTORY');const before=fs.realpathSync(beforeArg),after=fs.realpathSync(afterArg),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const report={kind:'phase4-ordered-stable-telescope-gate',started:new Date().toISOString(),inputs:Object.fromEntries([before,after,import.meta.filename].map(f=>[f,sha(f)])),cases:[],complete:false},save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const arities={subst:3,wnf:2,tele_check:5,ka_args:4,check:5,infer:4};
async function view(file,name,extra={}){const source=fs.readFileSync(file,'utf8'),helpers={...arities,...extra};for(const key of Object.keys(helpers))assert.ok(source.includes('function $'+key+'$('),key);const target=path.join(out,name+'.mjs');fs.writeFileSync(target,source+'\nexport const analysisHelpers={'+Object.entries(helpers).map(([key,n])=>JSON.stringify(key)+':run_lib($'+key+'$,'+n+')').join(',')+'};\n');const m=await import(pathToFileURL(target));return {...m.default,...m.analysisHelpers};}
const B=await view(before,'baseline'),C=await view(after,'candidate',{core_subst_stable:1,ka_args_cached:4});
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),t=(tag,name='',id=0,quant=0,kids=[],removed=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list(removed)}),qua=q=>t('Qua','',0,q),typ=q=>t('Typ','',0,0,[qua(q)]),v=id=>t('Var','x',id),all=(id,q,a,b)=>t('All','x',id,q,[a,b]),lam=(id,b)=>t('Lam','x',id,1,[b]),ref=n=>t('Ref',n),app=(f,x)=>t('App','',0,0,[f,x]),ctr=(n,...xs)=>t('Ctr',n,0,0,xs),adt=n=>t('ADT',n),ann=(x,ty)=>t('Ann','',0,0,[x,ty]);
const def=(name,ty,value=t('Absent'),arity=0,kind='Def',ctors=[])=>({$:'KDef',name,kind,arity,templates:0,typ:ty,value,ctors:list(ctors),native:false,unsafe:false});
const bool=def('Bool',typ(2),t('Absent'),0,'ADT',[def('True',adt('Bool'),t('Absent'),0,'Ctr'),def('False',adt('Bool'),t('Absent'),0,'Ctr')]),alias=def('Tail',typ(1),all(101,0,typ(1),all(102,1,v(101),v(101))));
const env=book=>({$:'KEnv',book:list(book),name:'probe',lhs:t('Absent'),pending:0,quantities:nil,unsafe:false}),e=env([bool,alias]),boolean=adt('Bool'),truth=ctr('True'),falsehood=ctr('False');
function equal(name,a,b){assert.deepEqual(a,b,name);report.cases.push({name,exact:true});}
try{
 const rootCases=[
  {name:'empty-arguments',tel:all(1,1,boolean,boolean),args:[],accept:true},
  {name:'closed-three-fields',tel:all(1,1,boolean,all(2,1,boolean,all(3,1,boolean,boolean))),args:[truth,falsehood,truth],accept:true},
  {name:'Ref-tail-reveals-dependent-binder',tel:all(1,1,boolean,ref('Tail')),args:[truth,boolean,falsehood],accept:true},
  {name:'Ann-tail-reveals-dependent-binder',tel:all(1,1,boolean,ann(ref('Tail'),typ(1))),args:[truth,boolean,falsehood],accept:true},
  {name:'App-tail-beta-rebuild-fallback',tel:all(1,1,boolean,app(lam(90,all(2,1,boolean,boolean)),truth)),args:[truth,falsehood],accept:true},
  {name:'dependent-type-argument',tel:all(101,0,typ(1),all(102,1,v(101),v(101))),args:[boolean,truth],accept:true},
  {name:'too-many-arguments',tel:all(1,1,boolean,boolean),args:[truth,falsehood],accept:false},
  {name:'earlier-type-error-preserved',tel:all(1,1,boolean,all(2,1,boolean,boolean)),args:[qua(1),ref('Missing')],accept:false},
  {name:'later-type-error-preserved',tel:all(1,1,boolean,all(2,1,boolean,boolean)),args:[truth,qua(1)],accept:false},
  {name:'residual-metadata',tel:all(1,1,boolean,t('ADT','Bool',0,0,[],['False'])),args:[truth],accept:true},
 ];
 for(const item of rootCases){const args=list(item.args),expected=B.tele_check(e,nil,item.tel,args,1);assert.equal(expected.error==='',item.accept,item.name+' control verdict');equal(item.name+' check',C.tele_check(e,nil,item.tel,args,1),expected);if(item.accept)equal(item.name+' annotate',C.ka_args_cached(e,nil,item.tel,args),B.ka_args(e,nil,item.tel,args));}
 const ctx=list([t('Bind','x',200,1,[boolean])]),twice=all(1,1,boolean,all(2,1,boolean,boolean)),args=list([v(200),v(200)]);equal('affine-use-accounting',C.tele_check(e,ctx,twice,args,1),B.tele_check(e,ctx,twice,args,1));
 const beta=app(lam(300,v(300)),truth);assert.notDeepEqual(B.subst(beta,999,falsehood),beta);assert.equal(C.core_subst_stable(beta),false);report.cases.push({name:'absent-binder-beta-is-not-static',exact:true});
 const pool=[boolean,truth,v(1),ref('Tail'),typ(2),beta,t('Var','payload',1,0,[truth]),t('App')];
 const staticFact=term=>term.tag!=='Var'&&term.tag!=='App'&&(()=>{for(let xs=term.kids;xs.$==='Con';xs=xs.tail)if(!staticFact(xs.head))return false;return true;})();
 for(let i=0;i<160;i++){const tag=['All','ADT','Ann','Ctr','Let','Lam','Min','Rwt'][i%8],term=t(tag,'term'+i,i,i%3,[pool[i%pool.length],pool[(i*7+3)%pool.length]],i%4?[]:['Removed']),expected=staticFact(term);equal('static-fact-'+i,C.core_subst_stable(term),expected);if(expected){equal('safe-substitution-'+i,B.subst(term,1000,falsehood),term);equal('candidate-substitution-'+i,C.subst(term,1000,falsehood),term);}}

 const stableFact=term=>{if(term.tag==='Var')return false;if(term.tag==='App'){const xs=[];for(let ks=term.kids;ks.$==='Con';ks=ks.tail)xs.push(ks.head);if(term.name!==''||term.id!==0||term.quant!==0||term.removed.$!=='Nil'||xs.length!==2||xs[0].tag==='Lam')return false;}for(let ks=term.kids;ks.$==='Con';ks=ks.tail)if(!stableFact(ks.head))return false;return true;};
 const canonical=app(ref('Neutral'),truth),neutralCases=[t('Unknown'),t('Unknown','tag-metadata',19,2,[canonical,truth],['X']),t('Unknown','',0,0,[v(500)]),t('Unknown','',0,0,[beta]),canonical,app(canonical,falsehood),app(ann(lam(500,truth),typ(1)),truth),app(lam(500,truth),truth),app(v(500),truth),t('App'),t('App','named',0,0,[ref('Neutral'),truth]),t('App','',5,0,[ref('Neutral'),truth]),t('App','',0,1,[ref('Neutral'),truth]),t('App','',0,0,[ref('Neutral'),truth],['Removed']),t('App','',0,0,[ref('Neutral')]),t('App','',0,0,[ref('Neutral'),truth,falsehood])];
 for(let i=0;i<240;i++){const child=neutralCases[i%neutralCases.length],other=pool[(i*3)%pool.length];neutralCases.push(t(['All','ADT','Ann','Ctr','Let','Lam','App'][i%7],i%7===6?'':'n'+i,i%7===6?0:i,0,[child,other]));}
 for(let i=0;i<neutralCases.length;i++){const term=neutralCases[i],stable=stableFact(term);equal('neutral-fact-'+i,C.core_subst_stable(term),stable);if(stable)equal('neutral-substitution-identity-'+i,B.subst(term,1000,falsehood),term);}
 report.inputsUnchanged=Object.entries(report.inputs).every(([f,h])=>sha(f)===h);assert.equal(report.inputsUnchanged,true);report.complete=true;
}catch(error){report.error=error.stack;process.exitCode=1;}finally{report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:report.complete,cases:report.cases.length,error:report.error}));}
