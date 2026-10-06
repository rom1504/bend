// Root-only execution: actual checked graph facts, independent graph oracles.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const [attemptArg,outArg,...options]=process.argv.slice(2);
assert(attemptArg&&outArg,'graph-controls.mjs ATTEMPT NEW_OUT [--scale N --shape chain|components|isolated] [--candidate-refusals] [--vertices N --edges N] [--expect-refusal]');
let scale=0,shape='chain',candidateRefusals=false,vertices=null,edges=null,expectRefusal=false;
for(let i=0;i<options.length;i++){
  if(options[i]==='--scale')scale=Number(options[++i]);
  else if(options[i]==='--shape')shape=options[++i];
  else if(options[i]==='--candidate-refusals')candidateRefusals=true;
  else if(options[i]==='--vertices')vertices=Number(options[++i]);
  else if(options[i]==='--edges')edges=Number(options[++i]);
  else if(options[i]==='--expect-refusal')expectRefusal=true;
  else throw Error('Unknown option '+options[i]);
}
assert(Number.isInteger(scale)&&scale>=0&&scale<=16384);
assert(['chain','components','isolated'].includes(shape));
assert((vertices===null)===(edges===null));
if(vertices!==null)assert(Number.isInteger(vertices)&&vertices>=0&&vertices<=16384&&Number.isInteger(edges)&&edges>=0&&edges<=4194304);
assert(!expectRefusal||scale>0);
const out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const hash=b=>createHash('sha256').update(b).digest('hex');
const identity=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return{file,sha256:hash(b),bytes:b.length};};
const report={kind:'phase54-direct-call-graph-controls',complete:false,pass:false,inputs:[],cases:[],
  scope:'Checked compiler graph-fact API through an appended diagnostic export. Independent small-graph reachability and sparse large-graph closed-form oracles. Does not execute generated programs, qualify source scanning, or claim a production size-limit change.'};
function pin(file,want){const p=identity(file);if(want)assert.equal(p.sha256,want.sha256);report.inputs.push(p);return p;}
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function array(xs){const a=[];while(xs?.$==='Con'){assert(a.length<=16384);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;}
const term=(tag,name='',kids=[])=>({$:'KTerm',tag,name,id:0,quant:0,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
function row(name,edges,unknown=false){return{$:'KDef',name,kind:'JDCall',arity:unknown?1:0,templates:0,
  typ:term('Absent'),value:term('JDCall',name,edges.map(name=>term('Ref',name))),ctors:list([]),native:false,unsafe:false};}
function graph(names,edges,seeds=[]){return names.map((name,i)=>({name,edges:edges[i].map(j=>typeof j==='string'?j:names[j]),unknown:seeds.includes(i)}));}
// Deliberately different from the production SCC algorithm: independent DFS
// per vertex, used only for small graphs. Each closure contains the start node.
function oracle(rows){
  const names=rows.map(r=>r.name),index=new Map(names.map((n,i)=>[n,i]));
  if(index.size!==rows.length||rows.some(r=>r.edges.some(n=>!index.has(n))))return{valid:false};
  const closures=rows.map((_,start)=>{const seen=new Set(),todo=[start];while(todo.length){const i=todo.pop();if(seen.has(i))continue;seen.add(i);for(const n of rows[i].edges)todo.push(index.get(n));}return seen;});
  return{valid:true,facts:rows.map((r,i)=>{const members=names.filter((_,j)=>closures[i].has(j)&&closures[j].has(i));return{name:r.name,members,id:members.indexOf(r.name),bounce:[...closures[i]].some(j=>rows[j].unknown)};})};
}
const cases=[];
function add(name,rows,expected=oracle(rows)){cases.push({name,rows,expected});}
if(!scale){
  add('empty',[]);
  add('isolated',graph(['unrelated'],[[]]));
  add('self-cycle-no-bounce',graph(['self'],[[0]]));
  add('self-unknown-tail',graph(['self'],[[0]],[0]));
  add('mutual-cycle',graph(['west','east'],[[1],[0]]));
  add('cycle-and-isolated',graph(['zeta','spare','alpha'],[[2],[],[0]],[2]));
  add('unknown-reachable-one-way',graph(['start','middle','last','unrelated'],[[1],[2],[],[]],[2]));
  add('diamond-shared-successor',graph(['root','left','right','join','leaf'],[[1,2],[3],[3],[4],[]],[4]));
  add('duplicate-edges',graph(['q','r','s'],[[1,1,1],[2,2],[1]]));
  add('unreachable-unknown',graph(['a','b','c','poison'],[[1],[0],[],[]],[3]));
  const original=graph(['rho','λ','omega','spare'],[[1],[2],[0],[]],[2]);
  add('unicode-and-input-order',original);
  for(const order of [[3,2,0,1],[1,0,3,2]])add('permuted-'+order.join(''),order.map(i=>original[i]));
  add('missing-target',graph(['known'],[['absent']]));
  if(candidateRefusals)add('duplicate-names-refused',[{name:'same',edges:[],unknown:false},{name:'same',edges:[],unknown:true}],{valid:false});
}else{
  const names=Array.from({length:scale},(_,i)=>'renamed_'+i);
  const rows=names.map((name,i)=>({name,edges:shape==='chain'?(i+1<scale?[names[i+1]]:[]):shape==='components'?[names[Math.floor(i/4)*4+(i+1)%Math.min(4,scale-Math.floor(i/4)*4)]]:[],unknown:shape==='chain'?i===scale-1:i%13===0}));
  const facts=rows.map((r,i)=>{const start=shape==='components'?Math.floor(i/4)*4:i,end=shape==='components'?Math.min(scale,start+4):i+1;
    return{name:r.name,members:names.slice(start,end),id:i-start,bounce:shape==='chain'||rows.slice(start,end).some(x=>x.unknown)};});
  add('scale-'+shape+'-'+scale,rows,expectRefusal?{valid:false}:{valid:true,facts});
}

try{
  pin(import.meta.filename);pin(process.execPath);
  const attemptFile=pin(path.join(attemptArg,'attempt.json')),attempt=JSON.parse(fs.readFileSync(attemptFile.file));
  assert(attempt.checked&&attempt.config.strictExact);assert.equal(attempt.artifactKind,'derived-b1');
  for(const key of ['api','runtime','base','node'])pin(attempt[key].file,attempt[key]);
  assert.equal(identity(process.execPath).sha256,attempt.node.sha256);
  const focused=pin(path.join(attemptArg,'validation-001/report.json')),gate=JSON.parse(fs.readFileSync(focused.file));
  assert(gate.complete&&gate.pass&&gate.strictExact);assert.equal(gate.attempt.sha256,attemptFile.sha256);assert.equal(gate.api.sha256,attempt.api.sha256);
  const original=fs.readFileSync(attempt.api.file,'utf8');
  const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
  new Function('module','exports',parserSource)(parser,parser.exports);
  const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(original);
  const symbols=['run_loop','$book_cached$','$jd_calls_context_rows$','$jd_calls_valid$','$jd_component$','$jd_component_id$','$jd_may_bounce$','$jd_same_component$'];
  if(vertices!==null)symbols.push('$jd_calls_context_bounded$');
  for(const name of symbols)assert.equal(ast.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name).length,1,'Missing unique diagnostic symbol '+name);
  assert(!original.includes('phase54Graph'));
  const graphCall=vertices===null?'$jd_calls_context_rows$($book_cached$({$:"Nil"},0),{$:"Some",value:rows})':`$jd_calls_context_bounded$($book_cached$({$:"Nil"},0),{$:"Some",value:rows},${vertices},${edges})`;
  report.graphEntry={name:vertices===null?'jd_calls_context_rows':'jd_calls_context_bounded',vertices,edges,diagnosticOnly:vertices!==null};
  const suffix=`\nexport const phase54Graph = rows => run_loop(${graphCall});
export const phase54Valid = book => run_loop($jd_calls_valid$(book));
export const phase54Fact = (book,name) => ({members:run_loop($jd_component$(book,name)),id:run_loop($jd_component_id$(book,name)),bounce:run_loop($jd_may_bounce$(book,name))});
export const phase54Same = (book,a,b) => run_loop($jd_same_component$(book,a,b));\n`;
  parse(original+suffix);const derivative=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(derivative,original+suffix,{flag:'wx'});
  fs.copyFileSync(import.meta.filename,path.join(out,'consumed-controls.mjs'));
  report.derivative={parent:identity(attempt.api.file),api:identity(derivative),suffixSha256:hash(suffix),parser:{version:parser.exports.version,sha256:hash(parserSource)},productionAbiChanged:false};
  const api=await import(pathToFileURL(derivative));
  for(const spec of cases){
    const input=list(spec.rows.map(r=>row(r.name,r.edges,r.unknown))),before=JSON.stringify(array(input)),start=performance.now();
    const book=api.phase54Graph(input),graphMs=performance.now()-start;
    assert.equal(JSON.stringify(array(input)),before,'Input mutation');assert.equal(api.phase54Valid(book),spec.expected.valid,spec.name);
    const observations=[];
    if(spec.expected.valid){
      for(const wanted of spec.expected.facts){const got=api.phase54Fact(book,wanted.name),fact={name:wanted.name,members:array(got.members),id:got.id,bounce:got.bounce};assert.deepEqual(fact,wanted,spec.name);observations.push(fact);}
      for(let i=0;i<observations.length;i++){const targets=scale?[(i*37+11)%observations.length]:observations.map((_,j)=>j);for(const j of targets)assert.equal(api.phase54Same(book,observations[i].name,observations[j].name),observations[i].members.includes(observations[j].name));}
      assert.equal(api.phase54Same(book,'$absent-one','$absent-two'),false);
      assert.equal(api.phase54Fact(book,'$absent-one').id,4294967295);
    }
    report.cases.push({name:spec.name,vertices:spec.rows.length,edges:spec.rows.reduce((n,r)=>n+r.edges.length,0),inputSha256:hash(before),valid:spec.expected.valid,graphMilliseconds:graphMs,oracle:scale?'Explicit sparse-shape formula':'Independent per-vertex reachability',facts:observations});
  }
  for(const row of report.inputs)assert.deepEqual(identity(row.file),row);assert.deepEqual(identity(derivative),report.derivative.api);
  report.complete=report.pass=true;report.inputsUnchanged=true;
}catch(error){report.error=error.stack;process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));
