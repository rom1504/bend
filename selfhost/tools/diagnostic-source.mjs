#!/usr/bin/env node
// Optional diagnostic instrumentation: never edits kernel.bend or compiler.json.
// The existing checking operations and rejection strings remain authoritative.
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'..');
const args=process.argv.slice(2);
const output=path.resolve(args.find(x=>!x.startsWith('--'))||path.join(root,'build/diagnostic/compiler.bend'));
fs.mkdirSync(path.dirname(output),{recursive:true});
const modules=['src/core/term.bend','src/core/index.bend','src/core/normalize.bend','src/core/graph.bend','src/core/pretty.bend','src/check/quantity.bend','src/check/kernel.bend','src/check/prefix.bend','src/diagnostic/model.bend','src/diagnostic/render.bend','src/diagnostic/trace.bend','src/diagnostic/produce.bend'];
if(args.includes('--frontend')) modules.push(...JSON.parse(fs.readFileSync(path.join(root,'src/compiler.json'),'utf8')).modules.filter(x=>x.startsWith('src/front/')||x.startsWith('src/load/')),'src/diagnostic/frontend.bend');
execFileSync(process.execPath,[path.join(root,'tools/assemble.mjs'),'--output',output,...modules],{stdio:'inherit'});
let source=fs.readFileSync(output,'utf8');
const edits=[
 ['infer_node(e, ctx, core_beta(t), dem, sp)','dg_trace(e, ctx, t, atom("Absent"), infer_node(e, ctx, core_beta(t), dem, sp))'],
 ['check_node(e, ctx, core_beta(t), dem, ty)','dg_trace(e, ctx, t, ty, check_node(e, ctx, core_beta(t), dem, ty))'],
 ['bad("type mismatch")','dg_bad_detail("type mismatch", ty, cy(r))'],
 ['bad("reflexivity endpoints differ")','dg_bad_detail("reflexivity endpoints differ", kid(ty, 0), kid(ty, 1))'],
 ['bad("application requires a function type")','dg_bad_detail("application requires a function type", dg_text("a function type"), cy(r))'],
 ['bad("affine variable consumed more than allowed")','dg_quant_error("affine variable consumed more than allowed", nm(t), q, uses_get(cs(r), ix(t)))'],
 ['bad("let binder consumed more than allowed")','dg_quant_error("let binder consumed more than allowed", nm(h), qt(h), uses_get(cs(r), ix(h)))'],
 ['bad("erased scrutinee in live match")','dg_bad_message("erased scrutinee in live match", dg_text("a live scrutinee (a - scrutinee matches only in a dead region)"))'],
 ['bad("match scrutinee requires a datatype")','dg_bad_detail("match scrutinee requires a datatype", dg_text("a datatype"), kid(ty, 0))'],
 ['bad("unknown or duplicate match constructor")','dg_bad_detail("unknown or duplicate match constructor", dg_text("a constructor of " ++ nm(a) ++ " (missing, or already matched)"), t)'],
 ['bad("nonexhaustive match")','dg_bad_detail("nonexhaustive match", dg_text("cases for " ++ dg_constructor_names(remaining(dc(lookup(cb(e), nm(a))), rm(a)))), t)'],
 ['bad("rewrite requires equality evidence")','dg_bad_detail("rewrite requires equality evidence", dg_text("an equation {a == b : T}"), cy(r))'],
 ['bad("rewrite motive does not fit goal")','dg_bad_detail("rewrite motive does not fit goal", ty, kapply(kapply(kid(t, 1), kid(eq, 1)), kid(t, 0)))'],
 ['bad("constructor does not belong to goal or field count differs")','dg_ctor_error(e, t, ty, ctr)'],
 ['bad("unknown family or wrong parameter count")','dg_bad_detail("unknown family or wrong parameter count", dg_text(kc(String, String.eq(dk(d), "ADT"), u => nm(t) ++ " with " ++ U32.show(da(d)) ++ kc(String, U32.is_eq(da(d), 1), u => " parameter", u => " parameters"), u => "a datatype")), t)'],
];
for(const [before,after] of edits){if(source.includes(after))continue;const count=source.split(before).length-1;if(count!==1)throw Error(`Diagnostic patch expected one occurrence (${count}): ${before}`);source=source.replace(before,after);}
fs.writeFileSync(output,source);
const originalKernel=fs.readFileSync(path.join(root,'src/check/kernel.bend'),'utf8');
let patchedKernel=originalKernel;for(const [before,after] of edits)if(!patchedKernel.includes(after))patchedKernel=patchedKernel.replace(before,after);
const originalPath=path.join(path.dirname(output),'kernel-original.bend'),patchedPath=path.join(path.dirname(output),'kernel-diagnostic.bend');
fs.writeFileSync(originalPath,originalKernel);fs.writeFileSync(patchedPath,patchedKernel);
let patch;try{patch=execFileSync('diff',['-u','--label','a/src/check/kernel.bend','--label','b/src/check/kernel.bend',originalPath,patchedPath],{encoding:'utf8'});}catch(e){if(e.status!==1)throw e;patch=e.stdout;}
if(patch)fs.writeFileSync(path.join(root,'src/diagnostic/kernel-instrumentation.patch'),patch);
console.log(JSON.stringify({output,instrumentedSites:edits.length,sourceFilesEdited:false}));
