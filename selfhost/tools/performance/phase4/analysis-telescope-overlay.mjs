// Isolated pure-Bend constructor telescope experiment; production files untouched.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import crypto from 'node:crypto';
const [baseArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('usage: analysis-telescope-overlay.mjs FROZEN_BASELINE NEW_DIRECTORY');const base=fs.realpathSync(baseArg),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const inputs={},outputs={},sha=s=>crypto.createHash('sha256').update(s).digest('hex');
function edit(file,change){const source=fs.readFileSync(path.join(base,file),'utf8'),output=change(source),target=path.join(out,file);fs.mkdirSync(path.dirname(target),{recursive:true});fs.writeFileSync(target,output);inputs[file]=sha(source);outputs[file]=sha(output);}
edit('src/core/term.bend',s=>s+`
# Substitution is the identity only when no variable replacement or App rebuild
# can occur. This is a syntactic fact about exactly this immutable term.
law core_subst_static:
  for +t: KTerm
  Bool

law core_subst_static_terms:
  for +ts: List<&2, KTerm>
  Bool

@unsafe
def core_subst_static(t):
  match t:
    case KTerm{tag, name, id, quant, kids, removed}:
      kc(Bool, String.eq(tag, "Var"), u => False{}, u => kc(Bool, String.eq(tag, "App"), u => False{}, u => core_subst_static_terms(kids)))

@unsafe
def core_subst_static_terms(ts):
  match ts:
    case Nil{}: True{}
    case Con{h, rest}:
      kc(Bool, core_subst_static(h), u => core_subst_static_terms(rest), u => False{})
`);
edit('src/check/annotate.bend',s=>{
 const old='ka_args(e, ctx, tele_fill(cb(e), dt(lookup(dc(lookup(cb(e), nm(ty))), nm(t))), ks(ty)), ks(t))';assert.equal(s.split(old).length,2);s=s.replace(old,old.replace('ka_args(', 'ka_args_cached('));
 return s+`
# Reuse a closed, App-free tail only while walking its literal All spine.
# Ref/Ann/other heads restart analysis after ordinary weak-head normalization.
law ka_args_cached:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

law ka_args_cached_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  List<&2, KTerm>

law ka_args_static:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +xs: List<&2, KTerm>
  List<&2, KTerm>

@unsafe
def ka_args_cached(e, ctx, tel, xs):
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}:
      ka_args_cached_head(e, ctx, wnf(cb(e), tel), h, rest)

@unsafe
def ka_args_cached_head(e, ctx, tel, h, rest):
  kc(List<&2, KTerm>, String.eq(tg(tel), "All"),
    u => kc(List<&2, KTerm>, core_subst_static(kid(tel, 1)),
      u => Con{annotate(e, ctx, h, kid(tel, 0)), ka_args_static(e, ctx, kid(tel, 1), rest)},
      u => ka_args_head(e, ctx, tel, h, rest)),
    u => ka_args_head(e, ctx, tel, h, rest))

@unsafe
def ka_args_static(e, ctx, tel, xs):
  match xs:
    case Nil{}: Nil{}
    case Con{h, rest}:
      kc(List<&2, KTerm>, String.eq(tg(tel), "All"),
        u => Con{annotate(e, ctx, h, kid(tel, 0)), ka_args_static(e, ctx, kid(tel, 1), rest)},
        u => ka_args_cached(e, ctx, tel, xs))
`;
});
edit('src/check/kernel.bend',s=>{
 const old='tele_check_head(e, ctx, wnf(cb(e), tel), h, t, dem)';assert.equal(s.split(old).length,2);s=s.replace(old,'tele_check_cached_head(e, ctx, wnf(cb(e), tel), h, t, dem)');
 return s+`
law tele_check_cached_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  KChecked

law tele_check_static:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  for +dem: U32
  KChecked

law tele_check_legacy:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +args: List<&2, KTerm>
  for +dem: U32
  KChecked

law tele_check_legacy_head:
  for +e: KEnv
  for +ctx: List<&2, KTerm>
  for +tel: KTerm
  for +h: KTerm
  for +rest: List<&2, KTerm>
  for +dem: U32
  KChecked

@unsafe
def tele_check_cached_head(e, ctx, tel, h, rest, dem):
  kc(KChecked, String.eq(tg(tel), "All"),
    u => kc(KChecked, core_subst_static(kid(tel, 1)),
      u => tele_check_done(check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0)), tele_check_static(e, ctx, kid(tel, 1), rest, dem)),
      u => tele_check_legacy_head(e, ctx, tel, h, rest, dem)),
    u => bad("too many telescope arguments"))

@unsafe
def tele_check_static(e, ctx, tel, args, dem):
  match args:
    case Nil{}: ok(atom("Args"), tel, Nil{})
    case Con{h, rest}:
      kc(KChecked, String.eq(tg(tel), "All"),
        u => tele_check_done(check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0)), tele_check_static(e, ctx, kid(tel, 1), rest, dem)),
        u => tele_check(e, ctx, tel, args, dem))

@unsafe
def tele_check_legacy(e, ctx, tel, args, dem):
  match args:
    case Nil{}: ok(atom("Args"), tel, Nil{})
    case Con{h, rest}:
      tele_check_legacy_head(e, ctx, wnf(cb(e), tel), h, rest, dem)

@unsafe
def tele_check_legacy_head(e, ctx, tel, h, rest, dem):
  kc(KChecked, String.eq(tg(tel), "All"), u => tele_check_done(check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0)), tele_check_legacy(e, ctx, subst(kid(tel, 1), ix(tel), h), rest, dem)), u => bad("too many telescope arguments"))
`;
});
fs.writeFileSync(path.join(out,'overlay.json'),JSON.stringify({kind:'phase4-closed-constructor-telescope-overlay',baseline:base,inputs,outputs,toolSha256:sha(fs.readFileSync(import.meta.filename)),scope:'Isolated candidate only; unchanged fallback for dependent/App-containing tails; invalidate at every non-All head.'},null,2)+'\n');
