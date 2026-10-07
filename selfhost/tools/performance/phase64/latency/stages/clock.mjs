// Diagnostic monotonic wall clocks. No inspector, target import or async wrapper.
import assert from 'node:assert/strict';

export const STAGE_SYMBOL=Symbol.for('bend.phase62.stages');
export function createStageClock({maxEvents=10000}={}) {
  assert.ok(Number.isInteger(maxEvents)&&maxEvents>0);
  const now=performance.now.bind(performance),origin=now(),frames=[],records=[];
  let next=0,last=origin;
  function stamp() {const t=now();assert.ok(t>=last,'Clock moved backwards');last=t;return t;}
  function begin(name) {
    const start=stamp();
    assert.ok(typeof name==='string'&&/^[a-z][a-z0-9.-]{0,95}$/.test(name));
    assert.ok(next<maxEvents,'Diagnostic stage event limit');
    const id=next++;
    frames.push({id,parent:frames.at(-1)?.id??null,name,start,children:0});
    return id;
  }
  function finish(end,incomplete) {
    const f=frames.pop(),duration=end-f.start,exclusive=duration-f.children;
    assert.ok(exclusive>=-1e-7,'Overlapping children');
    if(frames.length)frames.at(-1).children+=duration;
    records.push({id:f.id,parent:f.parent,name:f.name,startMs:f.start-origin,
      endMs:end-origin,inclusiveMs:duration,childMs:f.children,
      exclusiveMs:Math.max(0,exclusive),incomplete});
  }
  function end(token) {
    const time=stamp();
    const at=frames.findLastIndex(f=>typeof token==='number'?f.id===token:f.name===token);
    assert.ok(at>=0,'Unmatched diagnostic stage end: '+token);
    // A source exception/early return may skip a concrete-call end marker.
    // Close that incomplete child without changing the source return or throw.
    while(frames.length-1>at)finish(time,true);
    finish(time,false);
  }
  function snapshot() {
    assert.equal(frames.length,0,'Snapshot inside a stage');
    const events=records.slice().sort((a,b)=>a.id-b.id),roots=events.filter(x=>x.parent===null);
    const rootMs=roots.reduce((s,x)=>s+x.inclusiveMs,0);
    const exclusiveMs=events.reduce((s,x)=>s+x.exclusiveMs,0);
    assert.ok(Math.abs(rootMs-exclusiveMs)<=1e-6*Math.max(1,events.length),'Clock partition does not close');
    for(let i=1;i<roots.length;i++)assert.ok(roots[i].startMs>=roots[i-1].endMs,'Overlapping root intervals');
    const aggregate=new Map();
    for(const e of events) {
      if(!aggregate.has(e.name))aggregate.set(e.name,{name:e.name,calls:0,inclusiveMs:0,exclusiveMs:0,incomplete:0});
      const a=aggregate.get(e.name);a.calls++;a.inclusiveMs+=e.inclusiveMs;a.exclusiveMs+=e.exclusiveMs;a.incomplete+=Number(e.incomplete);
    }
    return {kind:'phase62-exclusive-stage-clock',version:1,diagnosticOnly:true,
      timingScope:'Monotonic wall time including synchronous hook overhead; never add nested inclusive intervals.',
      events,aggregate:[...aggregate.values()],rootMs,exclusiveMs,
      incomplete:events.filter(x=>x.incomplete).length};
  }
  return Object.freeze({version:1,begin,end,snapshot});
}
