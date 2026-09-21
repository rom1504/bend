import assert from 'node:assert/strict';
const {default:K}=await import(process.env.BEND_PREFIX_API || '../build/prefix-test.mjs');
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const t=(tag,name='',id=0,quant=0,kids=[],removed=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list(removed)});
const typ=q=>t('Typ','',0,0,[t('Qua','',0,q)]);
const d=(name,kind,ty,value=t('Absent'),ctors=[])=>({$:'KDef',name,kind,arity:0,templates:0,typ:ty,value,ctors:list(ctors),native:false,unsafe:false});
const bit=d('Bit','ADT',typ(2),t('Absent'),[d('On','Ctr',t('ADT','Bit'))]);
const main=d('main','Def',t('ADT','Bit'),t('Ctr','On'));
const prefix=list([bit]),book=list([bit,main]);
assert.equal(K.check_book(prefix),'');
assert.equal(K.check_from_exact_prefix(book,prefix),'');
assert.equal(K.exact_prefix(book,prefix),true);
for(const [field,value] of Object.entries({name:'Other',kind:'Def',arity:1,templates:1,native:true,unsafe:true,typ:typ(1),value:t('Ctr','On'),ctors:list([])})) {
 const modified=list([{...bit,[field]:value}]);assert.equal(K.exact_prefix(book,modified),false,field);
}
for(const [field,value] of Object.entries({tag:'Ref',name:'Other',id:8,quant:1,kids:list([]),removed:list(['On'])})){
 assert.equal(K.exact_prefix(book,list([{...bit,typ:{...bit.typ,[field]:value}}])),false,'term '+field);
}
const bad=list([bit,{...main,value:t('Qua','',0,1)}]);
assert.equal(K.check_from_exact_prefix(bad,prefix),'main: type mismatch');
assert.equal(K.check_from_exact_prefix(bad,list([{...bit,name:'Other'}])),'main: type mismatch');
assert.equal(K.exact_prefix(prefix,book),false);
console.log('PASS exact-prefix cached checking and complete-field mismatch tests');
