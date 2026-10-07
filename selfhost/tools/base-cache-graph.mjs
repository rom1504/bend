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
const listKinds=new Set(['terms','defs','strings']);
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

// References are strictly backwards, so cycles and dangling references cannot
// enter the compiler. Each distinct node is type/range checked once while built.
export function decodeBaseGraph(bytes,{base=null,range,termAbi=1,rootKinds}={}) {
  if(bytes.length>128*1024*1024)fail();
  const wire=JSON.parse(bytes.toString('utf8'));
  if(!Array.isArray(wire)||wire.length!==4||wire[0]!==1||!Array.isArray(wire[2])||!Array.isArray(wire[3])||
    wire[1]!== (base?.nodes.length??0)||!Array.isArray(rootKinds)||wire[2].length!==rootKinds.length||
    !range||!uint(range.begin)||range.begin===0||!uint(range.end)||range.end<=range.begin||wire[1]+wire[3].length>1048576)fail();
  const nodes=base?base.nodes.slice():[],kinds=base?base.kinds.slice():[];
  const accepts=(expected,actual)=>expected===actual||(actual==='empty'&&listKinds.has(expected));
  const ref=(index,type)=>{
    if(!Number.isSafeInteger(index)||index<0||index>=nodes.length||!accepts(type,kinds[index]))fail();
    return nodes[index];
  };
  for(const row of wire[3]){
    if(!Array.isArray(row)||!Number.isSafeInteger(row[0]))fail();
    const spec=specs[row[0]];
    if(!spec||row.length!==spec[2].length+1)fail();
    const [tag,kind,fields]=spec,node={$:tag};let actualKind=kind;
    for(let i=0;i<fields.length;i++){
      const [key,type]=fields[i],value=row[i+1];
      if(type==='s'){if(typeof value!=='string')fail();node[key]=value;}
      else if(type==='u'){if(!uint(value))fail();node[key]=value;}
      else if(type==='b'){if(typeof value!=='boolean')fail();node[key]=value;}
      else if(type==='head'){
        if(typeof value==='string'){node.head=value;actualKind='strings';}
        else {
          if(!Number.isSafeInteger(value)||value<0||value>=nodes.length||!['term','def'].includes(kinds[value]))fail();
          node.head=nodes[value];actualKind=kinds[value]==='term'?'terms':'defs';
        }
      }else node[key]=ref(value,type==='tail'?actualKind:type);
    }
    if(kind==='term'){
      const a=node.originBegin,b=node.originEnd;
      if(!((a===0&&b===0)||(a>=range.begin&&b>=a&&b<range.end)))fail();
      if(tag!=='KTerm'&&termAbi!==1)fail();
      if(tag==='KLiteral'&&(!['Nat','U32','F32','String'].includes(node.kind)||
        (node.kind==='String'?(node.number!==0||Array.from(node.text).some(c=>{const n=c.codePointAt(0);return n>=0xd800&&n<=0xdfff;})):node.text!=='')))fail();
    }
    nodes.push(node);kinds.push(actualKind);
  }
  const roots=wire[2].map((id,i)=>id===null?null:ref(id,rootKinds[i]));
  return {roots,nodes,kinds};
}
