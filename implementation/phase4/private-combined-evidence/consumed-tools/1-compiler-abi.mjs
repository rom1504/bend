// Host-side views of the compiler's positional ADT ABI. Compiler phases keep
// their original graphs; only fields inspected by the host acquire wrappers.
export function createCompilerAbi({fields,ctor,onPhase}) {
  const views=new WeakMap(),originals=new WeakMap();
  const counts={views:0,encoded:0,unwrapped:0,calls:0};
  const object=value=>value!==null&&typeof value==='object';
  const arrayIndex=key=>typeof key==='string'&&String(key>>>0)===key&&key!=='4294967295';
  const keysFor=value=>{
    const keys=Object.hasOwn(fields,value.$)?fields[value.$]:undefined;
    if(!keys)throw Error('Unknown compiler ABI constructor: '+value.$);
    return keys;
  };

  // A fresh memo is necessary for host-owned inputs: callers may change them
  // between calls. Already decoded views bypass both copying and traversal.
  function encode(value) {
    const memo=new WeakMap(),pending=[];
    const allocate=value=>{
      if(!object(value))return value;
      if(originals.has(value)){counts.unwrapped++;return originals.get(value);}
      if(memo.has(value))return memo.get(value);
      const keys=Array.isArray(value)?null:keysFor(value);
      const target=keys===null?new Array(value.length):ctor(value.$,new Array(keys.length));
      memo.set(value,target);pending.push({value,target,keys});counts.encoded++;
      return target;
    };
    const root=allocate(value);
    while(pending.length) {
      const {value,target,keys}=pending.pop();
      if(keys===null) {
        for(let i=0;i<value.length;i++)if(Object.hasOwn(value,i))target[i]=allocate(value[i]);
      } else for(let i=0;i<keys.length;i++)target.a[i]=allocate(value[keys[i]]);
    }
    return root;
  }

  function decode(value) {
    if(!object(value))return value;
    if(views.has(value))return views.get(value);
    const array=Array.isArray(value),keys=array?null:keysFor(value);
    const target=array?value:{};
    const view=new Proxy(target,{
      get(target,key,receiver) {
        if(array) {
          const result=Reflect.get(target,key,receiver);
          return arrayIndex(key)?decode(result):result;
        }
        if(key==='$')return value.$;
        const index=keys.indexOf(key);
        return index<0?Reflect.get(target,key,receiver):decode(value.a[index]);
      },
      has(target,key) {return array?Reflect.has(target,key):key==='$'||keys.includes(key)||Reflect.has(target,key);},
      ownKeys(target) {return array?Reflect.ownKeys(target):['$',...keys];},
      getOwnPropertyDescriptor(target,key) {
        if(array) {
          const descriptor=Reflect.getOwnPropertyDescriptor(target,key);
          if(descriptor&&'value' in descriptor&&descriptor.configurable)descriptor.value=decode(descriptor.value);
          return descriptor;
        }
        if(key==='$')return {value:value.$,enumerable:true,configurable:true,writable:false};
        const index=keys.indexOf(key);
        if(index>=0)return {value:decode(value.a[index]),enumerable:true,configurable:true,writable:false};
        return Reflect.getOwnPropertyDescriptor(target,key);
      },
      // Views are read-only so host edits cannot silently mutate a compiler
      // graph shared with another phase. Host-created inputs remain mutable.
      set(){throw TypeError('Compiler ABI views are read-only');},
      defineProperty(){throw TypeError('Compiler ABI views are read-only');},
      deleteProperty(){throw TypeError('Compiler ABI views are read-only');},
      preventExtensions(){throw TypeError('Compiler ABI views are read-only');},
      setPrototypeOf(){throw TypeError('Compiler ABI views are read-only');}
    });
    views.set(value,view);originals.set(view,value);counts.views++;
    return view;
  }

  const stats=()=>({...counts});
  function wrap(api) {
    return Object.fromEntries(Object.entries(api).map(([name,method])=>[name,(...args)=>{
      counts.calls++;
      onPhase?.({name,phase:'encode',stats:stats()});
      const input=encode(args);
      onPhase?.({name,phase:'invoke',stats:stats()});
      const output=method(...input);
      onPhase?.({name,phase:'decode',stats:stats()});
      const result=decode(output);
      onPhase?.({name,phase:'return',stats:stats()});
      return result;
    }]));
  }
  return {encode,decode,wrap,stats};
}
