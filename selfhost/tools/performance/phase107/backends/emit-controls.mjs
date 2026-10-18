// Checked Bend source owns all IR construction, verification and emission.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const [apiPath, output, casesPath] = process.argv.slice(2);
const api = (await import(pathToFileURL(path.resolve(apiPath)))).default;
const names = Object.keys(JSON.parse(fs.readFileSync(casesPath, 'utf8')));
const artifacts = {};
for (const name of names) {
  const selected = name.startsWith('qbe_') ? api.nxq_control(name) : api.nx_workload(name);
  if (selected.$ !== 'Some') throw Error('missing workload ' + name);
  artifacts[name] = {};
  for (const policy of ['raw', 'fold']) {
    const program = policy === 'fold' ? api.nx_optimize(selected.value) : selected.value;
    if (api.nx_verify(program) !== true) throw Error('verifier refused ' + name + '/' + policy);
    const stem = path.join(output, name + '-' + policy);
    fs.writeFileSync(stem + '.ssa', api.nxq_program(program));
    fs.writeFileSync(stem + '.json', api.nx_json_program(program));
    fs.writeFileSync(stem + '.c', api.nx_c_program(program));
    artifacts[name][policy] = {verified:true, stem};
  }
}
const rejected = [];
for (const name of ['bad_var','bad_call','bad_type','bad_effect','bad_return',
                    'bad_operator','bad_duplicate','bad_identifier']) {
  const selected = api.nx_workload(name);
  if (selected.$ !== 'Some' || api.nx_verify(selected.value) !== false ||
      api.nxq_program(selected.value) !== 'INVALID_NX_PROGRAM\n')
    throw Error('negative verifier control failed: ' + name);
  rejected.push(name);
}
fs.writeFileSync(path.join(output,'emission.json'), JSON.stringify({artifacts,rejected},null,2)+'\n');
