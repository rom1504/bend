// Validate the retained checked-emission -> C build -> executable chain.
// This checks artifact identity, not a hermetic compiler/linker environment.
import fs from 'node:fs';
import {createHash} from 'node:crypto';

const sha=bytes=>createHash('sha256').update(bytes).digest('hex');
const fileSha=file=>sha(fs.readFileSync(file));
const equal=(left,right)=>JSON.stringify(left)===JSON.stringify(right);

export function verifyNativeBuildEvidence({checked,cBuild,exposure,binary}) {
  if(!checked.complete||!cBuild.complete)throw Error('Incomplete checked/native build');
  if(fileSha(checked.source)!==checked.sourceSha256||fileSha(checked.javascript.file)!==checked.javascript.sha256||fileSha(checked.c.file)!==checked.c.sha256)
    throw Error('Checked compiler source or emitted artifact changed');
  if(checked.sourceSha256!==exposure.sourceSha256||checked.javascript.sha256!==exposure.checkedProgramSha256)
    throw Error('Exposed JS workers do not match the checked build');
  if(fileSha(binary)!==cBuild.binarySha256)throw Error('Native binary changed');

  if(cBuild.kind==='native-content-addressed-build') {
    const record=cBuild.record,identity=record?.identity;
    if(cBuild.version!==2||identity?.version!==2||typeof cBuild.cacheHit!=='boolean'||
       record.key!==cBuild.key||sha(JSON.stringify(identity))!==cBuild.key||
       record.binarySha256!==cBuild.binarySha256)
      throw Error('Corrupt native cache build identity');
    if(identity.sourceSha256!==checked.c.sha256||cBuild.inputSha256!==checked.c.sha256)
      throw Error('Native cache C source identity mismatch');
    for(const [outer,inner] of [['preprocessedSha256','preprocessedSha256'],['optimization','optimization'],['cachePlan','plan'],['compiler','compiler'],['toolSha256','toolSha256'],['cacheToolSha256','cacheToolSha256'],['environment','environment']]) {
      if(cBuild[outer]===undefined||!equal(cBuild[outer],identity[inner]))
        throw Error('Native cache report/record mismatch: '+outer);
    }
  } else if(cBuild.exitCode!==0||cBuild.sourceSha256!==checked.c.sha256) {
    throw Error('Native C build identity mismatch');
  }
  return {kind:cBuild.kind??'legacy-native-c-build',sourceSha256:checked.c.sha256,binarySha256:cBuild.binarySha256};
}

// A cache hit contains no evidence of the original C compilation duration.
// Keep it null, rather than silently treating reuse as a zero-cost compilation.
export function nativeBuildTiming(checked,cBuild) {
  const duration=value=>Number.isFinite(value)&&value>=0?value:null;
  const phases=checked.phases?.map(phase=>duration(phase.milliseconds));
  const checkedEmissionPhaseMs=phases?.length&&phases.every(value=>value!==null)?phases.reduce((sum,value)=>sum+value,0):null;
  const cached=cBuild.kind==='native-content-addressed-build';
  const cacheHit=cached?cBuild.cacheHit:false;
  const cCompileMs=cacheHit?null:duration(cached?cBuild.compileMs:cBuild.milliseconds);
  const cPreprocessMs=cached?duration(cBuild.preprocessMs):null;
  const phaseWorkMs=checkedEmissionPhaseMs!==null&&cCompileMs!==null&&(!cached||cPreprocessMs!==null)
    ?checkedEmissionPhaseMs+cCompileMs+(cPreprocessMs??0):null;
  return {optimization:cBuild.optimization,cacheHit,checkedEmissionPhaseMs,cCompileMs,cPreprocessMs,phaseWorkMs,
    note:cacheHit
      ?'Cache reuse: original C compilation time is unknown; phaseWorkMs is null. Preprocessing is measured for this lookup. Checking/emission are separate retained build phases.'
      :cached
        ?'Sum of recorded checking/emission, initial preprocessing and C compilation phases; excludes compiler discovery, post-build revalidation and publication. Not an end-to-end build timing or a per-request cost.'
        :'Sum of successful checking/emission/C-build phases, not an end-to-end timing; not charged to each reused-artifact compile'};
}
