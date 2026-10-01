// Correct the saved-output mechanism's DataView proof boundary without changing
// its cast replacement. Root executes and preserves the vulnerable parent too.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [parentArg,outArg]=process.argv.slice(2);
assert(parentArg&&outArg,'Usage: native-cast-dataview-derive-v3.mjs VULNERABLE_DERIVED NEW_OUT');
const parent=fs.realpathSync(parentArg),out=path.resolve(outArg);assert(!fs.existsSync(out));
const identity=file=>({path:fs.realpathSync(file),sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex'),bytes:fs.statSync(file).size});
const parentFile=path.join(parent,'derive.json'),old=JSON.parse(fs.readFileSync(parentFile));
assert.equal(old.kind,'phase37-private-native-cast-prototype');assert(old.complete);
const parserText=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const parser={exports:{}};new Function('module','exports',parserText)(parser,parser.exports);
assert.equal(parser.exports.version,'8.16.0');
const start='function regionHostGuard(){\n  if(regionProof!==null)return true;';
const replacement=`const regionDataViewCtor=DataView,regionDataViewPrototype=DataView.prototype;
const regionDataViewParent=regionGetPrototype(regionDataViewPrototype);
const regionDataViewKeys=['setUint32','getFloat32','setFloat32','getUint32'];
for(const key of regionDataViewKeys)regionNumericHooks.push([regionDataViewPrototype,key,regionDataViewPrototype[key]]);
regionNumericHooks.push([globalThis,'DataView',regionDataViewCtor],[regionDataViewCtor,'prototype',regionDataViewPrototype]);
function regionHostGuard(){
  if(regionProof!==null)return true;
  if(regionGetPrototype(floatView)!==regionDataViewPrototype||regionGetPrototype(regionDataViewPrototype)!==regionDataViewParent)return false;
  for(let i=0;i<regionDataViewKeys.length;i++)if(regionGetDescriptor(floatView,regionDataViewKeys[i]))return false;`;
fs.mkdirSync(out);
const report={kind:'phase37-private-native-cast-dataview-prototype',complete:false,checked:false,certified:false,
 producer:identity(import.meta.filename),parent:identity(parentFile),typescript:old.typescript,proposal:old.proposal,
 dependencies:old.dependencies,modules:[],scope:'Only direct variant gains DataView constructor/prototype/instance guards; original stays exact. Existing native cast replacements remain unchanged.'};
for(const row of old.modules){assert.deepEqual(identity(row.path),{path:row.path,sha256:row.sha256,bytes:row.bytes});
 let text=fs.readFileSync(row.path,'utf8');if(row.variant==='direct'){assert.equal(text.split(start).length,2);text=text.replace(start,replacement);}
 parser.exports.parse(text,{ecmaVersion:'latest',sourceType:'module'});
 const file=path.join(out,row.variant+(row.counters?'.mjs':'.clean.mjs'));fs.writeFileSync(file,text,{flag:'wx'});
 report.modules.push({variant:row.variant,counters:row.counters,parent:identity(row.path),...identity(file)});
}
const oldConfig=JSON.parse(fs.readFileSync(path.join(parent,'compare.json')));
const config={inputs:[path.join(out,'derive.json'),parentFile],cases:oldConfig.cases.map(row=>({...row,
 modules:{original:path.join(out,'original.clean.mjs'),direct:path.join(out,'direct.clean.mjs'),typescript:old.typescript.path}}))};
assert.deepEqual(identity(parentFile),report.parent);report.complete=true;
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify(config,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,out,modules:report.modules.length}));
