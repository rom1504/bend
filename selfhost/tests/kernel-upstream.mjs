// Differential test adapter only. Production compiler never imports upstream.
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const upstream=process.env.BEND_UPSTREAM || path.resolve(import.meta.dirname,'../../upstream-bend');
const U=await import(pathToFileURL(path.join(upstream,'bend2/bend.ts')));
const {default:K}=await import(process.env.BEND_KERNEL_API || '../build/kernel-test.mjs');
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const t=(tag,name='',id=0,quant=0,kids=[],removed=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list(removed)});
let uid=0;const q=x=>x?.$==='None'?0:x?.$==='Many'?2:1;
function lower(x,env=new Map()){
 switch(x.$){
 case 'Var':return t('Var',x.k,env.get(x.i)??x.i);
 case 'Ref':case 'Hol':return t(x.$,x.k);
 case 'Qua':return t('Qua','',0,q(x.q));
 case 'Qnt':case 'Efq':case 'Rfl':return t(x.$);
 case 'Typ':return t('Typ','',0,0,[lower(x.g,env)]);
 case 'All':case 'Lam':{const id=++uid,bind=new Map(env);bind.set(x.i,id);return t(x.$,x.k,id,q(x.q),x.$==='Lam'?[lower(x.f,bind)]:[lower(x.A,env),lower(x.B,bind)]);}
 case 'App':return t('App','',0,0,[lower(x.f,env),lower(x.x,env)]);
 case 'Min':return t('Min','',0,0,[lower(x.a,env),lower(x.b,env)]);
 case 'Ann':return t('Ann','',0,0,[lower(x.x,env),lower(x.T,env)]);
 case 'ADT':case 'Ctr':return t(x.$,x.k,0,0,x.x.map(y=>lower(y,env)),x.r??[]);
 case 'Mat':return t('Mat',x.k,0,0,[lower(x.h,env),lower(x.m,env)]);
 case 'Eql':return t('Eql','',0,0,[lower(x.a,env),lower(x.b,env),lower(x.T,env)]);
 case 'Rwt':return t('Rwt','',0,0,[lower(x.e,env),lower(x.p,env),lower(x.f,env)]);
 case 'Let':{const bind=new Map(env),bs=x.k.map((name,j)=>{let id=++uid;bind.set(x.i[j],id);return t('Bind',name,id,q(x.q[j]),[lower(x.v[j],env)]);});return t('Let','',0,0,[...bs,lower(x.f,bind)]);}
 default:throw Error('lower '+x.$);
 }
}
function def(name,x,body=true){return {$:'KDef',name,kind:x.$,arity:x.n,templates:x.x??0,typ:lower(U.term_lower(x.T)),value:body&&x.v?lower(U.term_lower(x.v)):t('Absent'),ctors:list((x.c??[]).map(c=>def(c.k,{$:'Ctr',n:c.n,T:c.T}))),native:!!x.b,unsafe:!!x.u};}
const book=U.book_nil();await U.book_load(book,process.argv[2]??U.BASE_BEND,'',new Map());
let counts=new Map();for(const name of book.order)counts.set(name,(counts.get(name)??0)+1);
const ds=book.order.map(name=>{counts.set(name,counts.get(name)-1);return def(name,book.tlds[name],counts.get(name)===0)});
console.log('decls',ds.length);console.time('check');const error=K.check_book(list(ds));console.log(error || 'PASS upstream-lowered book');if(error)process.exitCode=1;console.timeEnd('check');
