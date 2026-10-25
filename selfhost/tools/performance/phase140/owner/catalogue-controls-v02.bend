@unsafe
def p140cat_programs(+a: P111Program, +b: P111Program) -> Bool:
  match a b:
    case P111Program{aseg,c,s,n,e,p} P111Program{bseg,bc,bw,bn,be,bpure}:
      p140gm_headers(a,b) && p134v_list(N111Segment,p140r_segment,aseg,bseg)

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
  +source = p140oc_book(1,8)
  +segments = [p140gc_leaf("main",7)]
  +io = book_cached([KDef{"main","Def",0,0,kt("ADT","IO",0,0,[kt("ADT","Unit",0,0,[])]),ref("effect"),[],False{},False{}},
    KDef{"effect","Def",0,0,kt("ADT","Unit",0,0,[]),kt("Foreign","c",0,0,[]),[],False{},False{}}],40)
  [p131u_row(p140cat_case(source,["main","reader","leaf"],P111Book{segments,12,""}),"catalogue-pure-finish-exact"),
   p131u_row(p140cat_case(source,["main"],P111Book{segments,12,"deliberate preserved lowering error"}),"catalogue-error-finish-exact"),
   p131u_row(p140cat_case(source,[],P111Book{[],0,""}),"catalogue-empty-segments-exact"),
   p131u_row(p140cat_case(io,["main","effect"],P111Book{segments,12,""}),"catalogue-io-effects-finish-exact")]
