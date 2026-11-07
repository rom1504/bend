// Pinned checked Bend calls and complete-value comparisons only.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify,workspace} from '../../tools/build/hosted.mjs';

const args={};
for(let i=2;i<process.argv.length;i+=2){
  assert(process.argv[i]?.startsWith('--')&&process.argv[i+1]);
  const k=process.argv[i].slice(2);assert(!Object.hasOwn(args,k));args[k]=process.argv[i+1];
}
assert.deepEqual(Object.keys(args).sort(),['assembly','kind','out','receipt']);
assert(['store','borrow','scc'].includes(args.kind));
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const assembly=read(args.assembly),receipt=read(args.receipt);
assert(assembly.complete&&assembly.protectedUnchanged&&receipt.complete&&receipt.checked&&!receipt.error);
assert.deepEqual(assembly.source,receipt.source);
assert.deepEqual(assembly.exports,receipt.exports);
assert(args.kind!=='store'||assembly.replacements.length===0,'Independent store oracle must remain unchanged');
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(args.assembly),pin(args.receipt),
  ...assembly.inputs,assembly.source,assembly.exportManifest,assembly.binding,...receipt.inputs,receipt.api];
inputs.forEach(verify);
const out=path.resolve(args.out);
assert(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});assert.equal(fs.realpathSync(out),out);
const report={kind:'phase173-finite-controls',version:1,variant:args.kind,complete:false,inputs,rows:[],
  scope:'Finite complete-value and admission controls; not native execution, mathematical proof, or image qualification.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();const started=performance.now();
try{
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  if(args.kind==='store'){
    for(let mode=0;mode<26;mode++){
      const row=api.p173st_observe(mode);report.rows.push(row);
      assert.equal(row.$,'P173StoreObservation');assert.equal(row.mode,mode);
      assert.equal(row.importValid,true);assert.equal(row.compactValid,true);assert.equal(row.ok,true);
      assert.deepEqual(row.roundtrip,row.input,'Roundtrip '+mode);
      assert.deepEqual(row.actual,row.expected,'Compaction '+mode);
      assert.deepEqual(row.actualRefs,row.expectedRefs,'Ordered references '+mode);
    }
    report.refusals=[];
    for(let mode=0;mode<3;mode++){
      const row=api.p173st_refusal(mode);report.refusals.push(row);
      assert.equal(row.$,'P173StoreRefusal');assert.equal(row.mode,mode);
      assert.equal(row.ok,false);assert.equal(row.valid,false);
    }
  }else if(args.kind==='scc'){
    let list=api.p173sc_controls();
    while(list?.$==='Con'){
      assert(report.rows.length<50);const row=list.head;report.rows.push(row);
      assert.equal(typeof row,'string');assert(row.endsWith(':pass'),row);list=list.tail;
    }
    assert.equal(list?.$,'Nil');assert.equal(report.rows.length,18);
  }else{
    let list=api.p173b_controls();
    while(list?.$==='Con'){
      assert(report.rows.length<100);const row=list.head;report.rows.push(row);
      assert.equal(typeof row,'string');assert(row.startsWith('PASS '),row);list=list.tail;
    }
    assert.equal(list?.$,'Nil');assert.equal(report.rows.length,22);
    if(receipt.exports.includes('p173b_dispatch_controls')){
      report.dispatch=[];let more=api.p173b_dispatch_controls();
      while(more?.$==='Con'){
        assert(report.dispatch.length<20);const row=more.head;
        report.dispatch.push(row);assert.equal(typeof row,'string');assert(row.startsWith('PASS '),row);more=more.tail;
      }
      assert.equal(more?.$,'Nil');assert.equal(report.dispatch.length,8);
    }
    if(receipt.exports.includes('p173b_hot_controls')){
      report.hot=[];let more=api.p173b_hot_controls();
      while(more?.$==='Con'){
        assert(report.hot.length<20);const row=more.head;
        report.hot.push(row);assert.equal(typeof row,'string');assert(row.startsWith('PASS '),row);more=more.tail;
      }
      assert.equal(more?.$,'Nil');assert.equal(report.hot.length,8);
    }
    const text=api.p173b_template_observation();assert.equal(typeof text,'string');
    fs.writeFileSync(path.join(out,'template.txt'),text,{flag:'wx'});report.template=pin(path.join(out,'template.txt'));
  }
  inputs.forEach(verify);report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{report.wallSeconds=(performance.now()-started)/1000;save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));}
