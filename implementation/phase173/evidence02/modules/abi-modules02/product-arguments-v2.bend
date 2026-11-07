# Phase173 private ABI bridge revision2: a checked finite product may arrive boxed at a
# flat-worker argument boundary. Consume its OWNED shell using the established
# take primitive, then pass the resulting owned fields through the existing ABI.
# This introduces no borrowed projection, new runtime operation or verifier rule.

law p173ab_binding_count:
  for +id: U32
  for +env: List<&2,NC_Binding>
  U32

law p173ab_vars:
  for +terms: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  Bool

law p173ab_word_count:
  for +word: String
  for +env: List<&2,NC_Binding>
  U32

law p173ab_shape:
  for +shape: KTerm
  Bool

law p173ab_fit:
  for +shapes: List<&2,KTerm>
  for +args: List<&2,KTerm>
  for +all: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  Bool

law p173ab_fresh_word:
  for +word: String
  for +n: U32
  for +count: U32
  Bool

law p173ab_fresh_env:
  for +env: List<&2,NC_Binding>
  for +n: U32
  for +count: U32
  Bool

law p173ab_allowed:
  for +info: KDef
  for +args: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +n: U32
  Bool

law p173ab_original:
  for +book: List<&2,KDef>
  for +name: String
  for +args: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +target: P113PTarget
  for +n: U32
  P113DCode

law p173ab_bad_tag:
  for +target: P113PTarget
  for +n: U32
  P113DCode

law p173ab_lower:
  for +shapes: List<&2,KTerm>
  for +args: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +words: List<&2,N111Value>
  for +info: KDef
  for +target: P113PTarget
  for +n: U32
  P113DCode

law p173ab_take:
  for +shape: KTerm
  for +arg: KTerm
  for +shapes: List<&2,KTerm>
  for +args: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +words: List<&2,N111Value>
  for +info: KDef
  for +target: P113PTarget
  for +n: U32
  P113DCode

@unsafe
def p173ab_binding_count(id,env):
  match env:
    case Nil{}: 0
    case Con{NC_Binding{+at,+word,+kind},+rest}:
      U32.min(2,U32.add(nt_bool(U32.is_eq(at,id)),p173ab_binding_count(id,rest)))

@unsafe
def p173ab_word_count(word,env):
  match env:
    case Nil{}: 0
    case Con{NC_Binding{+at,+name,+kind},+rest}:
      U32.min(2,U32.add(nt_bool(String.eq(name,word)),p173ab_word_count(word,rest)))

# All already-sequenced argument leaves must have an actual owned/scalar slot.
# The source sequencing stage gives repeated source values separate argument IDs
# and inserts its normal keep operations before reaching this bridge.
@unsafe
def p173ab_vars(terms,env):
  match terms:
    case Nil{}: True{}
    case Con{+term,+rest}:
      String.eq(tg(term),"Var") && U32.is_eq(p173ab_binding_count(ix(term),env),1) && p173ab_vars(rest,env)

@unsafe
def p173ab_shape(shape):
  p113p_known(shape) && U32.is_eq(p111_special(nm(shape)),0) &&
    Bool.not(String.eq(nm(shape),"Emit") || String.eq(nm(shape),"Halt") || String.eq(nm(shape),"Word"))

@unsafe
def p173ab_fit(shapes,args,all,env):
  match shapes args:
    case Nil{} Nil{}: True{}
    case Con{+shape,+rest} Con{+arg,+more}:
      nt_choose(Bool,p113p_known(shape),
        u => nt_choose(Bool,String.eq(tg(arg),"NQBundle"),
          v => String.eq(nm(arg),nm(shape)) && U32.is_eq(terms_len(ks(arg)),ix(shape)) && p173ab_vars(ks(arg),env),
          v => p173ab_shape(shape) && p173ab_vars([arg],env) && U32.is_eq(nq_uses_list(all,ix(arg)),1) &&
            U32.is_eq(p173ab_word_count(nc_word(ix(arg),env),env),1) && Bool.not(p112to_nonowning(nk_kind(ix(arg),env)))),
        u => String.eq(tg(shape),"Absent") && p173ab_vars([arg],env)) && p173ab_fit(rest,more,all,env)
    case _ _: False{}

# Refuse both semantic-ID and emitted-local-name collisions. The whole bridge
# reserves at most the already-supported 32-word product-call ABI.
@unsafe
def p173ab_fresh_word(word,n,count):
  nt_choose(Bool,U32.is_eq(count,0),u => True{},u =>
    Bool.not(String.eq(word,"v_" ++ U32.show(nc_id(n)))) && p173ab_fresh_word(word,U32.inc(n),U32.sub(count,1)))

@unsafe
def p173ab_fresh_env(env,n,count):
  match env:
    case Nil{}: True{}
    case Con{NC_Binding{+id,+word,+kind},+rest}:
      (U32.is_lt(id,nc_id(U32.add(n,U32.sub(count,1)))) || U32.is_gt(id,nc_id(n))) &&
        p173ab_fresh_word(word,n,count) && p173ab_fresh_env(rest,n,count)

@unsafe
def p173ab_allowed(info,args,env,n):
  +shapes = ks(dv(info))
  +count = nq_shape_words(shapes)
  String.eq(tg(dv(info)),"NQSig") && p113p_shapes_valid(shapes) &&
    U32.is_gt(count,0) && U32.is_le(count,32) && U32.is_le(n,4294967262) &&
    p173ab_fit(shapes,args,args,env) &&
    p112m_fresh_terms(args,nc_id(U32.add(n,U32.sub(count,1))),nc_id(n)) &&
    p173ab_fresh_env(env,n,count)

# Unchanged pre-experiment route. Unsupported shapes, unknown signatures,
# duplicate tokens and unsafe fresh ranges retain the original fallback.
@unsafe
def p173ab_original(book,name,args,env,target,n):
  +info = lookup(p113pl_signatures(target),name)
  nt_choose(P113DCode,String.eq(tg(dv(info)),"NQSig") && nq_args_fit(ks(dv(info)),args),
    u => p113pl_call_result(nm(dv(info)),p113p_words(ks(dv(info)),args,env),dt(info),target,n),
    u => nt_choose(P113DCode,nq_has_bundle(args),
      v => p113pl_lower(book,nq_opaque_args("NPCall",name,args,[],n),env,target,U32.add(n,terms_len(args))),
      v => p113pl_call_result(p113d_public(book,name),p111_values(args,env),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},target,n)))

# A checked singleton product cannot have a different constructor. Keep an
# explicit runtime guard and the same impossible-match error as existing Efq.
# This is not a promise about ill-typed values manufactured by unsafe FFI.
@unsafe
def p173ab_bad_tag(target,n):
  p113d_prepend([N111Call{"ignored",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]}],
    p113pl_done(p113pl_zeroes(nq_width(p113pl_shape(target))),target,n))

@unsafe
def p173ab_take(shape,arg,shapes,args,env,words,info,target,n):
  +word : N111Value = N111Local{nc_word(ix(arg),env)}
  +fields = nq_bundle_params(ix(shape),n)
  +yes = p173ab_lower(shapes,args,nc_remove_env(env,ix(arg)),
    nt_append(N111Value,words,p111_env_words(fields)),info,target,U32.add(n,ix(shape)))
  p113d_prepend(p111_test(nm(shape),word),
    p113d_branch(N111Local{"match_condition"},
      p113d_prepend(p111_take(nm(shape),word,ix(shape),n),yes),
      p173ab_bad_tag(target,p113d_fresh(yes))))

@unsafe
def p173ab_lower(shapes,args,env,words,info,target,n):
  match shapes args:
    case Nil{} Nil{}: p113pl_call_result(nm(dv(info)),words,dt(info),target,n)
    case Con{+shape,+rest} Con{+arg,+more}:
      nt_choose(P113DCode,p113p_known(shape) && String.eq(tg(arg),"Var"),
        u => p173ab_take(shape,arg,rest,more,env,words,info,target,n),
        u => p173ab_lower(rest,more,env,nt_append(N111Value,words,p113p_words([shape],[arg],env)),info,target,n))
    case _ _: p113d_fail("product argument bridge arity",n)

# Only replace an opaque fallback that cannot satisfy a known product-result
# target. Do not replace previously admissible boxed calls merely because a flat
# signature exists: the flat callee may not become independently ready.
@unsafe
def p173ab_call(book,name,args,env,target,n):
  +info = lookup(p113pl_signatures(target),name)
  nt_choose(P113DCode,String.eq(tg(dv(info)),"NQSig") && nq_args_fit(ks(dv(info)),args),
    u => p113pl_call_result(nm(dv(info)),p113p_words(ks(dv(info)),args,env),dt(info),target,n),
    u => nt_choose(P113DCode,p113p_known(p113pl_shape(target)) && nq_same(dt(info),p113pl_shape(target)) && p173ab_allowed(info,args,env,n),
      v => p173ab_lower(ks(dv(info)),args,env,[],info,target,n),
      v => p173ab_original(book,name,args,env,target,n)))
