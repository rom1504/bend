// Focused filesystem-boundary regression controls. No Bend grammar substitute is
// used for conformance: the tiny API stub isolates the host's error taxonomy.
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
assert.ok(process.env.BEND_IMPORT_PHASE_DRIVER,'Select the actual candidate driver');
const {discoverSources}=await import(pathToFileURL(process.env.BEND_IMPORT_PHASE_DRIVER));
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const api={f_load_graph(){},f_parse(text){const x=JSON.parse(text);return {book:list([]),imports:list((x.imports??[]).map(name=>({name}))),error:x.error??''};}};
function fixture(body){const dir=fs.mkdtempSync(path.join(os.tmpdir(),'bend-import-phase-'));const file=path.join(dir,'main.bend');fs.writeFileSync(file,JSON.stringify(body));return {dir,file,put(name,value){const p=path.join(dir,name);fs.mkdirSync(path.dirname(p),{recursive:true});fs.writeFileSync(p,JSON.stringify(value));return p;},close(){fs.rmSync(dir,{recursive:true,force:true});}};}
function captured(fn){try{fn();assert.fail('Expected failure');}catch(e){return e;}}
test('missing root remains untagged; a missing declared relative import becomes parse',()=>{
 const f=fixture({imports:['./missing.bend']});try{const root=captured(()=>discoverSources(api,path.join(f.dir,'absent.bend')));assert.equal(root.code,'ENOENT');assert.equal(root.phase,undefined);const child=captured(()=>discoverSources(api,f.file));assert.equal(child.code,'ENOENT');assert.equal(child.phase,'parse');assert.equal(child.sourceFile,undefined);}finally{f.close();}
});
test('absolute and nested declared imports retain the same narrow classification',()=>{
 const f=fixture({});try{f.put('main.bend',{imports:[path.join(f.dir,'absent.bend')]});assert.equal(captured(()=>discoverSources(api,f.file)).phase,'parse');f.put('main.bend',{imports:['./nested/child.bend']});f.put('nested/child.bend',{imports:['./absent.bend']});assert.equal(captured(()=>discoverSources(api,f.file)).phase,'parse');}finally{f.close();}
});
test('only untagged ENOENT from import realpath is tagged; original Error identity survives',()=>{
 const f=fixture({imports:['./child.bend']});const target=f.put('child.bend',{}),real=fs.realpathSync;
 try{for(const code of ['ENOENT','EACCES','EIO','ELOOP','ENOTDIR',undefined])for(const phase of [undefined,'load','runtime','']){const error=Object.assign(Error('retained failure'),{code});if(phase!==undefined)error.phase=phase;fs.realpathSync=(file,...rest)=>{if(file===target)throw error;return real(file,...rest);};const observed=captured(()=>discoverSources(api,f.file));assert.equal(observed,error);assert.equal(observed.message,'retained failure');assert.equal(observed.phase,code==='ENOENT'&&phase===undefined?'parse':phase);assert.equal(observed.sourceFile,undefined);}}
 finally{fs.realpathSync=real;f.close();}
});
test('read failures after realpath remain unchanged, including ENOENT races',()=>{
 const f=fixture({imports:['./child.bend']});const target=f.put('child.bend',{}),read=fs.readFileSync;
 try{for(const code of ['ENOENT','EACCES','EIO']){const error=Object.assign(Error('read failure'),{code});fs.readFileSync=(file,...rest)=>{if(file===target)throw error;return read(file,...rest);};assert.equal(captured(()=>discoverSources(api,f.file)),error);assert.equal(error.phase,undefined);}}
 finally{fs.readFileSync=read;f.close();}
});
test('existing directories and symlink loops are not missing-import syntax',()=>{
 const f=fixture({imports:['./directory']});try{fs.mkdirSync(path.join(f.dir,'directory'));const d=captured(()=>discoverSources(api,f.file));assert.equal(d.code,'EISDIR');assert.equal(d.phase,undefined);fs.symlinkSync('loop',path.join(f.dir,'loop'));f.put('main.bend',{imports:['./loop']});const loop=captured(()=>discoverSources(api,f.file));assert.equal(loop.code,'ELOOP');assert.equal(loop.phase,undefined);fs.symlinkSync('missing',path.join(f.dir,'broken'));f.put('main.bend',{imports:['./broken']});const broken=captured(()=>discoverSources(api,f.file));assert.equal(broken.code,'ENOENT');assert.equal(broken.phase,'parse');}finally{f.close();}
});
test('root-body parsing still precedes discovering imports, preserving the known first-error boundary',()=>{
 const f=fixture({imports:['./absent.bend'],error:'Error: body first'});try{const e=captured(()=>discoverSources(api,f.file));assert.equal(e.message,'Error: body first');assert.equal(e.phase,'parse');assert.equal(e.sourceFile,f.file);}finally{f.close();}
});
test('valid imports keep canonical deduplication and observe edits in a later request',()=>{
 const f=fixture({imports:['./child.bend','./alias.bend']});try{const child=f.put('child.bend',{});fs.symlinkSync('child.bend',path.join(f.dir,'alias.bend'));const graph=discoverSources(api,f.file);assert.deepEqual(graph.files,[f.file,child]);assert.equal(graph.hasBase,false);f.put('child.bend',{imports:['./missing.bend']});assert.equal(captured(()=>discoverSources(api,f.file)).phase,'parse');f.put('child.bend',{});assert.deepEqual(discoverSources(api,f.file).files,[f.file,child]);}finally{f.close();}
});
test('module-name collisions preserve their explicit load phase',()=>{
 const f=fixture({imports:['./a/module.bend','./b/module.bend']});try{f.put('a/module.bend',{imports:['./same.bend']});f.put('b/module.bend',{imports:['./same.bend']});f.put('a/same.bend',{});f.put('b/same.bend',{});const oldApi={f_parse:api.f_parse};const e=captured(()=>discoverSources(oldApi,f.file));assert.match(e.message,/Module import path collision/);assert.equal(e.phase,'load');}finally{f.close();}
});
