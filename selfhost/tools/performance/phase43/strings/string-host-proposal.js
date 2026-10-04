// Standard host initialization is the established runtime premise.
const stringHostOwnKeys=Reflect.ownKeys;
const stringHostConstructor=String,stringHostPrototype=String.prototype;
const stringHostGlobal=regionGetDescriptor(globalThis,'String');
const stringHostRows=[stringHostConstructor,stringHostPrototype].map(object=>({object,parent:regionGetPrototype(object),keys:stringHostOwnKeys(object),descriptors:Object.getOwnPropertyDescriptors(object)}));
function stringHostDescriptor(a,b){if(!a||!b)return a===b;if(a.configurable!==b.configurable||a.enumerable!==b.enumerable)return false;
 const av=regionOwn(a,'value'),bv=regionOwn(b,'value');return av===bv&&(av?a.value===b.value&&a.writable===b.writable:a.get===b.get&&a.set===b.set);}
function stringHostGuard(){if(!stringHostDescriptor(regionGetDescriptor(globalThis,'String'),stringHostGlobal))return false;
 for(let i=0;i<stringHostRows.length;i++){const row=stringHostRows[i];if(regionGetPrototype(row.object)!==row.parent)return false;const keys=stringHostOwnKeys(row.object);if(keys.length!==row.keys.length)return false;
  for(let k=0;k<keys.length;k++)if(keys[k]!==row.keys[k]||!stringHostDescriptor(regionGetDescriptor(row.object,keys[k]),row.descriptors[keys[k]]))return false;}
 return true;}
