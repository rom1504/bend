// Independent complete BST/zipper oracle; no compiler/runtime dependency.
const u=x=>Number(BigInt.asUintN(32,BigInt(x)));
export const leaf=()=>({tag:'BLeaf'}),node=(l,v,r)=>({tag:'BNode',l,v:u(v),r});
export function down(fuel,x,tree,path=[]){let t=tree,p=[...path];for(let i=0;i<fuel;++i){if(t.tag==='BLeaf')continue;const left=x<t.v;p.unshift({v:t.v,other:left?t.r:t.l,left});t=left?t.l:t.r;}return{tree:t,path:p};}
export function up(path,tree){let t=tree;for(const f of path)t=f.left?node(t,f.v,f.other):node(f.other,f.v,t);return t;}
export function insert(fuel,x,tree){const s=down(fuel,x,tree);return up(s.path,s.tree.tag==='BLeaf'?node(leaf(),x,leaf()):s.tree);}
export function fromValues(values,fuel=values.length+1){let t=leaf();for(const x of values)t=insert(fuel,u(x),t);return t;}
export function build(size,seed,fuel=size+1){let t=leaf();for(let i=0;i<size;++i){const multiplier=u(BigInt(seed)*2n+1n),x=u(BigInt(u(BigInt(i)*BigInt(multiplier)))+BigInt(seed))%257;t=insert(fuel,x,t);}return t;}
export function inorder(tree,acc=0){let t=tree,v=u(acc);const stack=[];for(;;){if(t.tag==='BNode'){stack.push({r:t.r,v:t.v});t=t.l;continue;}if(!stack.length)return v;const f=stack.pop();v=u(BigInt(v)*10n+BigInt(f.v));t=f.r;}}
export function ordered(tree){let t=tree;const out=[],stack=[];for(;;){if(t.tag==='BNode'){stack.push(t);t=t.l;continue;}if(!stack.length)return out;const f=stack.pop();out.push(f.v);t=f.r;}}
export function skew(depth,side='right',seed=0){let t=leaf();for(let n=depth-1;n>=0;--n)t=side==='right'?node(leaf(),u(BigInt(seed)+BigInt(n)),t):node(t,u(BigInt(seed)+BigInt(n)),leaf());return t;}
