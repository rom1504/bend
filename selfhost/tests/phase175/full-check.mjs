// Independent source validation only: the exact load/valid/holes gates used by
// maintained stage0-library.mjs, without importing comp.ts or emitting an API.
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify,requireThat as need,workspace} from '../../tools/build/hosted.mjs';
const args={};
for(let i=2;i<process.argv.length;i+=2){need(process.argv[i]?.startsWith('--')&&process.argv[i+1],'--key value required');const key=process.argv[i].slice(2);need(['source','out'].includes(key)&&!Object.hasOwn(args,key),'unknown or duplicate argument');args[key]=process.argv[i+1];}
need(args.out,'--out required');
const source=pin(args.source??path.join(workspace,'selfhost/build/phase175/full-source01/compiler.bend'));
need(source.bytes===3163584&&source.sha256==='a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04','Expected exact selected Phase175 full candidate');
const out=path.resolve(args.out);need(out.startsWith(workspace+'/selfhost/build/phase175/')&&!fs.existsSync(out),'fresh Phase175 output required');
const upstream=path.join(workspace,'selfhost/.bootstrap/upstream-phase66');
const configFile=path.join(workspace,'selfhost/src/compiler.json'),config=JSON.parse(fs.readFileSync(configFile,'utf8'));
const revision=spawnSync('git',['-C',upstream,'rev-parse','HEAD'],{encoding:'utf8',maxBuffer:1024*1024});
const clean=spawnSync('git',['-C',upstream,'diff','--quiet','HEAD','--','bend2']);
need(revision.status===0&&revision.stdout.trim()===config.upstream&&clean.status===0,'Pinned upstream differs');
const assetsFile=path.join(workspace,'selfhost/manifests/assets-native.json'),assets=JSON.parse(fs.readFileSync(assetsFile,'utf8'));
const engine=pin(process.execPath),expectedEngine=assets.assets.bun;
need(engine.bytes===expectedEngine.bytes&&engine.sha256===expectedEngine.sha256,'Expected pinned Bun engine');
const compositionFile=path.join(path.dirname(source.file),'report.json'),composition=JSON.parse(fs.readFileSync(compositionFile,'utf8'));
need(composition.kind==='phase175-full-native-source'&&composition.complete&&composition.protectedDeclarationCount===112&&composition.protectedUnchanged&&composition.mainUnchanged&&composition.inverseExact,'Authenticated complete source composition required');
need(composition.source.sha256===source.sha256&&composition.source.bytes===source.bytes,'Composition/source differs');
const language=path.join(upstream,'bend2/bend.ts'),base=path.join(upstream,'bend2/base.bend');
const inputs=[pin(fileURLToPath(import.meta.url)),pin(path.join(workspace,'selfhost/tools/build/hosted.mjs')),engine,source,pin(compositionFile),pin(configFile),pin(assetsFile),pin(language),pin(base),pin(path.join(workspace,'selfhost/tools/stage0-library.mjs'))];
inputs.forEach(verify);fs.mkdirSync(out,{recursive:true});
const report={kind:'phase175-independent-full-source-check',version:1,complete:false,checked:false,typeAccepted:false,source,inputs,upstream:config.upstream,unresolvedHoles:null,kernelChecked:false,proofSafetyAssessed:false,emittedCode:false,executedCandidate:false,phase:'load',scope:'Unmodified upstream book_load + book_valid + zero unresolved holes, matching the maintained source gates before API emission. Unsafe/foreign declarations retain their existing assumptions; no proof-safety verdict, BendTT proof, backend ownership check, emission or candidate execution is claimed.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
const start=performance.now();save();
const short=x=>typeof x==='string'?x.slice(0,600):x&&typeof x==='object'?String(x.$??'object'):String(x);
try{
  const B=await import(pathToFileURL(language));
  const book=B.book_nil(),seen=new Map();let begin=performance.now();
  await B.book_load(book,source.file,'',seen);report.loadSeconds=(performance.now()-begin)/1000;
  const loaded=[...seen.keys()].map(file=>fs.realpathSync(file)).sort();
  need(loaded.length===2&&loaded.includes(source.file)&&loaded.includes(fs.realpathSync(base)),'Unexpected source import closure');
  report.loadedSources=loaded.map(pin);report.phase='check';begin=performance.now();
  B.book_valid(book);report.checkSeconds=(performance.now()-begin)/1000;report.checked=true;
  need(Number.isSafeInteger(book.hols)&&book.hols>=0,'Invalid checked-book hole count');report.unresolvedHoles=book.hols;
  need(book.hols===0,'Unresolved laws/holes: '+book.hols);report.typeAccepted=true;
  report.declarationEvents=book.order.length;
  report.directUnsafeDeclarations=Object.values(book.tlds).filter(t=>t.u===true).length;
  report.nonBaseForeignDeclarations=Object.values(book.tlds).filter(t=>t.i!==undefined&&t.b!==true).length;
  report.assumptionCountsScope='Direct checked-book declarations only, not transitive proof dependencies or discharged proofs.';
  inputs.forEach(verify);report.complete=true;report.phase='complete';
}catch(error){report.error={kind:short(error?.$??error?.name??'error'),definition:short(error?.def??''),expected:short(error?.exp??error?.message??error),observed:short(error?.obs??'')};process.exitCode=1;}
finally{
  report.changedInputs=[];for(const row of inputs){try{verify(row)}catch{report.changedInputs.push(row)}}
  if(report.changedInputs.length){report.complete=false;process.exitCode=1;}
  report.seconds=(performance.now()-start)/1000;save();
  console.log(JSON.stringify({complete:report.complete,checked:report.checked,typeAccepted:report.typeAccepted,unresolvedHoles:report.unresolvedHoles,proofSafetyAssessed:false,kernelChecked:false,seconds:report.seconds,error:report.error}));
}
