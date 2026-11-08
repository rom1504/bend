// Actual IR verification/emission happens in the checked Bend API. The C/asm
// observer checks literal outputs and the external machine calling convention.
import fs from 'node:fs';import path from 'node:path';import{pathToFileURL}from'node:url';import{spawnSync}from'node:child_process';
import{pin,verify,requireThat as need,workspace}from'../../tools/build/hosted.mjs';
const a={};for(let i=2;i<process.argv.length;i+=2)a[process.argv[i].slice(2)]=process.argv[i+1];
const out=path.resolve(a.out);need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out),'fresh output');fs.mkdirSync(out,{recursive:true});
const r=JSON.parse(fs.readFileSync(a.api));need(r.complete&&r.checked,'checked API');const inputs=[pin(import.meta.filename),pin(a.api),r.api,r.source,pin(process.execPath),pin(path.join(workspace,'selfhost/tests/phase181/abi-runner.c')),pin(path.join(workspace,'selfhost/tests/phase181/abi-preserve.s'))];inputs.forEach(verify);
const report={kind:'phase181-machine-abi-controls',complete:false,inputs,rows:[],jobs:[],scope:'Seventeen actual direct functions pass the unchanged IR verifier, then Bend emits assembly. Literal C observer plus ABI shim checks machine results. This is not source-language or ownership qualification.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');save();
try{
 const api=(await import(pathToFileURL(r.api.file))).default;const error=api.p181c_validate();need(error==='','IR rejected: '+error);report.irVerified=true;
 need(api.p181h_validate()==='','hygiene fixtures must pass unchanged verifier');
 const expectedHygiene=['valid-ir','hidden-result-parameter','reserved-prefix','nested-local','nested-alloca','call-destination','segment-local','segment-alloca','ordinary-accepted','nearby-prefix-accepted'].map(s=>s+'=1');
 const hygiene=[];let hs=api.p181h_controls();while(hs.$==='Con'){hygiene.push(hs.head);hs=hs.tail;}need(hs.$==='Nil'&&JSON.stringify(hygiene)===JSON.stringify(expectedHygiene),'hygiene observations differ');report.hygiene=hygiene;
 let functions=api.p181c_functions(),text='';const ids={$:'N111Ids',functions:api.missing(),constructors:api.missing()};
 while(functions.$==='Con'){const f=functions.head,o=api.x181_direct(f,ids);need(o.error==='','emission refused: '+o.error);let xs=o.chunks;while(xs.$==='Con'){text+=xs.head;xs=xs.tail;}need(xs.$==='Nil','proper chunks');report.rows.push({name:f.name,emitted:true});functions=functions.tail;}
 need(functions.$==='Nil'&&report.rows.length===17,'exact inventory');text+='.section .note.GNU-stack,"",@progbits\n';fs.writeFileSync(out+'/controls.s',text);report.assembly=pin(out+'/controls.s');
 const assets=JSON.parse(fs.readFileSync(path.join(workspace,'selfhost/manifests/assets-native.json'))),cc=assets.assets.linker;verify(cc);inputs.push(cc);
 for(const[label,cmd]of[['build',[cc.file,'-std=c11','-O2','-fno-pie','-no-pie',path.join(workspace,'selfhost/tests/phase181/abi-runner.c'),path.join(workspace,'selfhost/tests/phase181/abi-preserve.s'),out+'/controls.s','-o',out+'/controls']],['execute',[out+'/controls']]]){
  const begin=performance.now(),v=spawnSync(cmd[0],cmd.slice(1),{encoding:'utf8',timeout:15000});fs.writeFileSync(out+'/'+label+'.stdout',v.stdout??'');fs.writeFileSync(out+'/'+label+'.stderr',v.stderr??'');report.jobs.push({label,command:cmd,status:v.status,seconds:(performance.now()-begin)/1000,stdout:pin(out+'/'+label+'.stdout'),stderr:pin(out+'/'+label+'.stderr')});save();need(v.status===0,label+' failed');if(label==='execute')need(v.stdout==='controls pass\n'&&v.stderr==='','ABI expectations differ');
 }
 report.binary=pin(out+'/controls');inputs.forEach(verify);report.complete=true;
}catch(e){report.error=String(e.stack??e);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,rows:report.rows.length,error:report.error}));
