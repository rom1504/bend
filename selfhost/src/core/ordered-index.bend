
type P131UEntry is Data:
  P131UEntry{+id: U32, +low: U32, +high: U32}



def p131u_absent(entries: List<&2,P131UEntry>, +mode: U32) -> List<&2,P131UEntry>:
  match entries mode:
    case values 0: values
    case Nil{} other: []
    case Con{P131UEntry{id,low,high},rest} other:
      Con{P131UEntry{id,0,high},p131u_absent(rest,mode)}



def p131u_merge_loop(+left: List<&2,P131UEntry>, +right: List<&2,P131UEntry>, +mode: U32, order: Cmp, +li: U32, +ll: U32, +lh: U32, +ri: U32, +rl: U32, +rh: U32) -> List<&2,P131UEntry>:
  match left right order:
    case Nil{} values LT{}:
      Con{P131UEntry{li,p131a_low(mode,ll,0),p131a_high(mode,lh,0)},p131u_absent(Con{P131UEntry{ri,rl,rh},values},mode)}
    case Con{P131UEntry{+ni,nl,nh},rest} values LT{}:
      Con{P131UEntry{li,p131a_low(mode,ll,0),p131a_high(mode,lh,0)},p131u_merge_loop(rest,values,mode,U32.cmp(ni,ri),ni,nl,nh,ri,rl,rh)}
    case values Nil{} GT{}:
      Con{P131UEntry{ri,p131a_low(mode,0,rl),p131a_high(mode,0,rh)},p131u_absent(Con{P131UEntry{li,ll,lh},values},mode)}
    case values Con{P131UEntry{+ni,nl,nh},rest} GT{}:
      Con{P131UEntry{ri,p131a_low(mode,0,rl),p131a_high(mode,0,rh)},p131u_merge_loop(values,rest,mode,U32.cmp(li,ni),li,ll,lh,ni,nl,nh)}
    case Nil{} values EQ{}:
      Con{P131UEntry{li,p131a_low(mode,ll,rl),p131a_high(mode,lh,rh)},p131u_absent(values,mode)}
    case values Nil{} EQ{}:
      Con{P131UEntry{li,p131a_low(mode,ll,rl),p131a_high(mode,lh,rh)},p131u_absent(values,mode)}
    case Con{P131UEntry{+ni,nl,nh},xs} Con{P131UEntry{+mi,ml,mh},ys} EQ{}:
      Con{P131UEntry{li,p131a_low(mode,ll,rl),p131a_high(mode,lh,rh)},p131u_merge_loop(xs,ys,mode,U32.cmp(ni,mi),ni,nl,nh,mi,ml,mh)}



def p131u_merge(left: List<&2,P131UEntry>, right: List<&2,P131UEntry>, +mode: U32) -> List<&2,P131UEntry>:
  match left right:
    case Nil{} values: p131u_absent(values,mode)
    case values Nil{}: p131u_absent(values,mode)
    case Con{P131UEntry{+li,ll,lh},lr} Con{P131UEntry{+ri,rl,rh},rr}:
      p131u_merge_loop(lr,rr,mode,U32.cmp(li,ri),li,ll,lh,ri,rl,rh)


@unsafe
def p131u_build(+term: KTerm) -> List<&2,P131UEntry>:
  nt_choose(List<&2,P131UEntry>,p98_tag_eq(term,"Var"),
    u => [P131UEntry{ix(term),1,1}],u =>
    nt_choose(List<&2,P131UEntry>,p98_tag_eq(term,"Mat") && U32.is_eq(terms_len(ks(term)),2),
      v => p131u_merge(p131u_build(kid(term,0)),p131u_build(kid(term,1)),1),v =>
      nt_choose(List<&2,P131UEntry>,p98_tag_eq(term,"NWPattern"),
        w => p131u_rows(ks(term)),w => p131u_list(ks(term)))))



@unsafe
def p131u_list(terms: List<&2,KTerm>) -> List<&2,P131UEntry>:
  match terms:
    case Nil{}: []
    case Con{head,rest}: p131u_merge(p131u_build(head),p131u_list(rest),0)



@unsafe
def p131u_rows(rows: List<&2,KTerm>) -> List<&2,P131UEntry>:
  match rows:
    case Nil{}: []
    case Con{row,rest}: p131u_merge(p131u_build(kid(row,0)),p131u_rows(rest),2)



def p131u_max_loop(entries: List<&2,P131UEntry>, +id: U32, order: Cmp, value: U32) -> U32:
  match entries order:
    case values EQ{}: value
    case values GT{}: 0
    case Nil{} LT{}: 0
    case Con{P131UEntry{key,low,high},rest} LT{}:
      p131u_max_loop(rest,id,U32.cmp(key,id),high)



def p131u_max(entries: List<&2,P131UEntry>, id: U32) -> U32:
  p131u_max_loop(entries,id,LT{},0)



def p131u_min_loop(entries: List<&2,P131UEntry>, +id: U32, order: Cmp, value: U32) -> U32:
  match entries order:
    case values EQ{}: value
    case values GT{}: 0
    case Nil{} LT{}: 0
    case Con{P131UEntry{key,low,high},rest} LT{}:
      p131u_min_loop(rest,id,U32.cmp(key,id),low)



def p131u_min(entries: List<&2,P131UEntry>, id: U32) -> U32:
  p131u_min_loop(entries,id,LT{},0)

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
