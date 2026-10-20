// Independent finite IR interpreter extracted from frozen reflect-v2.mjs.
// Array extension tests below use explicit deterministic scalar-cell contracts,
// not the production allocator or heap model.
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
  // Controlled opaque handle 100 denotes the independent two-cell array [7,11].
  // This models logical observations only; no production heap layout is used.
  const arrays=new Map([[100n,[7n,11n]]]);
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
          if(s.symbol==='p113_rt_array_pair') {
            if(actuals.length!==6||!actuals[0]?.state||actuals[5]!==2n)
              throw Error('Array pair interpreter signature');
            const [state,op,input,count,output]=actuals;
            const handle=input.get(0),index=input.get(8),replacement=input.get(16);
            const cells=arrays.get(handle);
            if(!cells)throw Error('Unknown independent array handle');
            let second;
            if(op===72n&&count===2n)second=cells[Number(index%BigInt(cells.length))];
            else if(op===74n&&count===3n) {
              const at=Number(index%BigInt(cells.length));second=cells[at];cells[at]=replacement;
            } else if(op===75n&&count===1n)second=BigInt(cells.length);
            else throw Error('Unsupported independent array operation');
            trace.push('p113_rt_array_pair:'+op+':'+handle);
            output.set(0,handle);output.set(8,second);env.set(s.name,0n);return;
          }
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

export { list, arr, l, w, ptr, word, local, scalar, set, bin, ret, again, call, branch, alloc, store, load, rt, fn, bundle, execute, callCount, stackBytes };
