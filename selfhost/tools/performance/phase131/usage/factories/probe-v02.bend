# Isolated data-only prototype. No production entry, compiler pass, static
# image or verifier is overridden. Inputs are checked erased terms.
type P131CFResult is Data:
  P131CFValue{+term: KTerm}
  P131CFRefused{}

type P131CFResults is Data:
  P131CFValues{+terms: List<&2,KTerm>}
  P131CFNoValues{}

law p131cf_eval:
  for +book: List<&2,KDef>
  for +constructors: KDef
  for +term: KTerm
  for +fuel: U32
  P131CFResult

@unsafe
def p131cf_text_small(text: String, +left: U32) -> Bool:
  match text:
    case SNil{}: True{}
    case SCon{head,rest}: nt_choose(Bool,U32.is_gt(left,0),u => p131cf_text_small(rest,U32.sub(left,1)),u => False{})

# One String literal is one AST node; bound its expansion separately.
@unsafe
def p131cf_literals(terms: List<&2,KTerm>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{+head,+rest}:
      nt_choose(Bool,core_literal(head) && String.eq(nm(head),"String"),
        u => p131cf_text_small(kl_text(head),64) && p131cf_literals(rest),
        u => p131cf_literals(ks(head)) && p131cf_literals(rest))

@unsafe
def p131cf_cons(head: P131CFResult, tail: P131CFResults) -> P131CFResults:
  match head tail:
    case P131CFValue{first} P131CFValues{rest}: P131CFValues{Con{first,rest}}
    case _ _: P131CFNoValues{}

@unsafe
def p131cf_values(+book: List<&2,KDef>, +constructors: KDef, terms: List<&2,KTerm>, +fuel: U32) -> P131CFResults:
  match terms:
    case Nil{}: P131CFValues{[]}
    case Con{head,rest}: p131cf_cons(p131cf_eval(book,constructors,head,fuel),p131cf_values(book,constructors,rest,fuel))

@unsafe
def p131cf_constructor(+constructors: KDef, +term: KTerm, values: P131CFResults) -> P131CFResult:
  match values:
    case P131CFNoValues{}: P131CFRefused{}
    case P131CFValues{+fields}:
      nt_choose(P131CFResult,ns_ctor(constructors,nm(term),terms_len(fields)),
        u => P131CFValue{k_with_children(term,fields)},u => P131CFRefused{})

# Actuals are fully closed immutable data before substitution. No argument
# computation, effect or error can be dropped, duplicated or reordered here.
@unsafe
def p131cf_apply(+book: List<&2,KDef>, +constructors: KDef, +body: KTerm, args: List<&2,KTerm>, +fuel: U32) -> P131CFResult:
  match args:
    case Nil{}: p131cf_eval(book,constructors,body,fuel)
    case Con{+arg,rest}:
      nt_choose(P131CFResult,p98_tag_eq(body,"Lam") && U32.is_eq(terms_len(ks(body)),1),
        u => p131cf_apply(book,constructors,nq_layout_subst(kid(body,0),ix(body),arg),rest,fuel),
        u => P131CFRefused{})

@unsafe
def p131cf_body(+book: List<&2,KDef>, +constructors: KDef, +body: KTerm, +args: List<&2,KTerm>, +fuel: U32) -> P131CFResult:
  nt_choose(P131CFResult,U32.is_gt(nq_layout_remaining([body],65),0),
    u => nt_choose(P131CFResult,p131cf_literals([body]),
      v => p131cf_apply(book,constructors,nc_compact(body),args,fuel),v => P131CFRefused{}),
    u => P131CFRefused{})

@unsafe
def p131cf_definition(+book: List<&2,KDef>, +constructors: KDef, +d: KDef, values: P131CFResults, +fuel: U32) -> P131CFResult:
  match values:
    case P131CFNoValues{}: P131CFRefused{}
    case P131CFValues{+args}:
      nt_choose(P131CFResult,U32.is_gt(fuel,0) && U32.is_le(terms_len(args),8) && String.eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
        u => p131cf_body(book,constructors,nc_source_body(book,d,0),args,U32.sub(fuel,1)),
        u => P131CFRefused{})

@unsafe
def p131cf_call(+book: List<&2,KDef>, +constructors: KDef, +head: KTerm, +args: List<&2,KTerm>, +fuel: U32) -> P131CFResult:
  nt_choose(P131CFResult,p98_tag_eq(head,"Ref") && U32.is_eq(terms_len(ks(head)),0) && Bool.not(U32.is_eq(qt(head),3)),
    u => p131cf_definition(book,constructors,lookup(book,nm(head)),p131cf_values(book,constructors,args,fuel),fuel),
    u => P131CFRefused{})

@unsafe
def p131cf_eval(book,constructors,term,fuel):
  +scalar = nt_choose(KTerm,p98_tag_eq(term,"Ctr"),u => ns_static_scalar(term),u => term)
  nt_choose(P131CFResult,p98_tag_eq(scalar,"NWord") && U32.is_eq(terms_len(ks(scalar)),0),
    u => nt_choose(P131CFResult,ns_canonical(nm(scalar),U32.read(nm(scalar))),v => P131CFValue{scalar},v => P131CFRefused{}),u =>
  nt_choose(P131CFResult,p98_tag_eq(term,"Ctr"),u => p131cf_constructor(constructors,term,p131cf_values(book,constructors,ks(term),fuel)),u =>
  nt_choose(P131CFResult,p98_tag_eq(term,"App"),u => p131cf_call(book,constructors,nd_head(term),nd_args(term,[]),fuel),u =>
  nt_choose(P131CFResult,p98_tag_eq(term,"Ref"),u => p131cf_call(book,constructors,term,[],fuel),u => P131CFRefused{}))))
