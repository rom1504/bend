// Root-only compiler API execution. No native builds or program launches.
// node check-admission.mjs CANDIDATE_CHECKED_API NEW_OUTPUT_DIRECTORY
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {decodeBaseArena} from '../../../base-cache-graph.mjs';
const [apiArg,outArg]=process.argv.slice(2);assert(apiArg&&outArg);
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const root=path.resolve(import.meta.dirname,'../../../../..');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,bytes:b.length,sha256:sha(b)};};
const report={complete:false,inputs:[import.meta.filename,apiArg,path.join(import.meta.dirname,'append.bend'),path.join(root,'selfhost/build/phase102/append-admission-fixtures01/body-cases.json')].map(pin),observations:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const r=[];while(xs.$==='Con'){r.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return r;};
const kid=(n,i)=>unlist(n.kids)[i];
const clone=x=>structuredClone(x);
const observe=(name,actual,expected)=>{report.observations.push({name,actual,expected});save();assert.deepEqual(actual,expected,name);};
save();
try {
  const original=fs.readFileSync(apiArg,'utf8');
  const names=['nx_append_body','nx_append_allowed','nx_append_segments','nx_append_helper'];
  for(const name of names)assert.equal(original.split('function $'+name+'$(').length,2,'Exact checked helper '+name);
  const diagnostic=path.join(out,'diagnostic-api.mjs');
  const addition='\n// Diagnostic exports only; complete checked API prefix unchanged.\nexport const phase102Text={'+names.map(n=>n+':(...a)=>run_loop($'+n+'$(...a))').join(',')+'};\n';
  fs.writeFileSync(diagnostic,original+addition,{flag:'wx'});
  report.diagnostic={...pin(diagnostic),unchangedPrefixBytes:Buffer.byteLength(original),parentSHA256:sha(original)};
  const api=(await import(pathToFileURL(diagnostic))).phase102Text;
  const cases=JSON.parse(fs.readFileSync(path.join(root,'selfhost/build/phase102/append-admission-fixtures01/body-cases.json')));
  for(const c of cases)observe('body/'+c.name,api.nx_append_body(c.value),c.expected);
  const receipt=JSON.parse(fs.readFileSync(path.join(root,'selfhost/tools/performance/phase88/base/carrier01/receipt.json')));
  report.inputs.push(pin(receipt.inputPins.cache.file));
  assert.equal(report.inputs.at(-1).sha256,receipt.inputPins.cache.sha256);
  const input=fs.readFileSync(receipt.inputPins.cache.file),cut=input.indexOf(10),h=JSON.parse(input.subarray(0,cut));
  const arena=decodeBaseArena(input.subarray(cut+1,cut+1+h.segments[0]),{range:{begin:h.sourceBegin,end:h.sourceEnd},termAbi:h.termAbi,rootKinds:['defs']});
  const rows=unlist(arena.roots[0]);
  const probe=(name,expected,change=()=>{},checked=true)=>{const ds=clone(rows);change(ds);observe('permission/'+name,api.nx_append_allowed(list(ds),checked),expected);};
  const find=(rows,name)=>{const value=rows.find(d=>d.name===name);assert(value,name);return value;};
  probe('checked-canonical',true);
  probe('raw-even-canonical',false,()=>{},false);
  probe('unsafe-definition',false,ds=>find(ds,'String.append').unsafe=true);
  probe('user-definition-name',false,ds=>find(ds,'String.append').native=false);
  probe('wrong-arity',false,ds=>find(ds,'String.append').arity=1);
  probe('erased-parameter',false,ds=>find(ds,'String.append').templates=1);
  probe('body-mismatch',false,ds=>find(ds,'String.append').value=clone(cases[2].value));
  probe('noncanonical-String-owner',false,ds=>find(ds,'String').native=false);
  probe('noncanonical-Char-owner',false,ds=>find(ds,'Char').native=false);
  probe('noncanonical-U32-owner',false,ds=>find(ds,'U32').native=false);
  probe('wrong-SCon-arity',false,ds=>find(unlist(find(ds,'String').ctors),'SCon').arity=3);
  probe('shared-first-parameter',false,ds=>find(ds,'String.append').typ.quant=2);
  probe('shared-second-parameter',false,ds=>kid(find(ds,'String.append').typ,1).quant=2);
  const base={$:'N_Segment',name:'$direct.String.append',params:list([{$:'N_Param',name:'savedLeft',kind:{$:'N_W64'}},{$:'N_Param',name:'savedRight',kind:{$:'N_W64'}}]),result:1,frame:{$:'N_Direct'},body:'/* original canonical body */\nWL_RETN(1);',refs:list(['kept.ref']),host:false,spin:false,fork:false,bang:false};
  const lower=(segment,allowed)=>unlist(api.nx_append_segments(list([segment]),allowed))[0];
  const admitted=lower(clone(base),true),rest={...admitted,body:base.body};
  observe('segment/metadata-preserved',rest,base);
  observe('segment/parameters-before-register-bank',admitted.body.includes('native_string_append(e, savedLeft, savedRight)'),true);
  observe('segment/device-fallback',admitted.body.includes('#else\n'+base.body+'\n#endif'),true);
  observe('segment/raw-unchanged',lower(clone(base),false),base);
  for(const mode of ['other-name','wrong-result','stack-frame','wrong-kind','wrong-arity']) {
    const seg=clone(base);
    if(mode==='other-name')seg.name='sameShapeUserAppend';
    if(mode==='wrong-result')seg.result=2;
    if(mode==='stack-frame')seg.frame={$:'N_Frame',pop:2,slots:list(['a','b'])};
    if(mode==='wrong-kind')seg.params.head.kind={$:'N_W32'};
    if(mode==='wrong-arity')seg.params.tail=seg.params.tail.tail;
    observe('segment/'+mode,lower(clone(seg),true),seg);
  }
  const expectedHelper=JSON.parse(fs.readFileSync(path.join(import.meta.dirname,'helper-provenance.json'))).helperSHA256;
  observe('helper/derived-C-bytes',sha(api.nx_append_helper()),expectedHelper);
  for(const p of report.inputs)assert.deepEqual(pin(p.file),p);
  report.complete=true;
} catch(error) { report.error=error.stack??String(error);process.exitCode=1; }
finally { save(); }
console.log(JSON.stringify({complete:report.complete,observations:report.observations.length,report:path.join(out,'report.json'),error:report.error}));
