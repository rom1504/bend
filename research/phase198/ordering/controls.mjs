import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';
const [apiFile,out]=process.argv.slice(2);
const auth=JSON.parse(fs.readFileSync(apiFile));
if(!auth.complete||!auth.checked)throw Error('unchecked source');
verify(auth.api);verify(auth.source);fs.mkdirSync(out);
const api=(await import(pathToFileURL(auth.api.file))).default;
const n=(s,o={})=>({$:s,...o}), ls=xs=>xs.reduceRight((tail,head)=>n('Con',{head,tail}),n('Nil'));
const key=(arity,templates=0,kind='N111Id')=>n('KDef',{name:'',kind,arity,templates,typ:null,value:null,ctors:n('Nil'),native:false,unsafe:false});
let admissions=0;
for(const id of [0,1,65535,65536,4294967295])for(const arity of [0,1,2])for(const k of ['N111Id','Absent']) {
  if(api.x198ord_id(key(id,arity,k))!==(k==='N111Id'&&id<=65535&&arity===0))throw Error('constructor identity control');
  admissions++;
}
const reg=index=>n('X187Reg',{index,width:64,vector:false}), item=x=>n('X188One',{item:x});
const directive=(s,o)=>item(n(s,o)),inst=(op,...operands)=>item(n('PInst',{inst:n('X187Instruction',{op,operands:ls(operands)})}));
const seq=[directive('PSection',{section:1})];
for(const [name,word] of [['u32cmp',true],['natcmp',false]]) {
  seq.push(directive('PGlobal',{name}),directive('PType',{name,kind:2}), directive('PLabel',{name}),
     inst('movq',reg(7),reg(10)),api.x198ord_eval(word,key(65535),key(0),key(32769)),
     inst('movq',reg(11),reg(0)),inst('ret'),directive('PSize',{name}));
}
const s=api.x188_many(ls(seq)),a=api.x188_assemble(s);if(a.error)throw Error(a.error);
let xs=a.bytes;const bytes=[];while(xs.$==='Con'){bytes.push(xs.head);xs=xs.tail;}
if(xs.$!=='Nil')throw Error('truncated');
const asset=JSON.parse(fs.readFileSync('selfhost/build/phase194/assets.json')).assets.linker;verify(asset);
const oracle=fileURLToPath(new URL('./oracle.c',import.meta.url)),r={complete:false,api:auth.api,source:auth.source,oracle:pin(oracle),admissions,checks:[]};
for(const [ext,data] of [['s',api.x188_render(s)],['o',Buffer.from(bytes)]]){
 const code=path.join(out,'product.'+ext), exe=path.join(out,'test-'+ext);fs.writeFileSync(code,data);
 const cc=spawnSync(asset.file,['-O2',oracle,code,'-o',exe],{encoding:'utf8'});if(cc.status)throw Error(cc.stderr);
 const p=spawnSync(exe,[],{encoding:'utf8'});if(p.status!==0||p.stdout!=='checked 30098\n')throw Error('wrong order '+ext);
 r.checks.push({program:pin(exe),product:pin(code),stdout:p.stdout});
}
r.complete=true;fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(r,null,2));
