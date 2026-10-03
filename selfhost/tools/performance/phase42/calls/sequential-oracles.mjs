// Independent BigInt oracle; iterative construction/evaluation supports depth30000.
const u32=x=>Number(BigInt.asUintN(32,BigInt(x)));
export function sequenceMake(depth,seed,orientation='right'){
 let tree={tag:'SEmpty'};for(let n=depth-1;n>=0;--n){const empty={tag:'SEmpty'},value=u32(BigInt(seed)+BigInt(n));tree={tag:'SNode',left:orientation==='left'?tree:empty,value,right:orientation==='right'?tree:empty};}return tree;
}
export function sequenceFold(tree,acc,mode='sum',trace){
 let current=tree,value=u32(acc);const deferred=[];
 for(;;){
  if(current.tag==='SNode'){
   const mirror=mode==='mirror';trace?.push(['inner',current.value,value]);deferred.push({tree:mirror?current.right:current.left,node:current.value});current=mirror?current.left:current.right;continue;
  }
  if(!deferred.length)return value;
  const frame=deferred.pop();trace?.push(['resume',frame.node,value]);
  value=u32(mode==='weighted'?BigInt(value)*10n+BigInt(frame.node):mode==='mirror'?BigInt(frame.node)-BigInt(value):BigInt(value)+BigInt(frame.node));current=frame.tree;
 }
}
export const sequenceBench=(depth,seed,orientation='right',mode='sum')=>sequenceFold(sequenceMake(depth,seed,orientation),seed,mode);
