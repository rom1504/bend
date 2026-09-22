// A deliberately tiny purity proof, not a generic fn0 memoizer. The exact
// constructor-only missing -> atom -> kt implementation must match. Sharing
// is valid only for immutable compiler graphs inside the private inspect worker.
import {tokenize} from './tokens.mjs';
function canonical(line) {
 const names=new Map([...line.matchAll(/const (\w+)=a\[(\d+)\];/g)].map(m=>[m[1],'arg'+m[2]]));
 return tokenize(line).map(t=>names.get(t.text)??t.text).join(' ');
}
const proof={
 missing:'G["missing"]=fn(0,function(){return build("KDef",[()=>"",()=>"Absent",()=>0,()=>0,()=>jump(get(G,"atom"),["Absent"]),()=>jump(get(G,"atom"),["Absent"]),()=>build("Nil",[]),()=>build("False",[]),()=>build("False",[]),]);});',
 atom:'G["atom"]=fn(1,function(a){const x0=a[0];return jump(get(G,"kt"),[x0,"",0,0,ctor("Nil",[]),]);});',
 kt:'G["kt"]=fn(5,function(a){const x0=a[0];const x1=a[1];const x2=a[2];const x3=a[3];const x4=a[4];return build("KTerm",[()=>x0,()=>x1,()=>x2,()=>x3,()=>x4,()=>build("Nil",[]),]);});',
};
export function preparePrivateConstants(source,{memoize=true,instrument=false}={}) {
 const lines={};for(const [name,expected] of Object.entries(proof)) {
  const selected=source.split('\n').filter(x=>x.startsWith(`G[${JSON.stringify(name)}]=`));
  if(selected.length!==1||canonical(selected[0])!==canonical(expected))throw Error('Private constant purity proof failed: '+name);
  lines[name]=selected[0];
 }
 const line=lines.missing,expression=line.slice('G["missing"]=fn(0,function(){return '.length,-4);
 // Keep failed construction uncached; only a fully forced value is published.
 const replacement=`let privateMissingReady=false,privateMissingValue,privateMissingCalls=0,privateMissingBuilds=0;\nG["missing"]=fn(0,function(){${instrument?'privateMissingCalls++;':''}${memoize?'if(!privateMissingReady){':''}${instrument?'privateMissingBuilds++;':''}${memoize?'privateMissingValue=force('+expression+');privateMissingReady=true;}return privateMissingValue;':'return '+expression+';'}});`;
 source=source.replace(line,replacement);
 if(instrument)source+=`\nprocess.on('exit',()=>{if(process.env.BEND_PRIVATE_COUNTER_FILE)fs.writeFileSync(process.env.BEND_PRIVATE_COUNTER_FILE,JSON.stringify({missingCalls:privateMissingCalls,missingBuilds:privateMissingBuilds}));});\n`;
 return {source,stats:{memoized:memoize?['missing']:[],instrument,purityProof:'exact token-normalized missing/atom/kt constructor-only bodies',requiresPrivateBoundary:true}};
}
