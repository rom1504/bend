// Diagnostic observer only. No return forcing or trampoline changes.
let __p166 = null;
function __p166_count(name) { if (__p166) __p166.work[name] = (__p166.work[name] || 0) + 1; }
function __p166_object(tag) { if (__p166) __p166.objects[tag] = (__p166.objects[tag] || 0) + 1; }
function __p166_mark(name) {
  if (!__p166) return;
  __p166_count('entry:' + name);
  if (__p166.seen[name]) return;
  __p166.seen[name] = true;
  __p166.events.push({name, milliseconds:performance.now()-__p166.start,
    work:{...__p166.work}, objects:{...__p166.objects}});
}
export function p166_begin(role) {
  if (__p166) throw new Error('Overlapping diagnostic regions');
  __p166={role,start:performance.now(),work:Object.create(null),objects:Object.create(null),seen:Object.create(null),events:[]};
  __p166_mark('backend_begin');
}
export function p166_end() {
  if (!__p166) throw new Error('Diagnostic region absent');
  __p166_mark('backend_end');
  const state=__p166; __p166=null;
  const intervals=[];
  for(let i=1;i<state.events.length;i++) {
    const a=state.events[i-1],b=state.events[i];
    const delta=(x,y)=>Object.fromEntries(Object.keys(y).map(k=>[k,y[k]-(x[k]||0)]).filter(([,n])=>n));
    intervals.push({begin:a.name,end:b.name,milliseconds:b.milliseconds-a.milliseconds,
      work:delta(a.work,b.work),objects:delta(a.objects,b.objects)});
  }
  const required=['p144o_prepared','p111_compile_defs','p140or_finish','nq_signatures','p113pl_candidates',
    'p128raw_plan_finish','p126sc_candidates','p113d_passes','p128raw_session_finish',
    'p114s_open','p114s_inline','p134v_commit','p146c_verify','p128raw_verified',
    'p134e_begin','p134e_prepare','p134e_registered','p134e_next'];
  const observed=state.events.map(e=>e.name),positions=required.map(n=>observed.indexOf(n));
  return {role:state.role,work:state.work,objects:state.objects,events:state.events,intervals,
    qbeStageOrder:state.role==='qbe'?{required,positions,admitted:positions.every((p,i)=>p>=0&&(!i||p>positions[i-1]))}:null,
    units:'work: executed named JS entries or explicit nonempty-row visits; objects: literal tagged-object construction-site events, not native allocation calls/bytes or retained objects',
    scope:'Adjacent first-entry intervals partition this observed backend clock. They include descendant, continuation, observer, IO and GC work. No inclusive function-duration claim.'};
}
