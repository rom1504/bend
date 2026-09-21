// Readback regression tests use independently constructed core terms.
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
const {default:api}=await import(pathToFileURL(process.env.BEND_PRETTY_API||path.join(root,'build/pretty-test.mjs')));
const list=a=>a.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const k=(tag,name='',id=0,quant=1,kids=[])=>({$: 'KTerm',tag,name,id,quant,kids:list(kids),removed:list([])});
const c=(name,...kids)=>k('Ctr',name,0,1,kids);
const word=x=>{let w=c('WNil'); for(let i=31;i>=0;i--)w=c('WCon',c(x>>>i&1?'True':'False'),w);return w};
const u=x=>c('U32',word(x)); const chr=x=>c('Chr',u(x)); const str=s=>[...s].reduceRight((t,c0)=>c('SCon',chr(c0.codePointAt(0)),t),c('SNil'));
const lam=(s,id,t)=>k('Lam',s,id,1,[t]);const variable=(s,id)=>k('Var',s,id);
const app=(f,x)=>k('App','',0,1,[f,x]);
const cases=[['42',u(42)],["'é'",chr(233)],["'\\n'",chr(10)],['"a\\nb"',str('a\nb')],['[1, 2]',c('Con',u(1),c('Con',u(2),c('Nil')))],['(1, 2)',c('Tuple',u(1),u(2))],['x => x',lam('x',100,variable('x',100))],['\\{}',k('Efq')],['\\{True: False{}}',k('Mat','True',0,1,[c('False'),k('Efq')])],['1.0',c('F32',word(0x3f800000))],['-0.0',c('F32',word(0x80000000))],['1.0e-8',c('F32',word(0x322bcc77))],['x => x => x^0',lam('x',100,lam('x',200,variable('x',100)))],['x => x^',lam('x',100,k('Ref','x'))],['+x = 1; x',k('Let','',0,1,[k('Bind','x',100,2,[u(1)]),variable('x',100)])],['&x:Nat -> Nat',app(app(k('Ref','Exists'),k('Ref','Nat')),lam('x',100,k('Ref','Nat')))],['%p@e : P; x',k('Rwt','',0,1,[k('Ref','e'),lam('_',100,lam('p',200,k('Ref','P'))),k('Ref','x')])]];
for(const [want,t]of cases)assert.equal(api.kp_show(t),want);
console.log(`${cases.length} core readback tests passed`);
