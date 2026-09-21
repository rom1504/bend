import path from 'node:path';
import {pathToFileURL} from 'node:url';
const api=(await import(process.env.BEND_JS_BACKEND?pathToFileURL(path.resolve(process.env.BEND_JS_BACKEND)):new URL('../../../build/js-backend.mjs',import.meta.url))).default;
const reference=process.env.BEND_JS_REFERENCE?(await import(pathToFileURL(path.resolve(process.env.BEND_JS_REFERENCE)))).default:null;
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
const list=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const t=(tag,name='',kids=[],id=0,quant=0)=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([])});
const ctr=(name,...kids)=>t('Ctr',name,kids),ref=name=>t('Ref',name);
const nat=n=>n?ctr('Succ',nat(n-1)):ctr('Zero');
const word=n=>ctr('U32',Array.from({length:32},(_,i)=>(n>>>i)&1).reduceRight((w,b)=>ctr('WCon',ctr(b?'True':'False'),w),ctr('WNil')));
const def=(name,value,typ=t('ADT','Nat'))=>({$:'KDef',name,kind:'Def',arity:0,templates:0,typ,value,ctors:list([]),native:false,unsafe:false});
const app=(f,x)=>t('App','',[f,x]);
const charType=t('ADT','Char'), treeType=t('ADT','Tree');
const all=(name,id,a,b,q=1)=>t('All',name,[a,b],id,q);
const tree={$:'KDef',name:'Tree',kind:'ADT',arity:0,templates:0,typ:t('Typ'),value:t('Absent'),ctors:list([{...def('Leaf',t('Absent'),all('c',1,charType,treeType)),kind:'Ctr',arity:1},{...def('Branch',t('Absent'),all('l',2,treeType,all('r',3,treeType,treeType))),kind:'Ctr',arity:2}]),native:false,unsafe:false};
const deepMatch=(n,id)=>n?app(t('Mat','Succ',[t('Lam','p',[deepMatch(n-1,id+1)],id+1,1),t('Lam','z',[nat(0)],200+n,1)]),t('Var','p',[],id)):t('Var','captured',[],10);
const runtime=fs.readFileSync(process.env.BEND_JS_RUNTIME?path.resolve(process.env.BEND_JS_RUNTIME):new URL('../../runtime.mjs',import.meta.url),'utf8');
for(const [name,defs,want,status=0] of [
 ['tree',[tree,def('main',ctr('Branch',ctr('Leaf',ctr('Chr',word(97))),ctr('Leaf',ctr('Chr',word(233)))),treeType)],"Branch{Leaf{'a'}, Leaf{'é'}}"],
 ['erasure',[def('drop',t('Lam','x',[nat(9)],10,0),all('x',10,t('Typ'),t('ADT','Nat'),0)),def('main',app(ref('drop'),t('Hol')))],'9n'],
 ['char',[def('main',ctr('Chr',word(233)),t('ADT','Char'))],"'é'"],
 ['nat',[def('main',app(app(ref('Nat.add'),nat(3)),nat(4)))],'7n'],
 ['intrinsic-name',[def('Nat.add',t('Lam','a',[t('Lam','b',[t('Var','a',[],10)],11,1)],10,1),all('a',10,t('ADT','Nat'),all('b',11,t('ADT','Nat'),t('ADT','Nat')))),def('main',app(app(ref('Nat.add'),nat(3)),nat(4)))],'3n'],
 ['partial',[def('first',t('Lam','a',[t('Lam','b',[t('Var','a',[],10)],11,1)],10,1),all('a',10,t('ADT','Nat'),all('b',11,t('ADT','Nat'),t('ADT','Nat')))),def('saved',app(ref('first'),nat(3)),all('b',11,t('ADT','Nat'),t('ADT','Nat'))),def('main',app(ref('saved'),nat(4)))],'3n'],
 ['erased-partial',[def('keep',t('Lam','A',[t('Lam','x',[t('Var','x',[],11)],11,1)],10,0),all('A',10,t('Typ'),all('x',11,t('ADT','Nat'),t('ADT','Nat')),0)),def('main',app(app(ref('keep'),t('Hol')),nat(6)))],'6n'],
 ['apply-order',[def('first',t('Lam','a',[t('Let','',[t('Bind','bad',[ctr('Chr',word(55296))],12,1),t('Lam','b',[t('Var','b',[],11)],11,1)])],10,1),all('a',10,t('ADT','Nat'),all('b',11,charType,charType))),def('main',app(app(ref('first'),nat(0)),ctr('Chr',word(55297))),charType)],'bend: 55296 is not a Unicode scalar value',1],
 ['matched-apply-order',[def('stage',t('Mat','Succ',[t('Lam','p',[t('Let','',[t('Bind','bad',[ctr('Chr',word(55296))],22,1),t('Lam','y',[t('Var','y',[],23)],23,1)])],21,1),t('Lam','z',[t('Lam','y',[t('Var','y',[],25)],25,1)],24,1)]),all('n',20,t('ADT','Nat'),all('y',26,charType,charType))),def('main',app(app(ref('stage'),nat(1)),ctr('Chr',word(55297))),charType)],'bend: 55296 is not a Unicode scalar value',1],
 ['call',[def('id',t('Lam','x',[t('Var','x',[],10)],10,1),t('All','x',[t('ADT','Nat'),t('ADT','Nat')],10,1)),def('main',app(ref('id'),nat(6)))],'6n'],
 ['let',[def('main',t('Let','',[t('Bind','x',[nat(4)],10,1),t('Var','x',[],10)]))],'4n'],
 ['parallel-shadow',[def('main',app(t('Lam','x',[t('Let','',[t('Bind','x',[nat(4)],10,1),t('Bind','y',[t('Var','x',[],10)],11,1),t('Var','y',[],11)])],10,1),nat(8)))],'8n'],
 ['captured-let',[def('saved',t('Let','',[t('Bind','x',[nat(4)],10,1),t('Lam','y',[t('Var','x',[],10)],11,1)]),all('y',11,t('ADT','Nat'),t('ADT','Nat'))),def('main',app(ref('saved'),nat(8)))],'4n'],
 ['deep-capture',[def('saved',t('Let','',[t('Bind','captured',[nat(7)],10,1),t('Lam','n',[deepMatch(40,30)],30,1)]),all('n',30,t('ADT','Nat'),t('ADT','Nat'))),def('main',app(ref('saved'),nat(45)))],'7n'],
 ['match',[def('main',app(t('Mat','Succ',[t('Lam','x',[t('Var','x',[],10)],10,1),t('Lam','z',[nat(0)],11,1)]),nat(5)))],'4n']
]){
 const js=api.j_program(list(defs));if(reference&&name!=='deep-capture')assert.equal(js,reference.j_program(list(defs)),name+' changed below-threshold emission');fs.writeFileSync(new URL('../../../build/js-emitted-'+name+'.mjs',import.meta.url),runtime+'\n'+js);const r=spawnSync(process.execPath,[new URL('../../../build/js-emitted-'+name+'.mjs',import.meta.url).pathname],{encoding:'utf8'});assert.equal(r.status,status,r.stderr+'\n'+js);assert.equal((status?r.stderr:r.stdout).trim(),want,js);console.log(name,'ok');
}
