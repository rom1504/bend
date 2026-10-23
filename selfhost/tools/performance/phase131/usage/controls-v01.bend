# Differential gates retain the original independent single-query walkers.
@unsafe
def p131u_valid(entries: List<&2,P131UEntry>) -> Bool:
  match entries:
    case Nil{}: True{}
    case Con{P131UEntry{+id,low,+high},rest}:
      U32.is_le(low,high) && U32.is_ge(high,1) && U32.is_le(high,2) && p131u_after(rest,id)

@unsafe
def p131u_after(entries: List<&2,P131UEntry>, prior: U32) -> Bool:
  match entries:
    case Nil{}: True{}
    case Con{P131UEntry{+id,low,+high},rest}:
      U32.is_lt(prior,id) && U32.is_le(low,high) && U32.is_ge(high,1) && U32.is_le(high,2) && p131u_after(rest,id)

@unsafe
def p131u_agrees(+term: KTerm, ids: List<&2,U32>, +entries: List<&2,P131UEntry>) -> Bool:
  match ids:
    case Nil{}: True{}
    case Con{+id,rest}:
      U32.is_eq(p131u_max(entries,id),nq_uses(term,id)) &&
      U32.is_eq(p131u_min(entries,id),nq_min_uses(term,id)) && p131u_agrees(term,rest,entries)

# Enumerate all syntactic IDs independently, including ignored Var children,
# discarded NW row metadata and all three concrete KTerm variants.
@unsafe
def p131u_ids(+term: KTerm) -> List<&2,U32>:
  nt_choose(List<&2,U32>,p98_tag_eq(term,"Var"),
    u => Con{ix(term),p131u_ids_list(ks(term))},u => p131u_ids_list(ks(term)))

@unsafe
def p131u_ids_list(terms: List<&2,KTerm>) -> List<&2,U32>:
  match terms:
    case Nil{}: []
    case Con{head,rest}: nt_append(U32,p131u_ids(head),p131u_ids_list(rest))

@unsafe
def p131u_agrees_all(+term: KTerm) -> Bool:
  +entries = p131u_build(term)
  p131u_valid(entries) && p131u_agrees(term,nt_append(U32,[0,1,2,4294967294,4294967295],p131u_ids(term)),entries)

@unsafe
def p131u_control(term: KTerm, name: String) -> String:
  p131u_row(p131u_agrees_all(term),name)

@unsafe
def p131u_row(valid: Bool, name: String) -> String:
  match valid:
    case True{}: name ++ ":pass"
    case False{}: name ++ ":fail"

@unsafe
def p131u_controls() -> List<&2,String>:
  [p131u_control(atom("Empty"),"empty"),
   p131u_control(var("",0),"zero-id"),
   p131u_control(var("",4294967295),"maximum-id"),
   p131u_control(kt("Var","",7,0,[var("",8)]),"var-ignores-children"),
   p131u_control(kt("Seq","",0,0,[var("",1),var("",1),var("",1)]),"sequence-saturation"),
   p131u_control(kt("Seq","",0,0,[var("",4294967295),var("",0),var("",1)]),"unsigned-sort"),
   p131u_control(kt("Mat","",0,0,[var("",1),var("",1)]),"mat-both"),
   p131u_control(kt("Mat","",0,0,[var("",1),var("",2)]),"mat-conditional"),
   p131u_control(kt("Mat","",0,0,[kt("Seq","",0,0,[var("",1),var("",1)]),var("",1)]),"mat-one-many"),
   p131u_control(kt("Mat","",0,0,[]),"mat-empty-is-sequence"),
   p131u_control(kt("Mat","",0,0,[var("",1)]),"mat-single-is-sequence"),
   p131u_control(kt("Mat","",0,0,[var("",1),var("",1),var("",1)]),"mat-three-is-sequence"),
   p131u_control(kt("NWPattern","",0,0,[]),"pattern-empty"),
   p131u_control(kt("NWPattern","",0,0,[kt("Row","",0,0,[var("",1)])]),"pattern-minimum-zero"),
   p131u_control(kt("NWPattern","",0,0,[kt("Row","",0,0,[var("",1)]),kt("Row","",0,0,[var("",1)])]),"pattern-maximum-not-sum"),
   p131u_control(kt("NWPattern","",0,0,[kt("Row","",0,0,[var("",1),var("",2)])]),"pattern-ignores-row-tail"),
   p131u_control(kt("NWPattern","",0,0,[atom("EmptyRow")]),"pattern-missing-child"),
   p131u_control(KLambda{"x",0,2,[var("",1),var("",1)],[],0,0,True{}},"lambda-variant"),
   p131u_control(KLiteral{"U32",1,"",0,0},"literal-variant"),
   p131u_control(kt("Seq","",0,0,[kt("NWPattern","",0,0,[kt("Row","",0,0,[var("",1)])]),var("",1)]),"pattern-sequence-minimum"),
   p131u_control(kt("Mat","",0,0,[kt("NWPattern","",0,0,[kt("Row","",0,0,[var("",1)])]),var("",1)]),"pattern-branch-minimum"),
   p131u_control(kt("UnknownFutureForm","",0,0,[var("",1),var("",1)]),"unknown-tag-generic-sequence")]
