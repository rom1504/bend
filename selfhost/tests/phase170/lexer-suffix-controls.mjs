#!/usr/bin/env node
// Literal fixtures and observation only; both lexer/parser implementations run in Bend.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';

const own=fileURLToPath(import.meta.url),root=path.resolve(path.dirname(own),'../../..');
const MAX_BYTES=2*1024**2,MAX_TOKENS=2000000;
const requireThat=(ok,message)=>{if(!ok)throw Error(message);};
function pin(file){file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};}
const same=(a,b)=>a?.bytes===b?.bytes&&a?.sha256===b?.sha256;
function verify(row){requireThat(same(pin(row.file),row),'Changed input: '+row.file);}
const read=file=>JSON.parse(fs.readFileSync(file,'utf8'));
const list=items=>items.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const token=(text,f_line,f_col,f_kind,begin,end,previousEnd)=>({$: 'FToken',text,f_line,f_col,f_kind,begin,end,previousEnd});
const fields=['text','f_line','f_col','f_kind','begin','end','previousEnd'];
const exactKeys=(o,keys)=>o&&typeof o==='object'&&Object.keys(o).sort().join(',')===[...keys].sort().join(',');
function tokenValues(t){
  requireThat(exactKeys(t,['$',...fields])&&t.$==='FToken'&&typeof t.text==='string','Malformed token');
  for(const key of fields.slice(1))requireThat(Number.isInteger(t[key])&&t[key]>=0&&t[key]<=4294967295,'Malformed token field '+key);
  return fields.map(k=>t[k]);
}
function compareTokens(a,b){
  let count=0;const digest=crypto.createHash('sha256');
  while(a?.$==='Con'&&b?.$==='Con'){
    requireThat(++count<=MAX_TOKENS,'Token bound exceeded');
    requireThat(exactKeys(a,['$','head','tail'])&&exactKeys(b,['$','head','tail']),'Malformed token list cell');
    const x=tokenValues(a.head),y=tokenValues(b.head);
    for(let i=0;i<x.length;i++)requireThat(x[i]===y[i],'Complete token mismatch at '+(count-1)+' field '+fields[i]);
    digest.update(JSON.stringify(x)+'\n');a=a.tail;b=b.tail;
  }
  requireThat(a?.$==='Nil'&&b?.$==='Nil'&&exactKeys(a,['$'])&&exactKeys(b,['$']),'Token list shape/length differs');
  return {tokens:count,sha256:digest.digest('hex'),allSevenFieldsAndListShapeExact:true};
}
function comparatorControls(){
  const a=token('x',1,2,3,4,5,6);let passed=0;
  compareTokens(list([a]),list([{...a}]));passed++;
  const rejects=(x,y)=>{let failed=false;try{compareTokens(x,y);}catch{failed=true;}requireThat(failed,'Comparator accepted a mutant');passed++;};
  for(const key of fields)rejects(list([a]),list([{...a,[key]:key==='text'?'y':7}]));
  rejects(list([a]),list([]));rejects(list([]),list([a]));return passed;
}
// Exact literal inputs from p150p_inputs, including its concatenated escaped LF case.
const finite=[
  '', '\0', 'x\0y', 'a', 'a.b', '.', '..', '.a',
  'e-1', 'name+2', '1e+2', '1E-2', 'e+', 'e+x', 'e+2x',
  '-> => <- ++ <> == != <= >= && || << >>', '.&. .|. .^. <&>',
  '- = < ! & | > .& .| .^ <&', '.&x .<&>',
  '1n++foo', '1n++2n', '1n ++foo', 'n+abc', 'n +abc', '+_x +1 +λ',
  'a>>b a >> b a>b a > b', '> > > >', '     >      >>', 'a\n >\n      >>',
  '\n', '\r\n', '\r', '\t\u000b\u000c', '([{}\n])\n', ')\n(\n', '}\n',
  '# comment', 'a# comment\nb', '(# 😀\n x)\n', '# 😀\n>',
  '""', "''", "'\\''", '"\\\\"', '"a\\n"', '"a\nb"x',
  '"'+'\\'+'\n'+'"x', '"', "'", '"abc\\', 'x "broken',
  'λ 猫 😀', '"猫😀"x', "'😀'", '"\\u{1F600}"', '"\\u{XYZ}"', '"\\q"',
  '"abcd"z', 'abcd z', '++x', '>>x', '\n\n\n', '#ab\nx'
];
function states(){return [
  [1,0,0,list([]),0,0], [1,0,0,list([]),1,1],
  [7,6,1,list([token('17n',7,3,1,100,103,91)]),4294967294,103],
  [7,6,0,list([token('>op',6,0,0,9,10,6),token('n',5,0,1,7,8,4)]),4294967295,999],
  [4294967295,4294967295,4294967295,list([]),2,7]
];}
function generatedSource(minimum){
  requireThat(Number.isSafeInteger(minimum)&&minimum>0&&minimum<=MAX_BYTES,'Invalid bounded source size');
  const parts=['type Flag is Data:\n  Off{}\n'];let bytes=Buffer.byteLength(parts[0]),definitions=1;
  while(bytes<minimum){const next=`def keep_${definitions}() -> Flag:\n  Off{}\n`;bytes+=Buffer.byteLength(next);parts.push(next);definitions++;}
  requireThat(bytes<=MAX_BYTES,'Declaration-aligned source exceeds 2 MiB');
  return {text:parts.join(''),bytes,definitions};
}
function compareGraph(a,b){
  const pending=[[a,b]],seen=new WeakMap();let values=0;
  while(pending.length){
    requireThat(++values<=20000000,'Graph comparison bound exceeded');
    const [x,y]=pending.pop();if(Object.is(x,y))continue;
    requireThat(x!==null&&y!==null&&typeof x==='object'&&typeof y==='object','Complete graph scalar differs');
    let paired=seen.get(x);if(paired?.has(y))continue;if(!paired){paired=new WeakSet();seen.set(x,paired);}paired.add(y);
    requireThat(Array.isArray(x)===Array.isArray(y),'Graph container shape differs');
    const kx=Object.keys(x).sort(),ky=Object.keys(y).sort();
    requireThat(kx.length===ky.length&&kx.every((k,i)=>k===ky[i]),'Graph field shape differs');
    for(const key of kx)pending.push([x[key],y[key]]);
  }
  return {valuesCompared:values,completeGraphExact:true};
}
const args={};for(let i=2;i<process.argv.length;i+=2){requireThat(process.argv[i]?.startsWith('--')&&process.argv[i+1],'Expected --key value');args[process.argv[i].slice(2)]=process.argv[i+1];}
for(const key of ['baseline','candidate','audit','out'])requireThat(args[key],'Missing --'+key);
requireThat(Object.keys(args).every(k=>['baseline','candidate','audit','out','sizes','larger','load-size'].includes(k)),'Unknown option');
const auditPin=pin(args.audit),audit=read(auditPin.file);
requireThat(audit.kind==='phase170-lexer-suffix-source'&&audit.version===1&&audit.complete===true&&audit.inverseByteExact===true,'Complete exact source-overlay audit required');
const fixturePin=pin(path.join(root,'selfhost/tests/phase150/lexer-probe.bend'));
const inputs=[pin(own),pin(process.execPath),auditPin,fixturePin,...audit.inputs];
const authorities={};
for(const role of ['baseline','candidate']){
  const receipt=pin(args[role]),doc=read(receipt.file);
  requireThat(doc.kind==='bend-checked-hosted-api'&&doc.complete===true&&doc.checked===true&&!doc.error,'Actual complete checked B1 receipt required: '+role);
  requireThat(same(doc.source,audit[role]),'Checked API source differs from audited '+role);
  requireThat(doc.exports.includes('f_lex_cursor')&&doc.exports.includes('f_load_graph_trace'),'Missing explicit lexer/loader exports');
  inputs.push(receipt,doc.source,doc.api,...doc.inputs);authorities[role]={receipt,source:doc.source,image:doc.api};
}
requireThat(!same(authorities.baseline.source,authorities.candidate.source),'Baseline and candidate source must be distinct');
inputs.forEach(verify);
const sizes=(args.sizes??'16384,32768,65536').split(',').filter(Boolean).map(Number);
if(args.larger)sizes.push(Number(args.larger));
requireThat(sizes.length<=8&&sizes.every(x=>Number.isSafeInteger(x)&&x>0&&x<=MAX_BYTES),'Bounded scale sizes required');
const out=path.resolve(args.out);requireThat(out.startsWith(path.join(root,'selfhost/build')+path.sep)&&!fs.existsSync(out),'Fresh build output required');
fs.mkdirSync(out,{recursive:true});const progress=path.join(out,'progress.jsonl');fs.writeFileSync(progress,'',{flag:'wx'});
const report={kind:'phase170-lexer-suffix-controls',version:1,complete:false,passed:false,inputs,authorities,
  engine:{file:pin(process.execPath),version:process.version,bun:globalThis.Bun?.version??null},
  scope:'Checked independent Bend APIs; exact finite token and optional complete loader equivalence. Single-process timings and memory samples are diagnostic, not performance/native qualification.',
  fixtures:{source:fixturePin,strings:finite.length,states:5,expectedPairs:315},rows:[],scale:[]};
const started=performance.now(),save=()=>{report.seconds=(performance.now()-started)/1000;fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');};
function observe(name,role,fn){
  const before=process.memoryUsage(),begin=performance.now();
  fs.appendFileSync(progress,JSON.stringify({event:'start',name,role,elapsedSeconds:(begin-started)/1000})+'\n');
  const value=fn();
  const observation={seconds:(performance.now()-begin)/1000,memoryBefore:before,memoryAfter:process.memoryUsage(),processMaxRssKiB:process.resourceUsage().maxRSS};
  fs.appendFileSync(progress,JSON.stringify({event:'complete',name,role,...observation})+'\n');return {value,observation};
}
save();
try{
  requireThat(finite.length===63,'Retained literal input count differs');report.comparatorControls=comparatorControls();
  const apis={};for(const role of ['baseline','candidate'])apis[role]=(await import(pathToFileURL(authorities[role].image.file))).default;
  let pairs=0;
  for(let i=0;i<finite.length;i++)for(let j=0;j<5;j++){
    const values={};const order=(pairs%2)?['candidate','baseline']:['baseline','candidate'];
    for(const role of order)values[role]=apis[role].f_lex_cursor(finite[i],...states()[j]);
    const compared=compareTokens(values.baseline,values.candidate);report.rows.push({input:i,state:j,...compared});pairs++;
  }
  report.finitePairs=pairs;requireThat(pairs===315,'Finite matrix incomplete');save();
  for(let i=0;i<sizes.length;i++){
    const source=generatedSource(sizes[i]),file=path.join(out,`scale-${i}.bend`);fs.writeFileSync(file,source.text,{flag:'wx'});inputs.push(pin(file));
    const row={requestedBytes:sizes[i],source:pin(file),declarations:source.definitions,observations:{}};report.scale.push(row);save();
    const values={},order=i%2?['candidate','baseline']:['baseline','candidate'];
    for(const role of order){const got=observe(`scale-${i}`,role,()=>apis[role].f_lex_cursor(source.text,...states()[1]));values[role]=got.value;row.observations[role]=got.observation;save();}
    Object.assign(row,compareTokens(values.baseline,values.candidate));save();
  }
  if(args['load-size']){
    const source=generatedSource(Number(args['load-size'])),file=path.join(out,'loader.bend');fs.writeFileSync(file,source.text,{flag:'wx'});inputs.push(pin(file));
    const logical='/phase170/suffix-loader.bend';
    const supplied=()=>list([{$:'FLocatedSource',source:{$:'FSource',name:'Unit',path:logical,text:source.text},begin:1,end:source.text.length+2}]);
    const row=report.loader={source:pin(file),expectedDeclarations:source.definitions,observations:{}};const values={};save();
    for(const role of ['baseline','candidate']){
      const got=observe('loader',role,()=>apis[role].f_load_graph_trace(logical,supplied()));values[role]=got.value;row.observations[role]=got.observation;
      requireThat(got.value?.$==='FLoadTrace'&&got.value.result?.$==='FResult'&&got.value.result.error==='','Loader refused valid literal source: '+role);
      let count=0,book=got.value.result.book;while(book?.$==='Con'){requireThat(++count<=100000,'Book bound exceeded');book=book.tail;}
      requireThat(book?.$==='Nil'&&count===source.definitions,'Loader declaration count differs: '+role);save();
    }
    Object.assign(row,compareGraph(values.baseline,values.candidate));save();
  }
  inputs.forEach(verify);report.complete=true;report.passed=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{report.changedInputs=[];for(const row of inputs)try{verify(row);}catch{report.changedInputs.push(row.file);}if(report.changedInputs.length){report.complete=false;report.passed=false;process.exitCode=1;}save();}
console.log(JSON.stringify({complete:report.complete,passed:report.passed,finitePairs:report.finitePairs,scale:report.scale.length,loader:!!report.loader,error:report.error,report:path.join(out,'report.json')}));
