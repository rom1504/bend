// Observe an isolated copy of the checked Phase197 combination; no semantics changed.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const out=process.argv[2]; fs.mkdirSync(out,{recursive:true});
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function bytes(p){const b=fs.readFileSync(p.file);if(sha(b)!==p.sha256)throw Error('identity '+p.file);return b;}
const prior=read('selfhost/build/phase195/ctor-gate-emission-plan01.json').producer.bindingValue;
const auth=read('selfhost/build/phase197/combined-api02/report.json');
if(!auth.complete||!auth.checked||sha(fs.readFileSync(process.execPath))!==prior.engine.sha256)throw Error('authority');
const old=bytes(auth.api).toString();
const mark='function $x190_j_checked(_frame_0, _params_0, _setup_0, _body_0, _registerBody_0, _names_0, _rows_0, _groups_0) {';
if(old.split(mark).length!==2)throw Error('capture boundary');
const injection=`
  {const ar=x=>{const r=[];while(x.$==='Con'){r.push(x.head);x=x.tail;}return r;};
   const str=x=>str_out(x);
   const symbol=str(_frame_0.symbol);
   if(globalThis.keep(symbol)){
    const tails=[];
    const walk=body=>{for(const s of ar(body)){
      if(s.$==='P113DIf'){walk(s.yes);walk(s.no);}
      if(s.$==='P113DAgain')tails.push(ar(s.values).map(v=>v.$==='N111Local'?str(v.name):v.$));
    }}; walk(_body_0);
    globalThis.observe({symbol,params:ar(_params_0).map(str),tailParams:ar($$x181_tail_args(_frame_0)).map(str),names:ar(_names_0).map(str),rows:ar(_rows_0),groups:ar(_groups_0),tails});
   }
  }
`;
const apiFile=path.resolve(out,'instrumented.mjs');fs.writeFileSync(apiFile,old.replace(mark,()=>mark+injection));
const api=(await import(pathToFileURL(apiFile))).default;
const prep=api.p88_cache_prepare(prior.base.file,bytes(prior.base).toString(),bytes(prior.carrier).toString(),prior.stamp);
if(prep.$!=='P86PreparationReady')throw Error('base');
const refs=read('selfhost/build/phase195/native45-01/programs.manifest.json').cases;
const result={sourceApi:auth.api,instrumentedSha:sha(fs.readFileSync(apiFile)),cases:[]};
const pretty=s=>s.replace(/(?:\d+_){2,}/g,m=>String.fromCharCode(...m.slice(0,-1).split('_').map(Number)));
for(const id of ['editdist','local-fold']){
 const pin=refs.find(x=>x.id===id).source;const row={id,source:pin,workers:[]};
 globalThis.keep=s=>/p113d_.*(?:product.row|product.fold.loop)/.test(pretty(s));
 globalThis.observe=x=>row.workers.push({...x,pretty:pretty(x.symbol)});
 const planned=api.p86_plan(prep.seed,pin.file,bytes(pin).toString());
 if(planned.$!=='P86PlanReady')throw Error(planned.error);
 const lower=api.p169np_plan(planned);if(lower.error)throw Error(lower.error);
 const selected=api.x181_prepared(lower);if(selected.error)throw Error(selected.error);
 const asm=api.x188_render(api.x188_many(selected.chunks));
 const existing='selfhost/build/phase197/shared-emission01/combined/'+id+'/program.s';
 if(fs.existsSync(existing)&&sha(asm)!==sha(fs.readFileSync(existing)))throw Error('assembly drift '+id);
 fs.writeFileSync(path.join(out,id+'.s'),asm);
 result.cases.push({...row,asmSha:sha(asm)});
 fs.writeFileSync(path.join(out,'capture.json'),JSON.stringify(result,null,2)+'\n');
}
console.log(JSON.stringify(result.cases.map(x=>({id:x.id,workers:x.workers.length}))));
