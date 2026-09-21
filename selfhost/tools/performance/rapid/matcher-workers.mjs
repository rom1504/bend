/** Diagnostic fusion of literal matcher arm workers. A matching constructor
 * still goes through fields/project and a defensive slice. Only the temporary
 * fn wrapper and arm-application bounce are omitted on exact positive arity.
 * Zero fields, erased/eta-short mismatches and computed arms keep generic ABI.
 */
import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
import {tokenizeGeneratedDefinition as tokenize} from './direct-calls.mjs';

export function transformMatcherWorkers(source,{chains=false}={}){
 if(source.includes('function rapidMatcher1('))throw Error('Matcher transform already applied');
 for(const required of [
  'function matcher1(name,arm){return fn(1,([x])=>{const a=project(name,x);return a.length?jump(arm(),a):arm()})}',
  'function matcher(name,arm,other){return fn(1,([x])=>{const a=fields(name,x);return a===null?jump(other(),[x]):a.length?jump(arm(),a):arm()})}'
 ])if(!source.includes(required))throw Error('Unexpected matcher runtime');
 const stats={matchers:0,matcher1:0,byConstructor:{},skippedComputedOrNonliteral:0};
 const result=source.split('\n').map(line=>{
  if(!/^[GF]\[|^if\(!Object\.hasOwn\(G,|^function rapidPosWorker\d+\(/.test(line))return line;
  const ts=tokenize(line),edits=[];
  for(let i=0;i<ts.length;i++){
   const kind=ts[i].text;if(!['matcher','matcher1'].includes(kind)||ts[i+1]?.text!=='(')continue;
   const expected=['(',null,',','(',')','=','>','fn','(',null,',','function','(','a',')','{'];
   if(expected.some((text,j)=>text!==null&&ts[i+1+j]?.text!==text)){stats.skippedComputedOrNonliteral++;continue;}
   let name;try{name=JSON.parse(ts[i+2].text)}catch{stats.skippedComputedOrNonliteral++;continue;}
   if(typeof name!=='string'||!/^\d+$/.test(ts[i+10].text)){stats.skippedComputedOrNonliteral++;continue;}
   const arity=Number(ts[i+10].text),bodyEnd=ts[i+16].close,fnEnd=ts[i+9].close,matchEnd=ts[i+1].close;
   if(arity<=0||fnEnd!==bodyEnd+1||ts[fnEnd]?.text!==')'||(kind==='matcher1'?fnEnd+1!==matchEnd:ts[fnEnd+1]?.text!==',')){stats.skippedComputedOrNonliteral++;continue;}
   edits.push({start:ts[i].start,end:ts[i].end,text:kind==='matcher'?'rapidMatcher':'rapidMatcher1'});
   edits.push({start:ts[i+4].start,end:ts[i+4].start,text:arity+','});
   edits.push({start:ts[i+8].start,end:ts[i+12].start,text:''});
   edits.push({start:ts[fnEnd].start,end:ts[fnEnd].end,text:''});
   stats[kind==='matcher'?'matchers':'matcher1']++;stats.byConstructor[name]=(stats.byConstructor[name]??0)+1;
  }
  for(const e of edits.sort((a,b)=>b.start-a.start))line=line.slice(0,e.start)+e.text+line.slice(e.end);
  return line;
 }).join('\n');
 // After a custom slice, preserve apply's remaining arity behavior without
 // slicing twice. This branch is cold for ordinary constructor field arrays.
 const helpers=`
function rapidMatcherCopied(code,arity,all){
  if(all.length<arity)return fn(arity,code,null,all);
  let result=code.call(null,all.slice(0,arity));
  if(all.length>arity)result=jump(force(result),all.slice(arity));
  return result;
}
function rapidMatcherArm(a,arity,make){
  const size=a.length;
  const code=make();
  if(size===arity){const all=a.slice();return all.length===arity?code.call(null,all):rapidMatcherCopied(code,arity,all);}
  const value=fn(arity,code);return size?jump(value,a):value;
}
function rapidMatcher1(name,arity,make){return fn(1,([x])=>rapidMatcherArm(project(name,x),arity,make));}
function rapidMatcher(name,arity,make,other){return fn(1,([x])=>{const a=fields(name,x);return a===null?jump(other(),[x]):rapidMatcherArm(a,arity,make);});}
`;
 const chained=chains?transformChains(result):{source:result,stats:{chains:0,nodes:0}};
 return {source:chained.source+helpers+(chains?chainHelper:''),stats:{...stats,chainFusion:chained.stats}};
}
// Every hoisted arm/fallback is an explicit zero-argument arrow, whose
// creation is pure. Its body remains deferred until the selected match path.
function transformChains(source){
 const stats={chains:0,nodes:0};
 const result=source.split('\n').map(line=>{
  if(!/^[GF]\[|^if\(!Object\.hasOwn\(G,|^function rapidPosWorker\d+\(/.test(line))return line;
  const ts=tokenize(line),cache=new Map(),candidates=[];
  const span=(start,end)=>[ts[start].start,ts[end-1].end];
  const thunk=(start,end)=>ts.slice(start,start+4).map(t=>t.text).join(' ')==='( ) = >'&&start+4<end;
  function parse(start,end){
   const key=start+':'+end;if(cache.has(key))return cache.get(key);cache.set(key,null);
   const kind=ts[start]?.text;if(!['matcher','matcher1','rapidMatcher','rapidMatcher1'].includes(kind)||ts[start+1]?.text!=='('||ts[start+1].close!==end-1)return null;
   const args=[];for(let j=start+2;j<end-1;){const begin=j;while(j<end-1&&ts[j].text!==',')j=ts[j].close===undefined?j+1:ts[j].close+1;args.push([begin,j]);if(j<end-1)j++;}
   const fused=kind.startsWith('rapid'),project=kind.endsWith('1');
   if(args.length!==(project?2:3)+(fused?1:0)||args[0][1]!==args[0][0]+1)return null;
   let name;try{name=JSON.parse(ts[args[0][0]].text)}catch{return null;}if(typeof name!=='string')return null;
   let arity=null;if(fused){if(args[1][1]!==args[1][0]+1||!/^\d+$/.test(ts[args[1][0]].text))return null;arity=Number(ts[args[1][0]].text);if(arity<=0)return null;}
   const arm=args[fused?2:1];if(!thunk(...arm))return null;
   const node={name,project,arity,arm:span(...arm)};
   if(project){const found={nodes:[node],fallback:null};cache.set(key,found);return found;}
   const other=args[fused?3:2];if(!thunk(...other))return null;
   const nested=parse(other[0]+4,other[1]);
   const found=nested?{nodes:[node,...nested.nodes],fallback:nested.fallback}:{nodes:[node],fallback:span(...other)};
   cache.set(key,found);return found;
  }
  for(let i=0;i<ts.length;i++)if(['matcher','matcher1','rapidMatcher','rapidMatcher1'].includes(ts[i].text)&&ts[i+1]?.text==='('){
   const end=ts[i+1].close+1,chain=parse(i,end);if(chain?.nodes.length>1)candidates.push({start:ts[i].start,end:ts[end-1].end,...chain});
  }
  candidates.sort((a,b)=>a.start-b.start||b.end-a.end);
  function render(start,end){
   let result='',at=start;
   for(const c of candidates){
    if(c.start<at||c.end>end)continue;
    const descriptors=c.nodes.map(n=>'['+[JSON.stringify(n.name),n.project?'true':'false',n.arity===null?'null':n.arity,render(...n.arm)].join(',')+']');
    result+=line.slice(at,c.start)+'rapidMatcherChain(['+descriptors.join(',')+'],'+(c.fallback?render(...c.fallback):'null')+')';
    at=c.end;stats.chains++;stats.nodes+=c.nodes.length;
   }
   return result+line.slice(at,end);
  }
  return render(0,line.length);
 }).join('\n');
 return {source:result,stats};
}
const chainHelper=`
function rapidMatcherChain(nodes,other){return fn(1,([x])=>{
  for(const [name,one,arity,arm] of nodes){
    const a=one?project(name,x):fields(name,x);
    if(one||a!==null)return arity===null?(a.length?jump(arm(),a):arm()):rapidMatcherArm(a,arity,arm);
  }
  return jump(other(),[x]);
});}
`;
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 const [input,output,...flags]=process.argv.slice(2);if(!input||!output||path.resolve(input)===path.resolve(output))throw Error('Usage: node matcher-workers.mjs INPUT DISTINCT_OUTPUT');
 const r=transformMatcherWorkers(fs.readFileSync(input,'utf8'),{chains:flags.includes('--chains')});fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,r.source);fs.writeFileSync(output+'.transform.json',JSON.stringify(r.stats,null,2)+'\n');console.log(JSON.stringify(r.stats));
}
