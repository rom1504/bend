import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const request=JSON.parse(fs.readFileSync(process.argv[2],'utf8'));
try {
  const adapter=await import(pathToFileURL(request.adapter));
  const result=await adapter.probe(request);
  if(!result||!['ok','error','unsupported','timeout','crash'].includes(result.status)) throw Error('Adapter returned an invalid probe result');
  fs.writeFileSync(request.response,JSON.stringify(result));
} catch(error) {
  fs.writeFileSync(request.response,JSON.stringify({status:'crash',phase:'adapter',reason:error.stack||String(error)}));
  process.exitCode=1;
}
