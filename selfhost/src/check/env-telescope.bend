import Base

# Private first-order telescope cursor. Bindings are newest first; forcing
# applies ordinary substitution oldest first. Public KTerm representation stays
# unchanged. Admission excludes beta work, so a failed earlier argument cannot
# bypass eager beta normalization that the original traversal would perform.
type KTelescopeBinding is Data:
  KTelescopeBinding{+id: U32, +value: KTerm}

law env_tele_safe_terms:
  for +ts: List<&2,KTerm>
  Bool

@unsafe
def env_tele_safe(+t: KTerm) -> Bool:
  kc(Bool, core_literal(t) || String.eq(tg(t), "Var"), u => True{},
    u => kc(Bool, env_tele_safe_terms(ks(t)),
      u => kc(Bool, String.eq(tg(t), "App"),
        u => String.eq(nm(t), "") && U32.is_eq(ix(t), 0) && U32.is_eq(qt(t), 0) && core_subst_stable_app(ks(t), rm(t)) && Bool.not(String.eq(tg(kid(t, 0)), "Var")),
        u => True{}), u => False{}))

@unsafe
def env_tele_safe_terms(ts):
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: kc(Bool, env_tele_safe(h), u => env_tele_safe_terms(rest), u => False{})

@unsafe
def env_tele_apply_binding(+t: KTerm, +binding: KTelescopeBinding) -> KTerm:
  match binding:
    case KTelescopeBinding{id, value}: subst(t, id, value)

@unsafe
def env_tele_apply(+t: KTerm, +bindings: List<&2,KTelescopeBinding>) -> KTerm:
  env_subst_apply(t, bindings)

@unsafe
def env_tele_many(+args: List<&2,KTerm>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{h, rest}: Bool.not(List.is_empty(&2, KTerm, rest))

law env_tele_fill_loop:
  for +book: List<&2,KDef>
  for +tel: KTerm
  for +args: List<&2,KTerm>
  for +bindings: List<&2,KTelescopeBinding>
  for +count: U32
  KTerm

law env_tele_fill_eager:
  for +book: List<&2,KDef>
  for +tel: KTerm
  for +args: List<&2,KTerm>
  KTerm

@unsafe
def env_tele_fill(+book: List<&2,KDef>, +tel: KTerm, +args: List<&2,KTerm>) -> KTerm:
  kc(KTerm, env_tele_many(args),
    u => kc(KTerm, env_tele_safe(tel), u => env_tele_fill_loop(book, tel, args, Nil{}, 0), u => env_tele_fill_eager(book, tel, args)),
    u => env_tele_fill_eager(book, tel, args))

@unsafe
def env_tele_fill_eager_head(+book: List<&2,KDef>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  kc(KTerm, String.eq(tg(tel), "All"), u => env_tele_fill_eager(book, subst(kid(tel, 1), ix(tel), h), rest), u => atom("Error"))

@unsafe
def env_tele_fill_eager(book, tel, args):
  match args:
    case Nil{}: tel
    case Con{h, rest}: env_tele_fill_eager_head(book, wnf(book, tel), h, rest)

@unsafe
def env_tele_fill_open(+book: List<&2,KDef>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>) -> KTerm:
  kc(KTerm, String.eq(tg(tel), "All"),
    u => kc(KTerm, env_tele_safe(tel),
      u => env_tele_fill_loop(book, kid(tel, 1), rest, [KTelescopeBinding{ix(tel), h}], 1),
      u => env_tele_fill_eager_head(book, tel, h, rest)),
    u => atom("Error"))

@unsafe
def env_tele_fill_loop(book, tel, args, bindings, count):
  match args:
    case Nil{}: env_tele_apply(tel, bindings)
    case Con{h, rest}:
      kc(KTerm, env_tele_safe(h),
        u => kc(KTerm, String.eq(tg(tel), "All") && U32.is_lt(count, 64),
          u => env_tele_fill_loop(book, kid(tel, 1), rest, Con{KTelescopeBinding{ix(tel), h}, bindings}, U32.add(count, 1)),
          u => env_tele_fill_open(book, wnf(book, env_tele_apply(tel, bindings)), h, rest)),
        u => env_tele_fill_eager(book, env_tele_apply(tel, bindings), args))

law env_tele_check_loop:
  for +e: KEnv
  for +ctx: List<&2,KTerm>
  for +tel: KTerm
  for +args: List<&2,KTerm>
  for +dem: U32
  for +bindings: List<&2,KTelescopeBinding>
  for +count: U32
  KChecking

@unsafe
def env_tele_check(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +args: List<&2,KTerm>, +dem: U32) -> KChecking:
  kc(KChecking, env_tele_many(args),
    u => kc(KChecking, env_tele_safe(tel), u => env_tele_check_loop(e, ctx, tel, args, dem, Nil{}, 0), u => tele_check_legacy(e, ctx, tel, args, dem)),
    u => tele_check_legacy(e, ctx, tel, args, dem))

@unsafe
def env_tele_check_after(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32, +bindings: List<&2,KTelescopeBinding>, +count: U32, +r: KChecking) -> KChecking:
  kc(KChecking, good(r),
    u => tele_check_done(r, env_tele_check_loop(ke_world(e, rw(r)), ctx, kid(tel, 1), rest, dem, Con{KTelescopeBinding{ix(tel), h}, bindings}, U32.add(count, 1))),
    u => r)

@unsafe
def env_tele_check_head(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32, +bindings: List<&2,KTelescopeBinding>, +count: U32) -> KChecking:
  env_tele_check_after(e, ctx, tel, h, rest, dem, bindings, count, check(e, ctx, h, qdem(qt(tel), dem), env_tele_apply(kid(tel, 0), bindings)))

@unsafe
def env_tele_check_open(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2,KTerm>, +dem: U32) -> KChecking:
  kc(KChecking, String.eq(tg(tel), "All"),
    u => kc(KChecking, env_tele_safe(tel),
      u => env_tele_check_head(e, ctx, tel, h, rest, dem, Nil{}, 0),
      u => tele_check_legacy_head(e, ctx, tel, h, rest, dem)),
    u => bad(cw(e), "too many telescope arguments"))

@unsafe
def env_tele_check_loop(e, ctx, tel, args, dem, bindings, count):
  match args:
    case Nil{}: ok(cw(e), atom("Args"), env_tele_apply(tel, bindings), Nil{})
    case Con{h, rest}:
      kc(KChecking, env_tele_safe(h),
        u => kc(KChecking, String.eq(tg(tel), "All") && U32.is_lt(count, 64),
          u => env_tele_check_head(e, ctx, tel, h, rest, dem, bindings, count),
          u => env_tele_check_open(e, ctx, wnf(cb(e), env_tele_apply(tel, bindings)), h, rest, dem)),
        u => tele_check_legacy(e, ctx, env_tele_apply(tel, bindings), args, dem))
