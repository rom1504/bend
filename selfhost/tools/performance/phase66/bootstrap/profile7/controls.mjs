// Root-only actual-image controls; exposed private functions are test artifacts.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const [attemptArg,outArg,...extra]=process.argv.slice(2);
assert(attemptArg&&outArg&&!extra.length,'Usage: controls.mjs CHECKED_ATTEMPT FRESH_OUTPUT_DIRECTORY');
const root=path.resolve(import.meta.dirname,'../../../../../..'),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:hash(fs.readFileSync(file))});
const inputs=[],pin=file=>{const value=identity(file);inputs.push(value);return value;};
const read=file=>fs.readFileSync(file,'utf8');
const api=path.join(path.resolve(attemptArg),'api.mjs'),bootstrap=api+'.bootstrap.json';
const metadataFile=path.join(import.meta.dirname,'candidate.json'),metadata=JSON.parse(read(metadataFile));
const source=read(api);pin(api);pin(bootstrap);pin(metadataFile);pin(import.meta.filename);
const candidate=pin(metadata.candidate.file);assert.deepEqual(candidate,metadata.candidate);
const oldHelper=path.join(root,'selfhost/build/phase65/checked-state10/snapshot/tools/development/equality.mjs');
const oldApi=path.join(root,'selfhost/build/phase22/context-build-16/api.mjs');
const old6Api=path.join(root,'selfhost/build/phase65/checked-state10/api.mjs');
const history=path.join(root,'selfhost/dist/release-history');
const legacyGroups=fs.readdirSync(history).filter(n=>n.startsWith('9826ac8f'));assert.equal(legacyGroups.length,1);
const legacy=path.join(history,legacyGroups[0],'release-lineage/checked-api.mjs');
for(const file of [oldHelper,oldApi,old6Api,legacy])pin(file);
assert.equal(identity(oldHelper).sha256,metadata.parent.sha256,'Historical helper differs from proposal parent');
const report={kind:'phase66-profile7-controls',version:1,complete:false,pass:false,inputs,replay:[],refusals:[],primitivePairs:0,fallback:[],choiceCases:0,
  scope:'Source-bound checked B1 derivative; ordinary built-ins and compiler-host inputs. Historical profiles replay exactly. No full compiler conformance or throughput claim.'};
try {
  const previous=await import(pathToFileURL(oldHelper)),helper=await import(pathToFileURL(candidate.file));
  const {transformEquality,deriveEquality,verifyEqualityDerivation}=helper;
  for(const version of [1,2,3,4,5,6]){
    const text=read(version===1?legacy:version===6?old6Api:oldApi);
    const before=previous.transformEquality(text,version),after=transformEquality(text,version);
    assert.deepEqual(after,before);report.replay.push({version,sha256:hash(after.source)});
  }
  assert.deepEqual(transformEquality(read(oldApi)),previous.transformEquality(read(oldApi)));
  assert.deepEqual(transformEquality(read(old6Api)),previous.transformEquality(read(old6Api)));
  const transformed=transformEquality(source);assert.equal(transformed.stats.version,7);
  assert.deepEqual(transformEquality(source,7),transformed);
  assert(transformed.stats.choices.sites>0,'Literal choice optimization did not activate');
  assert.equal(transformed.stats.tailChoices,undefined,'Historical array-argument tail stage must not run');
  for(const name of ['$norm_dec$','$qjoin$','$kp_quant$']){
    const body=text=>{const begin=text.indexOf('function '+name+'('),end=text.indexOf('\nfunction ',begin+1);assert(begin>=0&&end>begin);return text.slice(begin,end);};
    assert(body(source).includes('$kc$('));assert(!body(transformed.source).includes('$kc$('));
    assert(body(transformed.source).includes('run_tail('),'Actual choice control did not activate');
  }
  const prefix='// Program\n// =======\n',runtimeEnd=source.indexOf(prefix)+prefix.length;
  assert(runtimeEnd>=prefix.length);assert.equal(transformed.source.slice(0,runtimeEnd),source.slice(0,runtimeEnd));
  assert.equal(transformed.source.slice(transformed.source.lastIndexOf('export default {')),source.slice(source.lastIndexOf('export default {')));
  report.transform=transformed.stats;
  const derived=await deriveEquality({api,bootstrapReport:bootstrap,outputDirectory:path.join(out,'derived')});
  verifyEqualityDerivation(derived.report);assert.equal(read(derived.api),transformed.source);
  report.derivation=pin(derived.report);report.derivedApi=pin(derived.api);
  const reject=(name,text,version)=>{assert.throws(()=>transformEquality(text,version));report.refusals.push(name);};
  reject('unknown runtime','\n'+source);reject('new image as profile6',source,6);reject('old image as profile7',read(old6Api),7);
  for(const name of [...Object.keys(transformed.stats.bodyHashes),'$kc$','$f_choose$','$nt_choose$']){
    const begin=source.indexOf('function '+name+'('),brace=source.indexOf('{\n',begin);assert(begin>=0&&brace>=0);
    reject('changed dependency '+name,source.slice(0,brace+2)+'  void 0;\n'+source.slice(brace+2),7);
  }
  reject('shadowed protected binding',source.replace('function $String$eq$(_a_0, _b_0)','function $String$eq$($Pair$snd$, _b_0)'),7);
  const exposures=[];
  const suffix='\nexport const phase66Controls={equality:(a,b)=>run_loop($String$eq$(a,b)),normDec:n=>run_loop($norm_dec$(n)),qjoin:(a,b)=>run_loop($qjoin$(a,b)),quant:q=>run_loop($kp_quant$(q))};\n';
  assert(!source.includes('phase66Controls'));
  for(const [name,text]of [['checked',source],['derived',transformed.source]]){
    const file=path.join(out,name+'-exposed.mjs');fs.writeFileSync(file,text+suffix,{flag:'wx'});
    pin(file);exposures.push((await import(pathToFileURL(file))).phase66Controls);
  }
  const compare=(a,b)=>{for(const exposed of exposures)assert.equal(exposed.equality(a,b),a===b);report.primitivePairs++;};
  for(let i=0;i<65536;i++){const a=String.fromCharCode(i);compare(a,a);compare(a,String.fromCharCode(i^1));}
  let seed=0x230006;const random=()=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return seed>>>0;};
  for(let i=0;i<10000;i++){let a='';for(let n=random()%65;n;n--)a+=String.fromCharCode(random()&65535);compare(a,a);compare(a,a+'x');}
  for(const a of ['', 'a', '\ud800', '\udc00', '🙂', 'x🙂\ud800'.repeat(256)]){compare(a,a);compare(a,a+'x');}
  const observe=(fn,value)=>{try{return {value:fn(value,'x')}}catch(error){return {error:String(error)}}};
  for(const value of [null,undefined,0,1,true,false,{},[],new String('x')]){
    const a=observe(exposures[0].equality,value),b=observe(exposures[1].equality,value);assert.deepEqual(b,a);report.fallback.push(a);
  }
  for(const n of [0,1,2,3,255,65535,4294967295]){
    for(const exposed of exposures){assert.equal(exposed.normDec(n),n===0?0:(n-1)>>>0);assert.equal(exposed.quant(n),n===0?'-':n===2?'+':'');}
    report.choiceCases+=2;
    for(const m of [0,1,2,4294967295]){for(const exposed of exposures)assert.equal(exposed.qjoin(n,m),Math.max(n,m));report.choiceCases++;}
  }
  for(const input of inputs)assert.deepEqual(identity(input.file),input);
  report.complete=report.pass=true;
} catch(error){report.error=String(error?.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({pass:report.pass,primitivePairs:report.primitivePairs,replay:report.replay.length,refusals:report.refusals.length,choiceCases:report.choiceCases,error:report.error}));
