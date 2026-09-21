// Type descriptors are emitted by the Bend2 backend; no source/type inference here.
// ['Char'], ['F32'], ['List', item], ['Array', item], ['Tuple', left, right],
// ['Type', normalizedSource], ['ADT', {Constructor: [fieldDescriptors]}].
function showChar(c,q){const e={10:'n',9:'t',13:'r',0:'0',92:'\\'}[c]??(c===q.codePointAt(0)?q:null);return e!==null?'\\'+e:c<32||c===127?'\\u{'+c.toString(16)+'}':String.fromCodePoint(c)}
function show(x,d=null,chain=false){
  if(d?.[0]==='Named')d=showSchemas[d[1]]?.(d[2])??null;
  const tag=d?.[0];
  if(tag==='Type'&&d[1]!==undefined)return d[1];
  if(tag==='Char')return "'"+showChar(typeof x==='string'?x.codePointAt(0):x,"'")+"'";
  if(tag==='F32')return floatShow(x).replace(/^-?\d+(?=e|$)/,'$&.0');
  if(x?.proof)return '{==}';
  if(x?.typeName)return x.typeName+(x.typeArgs?.length?'<'+x.typeArgs.map(t=>show(t)).join(', ')+'>':'');
  if(x===null)return 'Type';if(typeof x==='bigint')return x+'n';if(typeof x==='number')return String(x);if(typeof x==='boolean')return x?'True{}':'False{}';if(typeof x==='string')return '"'+Array.from(x,c=>showChar(c.codePointAt(0),'"')).join('')+'"';
  if(Array.isArray(x)){const left=show(x[0],d?.[1]),right=show(x[1],d?.[2],true);return (chain?'':'(')+left+', '+right+(chain?'':')')}
  if(x?.array||tag==='Array')return '['+arraydata(x).map(v=>show(v,d?.[1])).join(', ')+']';
  if(x?.$==='Con'||x?.$==='Nil')return '['+unlist(x).map(v=>show(v,tag==='ADT'?d[1]?.Con?.[0]:d?.[1])).join(', ')+']';
  if(x?.$){const ds=tag==='ADT'?d[1]?.[x.$]:null;return (constructorOwn[x.$]??x.$)+'{'+x.a.flatMap((v,i)=>ds?.[i]?.[0]==='Erased'?[]:[show(v,ds?.[i])]).join(', ')+'}'}
  return '<function>';
}
async function runmain(descriptor=null,isIO=false){
  let onExit;
  try{
    if(!G.main)return;
    if(runtimeOptions().help){fs.writeSync(1,'usage: '+process.argv[1]+'\n');return}
    const x=call(G.main,[]);
    if(x?.io||isIO){
      const deadlock=new Promise((_,reject)=>{onExit=()=>{if(pendingChannels)reject(Error('deadlock: every computation waits on a channel'))};process.once('beforeExit',onExit)});
      await Promise.race([runAction(x).then(async()=>{while(spawned.size)await Promise.all([...spawned])}),deadlock]);
    }else fs.writeSync(1,show(x,descriptor)+'\n');
  }catch(e){fs.writeSync(2,(e.rawMessage?'':'bend: ')+(e instanceof RangeError?'memory fault (machine stack overflow?)':e.message)+'\n');process.exitCode=e.exitCode??1}
  finally{if(onExit)process.off('beforeExit',onExit)}
  process.exit(process.exitCode??0);
}
