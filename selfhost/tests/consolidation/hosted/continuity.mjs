// Finite continuity controls, not compiler or generated-program timing.
// Run only under the root's process-tree/disk guard. No nested guard.
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {pin,verify,requireThat,workspace} from '../../../tools/build/hosted.mjs';
import {nativeBuildPlan} from '../../../tools/native-build.mjs';
const options={};for(let i=2;i<process.argv.length;i+=2){requireThat(process.argv[i].startsWith('--')&&process.argv[i+1],'Expected --option value');options[process.argv[i].slice(2)]=process.argv[i+1];}
for(const key of ['candidate','candidate-source','candidate-guard','out','cc'])requireThat(options[key],'Missing --'+key);
const out=path.resolve(options.out),here=import.meta.dirname;
requireThat(!fs.existsSync(out)&&out.startsWith(workspace+'/selfhost/build/'),'Fresh output in selfhost/build required');
const read=f=>JSON.parse(fs.readFileSync(f,'utf8'));
const candidate=pin(options.candidate),source=pin(options['candidate-source']),guardPin=pin(options['candidate-guard']),guard=read(guardPin.file);
requireThat(guard.complete&&guard.returncode===0&&!guard.stoppedFor,'Candidate checked acquisition did not complete');
// This probe is deliberately an explicit trusted command admission, not a fake
// historical checked-bootstrap sidecar. The caller supplies its exact pins.
requireThat(guard.artifactRoots?.includes(path.dirname(candidate.file)),'Acquisition did not own the API output');
requireThat(guard.command.some(x=>typeof x==='string'&&x.includes('stage0-library.mjs')),'Not a checked stage0 acquisition command');
const exportsFile=path.join(path.dirname(candidate.file),'exports.json');
const exports=read(exportsFile);requireThat(Array.isArray(exports)&&exports.includes('jd_program_selected')&&exports.includes('nr_compile_prepared'),'Probe API roots missing');
const installed=read(path.join(workspace,'selfhost/dist/release.json'));
const jsBaseline=pin(path.join(workspace,'selfhost/dist/typed-api.mjs'));
const installedRow=installed.files.find(x=>x.path==='dist/typed-api.mjs');requireThat(installedRow?.sha256===jsBaseline.sha256&&installedRow.bytes===jsBaseline.bytes,'Installed JS release identity differs');
const nativeBaseline=pin(path.join(workspace,'selfhost/dist/native/bend'));
const nativeReceipt=pin(path.join(workspace,'selfhost/dist/native/BUILD.json'));
const nativeBuild=read(nativeReceipt.file);
const base=pin(path.join(workspace,'selfhost/dist/base.bend')),cc=pin(options.cc);
const cases=read(path.join(here,'cases.json')).filter(row=>!options.cases||options.cases.split(',').includes(row.name));
requireThat(cases.length>0,'No cases selected');
fs.mkdirSync(out,{recursive:true});
const inputs=[pin(import.meta.filename),pin(path.join(here,'worker.mjs')),pin(path.join(here,'cases.json')),pin(process.execPath),candidate,source,guardPin,pin(exportsFile),jsBaseline,nativeBaseline,nativeReceipt,base,cc,pin(path.join(workspace,'selfhost/dist/release.json'))];
const report={kind:'bend-hosted-continuity',version:1,complete:false,passed:false,candidate:{api:candidate,source,acquisition:guardPin},baseline:{js:jsBaseline,jsRelease:pin(path.join(workspace,'selfhost/dist/release.json')),c:nativeBaseline,cBuild:nativeReceipt},inputs,rows:[],jobs:[],scope:'Finite direct/legacy JS and native-C continuity. Full output oracles and raw emitted-byte comparisons; no timing, self-hosting or full-conformance claim.'};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
const env={...process.env};for(const key of Object.keys(env))if(key.startsWith('BEND_')||['NODE_OPTIONS','NODE_PATH','LD_PRELOAD'].includes(key))delete env[key];
function run(label,command,seconds=30){
  const stdout=path.join(out,label+'.stdout'),stderr=path.join(out,label+'.stderr'),so=fs.openSync(stdout,'wx'),se=fs.openSync(stderr,'wx');
  let child;const start=performance.now();try{child=spawnSync(command[0],command.slice(1),{cwd:workspace,env,timeout:seconds*1000,stdio:['ignore',so,se]});}finally{fs.closeSync(so);fs.closeSync(se);}
  const row={label,command,seconds:(performance.now()-start)/1000,exitCode:child.status,signal:child.signal,error:child.error?.message??null,stdout:pin(stdout),stderr:pin(stderr)};report.jobs.push(row);save();return row;
}
function good(row){return row.exitCode===0&&!row.error&&!row.signal;}
try{
  for(const test of cases){
    const fixture=pin(path.join(here,test.file));inputs.push(fixture);
    for(const backend of ['direct','js','c']){
      const row={case:test.name,backend,source:fixture,expected:test.expected,roles:{}};report.rows.push(row);save();
      for(const role of ['baseline','candidate']){
        const label=test.name+'-'+backend+'-'+role;
        let compilation,product,accepted;
        if(backend==='c'&&role==='baseline'){
          const dest=path.join(out,label+'.c');compilation=run(label+'-compile',[nativeBaseline.file,fixture.file,'-o',dest],60);
          accepted=good(compilation)&&fs.existsSync(dest);if(accepted)product=pin(dest);
        }else{
          const image=role==='baseline'?jsBaseline:candidate,input={image,source:fixture,base,mode:backend==='c'?'native':'compile',backend:backend==='c'?'js':backend,inputs:[image,fixture,base]};
          const inputFile=path.join(out,label+'.json');fs.writeFileSync(inputFile,JSON.stringify(input,null,2)+'\n');
          const workerOut=path.join(out,label),job=run(label+'-compile',[process.execPath,path.join(here,'worker.mjs'),inputFile,workerOut],60);
          requireThat(good(job),'Worker process failed: '+label);
          compilation=read(path.join(workerOut,'report.json'));requireThat(compilation.complete,'Worker failed: '+label);
          product=compilation.product;accepted=compilation.observation.status==='ok'&&!!product;
        }
        const result={compilation,accepted,product};row.roles[role]=result;save();
        if(test.reject){result.pass=!accepted;continue;}
        if(!accepted){result.pass=false;continue;}
        let command;
        if(backend==='c'){
          const binary=path.join(out,label+'.bin'),plan=nativeBuildPlan({source:fs.readFileSync(product.file,'utf8'),file:product.file,binary,target:'cpu'});
          const built=run(label+'-build',[cc.file,...plan.args],60);result.build=built;
          if(!good(built)){result.pass=false;continue;}command=[binary,'--threads','1','--gpu','off'];
        }else command=[process.execPath,product.file];
        result.execution=run(label+'-execute',command,10);
        result.pass=good(result.execution)&&fs.readFileSync(result.execution.stdout.file,'utf8')===test.expected&&fs.readFileSync(result.execution.stderr.file,'utf8')==='';
      }
      row.byteExact=row.roles.baseline.product&&row.roles.candidate.product?row.roles.baseline.product.sha256===row.roles.candidate.product.sha256:null;
      row.pass=row.roles.baseline.pass===true&&row.roles.candidate.pass===true;
      if(test.reject){row.rejectionScope='Both compilers refuse; raw diagnostics retained without path/wording normalization.';}
      save();
    }
  }
  inputs.forEach(verify);report.complete=true;report.passed=report.rows.every(r=>r.pass);requireThat(report.passed,'Continuity/oracle failure; see all preserved rows');
}catch(error){report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,passed:report.passed,rows:report.rows.length,report:path.join(out,'report.json')}));
