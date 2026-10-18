#!/usr/bin/env bun
// Pure preparation. The coordinator owns every compiler/proof/runtime target.
import {readFileSync, writeFileSync, mkdirSync, existsSync} from 'node:fs';
import {resolve, dirname, relative, sep} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
const method=fileURLToPath(import.meta.url), here=dirname(method);
const root=resolve(here,'../../../../../..'), args=process.argv.slice(2);
if(args.length!==2||args[0]!=='--out')throw Error('usage: prepare.mjs --out NEW_PHASE110_DIR');
const out=resolve(root,args[1]);
if(!out.startsWith(resolve(root,'selfhost/build/phase110')+sep)||existsSync(out))throw Error('fresh Phase110 output required');
const pin=path=>{const bytes=readFileSync(path);return{file:relative(root,path),bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex')};};
const source=['candidate.bend','reference.bend','laws.bend'].map(name=>resolve(here,name));
const [candidate,reference,laws]=source.map(path=>readFileSync(path,'utf8'));
if(/@unsafe|^law /m.test(candidate)||/@unsafe|^law /m.test(reference))throw Error('safe law-free models required');
const stored='SpareDone{cid, target, cell, 1n, 0n, retained, remaining, frame, SpareEmpty{}}';
const cases=[
 {id:'steal-shared-wrapper',before:'case SpareSharedDynamic{cell, extra}: SpareEmpty{}',after:'case SpareSharedDynamic{cell, extra}: SpareHeld{cell}',law:'shared_parent_cannot_reserve',witness:'A parent with at least one other owner is incorrectly exposed as an exclusive spare.'},
 {id:'steal-static-wrapper',before:'case SpareStaticShell{redirected, cell}: SpareEmpty{}',after:'case SpareStaticShell{redirected, cell}: SpareHeld{cell}',law:'static_parent_cannot_reserve',witness:'A static parent or redirect to static storage incorrectly enters the dynamic wrapper path.'},
 {id:'extra-incoming-credit',before:stored,after:stored.replace('cell, 1n, 0n','cell, 2n, 0n'),law:'transferred_wrapper_has_one_owner',witness:'Transferred incoming redirect is initialized with count 2 instead of count 1.'},
 {id:'wrong-incoming-target',before:stored,after:stored.replace('cid, target, cell','cid, 1n+target, cell'),law:'spare_transfer_complete',witness:'New reference decodes to a different incoming value location.'},
 {id:'old-parent-credit-survives',before:stored,after:stored.replace('cell, 1n, 0n','cell, 1n, 1n'),law:'spare_transfer_complete',witness:'The consumed parent wrapper erroneously retains one live ownership credit.'},
 {id:'spare-not-cleared',before:'case SpareHeld{cell}:\n      '+stored,after:'case SpareHeld{+cell}:\n      '+stored.replace('frame, SpareEmpty{}','frame, SpareHeld{cell}'),law:'spare_transfer_complete',witness:'The result leaves the consumed token available for a second store; +cell only makes that semantic bug welltyped.'},
];
for(const item of cases)if(candidate.split(item.before).length!==2)throw Error('mutation boundary changed: '+item.id);
mkdirSync(out,{recursive:true});const files=[];
const write=(path,text)=>{writeFileSync(path,text);files.push(pin(path));};
function packageAt(name,text){const folder=resolve(out,name);mkdirSync(folder);write(resolve(folder,'candidate.bend'),text);write(resolve(folder,'reference.bend'),reference);write(resolve(folder,'laws.bend'),laws);return relative(root,folder);}
const baseline=packageAt('baseline',candidate);
for(const item of cases){const changed=candidate.replace(item.before,item.after);if(changed.replace(item.after,item.before)!==candidate)throw Error('inverse failed: '+item.id);item.folder=packageAt(item.id,changed);}
const manifest={schema:'phase110-wrapper-spare-model-laws-v1',targetsRun:false,modelOnly:true,actualRuntimeCorrespondenceProved:false,
 method:pin(method),source:source.slice(0,2).map(pin),frozenLaws:pin(source[2]),baseline,cases,files,lawCount:[...laws.matchAll(/^law /gm)].length,
 premise:'Parent is an exclusive last-owner redirect to an admitted dynamic shell; incoming is a raw constructor. The owned spare resource is disjoint from external ownership records. Arbitrary fresh reference address belongs to the same abstract resource class.',
 modeledObservations:'Incoming constructor metadata and target, incoming owner count, consumed-parent owner count, exact retained and remaining owners, arbitrary external ownership frame, and residual spare token. Only the newly live wrapper address is projected away.',
 connection:'Model-only ownership-resource transition. Actual physical exclusivity/classification, legal writer closure, word packing and allocator/free-list effects require separate authenticated source/runtime evidence.',
 exclusions:'No physical address validity/freshness theorem, heap equality, allocation/free-list equality, bounded counter arithmetic, failure or concurrency theorem. The retained-head seal is unchanged; stored-field seal omission is a distinct package.',
 negativeProtocol:'Admit each changed law-free model first, then require unchanged named laws to reject with expected/observed mismatch. Safe-law negatives remain frontend evidence.',
 checker:'selfhost/tools/laws/phase98/check.py'};
writeFileSync(resolve(out,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
console.log(JSON.stringify({out:relative(root,out),laws:manifest.lawCount,mutations:cases.length,targetsRun:false,modelOnly:true}));
