#!/usr/bin/env node
// Reuse the paired harness for the separate, bounded grammar follow-up matrix.
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
const [apiArgument,outputArgument,cpuArgument]=process.argv.slice(2);
if(!apiArgument||!outputArgument)throw Error('Usage: phase2-grammar.mjs CHECKED_API NEW_OUTPUT_DIRECTORY [CPU]');
const project=path.resolve(import.meta.dirname,'../..'),api=fs.realpathSync(apiArgument),output=path.resolve(outputArgument),config=output+'.config.json';
if(fs.existsSync(output)||fs.existsSync(config))throw Error('Use a new output directory and config path');
const cpu=cpuArgument===undefined?undefined:Number(cpuArgument);
if(cpu!==undefined&&(!Number.isSafeInteger(cpu)||cpu<0))throw Error('Invalid CPU');
fs.mkdirSync(path.dirname(config),{recursive:true});
fs.writeFileSync(config,JSON.stringify({
  upstream:path.resolve(process.env.BEND_UPSTREAM||path.join(project,'.bootstrap/upstream')),
  api,runtime:path.resolve(process.env.BEND_TYPED_RUNTIME||path.join(project,'src/runtime.mjs')),
  bootstrapReport:api+'.bootstrap.json',selection:path.join(import.meta.dirname,'phase2-grammar/cases.json'),
  cpu,timeoutMs:60000,stackKb:4096,heapMb:4096,retain:'all',
},null,2)+'\n');
const child=spawnSync(process.execPath,[path.join(project,'tools/conformance/target.mjs'),config,output],{stdio:'inherit',env:process.env});
if(child.error)throw child.error;
process.exitCode=child.status??1;
