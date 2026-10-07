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
  ['KBasePreparedWorld','world',[['state','checked'],['prefix','defs'],['final','defs'],['book','defs'],['checked','defs'],['seen','defs'],['todos','u'],['checkedBound','u']]],
  ['FReadyPrefixState','frontend',[['names','def'],['ctors','def'],['count','u'],['ready','b']]],
];
const byTag=new Map(specs.map((s,i)=>[s[0],i]));
const object=x=>x!==null&&typeof x==='object'&&!Array.isArray(x);
const uint=x=>Number.isSafeInteger(x)&&x>=0&&x<=U32_MAX;
const fail=()=>{throw Error('Invalid prepared Base graph');};
const scalar=t=>t==='s'||t==='u'||t==='b';

// Preparation may be comparatively expensive. Structural interning is exact,
// includes origins and flags, and never changes the public mutable input ABI.
function baseGraphRecords(roots,base=null,strictUnsigned=false) {
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
          // Arena scalars must be canonical before JSON-key interning can merge
          // equivalent records. The legacy JSON encoder keeps its old domain.
          if(strictUnsigned&&type==='u'&&(!uint(child)||Object.is(child,-0)))fail();
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
  return {records,intern,roots:indexes,baseCount};
}

export function encodeBaseGraph(roots,base=null) {
  const graph=baseGraphRecords(roots,base),{baseCount,roots:indexes,records}=graph;
  return {...graph,bytes:Buffer.from(JSON.stringify([1,baseCount,indexes,records.slice(baseCount)]))};
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
        if((r.length!==7&&r.length!==8&&r.length!==9)||(r.length>=8&&!u32(r[7]))||(r.length===9&&!u32(r[8])))fail();
        // Old optional worlds remain decodable; the host's version admission
        // decides whether their missing fact can be consumed by this API.
        node=r.length===7?{$:'KBasePreparedWorld',state:ref(r[1],CHECKED),prefix:ref(r[2],DEFS),final:ref(r[3],DEFS),book:ref(r[4],DEFS),checked:ref(r[5],DEFS),seen:ref(r[6],DEFS)}:
          r.length===8?{$:'KBasePreparedWorld',state:ref(r[1],CHECKED),prefix:ref(r[2],DEFS),final:ref(r[3],DEFS),book:ref(r[4],DEFS),checked:ref(r[5],DEFS),seen:ref(r[6],DEFS),todos:r[7]}:
          {$:'KBasePreparedWorld',state:ref(r[1],CHECKED),prefix:ref(r[2],DEFS),final:ref(r[3],DEFS),book:ref(r[4],DEFS),checked:ref(r[5],DEFS),seen:ref(r[6],DEFS),todos:r[7],checkedBound:r[8]};kind=WORLD;break;
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

// Arena transport shares constructor field roles and graph interning with JSON.
// Its typed tables avoid parsing JSON record arrays; every record still validates.
const ARENA_MAGIC=0x31494142,ARENA_MAX=1048576;
const TERM=1,DEF=2,TERMS=4,DEFS=8,STRINGS=16,EMPTY=28,CHECKED=32,FRESH=64,WORLD=128,FRONTEND=256;
const ARENA_LITTLE=new Uint8Array(new Uint32Array([1]).buffer)[0]===1;
const arenaCounts=specs.map(s=>s[2].length);
const arenaStringFields=specs.map(s=>s[2].flatMap((f,i)=>f[1]==='s'?[i]:[]));
const arenaBoolFields=specs.map(s=>s[2].flatMap((f,i)=>f[1]==='b'?[i]:[]));
const arenaMasks={term:TERM,def:DEF,terms:TERMS,defs:DEFS,strings:STRINGS,checked:CHECKED,fresh:FRESH,world:WORLD,frontend:FRONTEND};
const arenaU32=x=>typeof x==='number'&&(x>>>0)===x;
const arenaAlign=x=>(x+3)&~3;

export function encodeBaseArena(roots,base=null) {
  const graph=baseGraphRecords(roots,base,true),baseCount=graph.baseCount;
  const rows=graph.records.slice(baseCount),strings=base?base.strings.slice():[],ids=new Map(strings.map((s,i)=>[s,i]));
  const baseStrings=strings.length,tags=[],offsets=[0],fields=[];
  const intern=s=>{if(typeof s!=='string')fail();let id=ids.get(s);if(id===undefined){id=strings.length;strings.push(s);ids.set(s,id);}return id;};
  for(const row of rows){
    if(!Array.isArray(row)||!arenaU32(row[0])||row[0]>=arenaCounts.length)fail();
    const tag=row[0],size=row.length-1;
    if(size!==arenaCounts[tag]&&!(tag===10&&(size===6||size===7)))fail();
    if(tag===1&&typeof row[1]!=='string'&&(!arenaU32(row[1])||row[1]>=baseCount+tags.length))fail();
    tags.push(tag);
    for(let j=0;j<size;j++){
      let v=row[j+1];
      if(arenaStringFields[tag].includes(j))v=intern(v);
      else if(tag===1&&j===0&&typeof v==='string')v=intern(v)+0x80000000;
      else if(arenaBoolFields[tag].includes(j)){if(typeof v!=='boolean')fail();v=v?1:0;}
      else if(!arenaU32(v)||Object.is(v,-0))fail(); // Canonical producer JSON never emits -0.
      fields.push(v);
    }
    offsets.push(fields.length);
  }
  const newStrings=strings.slice(baseStrings),stringOffsets=[0],stringBytes=[];
  for(const s of newStrings){const b=Buffer.from(s,'utf16le');stringBytes.push(b);stringOffsets.push(stringOffsets.at(-1)+b.length/2);}
  const indexes=graph.roots,n=rows.length,nf=fields.length,ns=newStrings.length,units=stringOffsets.at(-1);
  if(n+baseCount>ARENA_MAX||strings.length>ARENA_MAX||indexes.length>8)fail();
  const total=arenaAlign(32+indexes.length*4+arenaAlign(n)+(n+1)*4+nf*4+(ns+1)*4+units*2);
  if(total>128*1024*1024)fail();
  const out=Buffer.alloc(total);let at=0;
  const word=v=>{out.writeUInt32LE(v,at);at+=4;};
  for(const v of [ARENA_MAGIC,baseCount,n,baseStrings,ns,nf,units,indexes.length])word(v);
  for(const id of indexes){if(id!==null&&(!arenaU32(id)||id>=baseCount+n))fail();word(id===null?0xffffffff:id);}
  for(const tag of tags)out[at++]=tag;at=arenaAlign(at);
  for(const v of offsets)word(v);for(const v of fields)word(v);for(const v of stringOffsets)word(v);
  for(const b of stringBytes){b.copy(out,at);at+=b.length;}
  return {...graph,bytes:out,strings};
}

export function decodeBaseArena(input,{base=null,range,termAbi=1,rootKinds}={}) {
  if(input.length<32||input.length>128*1024*1024||!Array.isArray(rootKinds)||!range||!arenaU32(range.begin)||!arenaU32(range.end)||range.begin===0||range.end<=range.begin)fail();
  const bytes=input.byteOffset%4?Buffer.from(input):input;
  if(bytes.readUInt32LE(0)!==ARENA_MAGIC)fail();
  const bn=bytes.readUInt32LE(4),n=bytes.readUInt32LE(8),bs=bytes.readUInt32LE(12),ns=bytes.readUInt32LE(16),nf=bytes.readUInt32LE(20),units=bytes.readUInt32LE(24),nr=bytes.readUInt32LE(28);
  if(bn!==(base?.nodes.length??0)||bs!==(base?.strings.length??0)||bn+n>ARENA_MAX||bs+ns>ARENA_MAX||nf>n*9||nr!==rootKinds.length||nr>8)fail();
  const tagsAt=32+nr*4,offsetsAt=tagsAt+arenaAlign(n),fieldsAt=offsetsAt+4*(n+1),stringsAt=fieldsAt+4*nf,textAt=stringsAt+4*(ns+1),end=textAt+units*2;
  if(!Number.isSafeInteger(end)||arenaAlign(end)!==bytes.length||end>bytes.length)fail();
  for(let i=tagsAt+n;i<offsetsAt;i++)if(bytes[i]!==0)fail();for(let i=end;i<bytes.length;i++)if(bytes[i]!==0)fail();
  const words=(at,length)=>{
    if(ARENA_LITTLE)return new Uint32Array(bytes.buffer,bytes.byteOffset+at,length);
    const out=new Uint32Array(length);for(let i=0;i<length;i++)out[i]=bytes.readUInt32LE(at+i*4);return out;
  };
  const offsets=words(offsetsAt,n+1),fields=words(fieldsAt,nf),stringOffsets=words(stringsAt,ns+1),rootIds=words(32,nr);
  if(offsets[0]!==0||offsets[n]!==nf||stringOffsets[0]!==0||stringOffsets[ns]!==units)fail();
  const text=bytes.toString('utf16le',textAt,end),strings=base?base.strings.slice():[];
  for(let i=0;i<ns;i++){const a=stringOffsets[i],b=stringOffsets[i+1];if(b<a||b>units)fail();strings.push(text.slice(a,b));}
  const nodes=base?base.nodes.slice():[],kinds=base?base.kinds.slice():[];
  const ref=(i,mask)=>{if(i>=nodes.length||!(kinds[i]&mask))fail();return nodes[i];};
  const str=i=>{if(i>=strings.length)fail();return strings[i];};
  const span=(a,b)=>{if(!((a===0&&b===0)||(a>=range.begin&&b>=a&&b<range.end)))fail();};
  for(let i=0;i<n;i++){
    const tag=bytes[tagsAt+i],at=offsets[i],size=offsets[i+1]-at;
    if(tag>=arenaCounts.length||at>nf||offsets[i+1]>nf||(size!==arenaCounts[tag]&&!(tag===10&&(size===6||size===7))))fail();
    const a=fields[at],b=fields[at+1],c=fields[at+2],d=fields[at+3],e=fields[at+4],f=fields[at+5],g=fields[at+6],h=fields[at+7],j=fields[at+8];
    let node,kind;
    switch(tag){
      case 0:node={$:'Nil'};kind=EMPTY;break;
      case 1:
        if(a&0x80000000){kind=STRINGS;node={$:'Con',head:str(a&0x7fffffff),tail:ref(b,STRINGS)};}
        else {if(a>=nodes.length)fail();if(kinds[a]===TERM)kind=TERMS;else if(kinds[a]===DEF)kind=DEFS;else fail();node={$:'Con',head:nodes[a],tail:ref(b,kind)};}
        break;
      case 2:
        span(g,h);node={$:'KTerm',tag:str(a),name:str(b),id:c,quant:d,kids:ref(e,TERMS),removed:ref(f,STRINGS),originBegin:g,originEnd:h};kind=TERM;break;
      case 3:
        if(termAbi!==1||h>1)fail();span(f,g);node={$:'KLambda',name:str(a),id:b,quant:c,kids:ref(d,TERMS),removed:ref(e,STRINGS),originBegin:f,originEnd:g,quantityPresent:h===1};kind=TERM;break;
      case 4: {
        if(termAbi!==1)fail();const literalKind=str(a),literalText=str(c);
        if(literalKind==='String'){if(b!==0)fail();for(const ch of literalText){const cp=ch.codePointAt(0);if(cp>=0xd800&&cp<=0xdfff)fail();}}
        else if((literalKind!=='Nat'&&literalKind!=='U32'&&literalKind!=='F32')||literalText!=='')fail();
        span(d,e);node={$:'KLiteral',kind:literalKind,number:b,text:literalText,originBegin:d,originEnd:e};kind=TERM;break;
      }
      case 5:
        if(h>1||j>1)fail();node={$:'KDef',name:str(a),kind:str(b),arity:c,templates:d,typ:ref(e,TERM),value:ref(f,TERM),ctors:ref(g,DEFS),native:h===1,unsafe:j===1};kind=DEF;break;
      case 6:node={$:'KIndexLeaf',hash:a,bucket:ref(b,DEFS)};kind=DEF;break;
      case 7:node={$:'KIndexNode',hash:a,mask:b,left:ref(c,DEF),right:ref(d,DEF)};kind=DEF;break;
      case 8:
        if(e>1)fail();node={$:'KBasePrefixState',bound:a,delta:b,stamp:c,patches:ref(d,DEFS),ready:e===1};kind=CHECKED;break;
      case 9:
        if(b>1)fail();node={$:'FFreshPrefixState',next:a,ready:b===1};kind=FRESH;break;
      case 10:
        node=size===6?{$:'KBasePreparedWorld',state:ref(a,CHECKED),prefix:ref(b,DEFS),final:ref(c,DEFS),book:ref(d,DEFS),checked:ref(e,DEFS),seen:ref(f,DEFS)}:
          size===7?{$:'KBasePreparedWorld',state:ref(a,CHECKED),prefix:ref(b,DEFS),final:ref(c,DEFS),book:ref(d,DEFS),checked:ref(e,DEFS),seen:ref(f,DEFS),todos:g}:
          {$:'KBasePreparedWorld',state:ref(a,CHECKED),prefix:ref(b,DEFS),final:ref(c,DEFS),book:ref(d,DEFS),checked:ref(e,DEFS),seen:ref(f,DEFS),todos:g,checkedBound:h};kind=WORLD;break;
      case 11:
        if(d>1)fail();node={$:'FReadyPrefixState',names:ref(a,DEF),ctors:ref(b,DEF),count:c,ready:d===1};kind=FRONTEND;break;
    }
    nodes.push(node);kinds.push(kind);
  }
  const roots=Array.from(rootIds,(id,i)=>{
    if(id===0xffffffff)return null;
    if(rootKinds[i]==='empty'){if(id>=nodes.length||kinds[id]!==EMPTY)fail();return nodes[id];}
    return ref(id,Object.hasOwn(arenaMasks,rootKinds[i])?arenaMasks[rootKinds[i]]:0);
  });
  return {roots,nodes,kinds,strings};
}

