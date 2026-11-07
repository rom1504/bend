// Context materializer extension; original borrow-oracle.mjs stays frozen.
// Transport only: call an independently upstream-checked workload's main,
// validate its complete result against fixed schemas, and serialize that VALUE
// as constant Bend source. No compiler/pass algorithm is implemented here.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,workspace} from '../../tools/build/hosted.mjs';

const args={};
for(let i=2;i<process.argv.length;i+=2){
  assert(process.argv[i]?.startsWith('--')&&process.argv[i+1]);
  const key=process.argv[i].slice(2);assert(!Object.hasOwn(args,key));args[key]=process.argv[i+1];
}
assert.deepEqual(Object.keys(args).sort(),['kind','out','receipt']);
assert(['compiler','alias','context','context-digest'].includes(args.kind));
const receipt=JSON.parse(fs.readFileSync(args.receipt,'utf8'));
assert.equal(receipt.kind,'bend-checked-hosted-api');
assert(receipt.complete&&receipt.checked&&receipt.status===0&&!receipt.error&&!receipt.signal);
assert.deepEqual(receipt.exports,['main'],'Oracle must export the actual unchanged workload main only');
assert.equal(receipt.command[0],fs.realpathSync(process.execPath),'Use the acquisition engine');
const inputs=[pin(fileURLToPath(import.meta.url)),pin(process.execPath),pin(args.receipt),
  ...receipt.inputs,receipt.source,receipt.api];
inputs.forEach(verify);
const source=fs.readFileSync(receipt.source.file,'utf8');

// Exact field order and quantities copied from the audited source declarations.
// Whitespace normalization below is only an identity check, not type parsing.
const declarations={
  KDef:`type KDef is Data:
  KDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2,KDef>, +native: Bool, +unsafe: Bool}
  KIndexLeaf{+hash: U32, +bucket: List<&2,KDef>}
  KIndexNode{+hash: U32, +mask: U32, +left: KDef, +right: KDef}
`,
  FResult:`type FResult is Data:
  FResult{+book: List<&2,KDef>, +error: String, +imports: List<&2,KTerm>}
`,
  P173CMReport:`type P173CMReport is Data:
  P173CMReport{+loaded: List<&2,FResult>, +materialized: List<&2,KTerm>, +aliases: List<&2,KTerm>}
`,
  KTerm:`type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}
`,
  GHeap:`type GHeap is Data:
  GEmpty{}
  GNode{+value: KTerm, +left: GHeap, +right: GHeap}
`,
  GState:`type GState is Data:
  GState{+heap: GHeap, +next: U32}
`,
  GResult:`type GResult is Data:
  GResult{+state: GState, +term: KTerm}
`,
  P173BWReport:`type P173BWReport is Data:
  P173BWReport{+located: List<&2,KTerm>, +shared: List<&2,GResult>, +replaced: KTerm}
`,
  BorrowBox:`type BorrowBox is Data:
  BorrowBox{+label: String, +low: U32, +high: U32, +values: List<&2,U32>, +other: List<&2,U32>, +kind: U32}
`
};
const L=element=>({list:element});
const schemas={
  KDef:{
    KDef:[['name','String'],['kind','String'],['arity','U32'],['templates','U32'],['typ','KTerm'],['value','KTerm'],['ctors',L('KDef')],['native','Bool'],['unsafe','Bool']],
    KIndexLeaf:[['hash','U32'],['bucket',L('KDef')]],
    KIndexNode:[['hash','U32'],['mask','U32'],['left','KDef'],['right','KDef']]
  },
  FResult:{FResult:[['book',L('KDef')],['error','String'],['imports',L('KTerm')]]},
  P173CMReport:{P173CMReport:[['loaded',L('FResult')],['materialized',L('KTerm')],['aliases',L('KTerm')]]},
  KTerm:{
    KTerm:[['tag','String'],['name','String'],['id','U32'],['quant','U32'],['kids',L('KTerm')],['removed',L('String')],['originBegin','U32'],['originEnd','U32']],
    KLambda:[['name','String'],['id','U32'],['quant','U32'],['kids',L('KTerm')],['removed',L('String')],['originBegin','U32'],['originEnd','U32'],['quantityPresent','Bool']],
    KLiteral:[['kind','String'],['number','U32'],['text','String'],['originBegin','U32'],['originEnd','U32']]
  },
  GHeap:{GEmpty:[],GNode:[['value','KTerm'],['left','GHeap'],['right','GHeap']]},
  GState:{GState:[['heap','GHeap'],['next','U32']]},
  GResult:{GResult:[['state','GState'],['term','KTerm']]},
  P173BWReport:{P173BWReport:[['located',L('KTerm')],['shared',L('GResult')],['replaced','KTerm']]},
  BorrowBox:{BorrowBox:[['label','String'],['low','U32'],['high','U32'],['values',L('U32')],['other',L('U32')],['kind','U32']]}
};
const configurations={
  compiler:{names:['KTerm','GHeap','GState','GResult','P173BWReport'],schema:'P173BWReport',result:'P173BWReport'},
  alias:{names:['BorrowBox'],schema:L(L('BorrowBox')),result:'List<&2,List<&2,BorrowBox>>'},
  context:{names:['KTerm','KDef','FResult','P173CMReport'],schema:'P173CMReport',result:'P173CMReport'},
  'context-digest':{names:['KTerm','KDef','FResult'],schema:'U32',result:'U32'}
};
const {names,schema:rootSchema,result:resultType}=configurations[args.kind];
function declaration(name){
  const lines=source.split('\n');
  const indices=lines.flatMap((line,index)=>line===`type ${name} is Data:`?[index]:[]);
  assert.equal(indices.length,1,`Exact source type ${name}`);
  const kept=[lines[indices[0]]];
  for(let i=indices[0]+1;i<lines.length;i++){
    if(lines[i].trim()&&!/^\s/.test(lines[i]))break;
    kept.push(lines[i]);
  }
  const actual=kept.join('\n').trim()+'\n';
  assert.equal(actual.replace(/\s/g,''),declarations[name].replace(/\s/g,''),`Changed ${name} source schema`);
  return {name,sha256:crypto.createHash('sha256').update(actual).digest('hex'),text:actual};
}
const typeBindings=names.map(declaration);
const out=path.resolve(args.out);
assert(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out));
assert.equal(fs.realpathSync(path.dirname(out)),path.dirname(out),'No symlink output parent');
fs.mkdirSync(out);
const report={kind:'phase173-independent-context-value-oracle',version:1,complete:false,
  variant:args.kind,inputs,source:receipt.source,acquisition:pin(args.receipt),typeBindings,
  scope:'Unchanged workload evaluated by pinned upstream JS; complete typed value transported to a constant Bend program. The constant requires independent checking and baseline native readback before use as an execution oracle.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();const start=performance.now();
let nodes=0,strings=0,maxDepth=0;
function object(value,keys){
  assert(value&&typeof value==='object'&&!Array.isArray(value));
  assert.deepEqual(Object.keys(value).sort(),keys.slice().sort(),'Unexpected value fields');
}
function quoted(value){
  assert.equal(typeof value,'string');assert(value.length<=65536);strings+=value.length;
  let text='"';
  for(const c of value){
    const n=c.codePointAt(0);assert(n<0xd800||n>0xdfff,'Unpaired surrogate');
    text+=c==='"'?'\\"':c==='\\'?'\\\\':c==='\n'?'\\n':c==='\r'?'\\r':c==='\t'?'\\t':
      n<32||n>126?'\\u{'+n.toString(16)+'}':c;
  }
  return text+'"';
}
function encode(value,type,depth=0){
  assert(++nodes<=100000&&depth<=512,'Bounded oracle value');maxDepth=Math.max(maxDepth,depth);
  if(type==='U32'){assert(Number.isInteger(value)&&value>=0&&value<=4294967295);return String(value);}
  if(type==='String')return quoted(value);
  if(type==='Bool'){assert.equal(typeof value,'boolean');return value?'True{}':'False{}';}
  if(type?.list){
    const parts=[],seen=new Set();let cursor=value;
    while(cursor?.$==='Con'){
      object(cursor,['$','head','tail']);assert(parts.length<4096&&!seen.has(cursor),'Bounded acyclic list');seen.add(cursor);
      parts.push(encode(cursor.head,type.list,depth+1));cursor=cursor.tail;
    }
    object(cursor,['$']);assert.equal(cursor.$,'Nil');return '['+parts.join(',')+']';
  }
  assert(Object.hasOwn(schemas,type),'Known source type');
  assert(value&&Object.hasOwn(schemas[type],value.$),'Known source constructor');
  const fields=schemas[type][value.$];object(value,['$',...fields.map(([name])=>name)]);
  return value.$+'{'+fields.map(([name,fieldType])=>encode(value[name],fieldType,depth+1)).join(',')+'}';
}
try{
  const api=(await import(pathToFileURL(receipt.api.file))).default;
  assert.equal(typeof api.main,'function');
  const value=api.main();
  if(args.kind==='context'){
    assert.equal(value?.$,'P173CMReport');let cursor=value.loaded;
    for(const rejected of [false,false,false,false,true,true]){
      assert.equal(cursor?.$,'Con','All six complete loader cases required');
      assert.equal(cursor.head?.$,'FResult');assert.equal(typeof cursor.head.error,'string');
      assert.equal(Boolean(cursor.head.error),rejected,'Unexpected loader fixture acceptance');
      cursor=cursor.tail;
    }
    assert.equal(cursor?.$,'Nil','Exactly six complete loader cases required');
  }
  const constant=encode(value,rootSchema);
  const text='import Base\n\n# Complete upstream-observed value; source SHA256 '+receipt.source.sha256+'\n'+
    typeBindings.map(x=>x.text).join('\n')+'\ndef main() -> '+resultType+':\n  '+constant+'\n';
  assert(Buffer.byteLength(text)<=1024*1024,'Bounded constant oracle');
  fs.writeFileSync(path.join(out,'value.json'),JSON.stringify(value,null,2)+'\n',{flag:'wx'});
  fs.writeFileSync(path.join(out,'oracle.bend'),text,{flag:'wx'});
  inputs.forEach(verify);report.value=pin(path.join(out,'value.json'));
  report.oracleSource=pin(path.join(out,'oracle.bend'));
  report.observation={nodes,strings,maxDepth,mainCalls:1};report.complete=true;
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
finally{report.wallSeconds=(performance.now()-start)/1000;save();console.log(JSON.stringify({complete:report.complete,error:report.error,oracleSource:report.oracleSource}));}
