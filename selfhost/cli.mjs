#!/usr/bin/env node
// Public command shell: select the qualified installed API before loading its host.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath} from 'node:url';
const project=path.dirname(fileURLToPath(import.meta.url));
const root=path.dirname(project);
function requireThat(value,message){if(!value)throw Error(message);}
function bound(row){
  requireThat(row&&typeof row.file==='string'&&Number.isSafeInteger(row.bytes)&&/^[0-9a-f]{64}$/.test(row.sha256),'Invalid current file identity');
  const file=path.resolve(root,row.file);
  requireThat(fs.realpathSync(file)===file,'Noncanonical current file path: '+row.file);
  const bytes=fs.readFileSync(file);
  requireThat(bytes.length===row.bytes&&crypto.createHash('sha256').update(bytes).digest('hex')===row.sha256,'Current file changed: '+row.file);
  return file;
}
async function run(){
  const current=JSON.parse(fs.readFileSync(path.join(project,'manifests/current.json'),'utf8'));
  requireThat(current.kind==='bend-current-bindings'&&current.version===1&&current.complete===true&&current.gateStatus?.qualified===true,'No complete qualified current compiler release');
  const js=current.components.js;
  requireThat(js.host==='js'&&js.stage==='B2'&&js.protocol==='hosted-api-v1','Current JavaScript compiler generation/protocol differs');
  const row=js.image,installed=current.files[row.file];
  requireThat(!path.isAbsolute(row.file)&&row.file.startsWith('selfhost/dist/')&&!row.file.split('/').includes('..')&&installed?.file===row.file&&installed.bytes===row.bytes&&installed.sha256===row.sha256,'Current API is absent from the installed inventory');
  const image=bound(row);
  if(!process.env.BEND_TYPED_API)process.env.BEND_TYPED_API=image;
  if(!process.env.BEND_BASE)process.env.BEND_BASE=bound(current.providers.base);
  if(!process.env.BEND_TYPED_RUNTIME)process.env.BEND_TYPED_RUNTIME=bound(current.providers.jsLegacyRuntime);
  requireThat(bound(current.providers.jsDirectRuntime)===path.join(project,'src/runtime/js/direct.mjs'),'Current direct runtime path differs from the host contract');
  const {main}=await import('./tools/typed-driver.mjs');
  await main(process.argv.slice(2));
}
run().catch(error=>{console.error(error.message);process.exitCode=1;});
