# Canonical App producers and fixed-arity consumers. No parser quantity changes.
@unsafe
def k_apply_span(function, argument, begin, end):
  KApply{function,argument,begin,end}

# A public structural rebuild may supply malformed child counts. Preserve them.
@unsafe
def k_apply_children(kids, begin, end):
  match kids:
    case Con{function,Con{argument,Nil{}}}: KApply{function,argument,begin,end}
    case _: KTerm{"App","",0,0,kids,[],begin,end}

@unsafe
def app(+f: KTerm, +x: KTerm) -> KTerm:
  KApply{f,x,0,0}

@unsafe
def kid(+t: KTerm, +n: U32) -> KTerm:
  match t:
    case KApply{function,argument,begin,end}:
      kc(KTerm,U32.is_eq(n,0),u => function,
        u => kc(KTerm,U32.is_eq(n,1),v => argument,v => atom("Absent")))
    case _: terms_at(ks(t),n)

@unsafe
def core_apply_span(+f: KTerm, +x: KTerm, +begin: U32, +end: U32) -> KTerm:
  kc(KTerm,p98_tag_eq(f,"Lam"),u => subst(kid(f,0),ix(f),x),
    u => KApply{f,x,begin,end})

@unsafe
def ki_pair(+t: KTerm, +ty: KTerm, +a: KChecking, +b: KChecking, +join: Bool) -> KChecking:
  match t:
    case KApply{function,argument,begin,end}:
      both(a,b,KApply{ct(a),ct(b),begin,end},ty,join)
    case _: both(a,b,k_with_children(t,[ct(a),ct(b)]),ty,join)

@unsafe
def env_subst_term(t, bindings):
  match t bindings:
    case _ Nil{}: t
    case KApply{function,argument,begin,end} Con{binding,rest}:
      KApply{env_subst_term(function,bindings),env_subst_term(argument,bindings),begin,end}
    case _ Con{binding,rest}:
      kc(KTerm,p98_tag_eq(t,"Var"),u => env_subst_find(t,bindings),
        u => kc(KTerm,core_literal(t),u => t,
          u => k_with_children(t,env_subst_terms(ks(t),bindings))))

@unsafe
def p152c_variant(a: KTerm, b: KTerm) -> Bool:
  match a b:
    case KTerm{a0,a1,a2,a3,a4,a5,a6,a7} KTerm{b0,b1,b2,b3,b4,b5,b6,b7}: True{}
    case KApply{a0,a1,a2,a3} KApply{b0,b1,b2,b3}: True{}
    case KApply{a0,a1,a2,a3} KTerm{b0,b1,b2,b3,b4,b5,b6,b7}: True{}
    case KTerm{a0,a1,a2,a3,a4,a5,a6,a7} KApply{b0,b1,b2,b3}: True{}
    case KLambda{a0,a1,a2,a3,a4,a5,a6,a7} KLambda{b0,b1,b2,b3,b4,b5,b6,b7}: Bool.not(Bool.xor(a7,b7))
    case _ _: False{}
