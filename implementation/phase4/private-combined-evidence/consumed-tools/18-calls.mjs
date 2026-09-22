// Compiler-private specialization. This is not a public library transformation.
import {tokenize} from "./tokens.mjs";
import {primitiveExpressions,assertRuntime} from "./primitives.mjs";
function edit(source, edits) {
  for (const e of edits.sort((a,b)=>b.start-a.start)) source=source.slice(0,e.start)+e.text+source.slice(e.end);
  return source;
}
function bodyToPositional(body, arity) {
  const ts=tokenize(body), edits=[];
  if(ts.some(t=>['this','arguments','eval'].includes(t.text)))return null;
  for(let i=0;i<ts.length;i++) {
    if(ts[i].text==='function') {
      const p=ts[i+1]?.text==='('?i+1:i+2, end=ts[p]?.close;
      if(end!==undefined&&ts.slice(p+1,end).some(t=>t.text==='a')&&ts[end+1]?.text==='{'){i=ts[end+1].close;continue;}
    }
    if(ts[i].text!=='a'||ts[i-1]?.text==='.')continue;
    const n=Number(ts[i+2]?.text);
    if(ts[i+1]?.text!=='['||ts[i+3]?.text!==']'||!/^\d+$/.test(ts[i+2]?.text??'')||n>=arity)return null;
    edits.push({start:ts[i].start,end:ts[i+3].end,text:'privateArg'+n});i+=3;
  }
  return edit(body,edits);
}
export function transformPrivateCalls(source,{exports=[],mode='combined'}={}) {
  if(!['control','calls','scalars','combined'].includes(mode))throw Error('Unknown private mode');
  if(source.includes('privateImageMarker'))throw Error('Already private');
  const ending='export {G,call,list,ctor};\nexport default Object.fromEntries(Object.keys(G).map(k=>[k,(...args)=>call(get(G,k),args)]));';
  if(source.split(ending).length!==2)throw Error('Expected exact self-emitted public ABI');
  if(!exports.length||exports.some(x=>typeof x!=='string')||new Set(exports).size!==exports.length)throw Error('Explicit unique host export list required');
  const workers=new Map(), lines=source.split('\n');
  const stats={mode,workers:0,calls:0,tails:0,scalarCalls:0,scalarTails:0,byName:{},skippedDefinitions:0,contract:'private inspect worker only; no public G/function objects'};
  const declared=new Set([...source.matchAll(/^G\[("(?:\\.|[^"\\])*")\]=/gm)].map(m=>JSON.parse(m[1])));
  if(mode==='calls'||mode==='combined')for(const line of lines) {
    const m=/^G\[("(?:\\.|[^"\\])*")\]=fn\((\d+),function\(a\)\{/.exec(line);
    if(!m||!line.endsWith('});')||Number(m[2])===0)continue;
    const ts=tokenize(line),open=ts.findIndex(t=>t.start===m[0].length-1),close=ts[open].close;
    if(ts[close+1]?.text!==')'||ts[close+2]?.text!==';'||close+3!==ts.length){stats.skippedDefinitions++;continue;}
    const arity=Number(m[2]),body=bodyToPositional(line.slice(m[0].length,-3),arity);
    if(body===null){stats.skippedDefinitions++;continue;}
    const name=JSON.parse(m[1]);if(workers.has(name))throw Error('Repeated global definition '+name);
    workers.set(name,{arity,body,id:workers.size,kind:'worker',leaf:arity===1&&/^return privateArg0\.a\[\d+\];$/.test(body)});
  }
  stats.workers=workers.size;
  const primitives=new Map();
  if(mode==='scalars'||mode==='combined') {
    // Refuse a runtime whose retained primitive semantics are not recognized.
    assertRuntime(source);
    for(const [name,[arity,expression]] of Object.entries(primitiveExpressions))if(!declared.has(name))primitives.set(name,{arity,expression,id:primitives.size,kind:'scalar'});
  }
  const rewrite=line=>{
    const ts=tokenize(line),edits=[];
    for(let i=0;i<ts.length;i++) {
      const tail=ts[i].text==='jump';if(ts[i].text!=='call'&&!tail)continue;
      if(ts.slice(i+1,i+6).map(t=>t.text).join(' ')!=='( get ( G ,')continue;
      if(ts[i+7]?.text!==')'||ts[i+8]?.text!==','||ts[i+9]?.text!=='[')continue;
      let name;try{name=JSON.parse(ts[i+6].text);}catch{continue;}
      const target=workers.get(name)||primitives.get(name);if(!target)continue;
      const end=ts[i+9].close;if(end+1!==ts[i+1].close)continue;
      let count=0,valid=true;
      for(let j=i+10;j<end;) {
        count++;if(ts[j].text==='.'&&ts[j+1]?.text==='.'){valid=false;break;}
        while(j<end&&ts[j].text!==',')j=ts[j].close===undefined?j+1:ts[j].close+1;
        if(j<end)j++;
      }
      if(!valid||count!==target.arity)continue;
      const method=target.kind==='worker'?(target.leaf?'privateWorker':tail?'privateTail':'privateCall'):(tail?'privateScalarTail':'privateScalar');
      edits.push({start:ts[i].start,end:ts[i+9].end,text:method+target.id+'('},{start:ts[end].start,end:ts[end].end,text:''});
      stats[target.kind==='worker'?(tail?'tails':'calls'):(tail?'scalarTails':'scalarCalls')]++;
      stats.byName[name]=(stats.byName[name]??0)+1;
    }
    return edit(line,edits);
  };
  // Only deferred generated definitions. Never transform runtime or quoted
  // generated-code strings, and never run workers during eager initialization.
  let result=lines.map(line=>/^G\["(?:\\.|[^"\\])*"\]=(?:fn\(\d+,function\(|matcher(?:1)?\()/.test(line)?rewrite(line):line).join('\n');
  if(workers.size) {
    const branch='if(x?.bounce){x=apply(x.f,x.args);continue}';
    if(result.split(branch).length!==2)throw Error('Unknown trampoline');
    result=result.replace(branch,'if(x?.bounce){x=x.privateWorker?x.privateWorker(...x.args):apply(x.f,x.args);continue}');
  }
  for(const w of workers.values()) {
    const args=Array.from({length:w.arity},(_,i)=>'privateArg'+i).join(',');
    result+=`\nfunction privateWorker${w.id}(${args}){${rewrite(w.body)}}\nfunction privateCall${w.id}(${args}){return force(privateWorker${w.id}(${args}));}\nfunction privateTail${w.id}(${args}){return {bounce:true,privateWorker:privateWorker${w.id},args:[${args}]};}\n`;
  }
  for(const p of primitives.values()) {
    const args=p.arity===1?'a':'a,b';
    result+=`\nfunction privateScalar${p.id}(${args}){return force(${p.expression});}\nfunction privateScalarTail${p.id}(${args}){return ${p.expression};}\n`;
  }
  const boundary=`// privateImageMarker: trusted worker-internal data ABI, NOT a public module.\nfor(const value of Object.values(G)){if(value&&typeof value==='object'){if(Array.isArray(value.bound))Object.freeze(value.bound);Object.freeze(value);}}\nObject.freeze(G);\nconst privateApi=Object.freeze(Object.fromEntries(${JSON.stringify(exports)}.map(k=>{if(!Object.hasOwn(G,k))throw Error('Missing private host export: '+k);return [k,(...args)=>call(get(G,k),args)];})));\nconst privatePositionalAbiMarker=Object.freeze({privateCompilerImage:true});\nexport {privatePositionalAbiMarker as G,ctor};\nexport default privateApi;`;
  result=result.replace(ending,boundary);
  return {source:result,stats};
}