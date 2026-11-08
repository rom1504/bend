#!/usr/bin/env bun
// Source acceptance only. No compiler backend, generated program, or IO effect runs.
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {pin, verify, requireThat as need, workspace} from '../../tools/build/hosted.mjs';
import {readBootstrapConfig, bootstrapConfigPath} from '../../tools/bootstrap-config.mjs';

const args = {};
for (let i = 2; i < process.argv.length; i += 2) {
  const key = process.argv[i], value = process.argv[i + 1];
  need(['--out', '--upstream', '--manifest', '--assets'].includes(key) && value && !Object.hasOwn(args, key), 'Unknown, incomplete, or duplicate option: ' + key);
  args[key] = value;
}
need(args['--out'], '--out required');
const own = fileURLToPath(import.meta.url);
const root = path.join(path.dirname(own), 'native');
const names = fs.readdirSync(root, {withFileTypes: true})
  .filter(entry => entry.isFile() && entry.name.endsWith('.bend')).map(entry => entry.name).sort();
need(names.length > 0, 'No top-level native controls');
const cases = names.map(name => ({name, input: pin(path.join(root, name))}));
const selection = readBootstrapConfig({manifest: args['--manifest'], upstream: args['--upstream']});
const upstream = fs.realpathSync(selection.upstream);
const revision = '9a4223d577ba56a0cb53d1fd952d2b481c38930f';
const head = spawnSync('git', ['-C', upstream, 'rev-parse', 'HEAD'], {encoding: 'utf8'});
const clean = spawnSync('git', ['-C', upstream, 'diff', '--quiet', 'HEAD', '--', 'bend2']);
need(selection.revision === revision && head.status === 0 && head.stdout.trim() === revision && clean.status === 0, 'Expected unmodified Phase182 upstream');
const assetsFile = path.resolve(args['--assets'] ?? path.join(workspace, 'selfhost/manifests/assets-native.json'));
const assets = JSON.parse(fs.readFileSync(assetsFile, 'utf8'));
const engine = pin(process.execPath), expectedEngine = assets.assets.bun;
need(engine.bytes === expectedEngine.bytes && engine.sha256 === expectedEngine.sha256, 'Expected pinned Bun engine');
const language = pin(path.join(upstream, 'bend2/bend.ts')), base = pin(path.join(upstream, 'bend2/base.bend'));
const inputs = [pin(own), pin(bootstrapConfigPath), pin(path.join(workspace, 'selfhost/tools/build/hosted.mjs')),
  pin(selection.manifest), pin(assetsFile), engine, language, base, ...cases.map(entry => entry.input)];
inputs.forEach(verify);
const out = path.resolve(args['--out']);
need(out.startsWith(workspace + '/selfhost/build/') && !fs.existsSync(out), 'Fresh selfhost/build output required');
fs.mkdirSync(out, {recursive: true});
const report = {kind: 'phase182-native-source-preflight', version: 1, complete: false, pass: false,
  upstream: revision, inputs, rows: [], kernelChecked: false, emittedCode: false, executedCandidate: false,
  scope: 'Unmodified upstream book_load + book_valid + zero holes for top-level native/*.bend only. Rejected fixtures are excluded. Expected runtime output and exit markers are not evaluated.'};
const save = () => fs.writeFileSync(path.join(out, 'report.json'), JSON.stringify(report, null, 2) + '\n');
const start = performance.now();
save();
try {
  for (const key of Object.keys(process.env)) if (key.startsWith('BEND_')) delete process.env[key];
  const B = await import(pathToFileURL(language.file));
  need(fs.realpathSync(B.BASE_BEND) === base.file, 'Upstream Base identity differs');
  for (const entry of cases) {
    report.active = entry.name;
    save();
    const book = B.book_nil(), seen = new Map();
    const row = {...entry, classification: 'crash', phase: 'load', holes: null};
    const begin = performance.now();
    try {
      await B.book_load(book, entry.input.file, '', seen);
      row.phase = 'check';
      B.book_valid(book);
      need(Number.isSafeInteger(book.hols) && book.hols >= 0, 'Invalid checked-book hole count');
      row.holes = book.hols;
      row.classification = book.hols === 0 ? 'accepted' : 'refused';
      if (book.hols !== 0) row.diagnostic = 'Unresolved laws/holes: ' + book.hols;
    } catch (error) {
      row.classification = error?.$ === 'Err' ? 'refused' : 'crash';
      row.diagnostic = error?.$ === 'Err' ? B.err_show(error) : String(error?.stack ?? error);
    }
    row.loadedSources = [...seen.keys()].map(pin);
    need(row.loadedSources.every(file => [entry.input, base].some(p => p.file === file.file && p.sha256 === file.sha256)), 'Unexpected source import closure');
    row.seconds = (performance.now() - begin) / 1000;
    report.rows.push(row);
    save();
  }
  inputs.forEach(verify);
  report.complete = true;
  report.pass = report.rows.every(row => row.classification === 'accepted');
  delete report.active;
} catch (error) {
  report.error = String(error?.stack ?? error);
} finally {
  report.changedInputs = [];
  for (const input of inputs) try { verify(input); } catch { report.changedInputs.push(input); }
  if (report.changedInputs.length) { report.complete = false; report.pass = false; }
  report.seconds = (performance.now() - start) / 1000;
  save();
  if (!report.pass) process.exitCode = 1;
  console.log(JSON.stringify({complete: report.complete, pass: report.pass, cases: report.rows.length,
    accepted: report.rows.filter(row => row.classification === 'accepted').length, report: path.join(out, 'report.json')}));
}
