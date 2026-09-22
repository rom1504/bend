// Refine the isolated telescope fact to permit structurally inert canonical Apps.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import crypto from 'node:crypto';
const [priorArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('usage: analysis-neutral-overlay.mjs PRIOR_TELESCOPE_OVERLAY NEW_DIRECTORY');const prior=fs.realpathSync(priorArg),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});const sha=s=>crypto.createHash('sha256').update(s).digest('hex'),inputs={},outputs={};
for(const file of ['src/core/term.bend','src/check/kernel.bend','src/check/annotate.bend']){let source=fs.readFileSync(path.join(prior,file),'utf8');inputs[file]=sha(source);if(file==='src/core/term.bend')source+=`
# A canonical App also survives substitution unchanged if both children do and
# its unchanged function is not Lam. Every metadata/arity check is necessary
# because core_rebuild canonicalizes App nodes even without beta reduction.
law core_subst_stable:
  for +t: KTerm
  Bool

law core_subst_stable_terms:
  for +ts: List<&2, KTerm>
  Bool

law core_subst_stable_app:
  for +kids: List<&2, KTerm>
  for +removed: List<&2, String>
  Bool

@unsafe
def core_subst_stable(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      kc(Bool, String.eq(tag, "Var"), u => False{},
        u => kc(Bool, String.eq(tag, "App"),
          u => kc(Bool, String.eq(name, "") && U32.is_eq(id, 0) && U32.is_eq(quant, 0), u => core_subst_stable_app(kids, removed), u => False{}),
          u => core_subst_stable_terms(kids)))

@unsafe
def core_subst_stable_terms(ts):
  match ts:
    case Nil{}: True{}
    case Con{h, rest}:
      kc(Bool, core_subst_stable(h), u => core_subst_stable_terms(rest), u => False{})

law core_subst_stable_app_kids:
  for +kids: List<&2, KTerm>
  Bool

law core_subst_stable_app_tail:
  for +f: KTerm
  for +tail: List<&2, KTerm>
  Bool

law core_subst_stable_app_last:
  for +f: KTerm
  for +x: KTerm
  for +rest: List<&2, KTerm>
  Bool

@unsafe
def core_subst_stable_app(kids, removed):
  match removed:
    case Con{h, rest}: False{}
    case Nil{}: core_subst_stable_app_kids(kids)

@unsafe
def core_subst_stable_app_kids(kids):
  match kids:
    case Nil{}: False{}
    case Con{f, tail}: core_subst_stable_app_tail(f, tail)

@unsafe
def core_subst_stable_app_tail(f, tail):
  match tail:
    case Nil{}: False{}
    case Con{x, rest}: core_subst_stable_app_last(f, x, rest)

@unsafe
def core_subst_stable_app_last(f, x, rest):
  match rest:
    case Con{h, tail}: False{}
    case Nil{}:
      kc(Bool, String.eq(tg(f), "Lam"), u => False{}, u => kc(Bool, core_subst_stable(f), u => core_subst_stable(x), u => False{}))

`;else{assert.ok(source.includes('core_subst_static(kid(tel, 1))'));source=source.replaceAll('core_subst_static(kid(tel, 1))','core_subst_stable(kid(tel, 1))');}const target=path.join(out,file);fs.mkdirSync(path.dirname(target),{recursive:true});fs.writeFileSync(target,source);outputs[file]=sha(source);}
fs.writeFileSync(path.join(out,'overlay.json'),JSON.stringify({kind:'phase4-neutral-App-telescope-overlay',prior,inputs,outputs,toolSha256:sha(fs.readFileSync(import.meta.filename)),scope:'Isolated refinement only. Vars, beta Apps and noncanonical Apps remain on legacy substitution; normalized non-All telescope heads invalidate facts.'},null,2)+'\n');
