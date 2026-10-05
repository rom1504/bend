// ROOT ONLY. NODE native-corpus-probe-v1.mjs PREPARED_MANIFEST NEW_OUT
// Derive counters from checked output; execute ordinary catalog points unchanged.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const [manifestArg,outArg]=process.argv.slice(2);assert(manifestArg&&outArg);
const hash=b=>createHash('sha256').update(b).digest('hex');
const id=p=>{p=fs.realpathSync(p);const b=fs.readFileSync(p);return {path:p,sha256:hash(b),bytes:b.length};};
const out=path.resolve(outArg);assert(!fs.existsSync(out));fs.mkdirSync(out);
const pm={exports:{}};new Function('module','exports',process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'])(pm,pm.exports);
const parse=s=>pm.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
function walk(n,f){if(!n||typeof n!=='object')return;f(n);for(const [k,v] of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,f));else if(v&&typeof v==='object')walk(v,f);}}
const manifest=JSON.parse(fs.readFileSync(manifestArg));const root=path.dirname(path.resolve(manifestArg));
const report={kind:'phase48-actual-native-corpus-activation',complete:false,passed:false,timingEligible:false,inputs:[id(import.meta.filename),id(manifestArg),id(process.execPath)],node:process.version,rows:[],derivatives:[]};
const marker='(/* private String.append */',insert=marker+'$p48CorpusAppend++,',cache=new Map();
try{
 assert(manifest.complete);assert.deepEqual(manifest.cases.map(x=>x.id).sort(),['coverage-unicode-text-16','coverage-unicode-text-64','test-morning-program']);assert.equal(report.inputs[2].sha256,'41a74efb34cbde5c7632cdac0cf8bd1a14d0b8d73dc1e82755014d9a9ce70f5c');
 for(const row of manifest.cases){
  const positive=row.id==='coverage-unicode-text-16'||row.id==='coverage-unicode-text-64';
  assert(positive||row.id==='test-morning-program','Frozen three-case scope');
  const moduleFile=path.resolve(root,row.modules.candidate.path);
  const actualReceipt=JSON.parse(fs.readFileSync(moduleFile+'.json'));
  const actualCatalog=JSON.parse(fs.readFileSync(actualReceipt.catalog.file??actualReceipt.catalog.canonicalPath));
  const catalogRows=actualCatalog.cases.filter(x=>x.id===row.id);assert.equal(catalogRows.length,1);assert.deepEqual(row.point,catalogRows[0].point,'Exact catalog point');assert.equal(row.sourceSha256,catalogRows[0].source.sha256);
  if(positive)assert.equal(row.point.expected,('α|β|🍎|中|'+String(row.point.args[1])+'|').repeat(row.point.args[0]),'Independent whole Unicode oracle');
  let entry=cache.get(moduleFile);
  if(!entry){
   const receiptFile=moduleFile+'.json',r=JSON.parse(fs.readFileSync(receiptFile));
   assert(r.complete&&r.observation.checked&&r.observation.status==='ok');
   const original=id(moduleFile);assert.equal(original.sha256,r.output.sha256);assert.equal(original.sha256,row.modules.candidate.sha256);assert.equal(r.input.sha256,row.sourceSha256);
   report.inputs.push(original,id(receiptFile));
   for(const x of [r.input,r.catalog,r.attempt,r.compiler.api,r.compiler.runtime,r.compiler.base]){const actual=id(x.file??x.canonicalPath);assert.equal(actual.sha256,x.sha256);report.inputs.push(actual);}
   assert.equal(r.catalog.sha256,manifest.catalogSha256);
   for(const part of ['api','runtime','base'])assert.equal(r.compiler[part].sha256,manifest.roles.candidate.compiler[part].sha256,'Manifest/receipt compiler '+part);
   const source=fs.readFileSync(moduleFile,'utf8');parse(source);assert(!source.includes('$p48CorpusAppend'));
   const sites=source.split(marker).length-1;
   const body=source.replaceAll(marker,insert);assert.equal(body.replaceAll(insert,marker),source,'Exact instrumentation inversion');
   const observed='let $p48CorpusAppend=0;\n'+body+'\nexport const $P48Corpus={count:()=>$p48CorpusAppend,reset:()=>{$p48CorpusAppend=0;},proof:()=>regionProof};\n';
   let astSites=0;walk(parse(observed),n=>{if(n.type==='SequenceExpression'&&n.expressions[0]?.type==='UpdateExpression'&&n.expressions[0].argument.name==='$p48CorpusAppend'){assert.equal(n.expressions.length,2);assert.equal(n.expressions[1].type,'BinaryExpression');assert.equal(n.expressions[1].operator,'+');astSites++;}});assert.equal(astSites,sites,'Every marker counter is the native concatenation comma expression');
   const target=path.join(out,'counted-'+cache.size+'.mjs');fs.writeFileSync(target,observed,{flag:'wx'});
   const derivative={...id(target),original,staticSites:sites,permission:'counter only; original admission/body/fallback retained'};report.derivatives.push(derivative);
   entry={m:await import(pathToFileURL(target)),derivative};cache.set(moduleFile,entry);
  }
  entry.m.$P48Corpus.reset();const value=entry.m.default[row.point.exportName](...row.point.args);assert.deepEqual(value,row.point.expected,'Full catalog oracle');const count=entry.m.$P48Corpus.count();assert.equal(entry.m.$P48Corpus.proof(),null);
  if(positive){assert(entry.derivative.staticSites>0);assert(count>0,'Ordinary Unicode root executes native append');}
  report.rows.push({id:row.id,args:row.point.args,expectedSha256:hash(JSON.stringify(row.point.expected)),valueSha256:hash(JSON.stringify(value)),codeUnits:typeof value==='string'?value.length:null,executedAppendCount:count,staticSites:entry.derivative.staticSites,positiveRequired:positive,proofNull:true});
 }
 assert.equal(report.rows.length,3);assert.equal(report.rows.filter(x=>x.positiveRequired).length,2);
 for(const input of [...report.inputs,...report.derivatives])assert.equal(id(input.path).sha256,input.sha256,'Unchanged inputs/derivatives');
 report.complete=true;report.passed=true;
}catch(error){report.failure={message:error.message,stack:error.stack};process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,passed:report.passed,rows:report.rows,failure:report.failure}));
