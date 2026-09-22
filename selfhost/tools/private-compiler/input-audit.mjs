// Observe the host's file transport, not Bend syntax. Hash the exact raw bytes
// returned by readFileSync, plus lexical->canonical resolutions. A request that
// observes changing bytes or symlink targets is never published as successful.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {digest,verifyIdentity} from './common.mjs';
export function auditReads({cacheDirectory}) {
 const read=fs.readFileSync,realpath=fs.realpathSync,files=new Map(),resolutions=new Map(),missing=new Set();let failure;
 const fileName=value=>typeof value==='string'?path.resolve(value):value instanceof URL&&value.protocol==='file:'?fileURLToPath(value):null;
 function remember(file,canonicalPath,bytes){
  const record={file,canonicalPath,sha256:digest(bytes)},old=files.get(file);
  if(old&&(old.sha256!==record.sha256||old.canonicalPath!==canonicalPath))failure=Error('Input changed while being read: '+file);
  files.set(file,record);
 }
 fs.readFileSync=function(file,options){
  const name=fileName(file);if(!name)return read.call(fs,file,options);
  const encoding=typeof options==='string'?options:options?.encoding;
  const rawOptions=typeof options==='object'&&options!==null?{...options,encoding:null}:undefined;
  try{const canonical=realpath.call(fs,name),bytes=read.call(fs,file,rawOptions);remember(name,canonical,bytes);return encoding?bytes.toString(encoding):bytes;}
  catch(error){if(error.code==='ENOENT'&&!name.startsWith(cacheDirectory+path.sep))missing.add(name);throw error;}
 };
 fs.realpathSync=Object.assign(function(file,options){
  const name=fileName(file);let value;
  try{value=realpath.call(fs,file,options);}catch(error){if(name&&['ENOENT','ENOTDIR'].includes(error.code)&&!name.startsWith(cacheDirectory+path.sep))missing.add(name);throw error;}
  if(name){const canonicalPath=Buffer.isBuffer(value)?value.toString():value,old=resolutions.get(name);if(old&&old!==canonicalPath)failure=Error('Input symlink changed during request: '+name);resolutions.set(name,canonicalPath);}
  return value;
 },realpath);
 let stopped=false;
 function stop(){if(!stopped){fs.readFileSync=read;fs.realpathSync=realpath;stopped=true;}}
 return {stop,finish(){
   stop();if(failure)throw failure;
   for(const item of files.values())if(realpath(item.file)!==item.canonicalPath||digest(read(item.file))!==item.sha256)throw Error('Input changed during compilation: '+item.file);
   for(const [file,canonical] of resolutions)if(realpath(file)!==canonical)throw Error('Input resolution changed during compilation: '+file);
   for(const file of missing)if(fs.existsSync(file))throw Error('Missing input appeared during compilation: '+file);
   return {files:[...files.values()],resolutions:[...resolutions].map(([file,canonicalPath])=>({file,canonicalPath})),missing:[...missing]};
 }};
}

export function verifyReadAudit(inputs) {
 if(!inputs||!Array.isArray(inputs.files)||!Array.isArray(inputs.resolutions)||!Array.isArray(inputs.missing))throw Error('Missing consumed-input audit');
 for(const record of inputs.files)verifyIdentity(record);
 for(const record of inputs.resolutions)if(fs.realpathSync(record.file)!==record.canonicalPath)throw Error('Input resolution changed before publication: '+record.file);
 for(const file of inputs.missing)if(fs.existsSync(file))throw Error('Missing input appeared before publication: '+file);
}
