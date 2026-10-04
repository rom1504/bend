// Manual translation of the complete benchmark component, retaining native ABI.
function $lxPrng(x){const b=(x^(x<<13))>>>0,d=(b^(b>>>17))>>>0;return (d^(d<<5))>>>0;}
function $lxSeed(i){return $lxPrng(Math.imul((i+1)>>>0,2654435761)>>>0);}
function $lxSalt(s,k){return $lxPrng((s^(Math.imul(k,2654435761)>>>0))>>>0);}
function $lxOpPick(b1,b0){return ctor('Chr',[b1?(b0?47:42):(b0?45:43)]);}
function $lxOp(t,rest){return ctor('SCon',[$lxOpPick((t&2)!==0,(t&1)!==0),rest]);}
function $lxIdent(n,t,rest){const heads=[];while(n!==0n){n-=1n;t=$lxPrng(t);heads.push(ctor('Chr',[(97+t%26)>>>0]));}for(let i=heads.length-1;i>=0;i--)rest=ctor('SCon',[heads[i],rest]);return rest;}
function $lxNum(n,t,rest){const heads=[];while(n!==0n){n-=1n;t=$lxPrng(t);heads.push(ctor('Chr',[(48+t%10)>>>0]));}for(let i=heads.length-1;i>=0;i--)rest=ctor('SCon',[heads[i],rest]);return rest;}
function $lxSlotGo(i,n,o){return ctor(i?'Id':n?'Nm':o?'Op':'Lit',[]);}
function $lxSlot(c){return $lxSlotGo(c===105,c===110,c===111);}
function $lxExpand(sl,c,t,rest){switch(sl.$){case 'Id':return $lxIdent(BigInt((1+(t&7))>>>0),t,rest);case 'Nm':return $lxNum(BigInt((1+t%6)>>>0),t,rest);case 'Op':return $lxOp(t,rest);case 'Lit':return ctor('SCon',[ctor('Chr',[c]),rest]);default:return bad('manual Slot invariant');}}
function $lxGenAt(c,t,rest){return $lxExpand($lxSlot(c),c,t,rest);}
function $lxGen(tpl,s,k){$lxBump('gen');const frames=[];while(fields('SNil',tpl)===null){const parts=project('SCon',tpl),c=project('Chr',parts[0])[0];frames.push([c,$lxSalt(s,k)]);tpl=parts[1];k=(k+1)>>>0;}let rest=ctor('SNil',[]);for(let i=frames.length-1;i>=0;i--)rest=$lxGenAt(frames[i][0],frames[i][1],rest);return rest;}
function $lxTpl(){return 'i = ( n o i ) o ( n o i ) o ( n o i ) ;';}
function $lxLine(i){$lxBump('line');const tpl=$lxTpl(),s=$lxSeed(i),text=$lxGen(tpl,s,0);return $lxLex(text,ctor('Tuple',[ctor('Gap',[]),0]));}
function $lxBatch(d,i){$lxBump('batch');const stack=[];let value;for(;;){if(d!==0n){const p=d-1n;stack.push({p,i,left:null});d=p;continue;}value=$lxLine(i);for(;;){if(stack.length===0)return value;const f=stack[stack.length-1];if(f.left===null){f.left=value;d=f.p;i=(f.i+(f.p>=32n?0:(1<<Number(f.p))>>>0))>>>0;break;}value=(f.left+value)>>>0;stack.pop();}}}
