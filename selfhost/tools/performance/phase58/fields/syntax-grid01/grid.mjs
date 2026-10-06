// JS microexperiment only: no Bend compiler, checked image or TS source involved.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';import {spawnSync} from 'node:child_process';
const hash=x=>createHash('sha256').update(x).digest('hex');
const pin=f=>{f=fs.realpathSync(f);const b=fs.readFileSync(f);return{file:f,sha256:hash(b),bytes:b.length};};
const configFile=path.join(import.meta.dirname,'config.json');
const config=JSON.parse(fs.readFileSync(configFile,'utf8'));assert.equal(config.kind,'phase58-js-field-syntax-grid');
const strings=['a','Bee','cDEF','ghijk','LMNOPQ','rstuvwx','YZabcdef','ghijklmno'];
function value(i,seed,previous,payload){return payload==='mixed'&&i%3===2?strings[(seed+i)&7]:((seed+Math.imul(i+1,17)+previous)>>>0);}
function scalar(v){return typeof v==='string'?(v.length*31+v.charCodeAt(0))>>>0:v;}
function model(width,context,payload,n){
 let seed=123456789,previous=0,sum=0;const ring=Array(config.sinkSlots).fill(null);
 for(let k=0;k<n;k++){
  seed=(Math.imul(seed,1664525)+1013904223)>>>0;
  const fields=Array.from({length:width},(_,i)=>value(i,seed,context==='loopCarried'?previous:0,payload));
  let d=0;for(const v of fields)d=(d+scalar(v))>>>0;
  sum=(sum+d)>>>0;previous=d;
  if(context==='opaqueEscape'||(k&255)===0)ring[k&(config.sinkSlots-1)]=fields;
 }
 return{sum,ring};
}
function generate(width,role,context,payload){
 const keys=Array.from({length:width},(_,i)=>'f'+i);
 const object=keys.map((k,i)=>(role==='computed'?'['+JSON.stringify(k)+']':JSON.stringify(k))+':'+
  (payload==='mixed'&&i%3===2?'strings[(seed+'+i+')&7]':'((seed+'+((i+1)*17)+'+previous)>>>0)')).join(',');
 const digest=keys.map((k,i)=>payload==='mixed'&&i%3===2?'(r.'+k+'.length*31+r.'+k+'.charCodeAt(0))':'r.'+k).join('+');
 return `return function batch(n){let seed=123456789,sum=0,previous=0,last=null;ring.fill(null);
 for(let k=0;k<n;k++){seed=(Math.imul(seed,1664525)+1013904223)>>>0;
 ${context==='loopCarried'?'previous=last?digest(last):0;':'previous=0;'}
 const r={${object}};const d=(${digest})>>>0;sum=(sum+d)>>>0;
 ${context==='loopCarried'?'last=r;':''}
 ${context==='opaqueEscape'?'escape(r,k);':'if((k&255)===0)escape(r,k);'}
 }return sum;};`;
}
function worker(width,role,context,payload,round){
 assert(config.screenWidths.concat(config.withheldWidths).includes(width));assert(config.roles.includes(role));
 assert(config.contexts.includes(context));assert(config.payloads.includes(payload));assert(Number.isInteger(round)&&round>=0&&round<config.rounds);
 const ring=Array(config.sinkSlots).fill(null);
 const escape=(r,k)=>{ring[k&(config.sinkSlots-1)]=r;};
 const digest=r=>{let sum=0;for(let i=0;i<width;i++)sum=(sum+scalar(r['f'+i]))>>>0;return sum;};
 const literal=generate(width,'literal',context,payload),computed=generate(width,'computed',context,payload);
 // The two bodies differ only at the declaration of ordinary object keys.
 assert.equal(computed.replace(/\["(f\d+)"\]:/g,'"$1":'),literal);
 const code=role==='literal'?literal:computed;
 const batch=new Function('strings','ring','escape','digest',code)(strings,ring,escape,digest);
 const expected=model(width,context,payload,config.batchRecords);
 function oracle(){assert.equal(batch(config.batchRecords),expected.sum);
  for(let slot=0;slot<ring.length;slot++){
   const got=ring[slot],want=expected.ring[slot];if(want===null){assert.equal(got,null);continue;}
   assert.equal(Object.getPrototypeOf(got),Object.prototype);
   assert.deepEqual(Reflect.ownKeys(got),Array.from({length:width},(_,i)=>'f'+i));
   assert.deepEqual(Object.values(got),want);
   for(let i=0;i<width;i++){const d=Object.getOwnPropertyDescriptor(got,'f'+i);assert(d.enumerable&&d.configurable&&d.writable&&!d.get&&!d.set);}
  }
 }
 oracle();
 function window(ms){const start=performance.now();let calls=0,checksum=0,end=start;
  do{checksum=(checksum+batch(config.batchRecords))>>>0;calls++;end=performance.now();}while(end-start<ms);
  assert.equal(checksum,Math.imul(expected.sum,calls)>>>0);return{ms:end-start,calls,records:calls*config.batchRecords,checksum};}
 const warmup=window(config.warmupMs),timed=window(config.targetMs);oracle();
 return{width,role,context,payload,round,code,codeSha256:hash(code),oracle:expected.sum,warmup,timed,
  nsPerRecord:timed.ms*1e6/timed.records,maxRssKiB:process.resourceUsage().maxRSS,
  sinkScope:context==='opaqueEscape'?'Every record enters bounded64-slot external sink':'Every256th record enters bounded external sink; loop-carried additionally retains previous record',pass:true};
}
if(process.argv[2]==='--worker'){
 const [width,role,context,payload,round]=process.argv.slice(3);assert.equal(process.argv.length,8);
 console.log(JSON.stringify(worker(Number(width),role,context,payload,Number(round))));
}else{
 const [mode,outArg]=process.argv.slice(2);assert(['screen','withheld'].includes(mode)&&outArg&&process.argv.length===4,'grid.mjs screen|withheld NEW_OUT');
 const raw=fs.realpathSync(path.resolve(import.meta.dirname,'../../../../../build/phase58')),out=path.resolve(outArg);
 assert(out.startsWith(raw+path.sep)&&!fs.existsSync(out));let ancestor=path.dirname(out);while(!fs.existsSync(ancestor))ancestor=path.dirname(ancestor);
 assert(fs.realpathSync(ancestor)===raw||fs.realpathSync(ancestor).startsWith(raw+path.sep));fs.mkdirSync(out,{recursive:true});
 const inputs=[pin(import.meta.filename),pin(configFile),pin(process.execPath)];
 const widths=mode==='screen'?config.screenWidths:config.withheldWidths;
 const cases=widths.flatMap(width=>config.contexts.flatMap(context=>config.payloads.map(payload=>({width,context,payload}))));
 const report={kind:'phase58-js-synthetic-field-syntax-grid',complete:false,pass:false,mode,config,inputs,cases,samples:[],pairs:[],
  scope:'Fresh process per sample; JS synthetics only. Trusted independent array-valued model checks full checksum and escaping own-field values. No Bend/TS compiler output, no checked receipt, no production threshold decision. Profiling is not combined with these timings.'};
 const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
 try{
  for(let round=0;round<config.rounds;round++)for(let at=0;at<cases.length;at++){
   const c=cases[(at+round*12)%cases.length],roles=(round+at)%2?[...config.roles].reverse():config.roles;
   for(const role of roles){const args=['--max-old-space-size=256',import.meta.filename,'--worker',String(c.width),role,c.context,c.payload,String(round)];
    const result=spawnSync(process.execPath,args,{encoding:'utf8',timeout:config.workerTimeoutMs,maxBuffer:2**20,env:{...process.env,NODE_OPTIONS:'',NODE_PATH:''}});
    const stem=[round,c.width,c.context,c.payload,role].join('-');fs.writeFileSync(path.join(out,stem+'.stdout'),result.stdout??'');fs.writeFileSync(path.join(out,stem+'.stderr'),result.stderr??'');
    assert.ifError(result.error);assert.equal(result.signal,null);assert.equal(result.status,0,result.stderr);
    const row=JSON.parse(result.stdout);assert.equal(row.pass,true);assert.deepEqual([row.width,row.context,row.payload,row.role,row.round],[c.width,c.context,c.payload,role,round]);
    report.samples.push(row);save();
   }
  }
  assert.equal(report.samples.length,cases.length*config.rounds*2);
  for(const c of cases){const rows=report.samples.filter(r=>r.width===c.width&&r.context===c.context&&r.payload===c.payload);
   const median=role=>rows.filter(r=>r.role===role).map(r=>r.nsPerRecord).sort((a,b)=>a-b)[1];
   report.pairs.push({...c,literalNs:median('literal'),computedNs:median('computed'),computedOverLiteral:median('computed')/median('literal'),proposedRole:c.width<=4?'computed':'literal'});
  }
  for(const i of inputs)assert.deepEqual(pin(i.file),i);report.pass=report.complete=true;
 }catch(e){report.error={message:e.message,stack:e.stack};process.exitCode=1;}finally{save();console.log(JSON.stringify({pass:report.pass,samples:report.samples.length,report:path.join(out,'report.json'),error:report.error?.message}));}
}
