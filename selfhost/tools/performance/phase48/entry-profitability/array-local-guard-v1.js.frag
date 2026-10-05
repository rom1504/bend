// Call only after a fresh successful arrayViewHostGuard and canonical inputs.
// No new top-level host captures: optional-fragment placement must preserve the
// existing runtime snapshots before embedded foreign initializers execute.
function arrayViewLocalGuard(names){
  if(regionProof!==null)return false;
  if(Object.getPrototypeOf(localArrayPrototype)!==scalarObjectPrototype)return false;
  for(let i=0;i<4;i++){
    const k=i===0?'request':i===1?'bounce':i===2?'build':'code';
    if(Object.getOwnPropertyDescriptor(localArrayPrototype,k))return false;
  }
  let needsString=false;
  for(let i=0;i<names.length;i++)if(scalarSnapshots[names[i]]?.stringFamily){needsString=true;break;}
  if(needsString&&!stringHostGuard())return false;
  if(Object.getPrototypeOf(scalarObjectPrototype)!==null||
      Object.getPrototypeOf(scalarFunctionPrototype)!==scalarObjectPrototype)return false;
  for(let i=0;i<=scalarPrimitivePrototypes.length;i++){
    const p=i===0?scalarObjectPrototype:scalarPrimitivePrototypes[i-1];
    if(p!==scalarObjectPrototype&&Object.getPrototypeOf(p)!==scalarObjectPrototype)return false;
    for(let j=0;j<4;j++){
      const k=j===0?'request':j===1?'bounce':j===2?'build':'code';
      if(Object.getOwnPropertyDescriptor(p,k))return false;
    }
  }
  for(let i=0;i<2;i++)if(Object.getOwnPropertyDescriptor(scalarObjectPrototype,i===0?'io':'typeName'))return false;
  const invoke=Object.getOwnPropertyDescriptor(scalarFunctionPrototype,'call');
  if(!invoke||!Object.hasOwn(invoke,'value')||invoke.value!==scalarFunctionCall)return false;
  for(let i=0;i<names.length;i++){
    const name=names[i];
    const s=name==='Nat.add'?scalarNatAddSnapshot:scalarSnapshots[name],g=Object.getOwnPropertyDescriptor(G,name);
    if(!s||!g||!Object.hasOwn(g,'value')||g.value!==s.original)return false;
    const f=s.original;
    if(Object.getPrototypeOf(f)!==scalarObjectPrototype||
        Object.getPrototypeOf(s.code)!==scalarFunctionPrototype||
        Object.getOwnPropertyDescriptor(s.code,'call'))return false;
    for(let j=0;j<2;j++)if(Object.getOwnPropertyDescriptor(f,j===0?'io':'typeName'))return false;
    const a=Object.getOwnPropertyDescriptor(f,'arity'),c=Object.getOwnPropertyDescriptor(f,'code');
    const e=Object.getOwnPropertyDescriptor(f,'env'),b=Object.getOwnPropertyDescriptor(f,'bound');
    if(!a||!c||!e||!b||!Object.hasOwn(a,'value')||!Object.hasOwn(c,'value')||
        !Object.hasOwn(e,'value')||!Object.hasOwn(b,'value')||
        a.value!==s.arity||c.value!==s.code||e.value!==null||b.value!==s.bound||
        Object.getOwnPropertyDescriptor(s.bound,'length').value!==0)return false;
  }
  return true;
}
