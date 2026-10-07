// Private prepared-Base transport. This codec preserves exact named ADT values,
// including source intervals, while sharing equal immutable subgraphs. It is not
// a checking certificate: callers still bind API/Base/path and producer identity.
const U32_MAX=0xffffffff;
const specs=[
  ['Nil','empty',[]],
  ['Con','list',[['head','head'],['tail','tail']]],
  ['KTerm','term',[['tag','s'],['name','s'],['id','u'],['quant','u'],['kids','terms'],['removed','strings'],['originBegin','u'],['originEnd','u']]],
  ['KLambda','term',[['name','s'],['id','u'],['quant','u'],['kids','terms'],['removed','strings'],['originBegin','u'],['originEnd','u'],['quantityPresent','b']]],
  ['KLiteral','term',[['kind','s'],['number','u'],['text','s'],['originBegin','u'],['originEnd','u']]],
  ['KDef','def',[['name','s'],['kind','s'],['arity','u'],['templates','u'],['typ','term'],['value','term'],['ctors','defs'],['native','b'],['unsafe','b']]],
  ['KIndexLeaf','def',[['hash','u'],['bucket','defs']]],
  ['KIndexNode','def',[['hash','u'],['mask','u'],['left','def'],['right','def']]],
  ['KBasePrefixState','checked',[['bound','u'],['delta','u'],['stamp','u'],['patches','defs'],['ready','b']]],
  ['FFreshPrefixState','fresh',[['next','u'],['ready','b']]],
  ['KBasePreparedWorld','world',[['state','checked'],['prefix','defs'],['final','defs'],['book','defs'],['checked','defs'],['seen','defs']]],
  ['FReadyPrefixState','frontend',[['names','def'],['ctors','def'],['count','u'],['ready','b']]],
];
const byTag=new Map(specs.map((s,i)=>[s[0],i]));
const object=x=>x!==null&&typeof x==='object'&&!Array.isArray(x);
const uint=x=>Number.isSafeInteger(x)&&x>=0&&x<=U32_MAX;
const fail=()=>{throw Error('Invalid prepared Base graph');};
const scalar=t=>t==='s'||t==='u'||t==='b';

// Preparation may be comparatively expensive. Structural interning is exact,
// includes origins and flags, and never changes the public mutable input ABI.
export function encodeBaseGraph(roots,base=null) {
  const records=base?base.records.slice():[],objects=new WeakMap(),intern=base?new Map(base.intern):new Map();
  const baseCount=records.length,active=new WeakSet();
  const visit=root=>{
    if(root===null)return null;
    const pending=[{value:root,done:false}];
    while(pending.length){
      const item=pending.pop(),value=item.value;
      if(!object(value))fail();
      if(objects.has(value))continue;
      const id=byTag.get(value.$),spec=specs[id];
      if(!spec||Object.keys(value).length!==spec[2].length+1||!Object.hasOwn(value,'$'))fail();
      if(!item.done){
        if(active.has(value))fail();
        active.add(value);pending.push({value,done:true});
        for(let i=spec[2].length-1;i>=0;i--){
          const [key,type]=spec[2][i];
          if(!Object.hasOwn(value,key))fail();
          const child=value[key];
          if(!scalar(type)&&!(type==='head'&&typeof child==='string'))pending.push({value:child,done:false});
        }
      }else{
        const row=[id];
        for(const [key,type] of spec[2]){
          const child=value[key];
          row.push(scalar(type)||(type==='head'&&typeof child==='string')?child:objects.get(child));
        }
        const key=JSON.stringify(row);let index=intern.get(key);
        if(index===undefined){index=records.length;records.push(row);intern.set(key,index);}
        objects.set(value,index);active.delete(value);
      }
    }
    return objects.get(root);
  };
  const indexes=roots.map(visit);
  return {bytes:Buffer.from(JSON.stringify([1,baseCount,indexes,records.slice(baseCount)])),records,intern};
}

// References are strictly backwards and constructor-specific checks run before
// allocation. Fixed literal shapes match compiler-produced named ADTs. Wire rows
// stay unchanged: numeric references are never replaced with object pointers.
export function decodeBaseGraph(bytes,{base=null,range,termAbi=1,rootKinds}={}) {
  if(bytes.length>128*1024*1024)fail();
  const wire=JSON.parse(bytes.toString('utf8'));
  if(!Array.isArray(wire)||wire.length!==4||wire[0]!==1||!Array.isArray(wire[2])||!Array.isArray(wire[3])||
    wire[1]!== (base?.nodes.length??0)||!Array.isArray(rootKinds)||wire[2].length!==rootKinds.length||
    !range||!uint(range.begin)||range.begin===0||!uint(range.end)||range.end<=range.begin||wire[1]+wire[3].length>1048576)fail();
  // The masks are private decode state: an empty list accepts each list family.
  const TERM=1,DEF=2,TERMS=4,DEFS=8,STRINGS=16,EMPTY=28,CHECKED=32,FRESH=64,WORLD=128,FRONTEND=256;
  const nodes=base?base.nodes.slice():[],kinds=base?base.kinds.slice():[];
  const u32=x=>typeof x==='number'&&(x>>>0)===x;
  const ref=(index,mask)=>{
    if(!u32(index)||index>=nodes.length||!(kinds[index]&mask))fail();
    return nodes[index];
  };
  const span=(a,b)=>{
    if(!u32(a)||!u32(b)||!((a===0&&b===0)||(a>=range.begin&&b>=a&&b<range.end)))fail();
  };
  const records=wire[3];
  for(let i=0;i<records.length;i++){
    const r=records[i];if(!Array.isArray(r))fail();
    let node,kind;
    switch(r[0]){
      case 0:
        if(r.length!==1)fail();
        node={$:'Nil'};kind=EMPTY;break;
      case 1: {
        if(r.length!==3)fail();
        const head=r[1];
        if(typeof head==='string'){kind=STRINGS;node={$:'Con',head,tail:ref(r[2],STRINGS)};}
        else {
          if(!u32(head)||head>=nodes.length)fail();
          const hkind=kinds[head];
          if(hkind===TERM)kind=TERMS;else if(hkind===DEF)kind=DEFS;else fail();
          node={$:'Con',head:nodes[head],tail:ref(r[2],kind)};
        }
        break;
      }
      case 2:
        if(r.length!==9||typeof r[1]!=='string'||typeof r[2]!=='string'||!u32(r[3])||!u32(r[4]))fail();
        span(r[7],r[8]);
        node={$:'KTerm',tag:r[1],name:r[2],id:r[3],quant:r[4],kids:ref(r[5],TERMS),removed:ref(r[6],STRINGS),originBegin:r[7],originEnd:r[8]};kind=TERM;break;
      case 3:
        if(r.length!==9||termAbi!==1||typeof r[1]!=='string'||!u32(r[2])||!u32(r[3])||typeof r[8]!=='boolean')fail();
        span(r[6],r[7]);
        node={$:'KLambda',name:r[1],id:r[2],quant:r[3],kids:ref(r[4],TERMS),removed:ref(r[5],STRINGS),originBegin:r[6],originEnd:r[7],quantityPresent:r[8]};kind=TERM;break;
      case 4:
        if(r.length!==6||termAbi!==1||!u32(r[2])||typeof r[3]!=='string')fail();
        if(r[1]==='String'){
          if(r[2]!==0)fail();
          for(const c of r[3]){const n=c.codePointAt(0);if(n>=0xd800&&n<=0xdfff)fail();}
        }else if((r[1]!=='Nat'&&r[1]!=='U32'&&r[1]!=='F32')||r[3]!=='')fail();
        span(r[4],r[5]);
        node={$:'KLiteral',kind:r[1],number:r[2],text:r[3],originBegin:r[4],originEnd:r[5]};kind=TERM;break;
      case 5:
        if(r.length!==10||typeof r[1]!=='string'||typeof r[2]!=='string'||!u32(r[3])||!u32(r[4])||typeof r[8]!=='boolean'||typeof r[9]!=='boolean')fail();
        node={$:'KDef',name:r[1],kind:r[2],arity:r[3],templates:r[4],typ:ref(r[5],TERM),value:ref(r[6],TERM),ctors:ref(r[7],DEFS),native:r[8],unsafe:r[9]};kind=DEF;break;
      case 6:
        if(r.length!==3||!u32(r[1]))fail();
        node={$:'KIndexLeaf',hash:r[1],bucket:ref(r[2],DEFS)};kind=DEF;break;
      case 7:
        if(r.length!==5||!u32(r[1])||!u32(r[2]))fail();
        node={$:'KIndexNode',hash:r[1],mask:r[2],left:ref(r[3],DEF),right:ref(r[4],DEF)};kind=DEF;break;
      case 8:
        if(r.length!==6||!u32(r[1])||!u32(r[2])||!u32(r[3])||typeof r[5]!=='boolean')fail();
        node={$:'KBasePrefixState',bound:r[1],delta:r[2],stamp:r[3],patches:ref(r[4],DEFS),ready:r[5]};kind=CHECKED;break;
      case 9:
        if(r.length!==3||!u32(r[1])||typeof r[2]!=='boolean')fail();
        node={$:'FFreshPrefixState',next:r[1],ready:r[2]};kind=FRESH;break;
      case 10:
        if(r.length!==7)fail();
        node={$:'KBasePreparedWorld',state:ref(r[1],CHECKED),prefix:ref(r[2],DEFS),final:ref(r[3],DEFS),book:ref(r[4],DEFS),checked:ref(r[5],DEFS),seen:ref(r[6],DEFS)};kind=WORLD;break;
      case 11:
        if(r.length!==5||!u32(r[3])||typeof r[4]!=='boolean')fail();
        node={$:'FReadyPrefixState',names:ref(r[1],DEF),ctors:ref(r[2],DEF),count:r[3],ready:r[4]};kind=FRONTEND;break;
      default:fail();
    }
    nodes.push(node);kinds.push(kind);
  }
  const masks={term:TERM,def:DEF,terms:TERMS,defs:DEFS,strings:STRINGS,checked:CHECKED,fresh:FRESH,world:WORLD,frontend:FRONTEND};
  const roots=wire[2].map((id,i)=>{
    if(id===null)return null;
    if(rootKinds[i]==='empty'){
      if(!u32(id)||id>=nodes.length||kinds[id]!==EMPTY)fail();
      return nodes[id];
    }
    return ref(id,Object.hasOwn(masks,rootKinds[i])?masks[rootKinds[i]]:0);
  });
  return {roots,nodes,kinds};
}
