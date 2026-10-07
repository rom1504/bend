#!/usr/bin/env node
// Preparation and each first-read worker are separate guarded root commands.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {performance} from 'node:perf_hooks';
import {pathToFileURL} from 'node:url';
import {encodeBaseGraph} from '../../base-cache-graph.mjs';
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
const [mode,...args]=process.argv.slice(2);
if(mode==='prepare'){
  const [input,directory]=args.map(x=>path.resolve(x));fs.mkdirSync(directory,{recursive:false});
  const bytes=fs.readFileSync(input),cut=bytes.indexOf(10),header=JSON.parse(bytes.subarray(0,cut));
  if(header.format!=='bend-base-cache-frame-2')throw Error('Expected frame2');
  const [nb,nc,nf]=header.segments,payload=bytes.subarray(cut+1);
  const raw=JSON.parse(payload.subarray(0,nb)),checked=nc?JSON.parse(payload.subarray(nb,nb+nc)):null,fresh=nf?JSON.parse(payload.subarray(nb+nc)):null;
  const book=encodeBaseGraph([raw]),state=encodeBaseGraph([checked,fresh,null,null],book),hash=sha(state.bytes);
  const graphHeader={...header,format:'bend-base-cache-frame-3',segments:[book.bytes.length,state.bytes.length],bookGraphSha256:sha(book.bytes),preparedGraphSha256:hash,checkedPrefixStateSha256:hash,freshPrefixStateSha256:hash};
  fs.writeFileSync(path.join(directory,'baseline-frame2.json'),bytes,{flag:'wx'});
  fs.writeFileSync(path.join(directory,'candidate-frame3.json'),Buffer.concat([Buffer.from(JSON.stringify(graphHeader)+'\n'),book.bytes,state.bytes]),{flag:'wx'});
  fs.writeFileSync(path.join(directory,'manifest.json'),JSON.stringify({input,sha256:sha(bytes),sourcePath:header.sourcePath,compilerSha256:header.compilerSha256,baseSha256:header.baseSha256,limits:'Same book and existing checked/fresh states; no new world/frontend state.'},null,2)+'\n',{flag:'wx'});
  console.log(JSON.stringify({pass:true,directory}));
}else if(mode==='worker'){
  const [driverFile,cacheFile,baseFile,outputFile]=args.map(x=>path.resolve(x));
  const directory=path.dirname(outputFile);fs.mkdirSync(directory,{recursive:true});
  const original=fs.readFileSync(driverFile,'utf8');
  const declaration="export const project=path.resolve(import.meta.dirname,'..');";
  if(original.split(declaration).length!==2)throw Error('Unexpected driver project declaration');
  let source=original.replace(declaration,`export const project=${JSON.stringify(path.resolve(path.dirname(driverFile),'..'))};`);
  source=source.replace(/from '(\.\/[^']+)'/g,(_,name)=>`from '${pathToFileURL(path.resolve(path.dirname(driverFile),name)).href}'`);
  source+='\nexport {readBaseCache};\n';
  const instrumented=outputFile+'.driver.mjs';fs.writeFileSync(instrumented,source,{flag:'wx'});
  const driver=await import(pathToFileURL(instrumented));
  const bytes=fs.readFileSync(cacheFile),header=JSON.parse(bytes.subarray(0,bytes.indexOf(10)));
  const info={version:header.version,termAbi:header.termAbi??0,compilerSha256:header.compilerSha256,baseSha256:header.baseSha256,
    sourcePath:fs.realpathSync(baseFile),sourceText:fs.readFileSync(baseFile,'utf8'),file:cacheFile};
  if(sha(Buffer.from(info.sourceText))!==info.baseSha256)throw Error('Base identity mismatch');
  const before=performance.now(),cached=driver.readBaseCache(info),ms=performance.now()-before;
  if(!cached?.book||!cached.checkedPrefixState||!cached.freshPrefixState)throw Error('Incomplete admission');
  const report={schema:'phase63-cache-first-read-1',pass:true,format:header.format,ms,driver:{file:driverFile,sha256:sha(original)},cache:{file:cacheFile,sha256:sha(bytes)},base:{file:baseFile,sha256:info.baseSha256},world:!!cached.preparedWorld,frontend:!!cached.frontendReadyState,
    limits:['One first admission in this process; no previous graph decode.','Includes file read, full outer-frame digest/parse and private state admission.','Driver import and API/Base identity discovery are outside the clock.','No compiler image executes; fresh compiler requests still decide promotion.']};
  fs.writeFileSync(outputFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({pass:true,format:report.format,ms}));
}else throw Error('Usage: cache-cold-probe.mjs prepare FRAME2 DIRECTORY | worker DRIVER CACHE BASE OUTPUT.json');
