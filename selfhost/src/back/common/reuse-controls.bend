
@unsafe
def p140eq_def(a: KDef, b: KDef) -> Bool:
  match a b:
    case KDef{an,ak,aa,ax,at,av,ac,ab,au} KDef{bn,bk,ba,bx,bt,bv,bc,bb,bu}:
      String.eq(an,bn) && String.eq(ak,bk) && U32.is_eq(aa,ba) && U32.is_eq(ax,bx) &&
        p134v_bool(ab,bb) && p134v_bool(au,bu) &&
        f_fresh_prefix_exact_terms([at,av],[bt,bv]) && p140eq_list(ac,bc)
    case KIndexLeaf{ah,ab} KIndexLeaf{bh,bb}:
      U32.is_eq(ah,bh) && p140eq_list(ab,bb)
    case KIndexNode{ah,am,al,ar} KIndexNode{bh,bm,bl,br}:
      U32.is_eq(ah,bh) && U32.is_eq(am,bm) && p140eq_def(al,bl) && p140eq_def(ar,br)
    case _ _: False{}


@unsafe
def p140eq_list(a: List<&2,KDef>, b: List<&2,KDef>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140eq_def(x,y) && p140eq_list(xs,ys)
    case _ _: False{}

@unsafe
def p140eq_old_def(a: KDef, b: KDef) -> Bool:
  p140eq_old_defs([a],[b])


def p140eq_old_variant(d: KDef) -> U32:
  match d:
    case KDef{name,kind,arity,templates,typ,value,children,native,unsafe}: 0
    case KIndexLeaf{hash,bucket}: 1
    case KIndexNode{hash,mask,left,right}: 2


@unsafe
def p140eq_old_defs(left: List<&2,KDef>, right: List<&2,KDef>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{+a,ar} Con{+b,br}:
      nt_choose(Bool,U32.is_eq(p140eq_old_variant(a),p140eq_old_variant(b)) && f_fresh_prefix_exact_head(a,b),
        u => p140eq_old_defs(norm_defs_join(dc(a),ar),norm_defs_join(dc(b),br)),u => False{})
    case _ _: False{}

@unsafe
def p140cat_def(name: String, value: KTerm) -> KDef:
  KDef{name,"Def",0,0,kt("ADT","U32",0,0,[]),value,[],False{},False{}}


@unsafe
def p140cat_book() -> List<&2,KDef>:
  book_cached([p140cat_def("main",ref("reader")),p140cat_def("reader",ref("leaf")),
    p140cat_def("leaf",kt("Lit","U32",1,0,[])),p140cat_def("unused",kt("Lit","U32",8,0,[]))],40)


@unsafe
def p140cat_leaf() -> N111Segment:
  N111Segment{"main",0,1,0,0,[N111Alloca{"scratch",2048,8},
    N111Store{N111U64{},N111Local{"scratch"},0,N111Const{7,0}},
    N111Call{"reply",N111U64{},"p111_rt_return",[N111Arg{N111Ptr{},N111Local{"state"}},
      N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{1,0}}]},
    N111Return{N111Local{"reply"}}]}


@unsafe
def p140cat_programs(+a: P111Program, +b: P111Program) -> Bool:
  match a b:
    case P111Program{aseg,c,s,n,e,p} P111Program{bseg,bc,bw,bn,be,bpure}:
      p140gm_headers(a,b) && p134v_list(~N111Segment,~p140r_segment,aseg,bseg)

@unsafe
def p140cat_results(a: P111Result, b: P111Result) -> Bool:
  match a b:
    case P111Result{ap,ae} P111Result{bp,be}:
      String.eq(ae,be) && p140cat_programs(ap,bp)


@unsafe
def p140cat_case(+source: List<&2,KDef>, +names: List<&2,String>, +compiled: P111Book) -> Bool:
  p140cat_results(p111_finish(source,names,compiled),
    p140or_finish(source,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)),compiled))


@unsafe
def p140cat_controls() -> List<&2,String>:
  +source = p140cat_book()
  +segments: List<&2,N111Segment> = [p140cat_leaf()]
  +io = book_cached([KDef{"main","Def",0,0,kt("ADT","IO",0,0,[kt("ADT","Unit",0,0,[])]),ref("effect"),[],False{},False{}},
    KDef{"effect","Def",0,0,kt("ADT","Unit",0,0,[]),kt("Foreign","c",0,0,[]),[],False{},False{}}],40)
  [p131u_row(p140cat_case(source,["main","reader","leaf"],P111Book{segments,12,""}),"catalogue-pure-finish-exact"),
   p131u_row(p140cat_case(source,["main"],P111Book{segments,12,"deliberate preserved lowering error"}),"catalogue-error-finish-exact"),
   p131u_row(p140cat_case(source,[],P111Book{[],0,""}),"catalogue-empty-segments-exact"),
   p131u_row(p140cat_case(io,["main","effect"],P111Book{segments,12,""}),"catalogue-io-effects-finish-exact")]
