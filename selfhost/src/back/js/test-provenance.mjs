// Primitive constructor encodings belong only to definitions imported from Base.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {loadApi,inspect,project} from '../../../tools/typed-driver.mjs';
const api=await loadApi(),backend=process.env.BEND_JS_BACKEND;
if(backend)Object.assign(api,(await import(pathToFileURL(path.resolve(backend)))).default);
const dir=path.join(project,'build/js-provenance');fs.mkdirSync(dir,{recursive:true});
const names=['True','False','Zero','Succ','SNil','SCon','Chr','Tuple','ALeaf','ANode'];
const source='type Flag is Data:\n  Up{}\n  Down{}\n\ntype Foo is Data:\n'+names.map(n=>'  '+n+'{+value: Flag}\n').join('')+'\ndef pick(f: Foo) -> Flag:\n  match f:\n'+names.map(n=>'    case '+n+'{value}: value\n').join('')+'\n'+names.map((n,i)=>'def make'+i+'() -> Foo:\n  '+n+'{Up{}}\n').join('\n');
const input=path.join(dir,'owned-constructors.bend'),output=path.join(dir,'owned-constructors.mjs');fs.writeFileSync(input,source);
const result=await inspect(input,{mode:'library',api});assert.equal(result.status,'ok',JSON.stringify(result));fs.writeFileSync(output,result.code);
const library=(await import(pathToFileURL(output))).default;
for(const [i,name] of names.entries()){const value=library['make'+i]();assert.equal(value.$,name);assert.deepEqual(library.pick(value),{$:'Up',a:[]});}
fs.writeFileSync(path.join(dir,'report.json'),JSON.stringify({status:'pass',source,constructors:names,checked:result.checked},null,2)+'\n');
console.log('10 no-Base primitive-name constructors preserve their declared fields and matching');
