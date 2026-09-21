// Expose unchanged workers from the SAME checked upstream-emitted Bend program
// for a JavaScript host comparison. No compiler algorithm is rewritten here.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
export function exposeNativeGraphApi(buildDirectory, outputDirectory) {
  const build=path.resolve(buildDirectory),output=path.resolve(outputDirectory);
  const report=JSON.parse(fs.readFileSync(path.join(build,'native-build-report.json'),'utf8'));
  if (!report.complete || !report.upstreamTrackedFilesClean || !['load','check-and-owned','javascript-emission','c-emission'].every(name=>report.phases.some(phase=>phase.name===name))) throw Error('A completed checked native component emission is required');
  const source=fs.readFileSync(report.javascript.file,'utf8');
  if(hash(source)!==report.javascript.sha256 || hash(fs.readFileSync(report.source))!==report.sourceSha256)throw Error('Checked program/source changed');
  const entry='cli(process.argv.slice(2));\nio_exit($main$, null);';
  if(source.split(entry).length!==2)throw Error('Unexpected checked program entry');
  const names=[...source.matchAll(/^function \$([A-Za-z_][A-Za-z_0-9]*)\$\(/gm)].map(match=>match[1]);
  for(const name of ['f_parse','f_load_graph','j_modules','rapid_graph_parse','rapid_bundle_loaded'])if(!names.includes(name))throw Error('Missing checked worker '+name);
  fs.mkdirSync(output,{recursive:false});
  const cjs=path.join(output,'workers.cjs'),api=path.join(output,'api.mjs');
  fs.writeFileSync(cjs,source.replace(entry,'module.exports={'+names.map(name=>JSON.stringify(name)+':run_lib($'+name+'$,$'+name+'$.length)').join(',')+'};'));
  fs.writeFileSync(api,"import {createRequire} from 'node:module';\nexport default createRequire(import.meta.url)('./workers.cjs');\n");
  const evidence={kind:'checked-native-program-js-worker-exposure',toolSha256:hash(fs.readFileSync(fileURLToPath(import.meta.url))),buildReport:path.join(build,'native-build-report.json'),checkedProgramSha256:report.javascript.sha256,sourceSha256:report.sourceSha256,api,apiSha256:hash(fs.readFileSync(api)),workers:cjs,workersSha256:hash(fs.readFileSync(cjs)),exportedWorkers:names.length};
  fs.writeFileSync(path.join(output,'exposure.json'),JSON.stringify(evidence,null,2)+'\n');
  return evidence;
}
if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url)){
  const [build,output]=process.argv.slice(2);if(!build||!output)throw Error('usage: native-graph-api.mjs CHECKED_BUILD NEW_OUTPUT_DIRECTORY');
  console.log(JSON.stringify(exposeNativeGraphApi(build,output)));
}
