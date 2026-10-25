# Requires verify/core-v03 and verify/controls-v02. Uses only returned caches;
# no forged prior judgments or host implementation grant reuse.
@unsafe
def p140vm_index(+a: KDef, +b: KDef) -> Bool:
  match a b:
    case KDef{an,ak,aa,ax,at,av,ac,ab,au} KDef{bn,bk,ba,bx,bt,bv,bc,bb,bu}: f_fresh_prefix_exact_defs([a],[b])
    case KIndexLeaf{ah,ad} KIndexLeaf{bh,bd}: U32.is_eq(ah,bh) && f_fresh_prefix_exact_defs(ad,bd)
    case KIndexNode{ah,am,al,ar} KIndexNode{bh,bm,bl,br}:
      U32.is_eq(ah,bh) && U32.is_eq(am,bm) && p140vm_index(al,bl) && p140vm_index(ar,br)
    case _ _: False{}

@unsafe
def p140vm_scan(a: P111VScan, b: P111VScan) -> Bool:
  match a b:
    case P111VScan{ai,ae,ac} P111VScan{bi,be,bc}: p140vm_index(ai,bi) && String.eq(ae,be) && U32.is_eq(ac,bc)

@unsafe
def p140vm_ids(a: N111Ids, b: N111Ids) -> Bool:
  match a b:
    case N111Ids{af,ac} N111Ids{bf,bc}: p140vm_index(af,bf) && p140vm_index(ac,bc)

@unsafe
def p140vm_fields(+original: P112StaticProgram, functions: P111VScan, ctors: P111VScan, ids: N111Ids) -> Bool:
  match original:
    case P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes}:
      p140vm_scan(functions,p111v_functions(segments,P111VScan{missing(),"",0})) &&
      p140vm_scan(ctors,p111v_constructors(constructors,P111VScan{missing(),"",0})) && p140vm_ids(ids,p114s_ids(original))

@unsafe
def p140vm_cache_matches(program: P113DProgram, cache: P140VCache) -> Bool:
  match program cache:
    case P113DProgram{original,functions} P140VCache{old,P140VMetadata{fs,cs,ids}}: p140vm_fields(original,fs,cs,ids)
    case _ _: False{}

@unsafe
def p140vm_admits(+old: P113DProgram, now: P113DProgram) -> Bool:
  p140vm_admitted(p140v_reuse(now,p140vt_cache(p140v_check(old,P140VEmpty{}))))

def p140vm_admitted(reuse: P140VReuse) -> Bool:
  match reuse:
    case P140VReuse{segments,functions,raw,direct,Some{metadata}}: raw
    case _: False{}

def p140vm_program(flags: U32, ctors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>) -> P113DProgram:
  P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,flags,[N111Return{N111Const{0,0}}]}],ctors,[0],[],[],True{}},nodes},[]}

@unsafe
def p140vm_controls() -> List<&2,String>:
  +plain = p140vm_program(0,[N_Constructor{"A",0,True{}},N_Constructor{"B",1,True{}}],[])
  +cache = p140vt_cache(p140v_check(plain,P140VEmpty{}))
  +body : P113DProgram = P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{9,0}}]}],[N_Constructor{"A",0,True{}},N_Constructor{"B",1,True{}}],[0],[],[],True{}},[]},[]}
  +changed_arity = p140vm_program(0,[N_Constructor{"A",1,True{}},N_Constructor{"B",1,True{}}],[])
  +changed_hot = p140vm_program(0,[N_Constructor{"A",0,False{}},N_Constructor{"B",1,True{}}],[])
  +changed_order = p140vm_program(0,[N_Constructor{"B",1,True{}},N_Constructor{"A",0,True{}}],[])
  +bad_image = p140vm_program(0,[N_Constructor{"A",0,True{}},N_Constructor{"B",1,True{}}],[P112SNode{0,"missing",[]}])
  +bad_flags = p140vm_program(256,[N_Constructor{"A",0,True{}},N_Constructor{"B",1,True{}}],[P112SNode{0,"missing",[]}])
  [p114st_row("metadata-cold-maps-exact-original",p140vm_cache_matches(plain,cache)),
   p114st_row("metadata-warm-maps-exact-original",p140vm_cache_matches(body,p140vt_cache(p140v_check(body,cache)))),
   p114st_row("metadata-body-edit-reuses",p140vm_admits(plain,body)),
   p114st_row("metadata-constructor-arity-refuses",Bool.not(p140vm_admits(plain,changed_arity))),
   p114st_row("metadata-constructor-hot-refuses",Bool.not(p140vm_admits(plain,changed_hot))),
   p114st_row("metadata-constructor-order-refuses",Bool.not(p140vm_admits(plain,changed_order))),
   p114st_row("metadata-flags-refuses",Bool.not(p140vm_admits(plain,bad_flags))),
   p114st_row("metadata-error-priority-unchanged",p140vt_equal(plain,bad_flags)),
   p114st_row("metadata-static-image-still-checked",p140vm_admits(plain,bad_image) && p140vt_equal(plain,bad_image)),
   p114st_row("metadata-static-failure-not-published",p140vt_empty(p140vt_cache(p140v_check(bad_image,cache))))]
