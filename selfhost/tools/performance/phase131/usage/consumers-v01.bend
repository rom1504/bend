# Exact decision traversals; only immutable-body nq_uses queries are replaced.
# Public wrappers build one local summary. Recursive scans never rebuild it.
@unsafe
def ns_unshared_terms(+book: List<&2,KDef>, body: KTerm, terms: List<&2,KTerm>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{head,rest}: p131u_unshared(book,p131u_build(body),Con{head,rest})

@unsafe
def p131u_unshared(+book: List<&2,KDef>, +uses: List<&2,P131UEntry>, terms: List<&2,KTerm>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{+term,+rest}:
      nt_choose(Bool,p98_tag_eq(term,"Ann"),
        u => nt_choose(Bool,p98_tag_eq(kid(term,0),"Var"),
          v => nt_choose(Bool,ns_array_free(book,kid(term,1)),w => p131u_unshared(book,uses,rest),w => nt_choose(Bool,U32.is_le(p131u_max(uses,ix(kid(term,0))),1),x => p131u_unshared(book,uses,rest),x => False{})),
          v => p131u_unshared(book,uses,Con{kid(term,0),rest})),
        u => nt_choose(Bool,p98_tag_eq(term,"Var"),
          v => nt_choose(Bool,U32.is_le(p131u_max(uses,ix(term)),1),w => p131u_unshared(book,uses,nt_append(KTerm,ks(term),rest)),w => False{}),
          v => p131u_unshared(book,uses,nt_append(KTerm,ks(term),rest))))

@unsafe
def nh_terms(+book: List<&2,KDef>, body: KTerm, terms: List<&2,KTerm>, +hot: List<&2,String>) -> List<&2,String>:
  match terms:
    case Nil{}: hot
    case Con{head,rest}:
      nt_choose(List<&2,String>,nb_contains(hot,"*"),u => hot,
        u => p131u_hot(book,p131u_build(body),Con{head,rest},hot))

@unsafe
def p131u_hot(+book: List<&2,KDef>, +uses: List<&2,P131UEntry>, terms: List<&2,KTerm>, +hot: List<&2,String>) -> List<&2,String>:
  match terms:
    case Nil{}: hot
    case Con{+term,+rest}:
      nt_choose(List<&2,String>,nb_contains(hot,"*"),u => hot,u =>
        nt_choose(List<&2,String>,p98_tag_eq(term,"Ann"),v =>
          nt_choose(List<&2,String>,p98_tag_eq(kid(term,0),"Var"),w =>
            p131u_hot(book,uses,rest,nt_choose(List<&2,String>,U32.is_gt(p131u_max(uses,ix(kid(term,0))),1),x => nh_type(book,kid(term,1),hot,64),x => hot)),
            w => p131u_hot(book,uses,Con{kid(term,0),rest},hot)),v =>
          nt_choose(List<&2,String>,p98_tag_eq(term,"Var"),w => nt_choose(List<&2,String>,U32.is_gt(p131u_max(uses,ix(term)),1),x => nh_add("*",hot),x => p131u_hot(book,uses,rest,hot)),w => p131u_hot(book,uses,nt_append(KTerm,ks(term),rest),hot))))
