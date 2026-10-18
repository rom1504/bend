#!/usr/bin/env bun
// Run only under the coordinator's exclusive target slot: eight serial checks.
import {readFileSync,writeFileSync,mkdirSync,existsSync} from 'node:fs';
import {resolve,dirname,relative,sep} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';

const method=fileURLToPath(import.meta.url),root=resolve(dirname(method),'../../../../..');
const argv=process.argv.slice(2),options={};
if(argv.length!==6)throw Error('usage: check-mutations.mjs --prepared DIR --accepted REPORT --out NEW_PHASE98_DIR');
for(let i=0;i<argv.length;i+=2)options[argv[i]]=resolve(root,argv[i+1]);
const prepared=options['--prepared'],acceptedPath=options['--accepted'],out=options['--out'];
if(!prepared||!acceptedPath||!out||!out.startsWith(resolve(root,'selfhost/build/phase98')+sep)||existsSync(out))throw Error('invalid/fresh output required');
const read=path=>JSON.parse(readFileSync(path,'utf8'));
const pin=path=>{const bytes=readFileSync(path);return{file:relative(root,path),bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex')};};
const manifest=read(resolve(prepared,'manifest.json')),accepted=read(acceptedPath);
if(!accepted.complete||!accepted.independentlyChecked||accepted.opaqueDefinitions.length||accepted.sourceOnly)throw Error('positive independent proof required');
if(accepted.source.file!==resolve(root,manifest.baseline,'laws.bend'))throw Error('wrong positive source');
function verifyInputs(){for(const item of manifest.files){const actual=pin(resolve(root,item.file));if(actual.bytes!==item.bytes||actual.sha256!==item.sha256)throw Error('changed prepared file: '+item.file);}}
verifyInputs();
if(pin(accepted.source.file).sha256!==accepted.source.sha256)throw Error('changed accepted laws');
for(const closure of accepted.sourceClosure){if(pin(closure.origin.file).sha256!==closure.origin.sha256)throw Error('changed accepted closure');}
mkdirSync(out,{recursive:true});
const report={schema:'phase106-fold-law-mutation-check-v1',complete:false,
  method:pin(method),prepared:pin(resolve(prepared,'manifest.json')),positive:pin(acceptedPath),
  rows:[],guardedSeconds:0,independentKernelNegativeChecks:false};
const save=()=>writeFileSync(resolve(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
function check(name,source,expected,law){
  const target=resolve(out,name),command=['-B',resolve(root,'selfhost/tools/laws/phase98/check.py'),'--source',source,'--out',target,'--source-only'];
  const result=spawnSync('python3',command,{cwd:root,encoding:'utf8',maxBuffer:4*1024*1024});
  writeFileSync(resolve(out,name+'.stdout.log'),result.stdout??'');writeFileSync(resolve(out,name+'.stderr.log'),result.stderr??'');
  const proof=read(resolve(target,'report.json')),row=proof.rows.check,proc=row?.process;
  if(result.error||result.status!==expected||!proc||proc.returncode!==expected||proc.stoppedFor)throw Error('unexpected check failure: '+name);
  if(expected===0){if(!proof.complete||!proof.inputsUnchanged||proof.lawNames.length)throw Error('helper was not safely admitted: '+name);}
  else if(proof.complete||!row.stderr.includes('SOME PROOFS FAIL')||!row.stderr.includes('- expected :')||!row.stderr.includes('- observed :')||!row.stderr.includes('Location: '+law))throw Error('not the required semantic law rejection: '+name);
  report.guardedSeconds+=proc.wallSeconds;
  const observation={name,expectedExit:expected,actualExit:result.status,law:law??null,report:pin(resolve(target,'report.json')),wallSeconds:proc.wallSeconds};
  report.rows.push(observation);save();return observation;
}
try{
  for(const item of manifest.cases){
    const folder=resolve(root,item.folder);
    check(item.id+'-helper',resolve(folder,'candidate.bend'),0);
    check(item.id+'-law',resolve(folder,'laws.bend'),1,item.law);
  }
  verifyInputs();report.complete=true;report.inputsUnchanged=true;
  report.interpretation='All four changed helpers safely admitted; unchanged source laws reject their semantic faults. Positive package independently checked separately. These are source-check negative results, not independent-kernel rejection of the mutants.';
}catch(error){report.error=String(error);throw error;}finally{save();}
console.log(JSON.stringify({complete:report.complete,mutations:manifest.cases.length,checks:report.rows.length,guardedSeconds:report.guardedSeconds}));
