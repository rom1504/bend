// Production-review candidate: restore evaluation order and trim unused helpers.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import crypto from 'node:crypto';
const [priorArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('usage: analysis-stable-overlay.mjs NEUTRAL_OVERLAY NEW_DIRECTORY');const prior=fs.realpathSync(priorArg),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});const sha=s=>crypto.createHash('sha256').update(s).digest('hex'),inputs={},outputs={};
for(const file of ['src/core/term.bend','src/check/kernel.bend','src/check/annotate.bend']){let s=fs.readFileSync(path.join(prior,file),'utf8');inputs[file]=sha(s);
 if(file==='src/core/term.bend'){
  const a=s.index('# Substitution is the identity only'),b=s.index('# A canonical App also');assert.ok(a>0&&b>a);s=s.slice(0,a)+s.slice(b);
  const old=`      kc(Bool, String.eq(tag, "Var"), u => False{},
        u => kc(Bool, String.eq(tag, "App"),
          u => kc(Bool, String.eq(name, "") && U32.is_eq(id, 0) && U32.is_eq(quant, 0), u => core_subst_stable_app(kids, removed), u => False{}),
          u => core_subst_stable_terms(kids)))`;
  const replacement=`      kc(Bool, String.eq(tag, "Var"), u => False{},
        u => kc(Bool, core_subst_stable_terms(kids),
          u => kc(Bool, String.eq(tag, "App"),
            u => kc(Bool, String.eq(name, "") && U32.is_eq(id, 0) && U32.is_eq(quant, 0), u => core_subst_stable_app(kids, removed), u => False{}),
            u => True{}),
          u => False{}))`;
  assert.ok(s.includes(old));s=s.replace(old,replacement).replace('kc(Bool, String.eq(tg(f), "Lam"), u => False{}, u => kc(Bool, core_subst_stable(f), u => core_subst_stable(x), u => False{}))','Bool.not(String.eq(tg(f), "Lam"))');
  s=s.replace('# A canonical App also survives', '# Scan in substitution order: Var test, children, then App rebuilding.\n# A false fact returns to ordinary substitution, preserving its work and errors.\n# A canonical App also survives');
 }else if(file==='src/check/annotate.bend'){
  s=s.replace('# Reuse a closed, App-free tail only while walking its literal All spine.', '# Reuse a closed tail with only inert canonical Apps along its literal All spine.');
  const old=`  kc(List<&2, KTerm>, String.eq(tg(tel), "All"),
    u => kc(List<&2, KTerm>, core_subst_stable(kid(tel, 1)),
      u => Con{annotate(e, ctx, h, kid(tel, 0)), ka_args_static(e, ctx, kid(tel, 1), rest)},
      u => ka_args_head(e, ctx, tel, h, rest)),
    u => ka_args_head(e, ctx, tel, h, rest))`;
  const replacement=`  kc(List<&2, KTerm>, String.eq(tg(tel), "All"),
    u => ka_args_after_head(e, ctx, tel, h, rest, annotate(e, ctx, h, kid(tel, 0))),
    u => ka_args_head(e, ctx, tel, h, rest))`;
  assert.ok(s.includes(old));s=s.replace(old,replacement);s+=`
law ka_args_after_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +annotated: KTerm
  List<&2, KTerm>

@unsafe
def ka_args_after_head(e, ctx, tel, h, rest, annotated):
  kc(List<&2, KTerm>, core_subst_stable(kid(tel, 1)),
    u => Con{annotated, ka_args_static(e, ctx, kid(tel, 1), rest)},
    u => Con{annotated, ka_args(e, ctx, subst(kid(tel, 1), ix(tel), h), rest)})
`;
 }else{
  const old=`  kc(KChecked, String.eq(tg(tel), "All"),
    u => kc(KChecked, core_subst_stable(kid(tel, 1)),
      u => tele_check_done(check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0)), tele_check_static(e, ctx, kid(tel, 1), rest, dem)),
      u => tele_check_legacy_head(e, ctx, tel, h, rest, dem)),
    u => bad("too many telescope arguments"))`;
  const replacement=`  kc(KChecked, String.eq(tg(tel), "All"),
    u => tele_check_after_head(e, ctx, tel, h, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0))),
    u => bad("too many telescope arguments"))`;
  assert.ok(s.includes(old));s=s.replace(old,replacement);s=s.replace('law tele_check_legacy:', '# A failed fact uses the original remaining traversal, avoiding repeated scans\n# of dependent tails. The public tele_check_head retains its existing behavior.\nlaw tele_check_legacy:');s+=`
law tele_check_after_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  for +checked_head: KChecked
  KChecked

@unsafe
def tele_check_after_head(e, ctx, tel, h, rest, dem, checked_head):
  kc(KChecked, core_subst_stable(kid(tel, 1)),
    u => tele_check_done(checked_head, tele_check_static(e, ctx, kid(tel, 1), rest, dem)),
    u => tele_check_done(checked_head, tele_check_legacy(e, ctx, subst(kid(tel, 1), ix(tel), h), rest, dem)))
`;
 }
 const target=path.join(out,file);fs.mkdirSync(path.dirname(target),{recursive:true});fs.writeFileSync(target,s);outputs[file]=sha(s);
}
fs.writeFileSync(path.join(out,'overlay.json'),JSON.stringify({kind:'phase4-ordered-stable-telescope-overlay',prior,inputs,outputs,toolSha256:sha(fs.readFileSync(import.meta.filename)),scope:'Head checked/annotated once before facts. Fact scans Var→children→App, conservatively falls back, and invalidates on non-All telescope heads.'},null,2)+'\n');
