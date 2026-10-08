#!/usr/bin/env python3
"""Isolated legacy Node effect migration; source construction only."""
from pathlib import Path
import hashlib,json,difflib
root=Path(__file__).resolve().parents[5];out=Path(__file__).resolve().parent
before={};after={}
def original(path):
    prior=out/'candidate-v1'/path
    return prior.read_text() if prior.exists() else (root/path).read_text()
def edit(path,old,new):
    if path not in before:before[path]=original(path);after[path]=before[path]
    assert after[path].count(old)==1,(path,old,after[path].count(old))
    after[path]=after[path].replace(old,new)
E='selfhost/src/runtime/js/effects.mjs'
s=original(E)
a=s.index('function channel(room)'); b=s.index("effect('IO.fork'",a)
channel=r"""const pollReady=x=>ctor('Ready',[x]),pollWait=x=>ctor('Wait',[x]);
const channelAnswer=(ms,x)=>ms===undefined?x:pollReady(x);
function channel(room){return {room,values:[],senders:[],receivers:[],closed:false}}
function channelPark(queue,item,ms,rest){
  return new Promise(resolve=>{
    let timer,settled=false;
    const row={item,finish:value=>{if(settled)return;settled=true;clearTimeout(timer);
      const i=queue.indexOf(row);if(i>=0)queue.splice(i,1);pendingChannels--;resolve(value)}};
    pendingChannels++;queue.push(row);
    row.wake=value=>row.finish(channelAnswer(ms,value));
    if(ms!==undefined)timer=setTimeout(()=>row.finish(pollWait(rest)),ms);
  });
}
function channelSend(c,v,ms){
  if(c.closed)return channelAnswer(ms,ctor('Fail',[v]));
  if(c.receivers.length){c.receivers[0].wake(some(v));return channelAnswer(ms,done(unit))}
  if(c.values.length<c.room){c.values.push(v);return channelAnswer(ms,done(unit))}
  if(ms===0)return pollWait(v);
  return channelPark(c.senders,v,ms,v);
}
function channelRecv(c,ms){
  if(c.values.length){const v=c.values.shift();if(c.senders.length){const s=c.senders[0];c.values.push(s.item);s.wake(done(unit))}return channelAnswer(ms,some(v))}
  if(c.senders.length){const s=c.senders[0],v=s.item;s.wake(done(unit));return channelAnswer(ms,some(v))}
  if(c.closed)return channelAnswer(ms,none());
  if(ms===0)return pollWait(unit);
  return channelPark(c.receivers,undefined,ms,unit);
}
function channelClose(c){c.closed=true;for(const r of [...c.receivers])r.wake(none());for(const s of [...c.senders])s.wake(ctor('Fail',[s.item]));return unit}
effect('Chan.new',2,(_t,room)=>channel(room));effect('Chan.send',3,(_t,c,v)=>channelSend(c,v));effect('Chan.recv',2,(_t,c)=>channelRecv(c));effect('Chan.close',2,(_t,c)=>channelClose(c));
effect('Chan.try_send',4,(_t,c,v,ms)=>channelSend(c,v,ms));effect('Chan.try_recv',3,(_t,c,ms)=>channelRecv(c,ms));
"""
edit(E,s[a:b],channel)
edit(E,"socket.on('end',()=>{s.closed=true;wake()})", "socket.on('end',()=>{s.ended=true;wake()})")
old="function ready(s,ms){if(s.queue.length||s.error||s.closed)return Promise.resolve(true);return new Promise(resolve=>{let timer;const wake=()=>{clearTimeout(timer);const i=s.waiters.indexOf(wake);if(i>=0)s.waiters.splice(i,1);resolve(s.queue.length>0||s.error!==null||s.closed)};s.waiters.push(wake);if(ms!==undefined)timer=setTimeout(wake,ms)})}"
new="function ready(s,ms){if(s.queue.length||s.error||s.closed||s.ended)return Promise.resolve(true);if(ms===0)return Promise.resolve(false);return new Promise(resolve=>{let timer;const wake=()=>{clearTimeout(timer);const i=s.waiters.indexOf(wake);if(i>=0)s.waiters.splice(i,1);resolve(s.queue.length>0||s.error!==null||s.closed||!!s.ended)};s.waiters.push(wake);if(ms!==undefined)timer=setTimeout(wake,ms)})}"
edit(E,old,new)
edit(E,"effect('TCP.accept',1,async s=>{await ready(s);return [s,s.queue.length?done(s.queue.shift()):fail(s.error??9)]});", "async function tcpAccept(s,ms){const got=await ready(s,ms);return [s,got?channelAnswer(ms,s.queue.length?done(s.queue.shift()):fail(s.error??9)):pollWait(unit)]}\neffect('TCP.accept',1,s=>tcpAccept(s));effect('TCP.try_accept',2,(s,ms)=>tcpAccept(s,ms));")
a=after[E].index("effect('TCP.send',2,");b=after[E].index("effect('UDP.bind'",a)
network=r"""// Node can report an asynchronous stream failure after an unknown prefix was
// accepted by the kernel. Do not invent the new ABI's exact unsent suffix.
const sendFailure=(error,rest)=>ctor('Fail',[[fail(error).a[0],rest]]);
function tcpSend(s,data,bytes=false){
  const values=bytes?unlist(data):null;
  if(bytes&&values.some(n=>n>255))return [s,sendFailure(22,data)];
  if(s.closed||s.socket.destroyed)return [s,sendFailure(32,data)];
  return new Promise((resolve,reject)=>{
    try{s.socket.write(bytes?Buffer.from(values):data,error=>{
      if(error){reject(Error('legacy Node cannot recover the exact unsent suffix after a TCP write error; use the direct backend'));return}
      resolve([s,done(unit)]);
    })}catch(error){reject(error)}
  });
}
async function tcpRead(s,max,ms,bytes=false){
  if(max===0)return [s,channelAnswer(ms,fail(22))];
  const got=await ready(s,ms);if(!got)return [s,pollWait(unit)];
  if(s.error)return [s,channelAnswer(ms,fail(s.error))];
  if(!s.queue.length)return [s,channelAnswer(ms,done(none()))];
  let b=s.queue.shift();if(b.length>max){s.queue.unshift(b.subarray(max));b=b.subarray(0,max)}
  return [s,channelAnswer(ms,done(some(bytes?list([...b]):b.toString('utf8'))))];
}
effect('TCP.send',2,(s,data)=>tcpSend(s,data));effect('TCP.send_bytes',2,(s,data)=>tcpSend(s,data,true));
effect('TCP.recv',2,(s,max)=>tcpRead(s,max));effect('TCP.recv_bytes',2,(s,max)=>tcpRead(s,max,undefined,true));
effect('TCP.try_recv',3,(s,max,ms)=>tcpRead(s,max,ms));effect('TCP.try_recv_bytes',3,(s,max,ms)=>tcpRead(s,max,ms,true));
// A queued Node write cannot be cancelled at a deadline. Returning Wait with
// those bytes would let the caller send a duplicate; refuse before sending any.
const noTimedSend=name=>bad('legacy Node cannot cancel queued writes for '+name+'; use the direct backend');
effect('TCP.try_send',3,()=>noTimedSend('TCP.try_send'));effect('TCP.try_send_bytes',3,()=>noTimedSend('TCP.try_send_bytes'));
"""
edit(E,after[E][a:b],network)
a=after[E].index("effect('UDP.send_to',4,");b=after[E].index("effect('Socket.close'",a)
udp=r"""function udpSend(s,host,port,data,bytes=false){
  const values=bytes?unlist(data):null;
  if(!addressValid(host,port)||bytes&&values.some(n=>n>255))return [s,sendFailure(22,data)];
  if(s.closed)return [s,sendFailure(9,data)];
  return new Promise(resolve=>{try{s.socket.send(bytes?Buffer.from(values):Buffer.from(data),port,host,error=>resolve([s,error?sendFailure(error,data):done(unit)]))}catch(error){resolve([s,sendFailure(error,data)])}});
}
async function udpRead(s,max,ms,bytes=false){
  if(max===0)return [s,channelAnswer(ms,fail(22))];
  const got=await ready(s,ms);if(!got)return [s,pollWait(unit)];
  if(s.error)return [s,channelAnswer(ms,fail(s.error))];
  if(!s.queue.length)return [s,channelAnswer(ms,fail(9))];
  const [b,r]=s.queue.shift(),part=b.subarray(0,max),v=[r.address,[r.port,bytes?list([...part]):part.toString('utf8')]];
  return [s,channelAnswer(ms,done(v))];
}
effect('UDP.send_to',4,(s,h,p,d)=>udpSend(s,h,p,d));effect('UDP.send_bytes_to',4,(s,h,p,d)=>udpSend(s,h,p,d,true));
effect('UDP.recv_from',2,(s,max)=>udpRead(s,max));effect('UDP.recv_bytes_from',2,(s,max)=>udpRead(s,max,undefined,true));
effect('UDP.try_recv_from',3,(s,max,ms)=>udpRead(s,max,ms));effect('UDP.try_recv_bytes_from',3,(s,max,ms)=>udpRead(s,max,ms,true));
effect('UDP.try_send_to',5,()=>noTimedSend('UDP.try_send_to'));effect('UDP.try_send_bytes_to',5,()=>noTimedSend('UDP.try_send_bytes_to'));
"""
edit(E,after[E][a:b],udp)
F='selfhost/src/back/js/foreign.bend'
edit(F,'|Chan.recv|Chan.close|','|Chan.recv|Chan.try_send|Chan.try_recv|Chan.close|')
edit(F,'|TCP.accept|TCP.connect|TCP.send|TCP.recv|TCP.send_bytes|TCP.recv_bytes|TCP.poll|UDP.bind|UDP.send_to|UDP.recv_from|UDP.poll|','|TCP.accept|TCP.try_accept|TCP.connect|TCP.send|TCP.try_send|TCP.recv|TCP.try_recv|TCP.send_bytes|TCP.try_send_bytes|TCP.recv_bytes|TCP.try_recv_bytes|UDP.bind|UDP.send_to|UDP.try_send_to|UDP.send_bytes_to|UDP.try_send_bytes_to|UDP.recv_from|UDP.try_recv_from|UDP.recv_bytes_from|UDP.try_recv_bytes_from|')
C='selfhost/src/runtime/js/core.mjs'
edit(C,"'Maybe','Result','Token'", "'Maybe','Result','Poll','Token'")
R='selfhost/src/runtime.mjs';parts=['core','base','effects','readback','foreign'];prefix='selfhost/src/runtime/js/';header='// Generated by src/runtime/js/build.mjs; edit the fragments.\n'
before[R]=original(R)
assert header+'\n'.join(original(prefix+n+'.mjs') for n in parts)==before[R]
after[R]=header+'\n'.join(after.get(prefix+n+'.mjs',original(prefix+n+'.mjs')) for n in parts)
rows=[];patch=[];sha=lambda s:hashlib.sha256(s.encode()).hexdigest()
for path in sorted(after):
    b=out/'legacy-effects-before-v1'/path;a=out/'legacy-effects-candidate-v1'/path
    b.parent.mkdir(parents=True,exist_ok=True);a.parent.mkdir(parents=True,exist_ok=True)
    assert not b.exists() and not a.exists()
    b.write_text(before[path]);a.write_text(after[path])
    rows.append({'path':path,'beforeSha256':sha(before[path]),'afterSha256':sha(after[path]),'beforeBytes':len(before[path].encode()),'afterBytes':len(after[path].encode()),'candidate':str(a.relative_to(root))})
    patch+=list(difflib.unified_diff(before[path].splitlines(True),after[path].splitlines(True),fromfile='a/'+path,tofile='b/'+path))
p=out/'legacy-effects-v1.patch';p.write_text(''.join(patch))
m={'kind':'phase66-legacy-effects-candidate','version':1,'status':'isolated-unexecuted','requires':'backend-v1','patchSha256':sha(p.read_text()),'files':rows,'unsupportedNewOperations':['TCP.try_send','TCP.try_send_bytes','UDP.try_send_to','UDP.try_send_bytes_to'],'remainingLimitation':'An asynchronous TCP write error cannot reveal the exact unsent suffix in Node. Refuse that ambiguous failure instead of fabricating a payload; normal blocking sends and preflight failures retain support.'}
(out/'legacy-effects-v1.json').write_text(json.dumps(m,indent=2)+'\n')
print(json.dumps({'files':len(rows),'patchSha256':m['patchSha256']},indent=2))
