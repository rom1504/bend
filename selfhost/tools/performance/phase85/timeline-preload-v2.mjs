// Trace-only bridge: retain ordinary worker/API, add common-clock user marks.
import {performance} from 'node:perf_hooks';
const original=console.log.bind(console),starts=new Map();
console.log=(...args)=>{
  if(typeof args[0]==='string' && args[0].startsWith('P85 ')){
    const row=JSON.parse(args[0].slice(4));
    performance.mark(`P85:${row.phase}:${row.call}`);
    original('P85_CLOCK '+JSON.stringify({job:process.argv[3],pid:process.pid,phase:row.phase,call:row.call,hrtimeUs:Number(process.hrtime.bigint()/1000n),performanceNow:performance.now()}));
    if(row.phase==='request-start')starts.set(row.call,process.cpuUsage());
    if(row.phase==='request-end')original('P85_CPU '+JSON.stringify({call:row.call,cpu:process.cpuUsage(starts.get(row.call))}));
  }
  return original(...args);
};
