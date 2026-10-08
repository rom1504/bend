// Exact candidate runtime controls; root executes in its guarded target lane.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {EventEmitter} from 'node:events';
const args=process.argv.slice(2),options={};
for(let i=0;i<args.length;i+=2){if(!args[i].startsWith('--')||args[i+1]===undefined)throw Error('Expected --key value');options[args[i].slice(2)]=args[i+1]}
if(!options.out)throw Error('Required --out fresh-directory');
const root=path.resolve(import.meta.dirname,'../../../../..');
const candidate=path.join(import.meta.dirname,'legacy-effects-v1.json');
const meta=JSON.parse(fs.readFileSync(candidate,'utf8'));
const item=meta.files.find(x=>x.path==='selfhost/src/runtime.mjs');
const runtime=path.resolve(options.runtime??path.join(root,item.candidate));
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const source=fs.readFileSync(runtime);if(hash(source)!==item.afterSha256)throw Error('Not the frozen legacy effect candidate');
const out=path.resolve(options.out);fs.mkdirSync(out,{recursive:false});
const copy=path.join(out,'runtime-observed.mjs');
fs.writeFileSync(copy,source.toString()+"\nexport {G,call,runAction,unlist,socketState};export const observePendingChannels=()=>pendingChannels;\n");
const r=await import(pathToFileURL(copy).href);
const run=(name,args)=>r.runAction(r.call(r.G[name],args));
const cases=[];
async function test(name,body){const start=performance.now();let timer;
 try{await Promise.race([body(),new Promise((_,reject)=>{timer=setTimeout(()=>reject(Error('Control deadline: '+name)),1500)})]);cases.push({name,pass:true,wallMs:performance.now()-start})}
 catch(error){cases.push({name,pass:false,error:String(error?.stack??error),wallMs:performance.now()-start})}
 finally{clearTimeout(timer)}
}
const tag=(v,k)=>{assert.equal(v?.$,k);return v.a[0]};
const stub=()=>{const s=new EventEmitter();s.destroyed=false;s.write=(_data,cb)=>queueMicrotask(()=>cb());s.send=(_data,_port,_host,cb)=>queueMicrotask(()=>cb());return s};
const state=(udp=false)=>r.socketState(stub(),udp);
await test('channel blocking send returns Done, receive keeps exact value',async()=>{
 const c=await run('Chan.new',[null,1]),value={owned:1};tag(await run('Chan.send',[null,c,value]),'Done');assert.equal(tag(await run('Chan.recv',[null,c]),'Some'),value);await run('Chan.close',[null,c]);tag(await run('Chan.recv',[null,c]),'None');
});
await test('closed channel send returns Fail with original value',async()=>{
 const c=await run('Chan.new',[null,0]),value={owned:2};await run('Chan.close',[null,c]);assert.equal(tag(await run('Chan.send',[null,c,value]),'Fail'),value);assert.equal(tag(tag(await run('Chan.try_send',[null,c,value,0]),'Ready'),'Fail'),value);
});
await test('zero-time channel refusal does not enqueue or consume',async()=>{
 const c=await run('Chan.new',[null,0]),value={owned:3};assert.equal(tag(await run('Chan.try_send',[null,c,value,0]),'Wait'),value);tag(await run('Chan.try_recv',[null,c,0]),'Wait');assert.equal(c.senders.length+c.receivers.length,0);
});
await test('timed channel send wakes exactly once and cancels timer',async()=>{
 const c=await run('Chan.new',[null,0]),value={owned:4};const send=run('Chan.try_send',[null,c,value,100]);assert.equal(tag(await run('Chan.recv',[null,c]),'Some'),value);tag(tag(await send,'Ready'),'Done');assert.equal(c.senders.length,0);
});
await test('timed channel receive wakes exactly once',async()=>{
 const c=await run('Chan.new',[null,0]),value={owned:5};const recv=run('Chan.try_recv',[null,c,100]);tag(await run('Chan.send',[null,c,value]),'Done');assert.equal(tag(tag(await recv,'Ready'),'Some'),value);assert.equal(c.receivers.length,0);
});
await test('timed channel send expiry returns original rest and removes waiter',async()=>{
 const c=await run('Chan.new',[null,0]),value={owned:6};assert.equal(tag(await run('Chan.try_send',[null,c,value,2]),'Wait'),value);tag(await run('Chan.try_recv',[null,c,0]),'Wait');assert.equal(c.senders.length,0);
});
await test('timed channel receive expiry returns Unit and removes waiter',async()=>{
 const c=await run('Chan.new',[null,0]);tag(tag(await run('Chan.try_recv',[null,c,2]),'Wait'),'Unit');assert.equal(c.receivers.length,0);
});
await test('closing wakes timed and ordinary parked sends with Fail',async()=>{
 const c=await run('Chan.new',[null,0]),x={x:1},y={y:2};const a=run('Chan.send',[null,c,x]),b=run('Chan.try_send',[null,c,y,100]);await run('Chan.close',[null,c]);assert.equal(tag(await a,'Fail'),x);assert.equal(tag(tag(await b,'Ready'),'Fail'),y);
});
await test('closing wakes timed and ordinary parked receivers with None',async()=>{
 const c=await run('Chan.new',[null,0]);const a=run('Chan.recv',[null,c]),b=run('Chan.try_recv',[null,c,100]);await run('Chan.close',[null,c]);tag(await a,'None');tag(tag(await b,'Ready'),'None');
});
await test('legacy fork/join retains result after Chan.send ABI change',async()=>{
 const value={forked:1},action=r.call(r.G['IO.pure'],[null,value]);const c=await run('IO.fork',[null,action]);assert.equal(await run('IO.join',[null,c]),value);
});
await test('TCP bytes receive preserves payload and suffix',async()=>{
 const s=state();s.queue.push(Buffer.from([0,255,128]));const got=await run('TCP.recv_bytes',[s,2]);assert.equal(got[0],s);assert.deepEqual(r.unlist(tag(tag(got[1],'Done'),'Some')),[0,255]);assert.deepEqual([...s.queue[0]],[128]);
});
await test('TCP EOF is Done None and leaves half-close writable',async()=>{
 const s=state();s.socket.emit('end');tag(tag((await run('TCP.recv',[s,8]))[1],'Done'),'None');assert.equal(s.closed,false);tag((await run('TCP.send',[s,'ok']))[1],'Done');
});
await test('TCP try receive/accept zero-time Wait leaves state untouched',async()=>{
 const s=state();tag((await run('TCP.try_recv',[s,8,0]))[1],'Wait');assert.equal(s.waiters.length,0);const listener={queue:[],waiters:[],error:null,closed:false};tag((await run('TCP.try_accept',[listener,0]))[1],'Wait');assert.equal(listener.waiters.length,0);
});
await test('TCP try receive present data and invalid maximum are Ready',async()=>{
 const s=state();s.queue.push(Buffer.from('ok'));assert.equal(tag(tag(tag((await run('TCP.try_recv',[s,8,0]))[1],'Ready'),'Done'),'Some'),'ok');const bad=tag(tag((await run('TCP.try_recv',[s,0,0]))[1],'Ready'),'Fail');assert.equal(bad[0],22);
});
await test('TCP blocking/try accept return the original listener and socket',async()=>{
 const socket=state(),listener={queue:[socket],waiters:[],error:null,closed:false};const a=await run('TCP.accept',[listener]);assert.equal(a[0],listener);assert.equal(tag(a[1],'Done'),socket);listener.queue.push(socket);assert.equal(tag(tag((await run('TCP.try_accept',[listener,0]))[1],'Ready'),'Done'),socket);
});
await test('TCP preflight failure retains complete original send value',async()=>{
 const s=state(),data='kept';s.closed=true;const failed=tag((await run('TCP.send',[s,data]))[1],'Fail');assert.equal(failed[0][0],32);assert.equal(failed[1],data);
});
await test('TCP asynchronous write error explicitly refuses unknown suffix',async()=>{
 const s=state();s.socket.write=(_data,cb)=>queueMicrotask(()=>cb(Object.assign(Error('broken'),{errno:32})));await assert.rejects(run('TCP.send',[s,'payload']),/cannot recover the exact unsent suffix/);
});
await test('UDP byte send emits exact bytes and retains original failure value',async()=>{
 const s=state(true);
 const bytes={$:'Con',a:[0,{$:'Con',a:[255,{$:'Nil',a:[]}]}]};let sent;
 s.socket.send=(data,_port,_host,cb)=>{sent=[...data];queueMicrotask(()=>cb())};tag((await run('UDP.send_bytes_to',[s,'127.0.0.1',9,bytes]))[1],'Done');assert.deepEqual(sent,[0,255]);const failed=tag((await run('UDP.send_bytes_to',[s,'invalid',9,bytes]))[1],'Fail');assert.equal(failed[0][0],22);assert.equal(failed[1],bytes);
});
await test('UDP empty datagram is Done and zero maximum preserves queued data',async()=>{
 const s=state(true),address={address:'127.0.0.1',port:7};s.queue.push([Buffer.alloc(0),address]);const got=tag((await run('UDP.recv_from',[s,8]))[1],'Done');assert.deepEqual(got,['127.0.0.1',[7,'']]);s.queue.push([Buffer.from([1]),address]);const failed=tag((await run('UDP.recv_from',[s,0]))[1],'Fail');assert.equal(failed[0],22);assert.equal(s.queue.length,1);
});
await test('UDP try byte receive preserves address/port and Poll state',async()=>{
 const s=state(true);tag((await run('UDP.try_recv_bytes_from',[s,8,0]))[1],'Wait');s.queue.push([Buffer.from([0,255]),{address:'127.0.0.1',port:7}]);const got=tag(tag((await run('UDP.try_recv_bytes_from',[s,8,0]))[1],'Ready'),'Done');assert.equal(got[0],'127.0.0.1');assert.equal(got[1][0],7);assert.deepEqual(r.unlist(got[1][1]),[0,255]);
});
for(const name of ['TCP.try_send','TCP.try_send_bytes','UDP.try_send_to','UDP.try_send_bytes_to'])await test(name+' refuses before host send',async()=>{
 let touched=0;const socket={get socket(){touched++;throw Error('should not inspect')}};const args=name.startsWith('TCP')?[socket,'x',0]:[socket,'127.0.0.1',9,'x',0];await assert.rejects(run(name,args),new RegExp('cannot cancel queued writes for '+name.replaceAll('.','\\.')));assert.equal(touched,0);
});
await test('all channel wait accounting returns to zero',async()=>assert.equal(r.observePendingChannels(),0));
const report={kind:'phase66-legacy-effects-controls',version:1,pass:cases.every(x=>x.pass),runtime:{path:runtime,sha256:hash(source),bytes:source.length},candidate:{path:candidate,sha256:hash(fs.readFileSync(candidate))},controller:{path:fs.realpathSync(import.meta.filename),sha256:hash(fs.readFileSync(import.meta.filename))},cases};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({pass:report.pass,total:cases.length,failed:cases.filter(x=>!x.pass).map(x=>x.name)}));if(!report.pass)process.exitCode=1;
