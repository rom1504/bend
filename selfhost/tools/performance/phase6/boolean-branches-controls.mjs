// Disposable internal views only; the checked APIs and release remain unchanged.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [beforeArg,afterArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: boolean-branches-controls.mjs BEFORE AFTER NEW_DIRECTORY');
const before=fs.realpathSync(beforeArg),after=fs.realpathSync(afterArg),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const sha=f=>createHash('sha256').update(fs.readFileSync(f)).digest('hex');const report={kind:'phase6-boolean-worker-controls',complete:false,started:new Date().toISOString(),cpu:2,controlledTiming:false,inputs:Object.fromEntries([before,after,import.meta.filename].map(f=>[f,sha(f)])),cases:[]};const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
async function view(file,name){let source=fs.readFileSync(file,'utf8');for(const key of ['core_subst_stable','core_subst_stable_terms'])assert.ok(source.includes('function $'+key+'$('));const target=path.join(out,name+'.mjs');fs.writeFileSync(target,source+'\nexport const controls={stable:run_lib($core_subst_stable$,1),terms:run_lib($core_subst_stable_terms$,1)};\n');return (await import(pathToFileURL(target))).controls;}
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil),t=(tag,name='',id=0,quant=0,kids=[],removed=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list(removed)});
const ref=t('Ref','Neutral'),atom=t('U32'),variable=t('Var','x',3),lam=t('Lam','x',3,1,[variable]);const app=(f,x)=>t('App','',0,0,[f,x]);
const stableOracle=x=>{if(x.tag==='Var')return false;for(let xs=x.kids;xs.$==='Con';xs=xs.tail)if(!stableOracle(xs.head))return false;if(x.tag!=='App')return true;const xs=[];for(let ys=x.kids;ys.$==='Con';ys=ys.tail)xs.push(ys.head);return x.name===''&&x.id===0&&x.quant===0&&x.removed.$==='Nil'&&xs.length===2&&xs[0].tag!=='Lam';};
const outcome=f=>{try{return {ok:true,value:f()};}catch(e){return {ok:false,name:e?.name,message:e?.message??String(e)};}};
try{
 const B=await view(before,'before'),C=await view(after,'after');
 function check(name,value,expected,method='stable'){const old=outcome(()=>B[method](value)),actual=outcome(()=>C[method](value));assert.deepEqual(actual,old,name);if(expected!==undefined)assert.deepEqual(actual,{ok:true,value:expected},name+' expected successful value');report.cases.push({name,method,result:actual});return actual;}
 const cases=[['atom',atom,true],['var',variable,false],['neutral-app',app(ref,atom),true],['beta-app',app(lam,atom),false],['unknown-tag',t('Unknown','metadata',9,2,[ref],['Removed']),true],['var-child',t('All','x',5,1,[atom,variable]),false],['noncanonical-name',t('App','x',0,0,[ref,atom]),false],['noncanonical-id',t('App','',7,0,[ref,atom]),false],['noncanonical-quant',t('App','',0,2,[ref,atom]),false],['removed',t('App','',0,0,[ref,atom],['X']),false],['zero-kids',t('App'),false],['one-kid',t('App','',0,0,[ref]),false],['three-kids',t('App','',0,0,[ref,atom,ref]),false]];
 for(const row of cases)check(...row);
 const pool=cases.map(x=>x[1]);for(let i=0;i<400;i++){const kids=[pool[i%pool.length],pool[(i*7+2)%pool.length]],value=t(['App','All','Ann','Ctr','Let','Min','Rwt','Unknown'][i%8],i%8===0?'':'field'+i,i%8===0?0:i,0,kids);check('generated-'+i,value,stableOracle(value));}
 for(const tag of ['','A\ud800','V\ud800','Var\ud800','App\ud800','😀','A\udfff']){check('utf16-'+JSON.stringify(tag),t(tag));check('utf16-bad-child-'+JSON.stringify(tag),{...t(tag),kids:{$:'BadList'}});}
 check('var-skips-malformed-kids',{...variable,kids:{$:'BadList'}},false);
 check('unstable-child-skips-malformed-name',{...t('App','',0,0,[variable]),name:null},false);
 const childFailure=check('child-before-name',{...t('App'),name:null,kids:{$:'BadList'}});
 assert.equal(childFailure.ok,false);assert.deepEqual(childFailure,check('same-child-only-error',{...t('App'),kids:{$:'BadList'}}));
 check('head-false-skips-malformed-tail',{$:'Con',head:variable,tail:{$:'BadList'}},false,'terms');
 const headError=check('head-before-tail',{$:'Con',head:null,tail:{$:'BadList'}},undefined,'terms');assert.equal(headError.ok,false);assert.deepEqual(headError,check('same-head-only-error',{$:'Con',head:null,tail:nil},undefined,'terms'));
 for(const depth of [128,512,1024]){let value=ref;for(let i=0;i<depth;i++)value=t('Ctr','C',0,0,[value]);check('deep-'+depth,value,true);}
 let many=nil;for(let i=0;i<100000;i++)many={$:'Con',head:ref,tail:many};check('100000-element-list',many,true,'terms');
 const source=fs.readFileSync(after,'utf8'),names=['core_subst_stable','core_subst_stable_terms','core_subst_stable_var','core_subst_stable_children','core_subst_stable_tag','core_subst_stable_shape','core_subst_stable_head'];
 report.generated=names.map(name=>{const match=source.match(new RegExp('^function \\$'+name+'\\$\\([^\\n]*\\) \\{\\n[\\s\\S]*?^\\}','m'));assert.ok(match,name);const body=match[0];assert.ok(!body.includes('$kc$(')&&!body.includes('=>')&&!body.includes('function ('),name+' still constructs branch closures');return {name,bytes:Buffer.byteLength(body),sha256:createHash('sha256').update(body).digest('hex'),body};});
 for(const [file,digest]of Object.entries(report.inputs))assert.equal(sha(file),digest);report.inputsUnchanged=true;report.complete=true;
}catch(error){report.error=error.stack;process.exitCode=1;}finally{report.finished=new Date().toISOString();save();console.log(JSON.stringify({complete:report.complete,cases:report.cases.length,error:report.error}));}
