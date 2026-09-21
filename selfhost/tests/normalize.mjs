// Export wnf/strong/compare from assembled term.bend + index.bend + normalize.bend to build/normalize-test.mjs.
import {pathToFileURL} from 'node:url';
const {default:K}=await import(process.env.BEND_NORMALIZE_API?pathToFileURL(process.env.BEND_NORMALIZE_API).href:new URL('../build/normalize-test.mjs',import.meta.url).href);
import assert from 'node:assert/strict';
const nil={$:'Nil'},list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
const t=(tag,name='',id=0,quant=0,kids=[],removed=[])=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list(removed)});
const qua=q=>t('Qua','',0,q),typ=q=>t('Typ','',0,0,[qua(q)]),v=id=>t('Var','x',id),all=(id,q,a,b)=>t('All','x',id,q,[a,b]),lam=(id,b)=>t('Lam','x',id,1,[b]),ref=n=>t('Ref',n),app=(f,x)=>t('App','',0,0,[f,x]),ctr=(n,...xs)=>t('Ctr',n,0,0,xs);
const a=ctr('A'),b=ctr('B'),id=lam(1,v(1)),mat=t('Mat','A',0,0,[b,t('Efq')]);
const def={$:'KDef',name:'f',kind:'Def',arity:1,templates:0,typ:t('Absent'),value:mat,ctors:nil,native:false,unsafe:false},book=list([def]);
let total=0;const check=(name,actual,expected=true)=>{assert.equal(actual,expected,name);console.log('PASS',name);total++};
check('share cell',K.wnf(nil,t('Var','x',5,0,[a])).name,'A');
check('beta reduction',K.wnf(nil,app(id,a)).name,'A');
check('alpha equivalence',K.compare(nil,id,lam(2,v(2)),false));
check('eta equivalence',K.compare(nil,lam(1,app(ref('g'),v(1))),ref('g'),false));
check('distinct constructors',K.compare(nil,a,b,false),false);
check('constructor match',K.wnf(nil,app(mat,a)).name,'B');
check('saturated definition',K.wnf(book,app(ref('f'),a)).name,'B');
check('stuck definition preserves head',K.wnf(book,app(ref('f'),v(9))).kids.head.name,'f');
check('under-applied definition',K.wnf(book,ref('f')).tag,'Ref');
check('quantity minimum',K.wnf(nil,t('Min','',0,0,[qua(2),qua(1)])).quant,1);
check('kind subtype',K.compare(nil,typ(2),typ(1),true));
check('kind direction',K.compare(nil,typ(1),typ(2),true),false);
check('dependent telescope alpha',K.compare(nil,all(1,1,typ(2),v(1)),all(2,1,typ(2),v(2)),false));
check('parallel let',K.wnf(nil,t('Let','',0,0,[t('Bind','x',7,1,[a]),v(7)])).name,'A');
check('rewrite reflexivity',K.wnf(nil,t('Rwt','',0,0,[t('Rfl'),t('Absent'),a])).name,'A');
check('strong constructor field',K.strong(nil,ctr('Wrap',app(id,a))).kids.head.name,'A');
check('residual subtype',K.compare(nil,t('ADT','D',0,0,[],['A']),t('ADT','D'),true));
check('residual equality',K.compare(nil,t('ADT','D',0,0,[],['A']),t('ADT','D'),false),false);
check('foreign definition stays opaque',K.wnf(list([{...def,value:t('Foreign')}]),app(ref('f'),a)).kids.head.name,'f');
// Deep readback and equality must use worklists, not the JavaScript call stack.
let deepA=ctr('A'),deepB=ctr('B');for(let i=0;i<5000;i++){deepA=ctr('Succ',deepA);deepB=ctr('Succ',deepB);}
check('deep reflexivity',K.compare(nil,deepA,deepA,false));
check('deep inequality',K.compare(nil,deepA,deepB,false),false);
let deepNF=K.strong(nil,deepA),depth=0;while(deepNF.name==='Succ'){depth++;deepNF=deepNF.kids.head;}
check('deep strong normalization',depth,5000);
check('cell payloads affect equality',K.compare(nil,t('Var','x',7,0,[a]),t('Var','x',7,0,[b]),false),false);
const mk={...def,name:'mk',value:lam(41,ctr('Wrap',lam(42,app(v(41),v(42)))))};
const nested=app(ref('mk'),lam(43,app(ref('mk'),lam(44,ctr('Pair',v(43),v(44))))));
const outer=K.strong(list([mk]),nested).kids.head;
const inner=outer.kids.head.kids.head;
const pair=inner.kids.head;
check('repeated unfolding freshens binders',outer.id===inner.id,false);
check('outer binder survives inner unfolding',pair.kids.head.id,outer.id);
check('inner binder remains distinct',pair.kids.tail.head.id,inner.id);
const kind=x=>t('Typ','',0,0,[x]),meet=(x,y)=>t('Min','',0,0,[x,y]);
check('kind meet alternative',K.compare(nil,kind(v(1)),kind(meet(v(2),v(1))),true));
check('kind alternatives preserve later failures',K.compare(nil,all(9,1,kind(meet(v(2),v(1))),a),all(10,1,kind(v(1)),b),true),false);
// Each level demands the same Boolean computation twice. The normal form is
// constant-sized, but copying or re-evaluating thunk payloads takes exponential work.
const sharedAnd={...def,name:'sharedAnd',arity:2,value:t('Mat','True',0,0,[lam(501,v(501)),t('Mat','False',0,0,[lam(502,ctr('False')),t('Efq')])])};
const sharedLoop={...def,name:'sharedLoop',arity:2,value:t('Mat','Zero',0,0,[lam(503,v(503)),t('Mat','Succ',0,0,[lam(504,lam(505,app(app(ref('sharedLoop'),v(504)),app(app(ref('sharedAnd'),v(505)),v(505))))),t('Efq')])])};
let fuel=ctr('Zero');for(let i=0;i<32;i++)fuel=ctr('Succ',fuel);
check('shared recursive demands are memoized',K.strong(list([sharedAnd,sharedLoop]),app(app(ref('sharedLoop'),fuel),ctr('True'))).name,'True');
const apply2=(f,x,y)=>app(app(f,x),y);
const arms=(yes,no)=>t('Mat','True',0,0,[yes,t('Mat','False',0,0,[no,t('Efq')])]);
const armSum=apply2(ref('sharedAnd'),app(v(604),ctr('True')),app(v(604),ctr('False')));
const armLoop={...def,name:'armLoop',arity:2,value:t('Mat','Zero',0,0,[lam(601,v(601)),t('Mat','Succ',0,0,[lam(603,lam(604,apply2(ref('armLoop'),v(603),arms(armSum,armSum)))),t('Efq')])])};
check('shared match arms are memoized',K.strong(list([sharedAnd,armLoop]),app(apply2(ref('armLoop'),fuel,arms(ctr('True'),ctr('True'))),ctr('True'))).name,'True');
const fieldSum={...def,name:'fieldSum',arity:1,value:t('Mat','Pair',0,0,[lam(701,lam(702,apply2(ref('sharedAnd'),v(701),v(702)))),t('Efq')])};
const fieldLoop={...def,name:'fieldLoop',arity:2,value:t('Mat','Zero',0,0,[lam(703,v(703)),t('Mat','Succ',0,0,[lam(704,lam(705,apply2(ref('fieldLoop'),v(704),ctr('Pair',app(ref('fieldSum'),v(705)),app(ref('fieldSum'),v(705)))))),t('Efq')])])};
check('shared constructor fields are memoized',K.strong(list([sharedAnd,fieldSum,fieldLoop]),app(ref('fieldSum'),apply2(ref('fieldLoop'),fuel,ctr('Pair',ctr('True'),ctr('True'))))).name,'True');
console.log(total+' normalization tests passed');
