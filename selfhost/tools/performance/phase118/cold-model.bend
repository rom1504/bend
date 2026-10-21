# Reuse the mature checked whole-program sharing certificate, without the
# stronger observer-dependent relaxation. All plans remain request-local.
type P118CPlan is Data:
  P118CPlan{+request: NR_Request, +hot: List<&2,String>, +cold: List<&2,String>, +valid: Bool, +error: String}

@unsafe
def p118c_ordinary(+name: String) -> Bool:
  Bool.not(nb_contains(["Zero","Succ","False","True","Chr","U32","F32",
    "ALeaf","ANode","WNil","WCon","Emit","Halt","Done","Fail"],name))

@unsafe
def p118c_ctor_names(ctors: List<&2,N_Constructor>, +hot: List<&2,String>) -> List<&2,String>:
  match ctors:
    case Nil{}: []
    case Con{N_Constructor{+name,+arity,was_hot},+rest}:
      nt_choose(List<&2,String>,U32.is_gt(arity,0) && p118c_ordinary(name) && Bool.not(nb_contains(hot,"ctor:" ++ name)),
        u => Con{name,p118c_ctor_names(rest,hot)},u => p118c_ctor_names(rest,hot))

@unsafe
def p118c_candidates(+book: List<&2,KDef>, defs: List<&2,KDef>, +hot: List<&2,String>) -> List<&2,String>:
  match defs:
    case Nil{}: []
    case Con{+d,+rest}:
      nt_choose(List<&2,String>,String.eq(dk(d),"ADT") &&
        Bool.not(nb_contains(["Nat","U32","F32","Char","Bool","Array","Word.Nil","Word.Con","IO","IO.OP"],dn(d))),
        u => nt_append(String,p118c_ctor_names(nc_ctor_specs(book,dc(d),da(d)),hot),p118c_candidates(book,rest,hot)),
        u => p118c_candidates(book,rest,hot))

@unsafe
def p118c_plan_hot(+request: NR_Request, +source: List<&2,KDef>, +book: List<&2,KDef>, +permission: Bool, +error: String, +hot: List<&2,String>) -> P118CPlan:
  +valid = permission && String.is_empty(error) && Bool.not(nb_contains(hot,"*"))
  P118CPlan{request,hot,nt_choose(List<&2,String>,valid,u => p118c_candidates(book,source,hot),u => []),valid,error}

@unsafe
def p118c_plan(+request: NR_Request) -> P118CPlan:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      +permission = ns_definitions(book,names)
      p118c_plan_hot(request,source,book,permission,error,
        nt_choose(List<&2,String>,permission && String.is_empty(error),
          u => nh_definitions(book,names,[]),u => ["*"]))

@unsafe
def p118c_hot(plan: P118CPlan) -> List<&2,String>:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}: hot

@unsafe
def p118c_cold(plan: P118CPlan) -> List<&2,String>:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}: cold

@unsafe
def p118c_valid(plan: P118CPlan) -> Bool:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}: valid

@unsafe
def p118c_ctors(ctors: List<&2,N_Constructor>, +cold: List<&2,String>) -> List<&2,N_Constructor>:
  match ctors:
    case Nil{}: []
    case Con{N_Constructor{+name,arity,hot},rest}:
      Con{N_Constructor{name,arity,Bool.not(nb_contains(cold,name))},p118c_ctors(rest,cold)}

@unsafe
def p118c_apply_verified(original: P113AProgram, +cold: List<&2,String>) -> P113AProgram:
  match original:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes},functions},certificate}:
      P113AProgram{P113DProgram{P112StaticProgram{P111Program{segments,p118c_ctors(ctors,cold),show,names,effects,pure},nodes},functions},certificate}

@unsafe
def p118c_apply_plan(+original: P113AProgram, plan: P118CPlan) -> P113AProgram:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}:
      nt_choose(P113AProgram,valid && String.is_empty(error),u => p118c_apply_verified(original,cold),u => original)

# Re-derive the certificate before applying it; caller-supplied cold lists are
# not authority. The ordinary program and plan must share the same request in
# the root harness, whose manifest pins checked source and runtime identities.
@unsafe
def p118c_apply(+original: P113AProgram, plan: P118CPlan) -> P113AProgram:
  match plan:
    case P118CPlan{request,hot,cold,valid,error}:
      nt_choose(P113AProgram,String.is_empty(p113a_verify(original)),
        u => p118c_apply_plan(original,p118c_plan(request)),u => original)
