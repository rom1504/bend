// Isolated eager arena experiment. Compiler algorithms and production cache
// readers are unchanged. Both mandatory and optional records validate eagerly.
import crypto from 'node:crypto';
const FORMAT='bend-base-cache-indexed-prototype-1',MAGIC=0x31494142,MAX=1048576;
const TERM=1,DEF=2,TERMS=4,DEFS=8,STRINGS=16,EMPTY=28,CHECKED=32,FRESH=64,WORLD=128,FRONTEND=256;
const LITTLE=new Uint8Array(new Uint32Array([1]).buffer)[0]===1;
const counts=[0,2,8,8,5,9,2,4,5,2,6,4];
const stringFields=[[],[],[0,1],[0],[0,2],[0,1],[],[],[],[],[],[]];
const boolFields=[[],[],[],[7],[],[7,8],[],[],[4],[1],[],[3]];
const digest=x=>crypto.createHash('sha256').update(x).digest('hex');
const fail=()=>{throw Error('Invalid indexed prepared Base');};
const u32=x=>typeof x==='number'&&(x>>>0)===x;
const align=x=>(x+3)&~3;

function pack(wire,base=null) {
  if(!Array.isArray(wire)||wire.length!==4||wire[0]!==1||wire[1]!== (base?.nodes??0)||!Array.isArray(wire[2])||!Array.isArray(wire[3]))fail();
  const rows=wire[3],strings=base?base.strings.slice():[],ids=new Map(strings.map((s,i)=>[s,i]));
  const baseStrings=strings.length,tags=[],offsets=[0],fields=[];
  const intern=s=>{if(typeof s!=='string')fail();let id=ids.get(s);if(id===undefined){id=strings.length;strings.push(s);ids.set(s,id);}return id;};
  for(const row of rows){
    if(!Array.isArray(row)||!u32(row[0])||row[0]>=counts.length)fail();
    const tag=row[0],size=row.length-1;
    if(size!==counts[tag]&&!(tag===10&&size===7))fail();
    if(tag===1&&typeof row[1]!=='string'&&(!u32(row[1])||row[1]>=wire[1]+tags.length))fail();
    tags.push(tag);
    for(let j=0;j<size;j++){
      let v=row[j+1];
      if(stringFields[tag].includes(j))v=intern(v);
      else if(tag===1&&j===0&&typeof v==='string')v=intern(v)+0x80000000;
      else if(boolFields[tag].includes(j)){if(typeof v!=='boolean')fail();v=v?1:0;}
      else if(!u32(v)||Object.is(v,-0))fail(); // Canonical producer JSON never emits -0.
      fields.push(v);
    }
    offsets.push(fields.length);
  }
  const newStrings=strings.slice(baseStrings),stringOffsets=[0],stringBytes=[];
  for(const s of newStrings){const b=Buffer.from(s,'utf16le');stringBytes.push(b);stringOffsets.push(stringOffsets.at(-1)+b.length/2);}
  const roots=wire[2],n=rows.length,nf=fields.length,ns=newStrings.length,units=stringOffsets.at(-1);
  if(n+wire[1]>MAX||strings.length>MAX||roots.length>8)fail();
  const total=align(32+roots.length*4+align(n)+(n+1)*4+nf*4+(ns+1)*4+units*2);
  if(total>128*1024*1024)fail();
  const out=Buffer.alloc(total);let at=0;
  const word=v=>{out.writeUInt32LE(v,at);at+=4;};
  for(const v of [MAGIC,wire[1],n,baseStrings,ns,nf,units,roots.length])word(v);
  for(const id of roots){if(id!==null&&(!u32(id)||id>=wire[1]+n))fail();word(id===null?0xffffffff:id);}
  for(const tag of tags)out[at++]=tag;at=align(at);
  for(const v of offsets)word(v);for(const v of fields)word(v);for(const v of stringOffsets)word(v);
  for(const b of stringBytes){b.copy(out,at);at+=b.length;}
  return {bytes:out,nodes:wire[1]+n,strings};
}

export function encodeIndexedFrame(frame3) {
  const cut=frame3.indexOf(10);if(cut<0)fail();
  const h=JSON.parse(frame3.subarray(0,cut)),payload=frame3.subarray(cut+1);
  if(h.format!=='bend-base-cache-frame-3'||!Array.isArray(h.segments)||h.segments.length!==2||h.segments[0]+h.segments[1]!==payload.length)fail();
  const b=payload.subarray(0,h.segments[0]),p=payload.subarray(h.segments[0]);
  if(digest(b)!==h.bookGraphSha256||digest(p)!==h.preparedGraphSha256)fail();
  const book=pack(JSON.parse(b)),prepared=pack(JSON.parse(p),book);
  const {format,segments,bookGraphSha256,preparedGraphSha256,...metadata}=h;
  const ph=digest(prepared.bytes);
  const header={...metadata,format:FORMAT,segments:[book.bytes.length,prepared.bytes.length],bookArenaSha256:digest(book.bytes),preparedArenaSha256:ph,
    checkedPrefixStateSha256:ph,freshPrefixStateSha256:ph};
  const text=Buffer.from(JSON.stringify(header));
  // A padded header allows direct typed views on ordinary file buffers.
  const padding=Buffer.alloc((4-(text.length+1)%4)%4,32);
  return Buffer.concat([text,padding,Buffer.from('\n'),book.bytes,prepared.bytes]);
}

function unpack(input,{base=null,range,termAbi,rootKinds}) {
  if(input.length<32||input.length>128*1024*1024||!range||!u32(range.begin)||!u32(range.end)||range.begin===0||range.end<=range.begin)fail();
  const bytes=input.byteOffset%4?Buffer.from(input):input;
  if(bytes.readUInt32LE(0)!==MAGIC)fail();
  const bn=bytes.readUInt32LE(4),n=bytes.readUInt32LE(8),bs=bytes.readUInt32LE(12),ns=bytes.readUInt32LE(16),nf=bytes.readUInt32LE(20),units=bytes.readUInt32LE(24),nr=bytes.readUInt32LE(28);
  if(bn!==(base?.nodes.length??0)||bs!==(base?.strings.length??0)||bn+n>MAX||bs+ns>MAX||nf>n*9||nr!==rootKinds.length||nr>8)fail();
  const tagsAt=32+nr*4,offsetsAt=tagsAt+align(n),fieldsAt=offsetsAt+4*(n+1),stringsAt=fieldsAt+4*nf,textAt=stringsAt+4*(ns+1),end=textAt+units*2;
  if(!Number.isSafeInteger(end)||align(end)!==bytes.length||end>bytes.length)fail();
  for(let i=tagsAt+n;i<offsetsAt;i++)if(bytes[i]!==0)fail();for(let i=end;i<bytes.length;i++)if(bytes[i]!==0)fail();
  const words=(at,length)=>{
    if(LITTLE)return new Uint32Array(bytes.buffer,bytes.byteOffset+at,length);
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
    if(tag>=counts.length||at>nf||offsets[i+1]>nf||(size!==counts[tag]&&!(tag===10&&size===7)))fail();
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
          {$:'KBasePreparedWorld',state:ref(a,CHECKED),prefix:ref(b,DEFS),final:ref(c,DEFS),book:ref(d,DEFS),checked:ref(e,DEFS),seen:ref(f,DEFS),todos:g};kind=WORLD;break;
      case 11:
        if(d>1)fail();node={$:'FReadyPrefixState',names:ref(a,DEF),ctors:ref(b,DEF),count:c,ready:d===1};kind=FRONTEND;break;
    }
    nodes.push(node);kinds.push(kind);
  }
  const roots=Array.from(rootIds,(id,i)=>id===0xffffffff?null:ref(id,rootKinds[i]));
  return {roots,nodes,kinds,strings};
}

export function decodeIndexedFrame(bytes) {
  const cut=bytes.indexOf(10);if(cut<0)fail();
  const header=JSON.parse(bytes.subarray(0,cut)),payload=bytes.subarray(cut+1);
  if(header===null||typeof header!=='object'||Array.isArray(header)||header.format!==FORMAT||
    ['book','checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState'].some(k=>Object.hasOwn(header,k))||
    !Array.isArray(header.segments)||header.segments.length!==2||header.segments.some(n=>!Number.isSafeInteger(n)||n<0)||header.segments[0]+header.segments[1]!==payload.length)fail();
  const bookBytes=payload.subarray(0,header.segments[0]),preparedBytes=payload.subarray(header.segments[0]);
  if(typeof header.bookArenaSha256!=='string'||digest(bookBytes)!==header.bookArenaSha256)fail();
  const options={range:{begin:header.sourceBegin,end:header.sourceEnd},termAbi:header.termAbi??0};
  const book=unpack(bookBytes,{...options,rootKinds:[DEFS]});if(book.roots[0]===null)fail();
  const {format,segments,bookArenaSha256,preparedArenaSha256,...metadata}=header;
  const cached={...metadata,book:book.roots[0]};
  if(preparedBytes.length&&typeof preparedArenaSha256==='string'&&digest(preparedBytes)===preparedArenaSha256){
    try {
      const prepared=unpack(preparedBytes,{...options,base:book,rootKinds:[CHECKED,FRESH,WORLD,FRONTEND]});
      for(const [i,key] of ['checkedPrefixState','freshPrefixState','preparedWorld','frontendReadyState'].entries())if(prepared.roots[i]!==null)cached[key]=prepared.roots[i];
    }catch { /* Invalid optional state retains ordinary checking. */ }
  }
  return cached;
}

export function inspectIndexedLayout(bytes) {
  const cut=bytes.indexOf(10),header=JSON.parse(bytes.subarray(0,cut)),payload=bytes.subarray(cut+1);
  return {header,segments:[payload.subarray(0,header.segments[0]),payload.subarray(header.segments[0])],headerBytes:cut+1};
}
