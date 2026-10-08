// Host effects. Programs call these primitives after Bend2 elaboration/emission.
// This module does not parse, check, interpret or compile Bend source.
const spawned=new Set();
let pendingChannels=0;
async function runAction(m){
  const continuations=[];
  for(;;){
    m=force(m);
    if(m?.ioBind){continuations.push(m.k);m=m.m;continue}
    let value;
    if(m?.io){value=m.io();if(value?.then)value=await value}
    else{
      let op=call(m,[null,fn(1,a=>ctor('Emit',a))]);
      for(;;){
        op=force(op);
        if(op?.request){op=call(op.k,[await runAction(op.action)]);continue}
        if(op?.$==='Emit'){value=op.a[0];break}
        if(op?.$==='Halt')halt(...op.a);
        bad('expected IO action');
      }
    }
    if(!continuations.length)return value;
    m=continuations.pop()(value);
  }
}
function spawnIO(m){const p=new Promise((resolve,reject)=>setImmediate(()=>runAction(m).then(resolve,reject)));spawned.add(p);p.then(()=>spawned.delete(p),()=>{});return unit}
function halt(code,message){const e=Error(message);e.exitCode=code;e.rawMessage=true;throw e}
native('IO.pure',2,(_t,x)=>pure(x));native('IO.bind',4,(_a,_b,m,k)=>bind(m,x=>call(k,[x])));
native('IO.try',2,(_t,m)=>bind(m,r=>r.$==='Fail'?{io:async()=>halt(...r.a[0])}:pure(r.a[0])));
native('IO.pass',2,(_t,r)=>r.$==='Fail'?{io:async()=>halt(...r.a[0])}:pure(r.a[0]));
effect('IO.die',3,(_t,code,msg)=>halt(code,msg));
function runtimeOptions(){const args=[process.argv[1]],argv=process.argv.slice(2);let help=false;for(let i=0;i<argv.length;i++){if(argv[i]==='--'){args.push(...argv.slice(i+1));break}if(argv[i]==='--bend-help'){help=true;break}if(argv[i]==='--threads'||argv[i]==='--gpu'){i++;continue}args.push(argv[i])}return {args,help}}
effect('IO.args',0,()=>list(runtimeOptions().args));
effect('IO.print',1,s=>{fs.writeSync(1,s+'\n');return unit});effect('IO.write',1,s=>{fs.writeSync(1,s);return unit});effect('IO.print_err',1,s=>{fs.writeSync(2,s+'\n');return unit});
effect('IO.get_env',1,k=>!k.includes('\0')&&Object.hasOwn(process.env,k)?done(process.env[k]):fail(2));
effect('IO.thread_count',0,()=>1);
effect('IO.now',0,()=>BigInt(Date.now()));effect('IO.sleep',1,ms=>new Promise(r=>setTimeout(()=>r(unit),ms)));
effect('IO.random_u32',0,()=>result(()=>randomBytes(4).readUInt32LE()));
effect('IO.spawn',2,(_t,m)=>spawnIO(m));
const pollReady=x=>ctor('Ready',[x]),pollWait=x=>ctor('Wait',[x]);
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
effect('IO.fork',2,(_t,m)=>{const c=channel(1);spawnIO(bind(m,v=>({io:async()=>channelSend(c,v)})));return c});
effect('IO.join',2,async(_t,c)=>{const r=await channelRecv(c);channelClose(c);if(r.$==='None')halt(1,'IO.join: the channel was closed');return r.a[0]});
effect('File.open',2,(p,m)=>p.includes('\0')?fail(process.platform==='darwin'?92:84):!['r','w','a'].includes(m)?fail(22):result(()=>fs.openSync(p,m,0o644)));
function fileRead(f,max,position=null,bytes=false){return [f,result(()=>{const b=Buffer.alloc(Math.min(max,2147483647));const n=fs.readSync(f,b,0,b.length,position);return bytes?list([...b.subarray(0,n)]):b.toString('utf8',0,n)})]}
function fileWrite(f,b){return [f,result(()=>{let at=0;while(at<b.length){const n=fs.writeSync(f,b,at,b.length-at,null);if(n===0)throw Object.assign(Error('short write'),{errno:5});at+=n}return unit})]}
effect('File.read',2,(f,max)=>fileRead(f,max));effect('File.read_bytes',2,(f,max)=>fileRead(f,max,null,true));effect('File.read_at',3,(f,at,max)=>fileRead(f,max,at,true));
effect('File.size',1,f=>[f,result(()=>{const n=fs.fstatSync(f).size;if(n>4294967295)throw {errno:process.platform==='darwin'?84:75};return n})]);
effect('File.write',2,(f,s)=>fileWrite(f,Buffer.from(s)));
effect('File.write_bytes',2,(f,x)=>{const a=unlist(x);return a.some(n=>n>255)?[f,fail(22)]:fileWrite(f,Buffer.from(a))});
effect('File.close',1,f=>{try{fs.closeSync(f)}catch{}return unit});
// Node streams supply portable readiness notification; handles retain unread bytes.
function socketState(socket,udp=false){const s={socket,udp,queue:[],waiters:[],closed:false,error:null};const wake=()=>{for(const f of s.waiters.splice(0))f()};s.wake=wake;socket.on('error',e=>{s.error=e;wake()});socket.on('close',()=>{s.closed=true;wake()});if(udp)socket.on('message',(b,r)=>{s.queue.push([b,r]);wake()});else{socket.on('data',b=>{s.queue.push(b);wake()});socket.on('end',()=>{s.ended=true;wake()})}return s}
function ready(s,ms){if(s.queue.length||s.error||s.closed||s.ended)return Promise.resolve(true);if(ms===0)return Promise.resolve(false);return new Promise(resolve=>{let timer;const wake=()=>{clearTimeout(timer);const i=s.waiters.indexOf(wake);if(i>=0)s.waiters.splice(i,1);resolve(s.queue.length>0||s.error!==null||s.closed||!!s.ended)};s.waiters.push(wake);if(ms!==undefined)timer=setTimeout(wake,ms)})}
const addressValid=(host,port)=>net.isIPv4(host)&&Number.isInteger(port)&&port<=65535;
effect('TCP.listen',2,(host,port)=>!addressValid(host,port)?fail(22):new Promise(resolve=>{const server=net.createServer();const s={server,queue:[],waiters:[],error:null,closed:false};server.on('connection',c=>{s.queue.push(socketState(c));for(const f of s.waiters.splice(0))f()});server.on('error',e=>{s.error=e;for(const f of s.waiters.splice(0))f()});server.once('error',e=>resolve(fail(e)));server.listen(port,host,()=>resolve(done(s)))}));
async function tcpAccept(s,ms){const got=await ready(s,ms);return [s,got?channelAnswer(ms,s.queue.length?done(s.queue.shift()):fail(s.error??9)):pollWait(unit)]}
effect('TCP.accept',1,s=>tcpAccept(s));effect('TCP.try_accept',2,(s,ms)=>tcpAccept(s,ms));
effect('TCP.connect',2,(host,port)=>!addressValid(host,port)?fail(22):new Promise(resolve=>{const socket=net.createConnection({host,port});const s=socketState(socket);socket.once('connect',()=>resolve(done(s)));socket.once('error',e=>resolve(fail(e)))}));
// Node can report an asynchronous stream failure after an unknown prefix was
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
effect('UDP.bind',2,(host,port)=>!addressValid(host,port)?fail(22):new Promise(resolve=>{const socket=dgram.createSocket('udp4');const s=socketState(socket,true);socket.once('error',e=>resolve(fail(e)));socket.bind(port,host,()=>resolve(done(s)))}));
function udpSend(s,host,port,data,bytes=false){
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
effect('Socket.close',1,s=>{s.closed=true;s.udp?s.socket.close():s.socket.destroy();s.wake();return unit});
effect('Listener.close',1,s=>{s.closed=true;s.server.close();for(const f of s.waiters.splice(0))f();return unit});
effect('Window.open',3,()=>ctor('Fail',[[process.platform==='darwin'?45:95,'Window.open: no display (build a native binary with bend <file> -o <out> and run it from a desktop session)']]));
effect('Window.grab',2,w=>w);
effect('Window.frame',2,(w,i)=>[w,[i,list([])]]);effect('Window.set_title',2,w=>w);effect('Window.close',1,()=>unit);
effect('Audio.open',1,rate=>rate<8000||rate>192000?fail(22):done({rate,queued:0,at:Date.now()}));
effect('Audio.write',2,(a,xs)=>{const n=unlist(xs).length,now=Date.now();a.queued=Math.max(0,a.queued-(now-a.at)*a.rate/1000);a.at=now;if(a.queued+n/2<=4096)a.queued+=n/2;return [a,Math.floor(a.queued)]});effect('Audio.close',1,()=>unit);

// Process.run owns only its direct child. Completion follows child exit, not
// pipe closure: descendants may inherit stdout/stderr indefinitely.
effect('Process.run',5,(program,args,input,maxOutput,timeoutMs)=>{
  const argv=unlist(args);
  if(!maxOutput||!timeoutMs||[program,...argv].some(arg=>arg.includes('\0')))return fail(22);
  return new Promise(resolve=>{
    let child,complete=false,total=0,timer;const out=[],err=[];
    const finish=(error,code=0)=>{
      if(complete)return;complete=true;clearTimeout(timer);
      child?.stdin.destroy();child?.stdout.destroy();child?.stderr.destroy();
      if(error)child?.kill('SIGKILL');
      resolve(error?fail(error):done([code,[Buffer.concat(out).toString('utf8'),Buffer.concat(err).toString('utf8')]]));
    };
    try{child=spawn(program,argv,{stdio:['pipe','pipe','pipe']});}catch(error){finish(error);return}
    const collect=(parts,bytes)=>{if(complete)return;total+=bytes.length;if(total>maxOutput)finish(27);else parts.push(bytes)};
    child.stdout.on('data',bytes=>collect(out,bytes));child.stderr.on('data',bytes=>collect(err,bytes));
    child.on('error',error=>finish(error));
    child.on('exit',(code,signal)=>setImmediate(()=>finish(null,code??128+(hostConstants.signals[signal]??0))));
    child.stdin.on('error',error=>{if(error.code!=='EPIPE')finish(error)});
    timer=setTimeout(()=>finish(process.platform==='darwin'?60:110),timeoutMs);
    child.stdin.end(Buffer.from(input));
  });
});
