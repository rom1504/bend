// Independent nested-array oracles only. Root owns concrete compiler controls.
export const leaf = value => [value];
export const node = (left, right) => [left, right];
export const u32 = x => Number(BigInt(x) & 0xffffffffn);
export function warp(a,b,s) {
  if(a.length===1 && b.length===1) {
    const flip=s!==(a[0]>b[0]);
    return node(leaf(flip?b[0]:a[0]),leaf(flip?a[0]:b[0]));
  }
  if(a.length===1 || b.length===1) return leaf(0);
  const left=warp(a[0],b[0],s),right=warp(a[1],b[1],s);
  return left.length===2 && right.length===2
    ? node(node(left[0],right[0]),node(left[1],right[1])) : leaf(0);
}
export function warpNode(tree,s) {
  return tree.length===1 ? leaf(tree[0]) : warp(tree[0],tree[1],s);
}
export function flow(n,s,tree) {
  if(n===0 || tree.length===1)
    return tree.length===1 ? leaf(tree[0]) : node(tree[0],tree[1]);
  return node(flow(n-1,s,warpNode(tree[0],s)),flow(n-1,s,warpNode(tree[1],s)));
}
export function summary(tree) {
  let nodes=0,leaves=0,sum=0n;
  const todo=[tree];
  while(todo.length) {
    const value=todo.pop();
    if(value.length===1) { ++leaves;sum+=BigInt(value[0]); }
    else { ++nodes;todo.push(value[1],value[0]); }
  }
  return {nodes,leaves,sum:String(sum)};
}
export function deepFlowExpected(depth,value=7) {
  return {nodes:2*depth+2,leaves:2*depth+3,sum:String(BigInt(value)*BigInt(2*depth+3))};
}
export function decodeTagged(tree,leafTag='Leaf',nodeTag='Node') {
  // Iterative and independent of emitted constructors/workers, including deep trees.
  const root=[],todo=[[tree,root,0]];
  while(todo.length) {
    const [value,parent,slot]=todo.pop();
    if(value.$===leafTag) parent[slot]=leaf(value.a[0]);
    else {
      if(value.$!==nodeTag) throw Error('unexpected public constructor '+value.$);
      const result=[];parent[slot]=result;
      todo.push([value.a[1],result,1],[value.a[0],result,0]);
    }
  }
  return root[0];
}

// Independent fixture-renamed.bend equations use BigInt for U32 arithmetic.
export const reviewKey = x => u32(BigInt(x)*1103515245n+12345n);
export function reviewPair(a,b,flag) {
  return flag!==(a>b) ? node(leaf(b),leaf(a)) : node(leaf(a),leaf(b));
}
export function reviewMap(tree,flag) {
  return tree.length===1 ? reviewPair(tree[0],reviewKey(tree[0]),flag)
    : node(reviewMap(tree[0],flag),reviewMap(tree[1],flag));
}
export function reviewMake(depth,seed) {
  return depth===0 ? leaf(seed)
    : node(reviewMake(depth-1,u32(BigInt(seed)+1n)),leaf(u32(BigInt(seed)^91n)));
}
export function reviewScore(tree) {
  return tree.length===1 ? tree[0]
    : u32(BigInt(reviewScore(tree[0]))*3n+BigInt(reviewScore(tree[1])));
}
export function reviewBench(depth,seed) {
  return reviewScore(reviewMap(reviewMake(depth,seed),seed%2===0));
}
