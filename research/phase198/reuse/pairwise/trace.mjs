// Diagnostics only. The ordinary plan and ordinary target products never use
// these synthetic role maps. Each traced pattern matcher is a checked export.
const fnv=n=>{let x=2166136261;for(const c of n)x=Math.imul(x^c.codePointAt(0),16777619)>>>0;return x;};
const list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function index(es){if(es.length===1)return {$:'KIndexLeaf',hash:es[0].h,bucket:list([es[0].v])};
 const a=es[0].h;let d=0;for(const e of es)d|=a^e.h;
 if(!d)return {$:'KIndexLeaf',hash:a,bucket:list(es.map(e=>e.v))};
 const mask=(2**(31-Math.clz32(d)))>>>0;
 return {$:'KIndexNode',hash:a,mask,left:index(es.filter(e=>!(e.h&mask))),right:index(es.filter(e=>e.h&mask))};}
function entries(x){if(x.$==='KIndexNode')return [...entries(x.left),...entries(x.right)];const a=[];for(let t=x.bucket;t?.$==='Con';t=t.tail)a.push([t.head.name,t.head.typ.name]);return a;}
export function stageTrace(api,src,owner,leaf,node){
 const absent=api.x198pw_descriptor(src,'$p198.missing-diagnostic');
 const spec={self:owner,leaf,node,false:'False',true:'True'};
 const es=Object.entries(spec).map(([name,id])=>({h:fnv(name),v:{...absent,name,kind:'X198PWName',typ:{...absent.typ,tag:'Name',name:id}}}));
 let state={$:'X198PWState',roles:index(es),vars:absent};const ans=[];
 const stages=[['self',3,api.x198pw_root_leaf()],['self',3,api.x198pw_root_node()],['join',2,api.x198pw_join()],['leafFunction',3,api.x198pw_leaf_function()],['order',3,api.x198pw_order('false','a','b')],['order',3,api.x198pw_order('true','b','a')]];
 for(const [role,arity,pattern] of stages){state=api.x198pw_def(src.book,role,arity,pattern,state);ans.push({role,tag:state.$,roles:state.roles?Object.fromEntries(entries(state.roles)):null});if(state.$==='X198PWBad')break;}
 return ans;
}
export function markedContexts(api,cur,name){const ans=[];let n=0;
 for(;cur&&n++<15;cur=cur.next){const ctx=cur.context;if(!ctx)continue;const m=api.x198pw_get_mark('$direct.'+name,ctx.ids);ans.push({cursor:cur.$,mark:m.kind,leaf:m.typ?.name,node:m.value?.name});}
 return ans;
}
