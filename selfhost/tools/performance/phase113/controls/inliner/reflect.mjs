// Independent executable specification for the finite raw-IR controls below.
// It interprets full U64 words, lexical activation records, scratch memories and
// observable runtime-call order. It is not a Bend frontend or ownership proof.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiArg,outArg]=process.argv.slice(2);
if(!apiArg||!outArg||process.argv.length!==4)throw Error('Usage: reflect.mjs CHECKED_API FRESH_PHASE113_OUT');
const root=path.resolve(import.meta.dirname,'../../../../../..');
const apiFile=path.resolve(apiArg),out=path.resolve(outArg);
if(!out.startsWith(root+'/selfhost/build/phase113/')||fs.existsSync(out))throw Error('Fresh Phase113 output required');
const pin=file=>{file=path.resolve(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:crypto.createHash('sha256').update(b).digest('hex')};};
const receiptFile=path.join(path.dirname(apiFile),'report.json'),receipt=JSON.parse(fs.readFileSync(receiptFile));
const required=['p113d_verify','p113i_optimize','p113i_eligible'];
const sourcePin=pin(apiFile);
if(!receipt.complete||!receipt.checked||!required.every(x=>receipt.exports?.includes(x))||
   receipt.api.sha256!==sourcePin.sha256||receipt.api.bytes!==sourcePin.bytes||
   path.resolve(receipt.api.file)!==apiFile)throw Error('Complete matching checked inliner API required');
fs.mkdirSync(out,{recursive:true});
fs.copyFileSync(import.meta.filename,path.join(out,'method.mjs'));
const report={kind:'phase113-independent-inliner-reflection',complete:false,
  inputs:[pin(import.meta.filename),sourcePin,pin(receiptFile)],cases:[],
  scope:'Finite raw-IR interpretation and structural shape gates. No native execution, heap/reference-count proof, general optimizer correctness or speed claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const arr=xs=>{const r=[];while(xs?.$==='Con'){r.push(xs.head);xs=xs.tail;}if(xs?.$!=='Nil')throw Error('Bad list');return r;};
const l={$:'N111U64'},w={$:'N111U32'},ptr={$:'N111Ptr'};
const word=(lo,hi=0)=>({$:'N111Const',lo,hi}),local=name=>({$:'N111Local',name});
const scalar=stmt=>({$:'P113DScalar',stmt});
const set=(name,value)=>scalar({$:'N111Set',name,typ:l,value});
const bin=(name,op,left,right)=>scalar({$:'N111Bin',name,typ:l,op,left,right});
const ret=(...values)=>({$:'P113DResult',values:list(values)});
const again=(...values)=>({$:'P113DAgain',values:list(values)});
const call=(dest,target,...args)=>({$:'P113DCall',destinations:list(Array.isArray(dest)?dest:[dest]),target,args:list(args)});
const branch=(condition,yes,no)=>({$:'P113DIf',condition,yes:list(yes),no:list(no)});
const alloc=name=>scalar({$:'N111Alloca',name,bytes:2048,align:8});
const store=(base,value)=>scalar({$:'N111Store',typ:l,base:local(base),offset:0,value});
const load=(name,base)=>scalar({$:'N111Load',name,typ:l,base:local(base),offset:0});
const rt=(name,symbol,value)=>scalar({$:'N111Call',name,typ:l,symbol,args:list([
  {$:'N111Arg',typ:ptr,value:local('state')},{$:'N111Arg',typ:l,value}])});
const fn=(name,params,body,result=1,pub=true)=>({$:'P113DFunction',name,
  params:list(params.map((word,id)=>({$:'NC_Binding',word,id,kind:{$:'N_Box'}}))),
  body:list(body),result,public:pub});
const seg=(name,arity)=>({$:'N111Segment',name,arity,result:1,incoming:0,flags:0,
  body:list([{$:'N111Return',value:word(0)}])});
const core=[['SNil',0],['SCon',2],['WNil',0],['WCon',2],['Nil',0],['Con',2],['Tuple',2],['Unit',0],
  ['None',0],['Some',1],['Fail',1],['Done',1],['Emit',1],['Halt',2],['True',0],['LT',0],['EQ',0],['GT',0]];
const bundle=functions=>({$:'P113DProgram',functions:list(functions),original:{$:'P112StaticProgram',nodes:list([]),
  program:{$:'P111Program',segments:list([seg('main',0),...functions.map(f=>seg(f.name,arr(f.params).length))]),
    constructors:list(core.map(([name,arity])=>({$:'N_Constructor',name,arity,hot:arity>0}))),
    show:list([0]),show_names:list([]),effects:list([]),pure:true}}});
const U64=(1n<<64n)-1n;
function execute(program,entry,args) {
  const functions=new Map(arr(program.functions).map(f=>[f.name,f])),trace=[];
  let ticks=0;
  function invoke(name,actuals) {
    if(++ticks>20000)throw Error('Interpreter step bound');
    const f=functions.get(name);if(!f)throw Error('Unknown interpreter callee '+name);
    const formals=arr(f.params);if(actuals.length!==formals.length)throw Error('Arity');
    const env=new Map([['state',{state:true}],['scratch',new Map()]]);
    formals.forEach((p,i)=>env.set(p.word,actuals[i]));
    const value=v=>{
      if(v.$==='N111Const')return BigInt(v.lo)+(BigInt(v.hi)<<32n);
      if(v.$==='N111Local'&&env.has(v.name))return env.get(v.name);
      throw Error('Unsupported/unbound interpreter value '+JSON.stringify(v));
    };
    function scalarStep(s) {
      if(++ticks>20000)throw Error('Interpreter step bound');
      switch(s.$) {
        case 'N111Set':env.set(s.name,value(s.value));return;
        case 'N111Alloca':env.set(s.name,new Map());return;
        case 'N111Store':value(s.base).set(s.offset,value(s.value));return;
        case 'N111Load':{
          const memory=value(s.base);if(!memory.has(s.offset))throw Error('Uninitialized scratch read');
          env.set(s.name,memory.get(s.offset));return;
        }
        case 'N111Bin':{
          const a=value(s.left),b=value(s.right);let v;
          switch(s.op) {
            case 'add':v=(a+b)&U64;break;case 'sub':v=(a-b)&U64;break;
            case 'mul':v=(a*b)&U64;break;case 'xor':v=a^b;break;
            case 'and':v=a&b;break;case 'or':v=a|b;break;
            case 'eq':v=a===b?1n:0n;break;case 'ne':v=a!==b?1n:0n;break;
            case 'ult':v=a<b?1n:0n;break;default:throw Error('Interpreter opcode '+s.op);
          }env.set(s.name,v);return;
        }
        case 'N111If':for(const x of arr(value(s.condition)!==0n?s.yes:s.no))scalarStep(x);return;
        case 'N111Call':{
          const actuals=arr(s.args).map(a=>value(a.value));
          if(!actuals[0]?.state||actuals.length!==2||!['p111_rt_keep','p111_rt_sink'].includes(s.symbol))
            throw Error('Unsupported interpreter runtime call');
          trace.push(s.symbol+':'+actuals[1].toString());
          env.set(s.name,s.symbol==='p111_rt_keep'?actuals[1]:0n);return;
        }
        default:throw Error('Unsupported scalar '+s.$);
      }
    }
    function body(stmts) {
      for(const s of arr(stmts)) {
        if(++ticks>20000)throw Error('Interpreter step bound');
        switch(s.$) {
          case 'P113DScalar':scalarStep(s.stmt);break;
          case 'P113DIf':{
            const terminal=body(value(s.condition)!==0n?s.yes:s.no);
            if(terminal)return terminal;break;
          }
          case 'P113DCall':{
            // Snapshot every actual before entering or assigning destinations.
            const actuals=arr(s.args).map(value),result=invoke(s.target,actuals);
            const destinations=arr(s.destinations);
            if(result.length!==destinations.length)throw Error('Result arity');
            destinations.forEach((n,i)=>env.set(n,result[i]));break;
          }
          case 'P113DResult':return {result:arr(s.values).map(value)};
          case 'P113DAgain':return {again:arr(s.values).map(value)};
          default:throw Error('Unknown direct stmt');
        }
      }return null;
    }
    for(;;) {
      const terminal=body(f.body);if(!terminal)throw Error('Missing terminal');
      if(terminal.result)return terminal.result;
      if(terminal.again.length!==formals.length)throw Error('Again arity');
      formals.forEach((p,i)=>env.set(p.word,terminal.again[i]));
    }
  }
  return {values:invoke(entry,args.map(BigInt)).map(String),trace};
}
function callCount(body) {
  return arr(body).reduce((n,s)=>n+(s.$==='P113DCall'?1:s.$==='P113DIf'?callCount(s.yes)+callCount(s.no):0),0);
}
function stackBytes(body) {
  const scalars=xs=>arr(xs).reduce((n,s)=>n+(s.$==='N111Alloca'?s.bytes:s.$==='N111If'?scalars(s.yes)+scalars(s.no):0),0);
  return arr(body).reduce((n,s)=>n+(s.$==='P113DScalar'?scalars(list([s.stmt])):s.$==='P113DIf'?stackBytes(s.yes)+stackBytes(s.no):0),0);
}
const cases=[];
const add=(name,functions,expected,remaining,{entry='caller',args=[],trace=[],eligible={},unchanged=false,maxStack=16384}={})=>
  cases.push({name,program:bundle(functions),expected:{values:expected.map(String),trace},remaining,entry,args,eligible,unchanged,maxStack});
const identity=()=>fn('leaf',['a'],[ret(local('a'))]);
const arithmetic=()=>fn('leaf',['a','b'],[bin('x','mul',local('a'),word(10)),bin('x','add',local('x'),local('b')),ret(local('x'))]);
add('aliased-destination-argument-snapshot',[arithmetic(),fn('caller',[],[
  set('a',word(2)),set('b',word(7)),call('a','leaf',local('b'),local('a')),ret(local('a'))])],[72],0);
add('hygienic-scratch',[fn('leaf',['a'],[store('scratch',local('a')),load('x','scratch'),ret(local('x'))]),
  fn('caller',[],[store('scratch',word(901)),call('x','leaf',word(7)),load('y','scratch'),
    bin('z','add',local('x'),local('y')),ret(local('z'))])],[908],0);
add('evaluated-once-actual',[arithmetic(),fn('caller',[],[
  rt('a','p111_rt_keep',word(17)),call('a','leaf',local('a'),local('a')),ret(local('a'))])],[187],0,
  {trace:['p111_rt_keep:17']});
add('ordered-ownership-operations',[fn('leaf',['a'],[
  rt('b','p111_rt_keep',local('a')),rt('ignored','p111_rt_sink',local('b')),ret(local('a'))]),
  fn('caller',[],[rt('x','p111_rt_keep',word(44)),call('x','leaf',word(10)),
    rt('y','p111_rt_keep',word(33)),ret(local('x'))])],[10],0,
  {trace:['p111_rt_keep:44','p111_rt_keep:10','p111_rt_sink:10','p111_rt_keep:33']});
const choose=()=>fn('leaf',['a'],[bin('c','eq',local('a'),word(0)),
  branch(local('c'),[ret(word(10))],[ret(word(20))])]);
add('terminal-branch-both-values',[choose(),fn('caller',[],[
  call('x','leaf',word(0)),call('y','leaf',word(1)),bin('z','add',local('x'),local('y')),ret(local('z'))])],[30],0);
add('scalar-branch-local-join',[fn('leaf',['a'],[bin('c','eq',local('a'),word(0)),
  scalar({$:'N111If',condition:local('c'),yes:list([{$:'N111Set',name:'v',typ:l,value:word(4)}]),
    no:list([{$:'N111Set',name:'v',typ:l,value:word(9)}])}),ret(local('v'))]),
  fn('caller',[],[call('x','leaf',word(0)),call('y','leaf',word(1)),
    bin('z','add',local('x'),local('y')),ret(local('z'))])],[13],0);
add('bottom-up-wrapper-chain',[identity(),fn('middle',['a'],[call('x','leaf',local('a')),ret(local('x'))]),
  fn('caller',[],[call('x','middle',word(81)),ret(local('x'))])],[81],0,{eligible:{middle:false}});
const partial=()=>fn('leaf',['a'],[bin('c','eq',local('a'),word(0)),
  branch(local('c'),[ret(word(7))],[set('x',word(8))]),ret(local('x'))]);
add('refuse-partial-return-common-suffix',[partial(),fn('caller',[],[
  call('x','leaf',word(0)),call('y','leaf',word(1)),bin('z','add',local('x'),local('y')),ret(local('z'))])],[15],2,
  {eligible:{leaf:false},unchanged:true});
const loop=()=>fn('leaf',['a'],[bin('c','eq',local('a'),word(0)),
  branch(local('c'),[ret(word(9))],[bin('next','sub',local('a'),word(1)),again(local('next'))])]);
add('refuse-self-loop-leaf',[loop(),fn('caller',[],[call('x','leaf',word(5)),ret(local('x'))])],[9],1,
  {eligible:{leaf:false},unchanged:true});
add('refuse-private-product',[fn('pair',['a','b'],[ret(local('b'),local('a'))],2,false),
  fn('caller',[],[call(['x','y'],'pair',word(6),word(3)),ret(local('y'))])],[6],1,
  {eligible:{pair:false},unchanged:true});
add('refuse-caller-prefix-collision',[identity(),fn('caller',[],[
  set('p113i_user',word(23)),call('x','leaf',local('p113i_user')),ret(local('x'))])],[23],1,
  {unchanged:true});
add('refuse-callee-prefix-collision',[fn('leaf',['a'],[set('p113i_user',local('a')),ret(local('p113i_user'))]),
  fn('caller',[],[call('x','leaf',word(23)),ret(local('x'))])],[23],1,{unchanged:true});
add('four-site-budget',[identity(),fn('caller',[],[
  ...Array.from({length:5},(_,i)=>call('x'+i,'leaf',word(i))),ret(local('x4'))])],[4],1);
const large=()=>fn('leaf',['a'],[...Array.from({length:40},(_,i)=>set('v'+i,local('a'))),ret(local('v39'))]);
add('growth-budget',[large(),fn('caller',[],[
  ...Array.from({length:4},(_,i)=>call('x'+i,'leaf',word(i))),ret(local('x3'))])],[3],1);
add('callee-node-limit',[fn('leaf',['a'],[
  ...Array.from({length:49},(_,i)=>set('v'+i,local('a'))),ret(local('v48'))]),
  fn('caller',[],[call('x','leaf',word(4)),ret(local('x'))])],[4],1,
  {eligible:{leaf:false},unchanged:true});
add('callee-stack-limit',[fn('leaf',['a'],[
  ...Array.from({length:5},(_,i)=>alloc('buffer'+i)),ret(local('a'))]),
  fn('caller',[],[call('x','leaf',word(4)),ret(local('x'))])],[4],1,
  {eligible:{leaf:false},unchanged:true});
add('caller-stack-at-limit',[identity(),fn('caller',[],[
  ...Array.from({length:7},(_,i)=>alloc('buffer'+i)),call('x','leaf',word(4)),ret(local('x'))])],[4],0);
add('caller-stack-rollback',[identity(),fn('caller',[],[
  ...Array.from({length:8},(_,i)=>alloc('buffer'+i)),call('x','leaf',word(4)),ret(local('x'))])],[4],1,{unchanged:true});
add('caller-node-limit',[identity(),fn('caller',[],[
  ...Array.from({length:1024},(_,i)=>set('v'+i,word(i))),call('x','leaf',word(4)),ret(local('x'))])],[4],1,
  {unchanged:true});

save();
try {
  const api=(await import(pathToFileURL(apiFile))).default;
  for(const c of cases) {
    const row={name:c.name,expected:c.expected,expectedRemainingCalls:c.remaining};
    report.cases.push(row);save();
    fs.writeFileSync(path.join(out,c.name+'.before.json'),JSON.stringify(c.program)+'\n');
    try {
      row.beforeDiagnostic=api.p113d_verify(c.program);
      if(row.beforeDiagnostic!=='')throw Error('Original IR invalid: '+row.beforeDiagnostic);
      const after=api.p113i_optimize(c.program);
      fs.writeFileSync(path.join(out,c.name+'.after.json'),JSON.stringify(after)+'\n');
      row.afterDiagnostic=api.p113d_verify(after);
      row.before=execute(c.program,c.entry,c.args);row.after=execute(after,c.entry,c.args);
      const entry=arr(after.functions).find(f=>f.name===c.entry);
      row.remainingCalls=callCount(entry.body);row.explicitStackBytes=stackBytes(entry.body);
      row.eligibility={};
      for(const [name,want] of Object.entries(c.eligible)) {
        const value=api.p113i_eligible(arr(c.program.functions).find(f=>f.name===name));
        row.eligibility[name]={expected:want,actual:value};
      }
      row.originalRetained=JSON.stringify(after.original)===JSON.stringify(c.program.original);
      row.idempotent=JSON.stringify(api.p113i_optimize(after))===JSON.stringify(after);
      row.unchanged=JSON.stringify(after)===JSON.stringify(c.program);
      row.pass=row.afterDiagnostic===''&&JSON.stringify(row.before)===JSON.stringify(c.expected)&&
        JSON.stringify(row.after)===JSON.stringify(c.expected)&&row.remainingCalls===c.remaining&&
        row.explicitStackBytes<=c.maxStack&&row.originalRetained&&row.idempotent&&
        (!c.unchanged||row.unchanged)&&Object.values(row.eligibility).every(x=>x.expected===x.actual);
    }catch(error){row.error=String(error);row.pass=false;}
    save();console.log(JSON.stringify(row));
  }
  report.complete=report.cases.every(x=>x.pass);
  for(const p of report.inputs)if(JSON.stringify(pin(p.file))!==JSON.stringify(p))throw Error('Input changed '+p.file);
}catch(error){report.error=String(error);throw error;}
finally{save();}
if(!report.complete)process.exitCode=1;
