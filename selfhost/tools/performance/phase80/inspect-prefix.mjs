import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const dir=path.resolve(process.argv[2]);
const plan=JSON.parse(fs.readFileSync(path.resolve(process.argv[3]),'utf8')),role=plan.roles.ordinary;process.env.BEND_TYPED_API=role.api.file;process.env.BEND_TYPED_RUNTIME=role.runtime.file;process.env.BEND_BASE=role.base.file;
const D=await import(pathToFileURL(path.join(dir,'tools/typed-driver.mjs')));
const api=await D.loadApi();
const orig=api.base_prefix_prepare;
api.base_prefix_prepare=book=>{const state=orig(book);console.log(JSON.stringify({state:{...state,patches:undefined},patches:count(state.patches),rawBound:max(book),patchBound:max(state.patches),rawNodes:nodes(book),patchNodes:nodes(state.patches)}));return state};
function count(x){let n=0;while(x?.$==='Con'){n++;x=x.tail;}return n;}
function max(x){let m=0;const todo=[x],seen=new Set();while(todo.length){const t=todo.pop();if(!t||typeof t!=='object'||seen.has(t))continue;seen.add(t);if(['KTerm','KLambda'].includes(t.$))m=Math.max(m,t.id??0);for(const v of Object.values(t))if(v&&typeof v==='object')todo.push(v);}return m;}
function nodes(x){const todo=[x],seen=new Set();while(todo.length){const t=todo.pop();if(!t||typeof t!=='object'||seen.has(t))continue;seen.add(t);for(const v of Object.values(t))if(v&&typeof v==='object')todo.push(v);}return seen.size;}
const source={ $:'FSource',name:'Base',path:role.base.file,text:fs.readFileSync(role.base.file,'utf8')};
const located=api.f_source_located(source,1,1+[...source.text].length);const loaded=api.f_load_graph('Base',{$:'Con',head:located,tail:{$:'Nil'}});if(loaded.error)throw Error(loaded.error);api.base_prefix_prepare(loaded.book);
