// Root-owned genuine-B2 lexical census. No source candidate or clean timing.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [prepArg,planArg,caseId,outArg]=process.argv.slice(2);assert(prepArg&&planArg&&caseId&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase65')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const sha=x=>createHash('sha256').update(x).digest('hex'),identity=file=>({file:fs.realpathSync(file),sha256:sha(fs.readFileSync(file))});
const inputs=new Map(),pin=(file,want)=>{const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(x.file))assert.deepEqual(inputs.get(x.file),x);inputs.set(x.file,x);return x;};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const report={kind:'phase65-genuine-b2-closure-output-opportunity',complete:false,pass:false,case:caseId,diagnosticOnly:true,productionQualified:false,
 scope:'Actual original B2 code with lexical observation only. Count live-lambda Nil-arm admissions and its exact outer jd_text_raw scan; original body lowering is unchanged. Complete ordinary-driver output equality; no clean timing or selected source change.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');save();
try{
 report.preparation=pin(prepArg);report.plan=pin(planArg);pin(import.meta.filename);pin(process.execPath);
 const prep=read(prepArg),plan=read(planArg),image=prep.image;
 assert(prep.complete&&prep.pass&&prep.stage==='prepare'&&prep.role==='baseline');
 assert(image.kind==='direct'&&image.strictExact&&image.diagnosticDerivation===null);
 assert.equal(image.api.sha256,'b09fe54ad58d105d1c77ccb399f4076660d6109cf2a7f4b21e13933b89c22c2e');
 assert.equal(identity(process.execPath).sha256,plan.node.sha256);
 report.image=image;pin(prep.config.file,prep.config);
 for(const x of [...plan.inputs,...prep.copies.map(x=>x.after),...prep.verification.cacheFiles])pin(x.file,x);
 for(const key of ['api','source','emission','checkedGenerator','runtime','base','directRuntime','driver'])pin(image[key].file,image[key]);
 const row=plan.cases.find(x=>x.id===caseId);assert(row);const expected=prep.outputs.find(x=>x.id===caseId);assert(expected?.oracle.pass);
 for(const x of [row.source,...row.files,...row.emissionInputs,row.references.baseline,expected.output])pin(x.file,x);
 assert.equal(expected.output.sha256,row.references.baseline.sha256);report.source=row.source;report.expected=expected.output;
 const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
 new Function('module','exports',parserSource)(parser,parser.exports);const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
 const walk=(node,fn)=>{if(!node||typeof node!=='object')return;if(typeof node.type==='string')fn(node);for(const [k,v]of Object.entries(node)){if(k==='start'||k==='end')continue;if(Array.isArray(v))for(const x of v)walk(x,fn);else if(v&&typeof v==='object')walk(v,fn);}};
 const original=fs.readFileSync(image.api.file,'utf8'),ast=parse(original),get=name=>{const xs=ast.body.filter(x=>x.type==='FunctionDeclaration'&&x.id.name===name);assert.equal(xs.length,1,name);return xs[0];};assert(!original.includes('$phase65'));
 const enclosing=get('$jd$jd_95_doc_95_body_95_live_95_lambda'),raw=get('$jd$jd_95_text_95_raw');
 get('$jd$tg');get('$jd$qt');assert.equal(enclosing.params.length,5);
 const calls=[];walk(enclosing.body,n=>{if(n.type==='CallExpression'&&n.callee.type==='Identifier'&&n.callee.name===raw.id.name)calls.push(n);});assert.equal(calls.length,1);
 const apiEdits=[{start:calls[0].callee.start,end:calls[0].callee.end,text:'$phase65ClosureRaw',reason:'observe only the outer raw scan in the live-lambda Nil arm'}];
 const suffix=`
const $phase65Groups=[],$phase65Stack=[];
let $phase65Entries=0;
function $phase65ClosureRaw(code){
 const group=$phase65Stack.at(-1);if(!group)throw Error('Closure census lost enclosing ownership');
 if(!code.startsWith('return jd_clo(($arg)=>{')||!code.endsWith('});'))throw Error('Closure envelope changed');
 const result=$jd$jd_95_text_95_raw(code),n=Array.from(code).length;
 if(result.$!=='JDTextLeaf'||result.size!==Math.min(n,2097153))throw Error('Closure raw size changed');
 group.rawCalls++;group.codepoints=n;group.rescannedCodepoints=Math.min(n,2097153);group.nestedBodyCodepoints=n-26;group.safe=result.safe;
 return result;
}
const $phase65OriginalLive=$jd$jd_95_doc_95_body_95_live_95_lambda;
$jd$jd_95_doc_95_body_95_live_95_lambda=(...args)=>{
 $phase65Entries++;if(args[4].$!=='Nil')return $phase65OriginalLive(...args);
 if($jd$tg(args[2])!=='Lam'||$jd$tg(args[3])!=='All'||$jd$qt(args[3])===0)throw Error('Closure precondition changed');
 if($phase65Groups.length>=100000)throw Error('Closure census group budget');
 const group={index:$phase65Groups.length,rawCalls:0};$phase65Groups.push(group);$phase65Stack.push(group);
 try{const result=$phase65OriginalLive(...args);if(group.rawCalls!==1)throw Error('One outer raw scan per closure');return result;}finally{if($phase65Stack.pop()!==group)throw Error('Closure census stack');}
};
export const phase65Opportunity={
 reset(){if($phase65Stack.length)throw Error('Active closure census');$phase65Groups.length=0;$phase65Entries=0;},
 snapshot(){if($phase65Stack.length)throw Error('Unclosed closure census');return {entries:$phase65Entries,groups:$phase65Groups};}
};
`;
 function apply(source,edits,suffix=''){
  const ordered=[...edits].sort((a,b)=>a.start-b.start);let at=0,output='';
  for(const e of ordered){assert(e.start>=at);e.before=source.slice(e.start,e.end);output+=source.slice(at,e.start);e.outputStart=output.length;output+=e.text;at=e.end;}output+=source.slice(at);const body=output;
  for(const e of [...ordered].reverse()){assert.equal(output.slice(e.outputStart,e.outputStart+e.text.length),e.text);output=output.slice(0,e.outputStart)+e.before+output.slice(e.outputStart+e.text.length);}assert.equal(output,source);
  return {code:body+suffix,edits:ordered,exactInverse:true,suffixSha256:sha(suffix),offsetUnit:'UTF-16 code units'};
 }
 const api=apply(original,apiEdits,suffix);parse(api.code);const apiFile=path.join(out,'instrumented-api.mjs');fs.writeFileSync(apiFile,api.code,{flag:'wx'});
 report.apiDerivation={parent:image.api,output:identity(apiFile),...api,code:undefined,parserSha256:sha(parserSource)};
 const driverOriginal=fs.readFileSync(image.driver.file,'utf8'),driverAst=parse(driverOriginal),driverEdits=[];
 const driverUrl=pathToFileURL(image.driver.file).href,meta={url:driverUrl,dirname:path.dirname(image.driver.file)};
 walk(driverAst,n=>{
  if(n.type==='ImportDeclaration'&&n.source.value.startsWith('.'))driverEdits.push({start:n.source.start,end:n.source.end,text:JSON.stringify(new URL(n.source.value,driverUrl).href),reason:'preserve original helper import location'});
  if(n.type==='MetaProperty'&&n.meta.name==='import'&&n.property.name==='meta')driverEdits.push({start:n.start,end:n.end,text:'('+JSON.stringify(meta)+')',reason:'preserve original driver/project/path identities'});
  if(n.type==='ImportExpression'&&n.source.type==='Identifier'&&n.source.name==='url')driverEdits.push({start:n.source.start,end:n.source.end,text:JSON.stringify(pathToFileURL(apiFile).href),reason:'redirect private API import to exact diagnostic derivative'});
 });
 assert.equal(driverEdits.filter(x=>x.reason.startsWith('redirect')).length,1);
 const driver=apply(driverOriginal,driverEdits);parse(driver.code);const driverFile=path.join(out,'instrumented-driver.mjs');fs.writeFileSync(driverFile,driver.code,{flag:'wx'});
 report.driverDerivation={parent:image.driver,output:identity(driverFile),...driver,code:undefined};save();
 for(const k of Object.keys(process.env))if(k.startsWith('BEND_'))delete process.env[k];
 process.env.BEND_TYPED_API=image.api.file;process.env.BEND_TYPED_RUNTIME=image.runtime.file;process.env.BEND_BASE=image.base.file;
 const D=await import(pathToFileURL(driverFile));assert.equal(D.apiPath,image.api.file);assert.equal(D.directRuntimePath,image.directRuntime.file);assert.equal(D.driverPath,image.driver.file);
 await D.loadApi();const A=await import(pathToFileURL(apiFile));A.phase65Opportunity.reset();
 const result=await D.inspect(row.source.file,{mode:'library',backend:'direct'});assert.equal(result.status,'ok',result.diagnostic);assert.equal(result.checked,true);assert.equal(result.backend,'direct');
 const {code,...observation}=result;report.observation=observation;assert.equal(Buffer.from(code).compare(fs.readFileSync(expected.output.file)),0,'Full original output differs');
 const output=path.join(out,'output.mjs');fs.writeFileSync(output,code,{flag:'wx'});report.output=identity(output);report.exactOriginalOutput=true;
 const observed=A.phase65Opportunity.snapshot();report.entries=observed.entries;report.groups=observed.groups;
 report.totals={allLiveLambdaEntries:observed.entries,eligibleClosures:observed.groups.length,outerRawScans:observed.groups.reduce((n,g)=>n+g.rawCalls,0),rescannedCodepoints:observed.groups.reduce((n,g)=>n+g.rescannedCodepoints,0),nestedBodyCodepoints:observed.groups.reduce((n,g)=>n+g.nestedBodyCodepoints,0)};
 report.opportunityObserved=report.totals.eligibleClosures>0;
 for(const x of inputs.values())assert.deepEqual(identity(x.file),x);assert.deepEqual(identity(apiFile),report.apiDerivation.output);assert.deepEqual(identity(driverFile),report.driverDerivation.output);
 report.complete=report.pass=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,case:caseId,totals:report.totals,error:report.error}));
