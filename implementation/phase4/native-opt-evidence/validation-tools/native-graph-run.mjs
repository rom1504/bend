// Explicit filesystem manifest boundary. Parsing, graph loading and compilation
// execute in the native Bend binary; this module only manages bytes and paths.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnFileCapture as spawnSync} from './native-file-capture.mjs';
import {createHash} from 'node:crypto';
const MAX_FILE = 16 * 1024 * 1024, MAX_TOTAL = 128 * 1024 * 1024, MAX_RECORDS = 4096;
const sha = bytes => createHash('sha256').update(bytes).digest('hex');
const fingerprint = stat => ['dev','ino','size','mtimeNs','ctimeNs','mode'].map(key => String(stat[key])).join(':');
function field(value, name) {
  if (typeof value !== 'string' || !value || value.includes('\0') || !value.isWellFormed() || Buffer.byteLength(value) > 8192) throw Error(`Invalid ${name}`);
  return value;
}
function inspect(file, role, optional = false) {
  const lexical = path.resolve(file);
  try {
    const canonical = fs.realpathSync(lexical), stat = fs.statSync(canonical, {bigint: true});
    if (!stat.isFile()) throw Error(`${role} must be a regular file`);
    if (role !== 'binary' && stat.size > BigInt(MAX_FILE)) throw Error(`${role} exceeds 16 MiB`);
    return {role, lexical, path: canonical, fingerprint: fingerprint(stat), dev: String(stat.dev), ino: String(stat.ino), bytes: Number(stat.size)};
  } catch (error) {
    if (optional && error.code === 'ENOENT') return {role, lexical, path: lexical, missing: true};
    throw error;
  }
}
function unchanged(record) {
  const now = inspect(record.lexical, record.role, record.missing);
  if (now.path !== record.path || now.fingerprint !== record.fingerprint || Boolean(now.missing) !== Boolean(record.missing)) throw Error(`Input changed during native graph run: ${record.lexical}`);
}
function destination(file, inputs) {
  const absolute = path.resolve(file), output = path.join(fs.realpathSync(path.dirname(absolute)), path.basename(absolute));
  let existing;
  try {
    if (fs.lstatSync(output).isSymbolicLink()) throw Error('Output must not be a symbolic link');
    existing = inspect(output, 'output');
  } catch (error) { if (error.code !== 'ENOENT') throw error; }
  for (const input of inputs) {
    if (output === input.path || output === input.lexical || existing && !input.missing && existing.dev === input.dev && existing.ino === input.ino) throw Error(`Output aliases protected input: ${input.path}`);
  }
  return output;
}
function entry(value, directory, role) {
  const object = typeof value === 'string' ? {path: value} : value;
  if (!object || typeof object !== 'object' || Array.isArray(object) || Object.keys(object).some(key => !['name','path'].includes(key))) throw Error(`Invalid ${role} record`);
  const lexical = path.resolve(directory, field(object.path, `${role} path`));
  const name = object.name === undefined ? lexical : path.resolve(directory, field(object.name, `${role} name`));
  return {name, ...inspect(lexical, role, role === 'asset')};
}
export function loadNativeGraphManifest(manifestFile) {
  const manifest = inspect(manifestFile, 'manifest'), bytes = fs.readFileSync(manifest.path);
  unchanged(manifest);
  const data = JSON.parse(bytes), directory = path.dirname(manifest.path);
  if (!data || data.version !== 1 || Object.keys(data).some(key => !['version','main','base','modules','assets'].includes(key)) || !Array.isArray(data.modules ?? []) || !Array.isArray(data.assets ?? [])) throw Error('Expected native graph manifest version 1');
  const main = entry(field(data.main, 'main'), directory, 'module');
  const base = entry(field(data.base, 'base'), directory, 'module'); base.name = 'Base';
  const modules = [main, base, ...(data.modules ?? []).map(value => entry(value, directory, 'module'))];
  const assets = (data.assets ?? []).map(value => entry(value, directory, 'asset'));
  if (modules.length + assets.length > MAX_RECORDS) throw Error('Graph manifest exceeds 4096 records');
  const names = new Map(), unique = [];
  for (const source of modules) {
    field(source.name, 'module name'); field(source.path, 'canonical module path');
    const prior = names.get(source.name);
    if (prior && prior.path !== source.path) throw Error(`Module import path collision: ${source.name}`);
    if (!prior) { names.set(source.name, source); unique.push(source); }
  }
  for (const source of unique) {
    const logical = names.get(source.path);
    if (logical && logical.path !== source.path) throw Error(`Module logical/physical identity collision: ${source.path}`);
  }
  const assetNames = new Set();
  for (const asset of assets) {
    field(asset.name, 'asset name'); field(asset.path, 'canonical asset path');
    if (assetNames.has(asset.name)) throw Error(`Duplicate asset name: ${asset.name}`);
    assetNames.add(asset.name);
  }
  return {version: 1, main: main.name, manifest: {...manifest, sha256: sha(bytes)}, modules: unique, moduleAliases: modules.filter(source => !unique.includes(source)), assets};
}
export async function runNativeGraph({binary, manifest, runtime, output, mode = 'program', cpu, timeoutMs = 120000}, {spawn = spawnSync} = {}) {
  const started = performance.now();
  if (!['program','library'].includes(mode)) throw Error('Graph mode must be program or library');
  if (cpu !== undefined && !/^\d+$/.test(String(cpu))) throw Error('CPU must be a nonnegative integer');
  if (!Number.isSafeInteger(timeoutMs) || timeoutMs <= 0) throw Error('Timeout must be a positive integer');
  const graph = loadNativeGraphManifest(manifest), executable = inspect(binary, 'binary'), runtimeFile = inspect(runtime, 'runtime');
  const inputs = [executable, runtimeFile, graph.manifest, ...graph.modules, ...graph.moduleAliases, ...graph.assets];
  const target = destination(output, inputs), temporary = fs.mkdtempSync(path.join(path.dirname(target), '.bend-native-graph-'));
  const temporaryOutput = path.join(temporary, 'output.mjs'), wirePath = path.join(temporary, 'graph.wire');
  let total = 0;
  const copied = new Map();
  const snapshot = input => {
    const prior = copied.get(input.path);
    if (prior) { input.sha256 = prior.sha256; return prior.file; }
    unchanged(input);
    const bytes = fs.readFileSync(input.path); total += bytes.length;
    if (total > MAX_TOTAL) throw Error('Graph snapshots exceed 128 MiB');
    unchanged(input);
    const sha256 = sha(bytes), file = path.join(temporary, `source-${copied.size}.txt`);
    fs.writeFileSync(file, bytes, {flag:'wx'}); copied.set(input.path, {file, sha256}); input.sha256 = sha256;
    return file;
  };
  let report;
  try {
    executable.sha256 = sha(fs.readFileSync(executable.path)); unchanged(executable);
    const runtimeSnapshot = snapshot(runtimeFile);
    const fields = ['BEND_GRAPH_1', graph.main];
    for (const module of graph.modules) fields.push('S', module.name, module.path, snapshot(module));
    for (const alias of graph.moduleAliases) alias.sha256 = copied.get(alias.path)?.sha256;
    for (const asset of graph.assets) fields.push('A', asset.name, asset.path);
    fields.push('E'); fields.forEach(value => field(value, 'transport field'));
    const wire = Buffer.from(fields.join('\0') + '\0');
    if (wire.length > 4 * 1024 * 1024) throw Error('Graph transport exceeds 4 MiB');
    fs.writeFileSync(wirePath, wire, {flag:'wx'});
    const preparationMs = performance.now() - started;
    const args = ['--threads','1','--gpu','off','--','--graph',wirePath,runtimeSnapshot,temporaryOutput,mode];
    const command = cpu === undefined ? executable.path : 'taskset', commandArgs = cpu === undefined ? args : ['-c',String(cpu),executable.path,...args];
    const nativeStarted = performance.now();
    const result = await spawn(command, commandArgs, {encoding:'utf8',timeout:timeoutMs,maxBuffer:16*1024*1024});
    const nativeWallMs = performance.now() - nativeStarted;
    const usedAssetIds = [...new Set([...String(result.stderr ?? '').matchAll(/^asset_used=(\d+)$/gm)].map(match => Number(match[1])))];
    const diagnostic = /(?:^|\n)phase=(\w+) checked=(True|False): ([\s\S]*)/.exec(result.stderr ?? '');
    report = {kind:'native-graph-run', version:1, mode, cpu:cpu === undefined ? null : Number(cpu), timeoutMs,
      status:result.status, signal:result.signal ?? null, error:result.error?.message ?? null,
      phase:diagnostic?.[1] ?? (result.status === 0 ? 'compile' : 'load'), checked:diagnostic ? diagnostic[2] === 'True' : result.status === 0,
      diagnostic:diagnostic?.[3]?.trimEnd() ?? '', stdout:result.stdout ?? '', stderr:result.stderr ?? '',
      preparationMs,nativeWallMs,compileMs:Number(/(?:^|\n)compile_ms=(\d+)/.exec(result.stderr ?? '')?.[1] ?? NaN),
      consumedChars:Number(/(?:^|\n)consumed_chars=(\d+)/.exec(result.stderr ?? '')?.[1] ?? NaN),
      manifest:graph.manifest,main:graph.main,modules:graph.modules,moduleAliases:graph.moduleAliases,assets:graph.assets,usedAssetIds,binary:executable,runtime:runtimeFile,
      transportSha256:sha(wire),output:target,published:false,
      scope:'Explicit module/asset manifest; native Bend graph, checks and JS emission; no discovery or JS/TypeScript compiler fallback. compileMs includes native source/selected-asset IO; wallMs includes host snapshot/provenance overhead.'};
    for (const input of inputs) unchanged(input);
    if (sha(fs.readFileSync(executable.path)) !== executable.sha256) throw Error('Native binary bytes changed during execution');
    unchanged(executable);
    for (const id of usedAssetIds) {
      const asset = graph.assets[id];
      if (!asset || asset.missing) throw Error('Native output reports an invalid asset identity');
      asset.sha256 = sha(fs.readFileSync(asset.path)); unchanged(asset);
    }
    // Source snapshots fix bytes used by Bend. Verify originals again before publication.
    for (const input of [runtimeFile, ...graph.modules]) {
      if (sha(fs.readFileSync(input.path)) !== input.sha256) throw Error(`Input bytes changed during native graph run: ${input.path}`);
      unchanged(input);
    }
    if (result.status === 0 && !result.error) {
      const emitted = inspect(temporaryOutput, 'emitted output');
      destination(target, inputs);
      report.outputBytes = emitted.bytes; report.outputSha256 = sha(fs.readFileSync(temporaryOutput));
      fs.renameSync(temporaryOutput, target); report.published = true;
    }
    report.wallMs = performance.now() - started;
    return report;
  } catch (error) {
    if (!report) throw error;
    report.nativePhase = report.phase;
    report.phase = 'host'; report.error = error.message; report.publicationError = error.message;
    report.published = false; report.wallMs = performance.now() - started;
    try { const bytes = fs.readFileSync(temporaryOutput); report.unpublishedOutput = {bytes:bytes.length,sha256:sha(bytes)}; } catch {}
    return report;
  } finally { fs.rmSync(temporary, {recursive:true,force:true}); }
}
if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [binary,manifest,runtime,output,mode,...options] = process.argv.slice(2);
  if (![binary,manifest,runtime,output,mode].every(Boolean) || options.some(value => !/^--(?:cpu|timeout-ms)=\d+$/.test(value))) throw Error('usage: node native-graph-run.mjs BINARY MANIFEST.json RUNTIME.mjs OUTPUT.mjs program|library [--cpu=N] [--timeout-ms=N]');
  const value = key => options.find(option => option.startsWith(`--${key}=`))?.split('=')[1];
  const report = await runNativeGraph({binary,manifest,runtime,output,mode,cpu:value('cpu'),timeoutMs:Number(value('timeout-ms') ?? 120000)});
  console.log(JSON.stringify(report,null,2)); if (!report.published) process.exitCode = 1;
}
