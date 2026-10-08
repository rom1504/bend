// Root-owned genuine-B2 lexical census. No source candidate or clean timing.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [prepArg,planArg,caseId,outArg]=process.argv.slice(2);assert(prepArg&&planArg&&caseId&&outArg);
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase65')+path.sep)&&!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
const sha=x=>createHash('sha256').update(x).digest('hex'),identity=file=>({file:fs.realpathSync(file),sha256:sha(fs.readFileSync(file))});
const inputs=new Map(),pin=(file,want)=>{const x=identity(file);if(want)assert.equal(x.sha256,want.sha256);if(inputs.has(x.file))assert.deepEqual(inputs.get(x.file),x);inputs.set(x.file,x);return x;};
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const report={kind:'phase65-genuine-b2-ordered-demand-opportunity',complete:false,pass:false,case:caseId,diagnosticOnly:true,productionQualified:false,
 scope:'Actual original B2 code with lexical observation only. Groups enter at jd_ordered_let_body; only String.contains calls lexically in jd_ordered_bindings activate counters. Every nonempty String.contains SCC search state counts one tested haystack code point. Needle comparisons and unrelated searches are excluded. Ordinary owned driver path, exact complete output oracle; no speed result.'};
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
 const enclosing=get('$jd$jd_95_ordered_95_let_95_body'),bindings=get('$jd$jd_95_ordered_95_bindings'),contains=get('$jd$String_46_contains'),dispatch=get('$jd$String_46_contains_46_if$scc');
 const starts=[];walk(contains.body,n=>{if(n.type==='CallExpression'&&n.callee.type==='Identifier'&&n.callee.name===dispatch.id.name)starts.push(n);});
 assert.equal(starts.length,1);assert.equal(starts[0].arguments[0].value,1,'String.contains search-state ordinal changed');
 const calls=[];walk(bindings.body,n=>{if(n.type==='CallExpression'&&n.callee.type==='Identifier'&&n.callee.name===contains.id.name)calls.push(n);});assert.equal(calls.length,1);
 const states=[];walk(dispatch.body,n=>{if(n.type==='SwitchStatement'&&n.discriminant.type==='Identifier'&&n.discriminant.name==='$pc')states.push(n);});assert.equal(states.length,1);
 const search=states[0].cases.find(x=>x.test?.value===1);assert(search&&search.consequent.length===1&&search.consequent[0].type==='BlockStatement');
 assert.equal(dispatch.params[1].name,'$a0');assert.equal(enclosing.params.length,5);
 const apiEdits=[{start:calls[0].callee.start,end:calls[0].callee.end,text:'$phase65Contains',reason:'observe the one lexical ordered-demand substring call'},
  {start:search.consequent[0].start+1,end:search.consequent[0].start+1,text:'$phase65Visit($a0);',reason:'count actual nonempty search-state haystack positions'}];
 const suffix=`
const $phase65Groups=[],$phase65GroupStack=[],$phase65QueryStack=[];
let $phase65Positions=0;
function $phase65Visit(text){const q=$phase65QueryStack.at(-1);if(q){if(text!==''){q.haystackCodepoints++;if(++$phase65Positions>100000000)throw Error('Ordered census character budget');}else q.emptyEndChecks++;}}
function $phase65Contains(text,needle){
 const group=$phase65GroupStack.at(-1);if(!group||text!==group.body)throw Error('Ordered census lost body ownership');
 const query={needle,haystackCodepoints:0,emptyEndChecks:0,matched:null};group.queries.push(query);$phase65QueryStack.push(query);
 try{const answer=$jd$String_46_contains(text,needle);if(typeof answer!=='boolean')throw Error('String.contains did not return Bool');query.matched=answer;return answer;}finally{if($phase65QueryStack.pop()!==query)throw Error('Ordered query stack');}
}
const $phase65OriginalLet=$jd$jd_95_ordered_95_let_95_body;
$jd$jd_95_ordered_95_let_95_body=(...args)=>{
 let n=0,x=args[2];while(x.$==='Con'){n++;x=x.tail;if(n>65536)throw Error('Ordered binder budget');}if(x.$!=='Nil')throw Error('Ordered list changed');
 const body=args[4].prefix+args[4].value,group={index:$phase65Groups.length,binders:Math.max(0,n-1),body,bodyCodepoints:Array.from(body).length,queries:[]};
 if($phase65Groups.length>=100000)throw Error('Ordered group budget');$phase65Groups.push(group);$phase65GroupStack.push(group);
 try{return $phase65OriginalLet(...args);}finally{if($phase65GroupStack.pop()!==group)throw Error('Ordered group stack');}
};
export const phase65Opportunity={
 selfTest(){
  const cases=[['','x',false,0,1],['','',true,0,1],['ab','a',true,1,0],['ab','b',true,2,0],['ab','z',false,2,1],['a🧭b','🧭b',true,2,0],['abc','',true,1,0]],rows=[];
  for(const [text,needle,wanted,positions,empty]of cases){const group={body:text,queries:[]};$phase65GroupStack.push(group);let answer;try{answer=$phase65Contains(text,needle);}finally{$phase65GroupStack.pop();}const q=group.queries[0];if(answer!==wanted||q.haystackCodepoints!==positions||q.emptyEndChecks!==empty)throw Error('Ordered census self-test');rows.push({text,needle,answer,haystackCodepoints:q.haystackCodepoints,emptyEndChecks:q.emptyEndChecks});}return rows;
 },
 reset(){if($phase65GroupStack.length||$phase65QueryStack.length)throw Error('Active ordered census');$phase65Groups.length=0;$phase65Positions=0;},
 snapshot(){if($phase65GroupStack.length||$phase65QueryStack.length)throw Error('Unclosed ordered census');return $phase65Groups.map(({body,...g})=>g);}
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
 await D.loadApi();const A=await import(pathToFileURL(apiFile));report.counterControls=A.phase65Opportunity.selfTest();A.phase65Opportunity.reset();
 const result=await D.inspect(row.source.file,{mode:'library',backend:'direct'});assert.equal(result.status,'ok',result.diagnostic);assert.equal(result.checked,true);assert.equal(result.backend,'direct');
 const {code,...observation}=result;report.observation=observation;assert.equal(Buffer.from(code).compare(fs.readFileSync(expected.output.file)),0,'Full original output differs');
 const output=path.join(out,'output.mjs');fs.writeFileSync(output,code,{flag:'wx'});report.output=identity(output);report.exactOriginalOutput=true;
 report.groups=A.phase65Opportunity.snapshot();
 const totals=groups=>({groups:groups.length,binders:groups.reduce((n,g)=>n+g.binders,0),bodyCodepoints:groups.reduce((n,g)=>n+g.bodyCodepoints,0),queries:groups.reduce((n,g)=>n+g.queries.length,0),haystackCodepoints:groups.reduce((n,g)=>n+g.queries.reduce((m,q)=>m+q.haystackCodepoints,0),0),matches:groups.reduce((n,g)=>n+g.queries.filter(q=>q.matched).length,0)});
 report.totals={all:totals(report.groups),multiBinder:totals(report.groups.filter(g=>g.binders>=2))};
 report.multiBinderOpportunityObserved=report.totals.multiBinder.groups>0;
 for(const group of report.groups)assert.equal(group.queries.length,group.binders,'One demand query per binder');
 for(const x of inputs.values())assert.deepEqual(identity(x.file),x);assert.deepEqual(identity(apiFile),report.apiDerivation.output);assert.deepEqual(identity(driverFile),report.driverDerivation.output);
 report.complete=report.pass=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,case:caseId,totals:report.totals,error:report.error}));
