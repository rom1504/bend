#!/usr/bin/env bun
// Pure preparation of the seal model; no compiler or runtime execution.
import {readFileSync, writeFileSync, mkdirSync, existsSync} from 'node:fs';
import {resolve, dirname, relative, sep} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
const method = fileURLToPath(import.meta.url), here = dirname(method);
const root = resolve(here, '../../../../../..');
const args = process.argv.slice(2);
if (args.length !== 2 || args[0] !== '--out') throw Error('usage: prepare.mjs --out NEW_PHASE110_DIR');
const out = resolve(root, args[1]);
if (!out.startsWith(resolve(root,'selfhost/build/phase110') + sep) || existsSync(out)) throw Error('fresh Phase110 output required');
const pin = path => {const bytes=readFileSync(path);return {file:relative(root,path),bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex')};};
const candidatePath = resolve(here,'candidate.bend'), lawPath = resolve(here,'laws.bend');
const candidate=readFileSync(candidatePath,'utf8'), laws=readFileSync(lawPath,'utf8');
if (/@unsafe|^law /m.test(candidate)) throw Error('expected law-free safe model');
const cases=[
 {id:'skip-initial-raw-seal',before:'case SealRaw{cid, location}: seal_wrap_raw(cid, location, state)',after:'case SealRaw{cid, location}: SealDone{SealRaw{cid, location}, state}',law:'raw_seal_allocates_one',witness:'Raw constructor remains unsealed and allocates no count-1 redirect.'},
 {id:'rewrap-existing-reference',before:'case SealRef{cid, cell}: SealDone{SealRef{cid, cell}, state}',after:'case SealRef{cid, cell}: seal_wrap_raw(cid, cell, state)',law:'stored_field_fixed_in_later_state',witness:'Resealing an existing reference changes the word and allocation ledger.'},
 {id:'omit-other-seal',before:'seal_rebuild_finish(retained, remaining, seal_word_operation(other, state))',after:'seal_rebuild_finish(retained, remaining, SealDone{other, state})',law:'retained_seal_omission_complete',witness:'The external other owner may be raw; dropping its seal changes the complete reconstructed result.'},
];
// The same expression occurs in the original continuation and optimized body.
// Scope this mutation to the final definition; retain the original protocol.
const omissionStart=candidate.indexOf('def seal_rebuild_omit(');
if(omissionStart<0)throw Error('missing optimized consumer');
for(const item of cases){const target=item.id==='omit-other-seal'?candidate.slice(omissionStart):candidate;if(target.split(item.before).length!==2)throw Error('mutation boundary changed: '+item.id);}
mkdirSync(out,{recursive:true});const files=[];
const write=(path,text)=>{writeFileSync(path,text);files.push(pin(path));};
function packageAt(name,text){const folder=resolve(out,name);mkdirSync(folder);write(resolve(folder,'candidate.bend'),text);write(resolve(folder,'laws.bend'),laws);return relative(root,folder);}
const baseline=packageAt('baseline',candidate);
for(const item of cases){const changed=item.id==='omit-other-seal'?candidate.slice(0,omissionStart)+candidate.slice(omissionStart).replace(item.before,item.after):candidate.replace(item.before,item.after);item.folder=packageAt(item.id,changed);}
const manifest={schema:'phase110-stored-field-seal-model-laws-v1',targetsRun:false,modelOnly:true,actualRuntimeCorrespondenceProved:false,
 method:pin(method),source:[pin(candidatePath)],frozenLaws:pin(lawPath),baseline,cases,files,lawCount:[...laws.matchAll(/^law /gm)].length,
 premise:'Retained word is produced by the modeled dynamic constructor writer seal. The later allocation state and incoming other owner are arbitrary.',
 modeledObservations:'Complete result word representations, count-1 wrapper allocation records, next allocation token, prior allocation ledger and remaining field.',
 connection:'Actual dynamic-writer closure and fixed-point correspondence are separate authenticated source/runtime obligations; this is not an extraction of C or generated Nx semantics.',
 exclusions:'No physical address/refcount validity, finite word/counter arithmetic, allocator correctness, failure, concurrency, source admission or whole-pass theorem.',
 negativeProtocol:'Admit each changed model alone, then require unchanged named laws to reject with expected/observed mismatch. Safe-law negatives remain frontend evidence.',
 checker:'selfhost/tools/laws/phase98/check.py'};
writeFileSync(resolve(out,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
console.log(JSON.stringify({out:relative(root,out),laws:manifest.lawCount,mutations:cases.length,targetsRun:false,modelOnly:true}));
