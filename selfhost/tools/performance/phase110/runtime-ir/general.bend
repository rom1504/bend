# Additive generalization of the exact private ownership templates. These
# definitions do not replace the frozen v1 source until exact overrides select
# this candidate. All suffixes remain checked by the original ownership graph.

# Production heap_free(e,1,src): both children have already been transferred.
def nx110rtg_free_shell() -> List<&2,NxStmt>:
  [NxSet{"ir_free",NxLoad{NxU64{},NxVar{"ir_alc"},8}},
   NxStore{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0,NxVar{"ir_free"}},
   NxStore{NxU64{},NxVar{"ir_alc"},8,NxVar{"ir_src"}},
   NxSet{"ir_len",NxLoad{NxU64{},NxVar{"ir_alc"},264}},
   NxSet{"ir_len",NxBin{"add",NxVar{"ir_len"},nx110rt_u(2)}},
   NxStore{NxU64{},NxVar{"ir_alc"},264,NxVar{"ir_len"}},
   NxIf{NxBin{"ult",NxVar{"ir_len"},nx110rt_u(32768)},[],[NxSet{"ir_status",NxCall{"rt_ir_hand1",[NxVar{"ctx"}]}}]}]

@unsafe
def nx110rtg_take_fast(+a: String, +b: String) -> List<&2,NxStmt>:
  nxo_join(NxStmt,
    [NxSet{"ir_old0",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0}},
     NxSet{"ir_old1",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_src"}),8}},
     NxIf{NxBin{"eq",NxVar{"ir_rfc"},nx110rt_u(1)},nx110rt_free_wrapper(),[]}],
    nxo_join(NxStmt,nx110rtg_free_shell(),
      [NxSet{a,NxVar{"ir_old0"}},NxSet{b,NxVar{"ir_old1"}},NxSet{"status",NxConst{NxU32{},0}}]))

@unsafe
def nx110rtg_take(+parent: String, +a: String, +b: String, +view: String) -> List<&2,NxStmt>:
  nxo_join(NxStmt,nx110rt_classify(parent,view),
    [NxIf{NxVar{"ir_ok"},nx110rtg_take_fast(a,b),
      [NxSet{"status",NxCall{"rt_fast_take2",[NxVar{"ctx"},NxVar{parent}]}},
       NxSet{a,NxCall{"rt_fast_field",[NxVar{"ctx"},NxConst{NxU32{},0}]}},
       NxSet{b,NxCall{"rt_fast_field",[NxVar{"ctx"},NxConst{NxU32{},1}]}}]}])

# This is exactly the old adjacent reconstruction guard without its Tail2
# restriction. No operation is crossed. Independent Nxo checking establishes
# every remaining credit through the arbitrary suffix; the kept child has
# already been consumed and cannot escape or be consumed again.
@unsafe
def nx110rtg_fusion_shape(+parent: String, +a: String, +b: String, +dest: String, +cid: U32, +keep: String, +other: String) -> Bool:
  (U32.is_eq(cid,1) || U32.is_eq(cid,3)) &&
  Bool.not(String.eq(a,b) || String.eq(parent,a) || String.eq(parent,b)) &&
  (String.eq(keep,a) || String.eq(keep,b)) &&
  Bool.not(String.eq(other,parent) || String.eq(other,a) || String.eq(other,b)) &&
  Bool.not(String.eq(dest,parent) || String.eq(dest,a) || String.eq(dest,b) || String.eq(dest,other))

@unsafe
def nx110rtg_rebuild(+parent: String, +dest: String, +cid: U32, +other: String, +view: String, +selection: NxoLawSelection<String>) -> List<&2,NxStmt>:
  match selection:
    case NxoLawSelection{index,retained,remaining}:
      nxo_join(NxStmt,nx110rt_classify(parent,view),
        [NxIf{NxVar{"ir_ok"},
          Con{NxSet{"ir_tail",NxVar{other}},nx110rt_rebuild_fast(dest,remaining,cid,index)},
          [NxSet{dest,NxCall{nxo110_rebuild_name(cid,index),[NxVar{"ctx"},NxVar{parent},NxVar{other}]}},
           NxSet{remaining,NxCall{"rt_fast_field",[NxVar{"ctx"},NxConst{NxU32{},0}]}}]}])

@unsafe
def nx110rtg_op(+op: NxoOp, +view: String, +tag_word: String) -> List<&2,NxStmt>:
  match op:
    case NxoTake{parent,Con{a,Con{b,Nil{}}}}: nx110rtg_take(parent,a,b,view)
    case NxoBranch{word,cid,yes,no}:
      nxo_join(NxStmt,nx_choose(List<&2,NxStmt>,String.eq(word,tag_word),u => [],u => [NxSet{"tag110",nxo110_tag(word)}]),
        [NxIf{NxBin{"eq",NxVar{"tag110"},nx110rt_u(cid)},nx110rtg_ops(yes,view,word),nx110rtg_ops(no,view,word)}])
    case _: nxo_p_op(op,"trusted",tag_word)

@unsafe
def nx110rtg_fallback(+ops: List<&2,NxoOp>, +view: String, +tag_word: String) -> List<&2,NxStmt>:
  match ops:
    case Nil{}: []
    case Con{head,rest}: nxo_join(NxStmt,nx110rtg_op(head,view,tag_word),nx110rtg_ops(rest,view,""))

@unsafe
def nx110rtg_ops(+ops: List<&2,NxoOp>, +view: String, +tag_word: String) -> List<&2,NxStmt>:
  match ops:
    case Con{NxoTake{parent,Con{a,Con{b,Nil{}}}},Con{NxoBuild{dest,cid,Con{keep,Con{other,Nil{}}}},rest}}:
      nx_choose(List<&2,NxStmt>,nx110rtg_fusion_shape(parent,a,b,dest,cid,keep,other),
        u => nxo_join(NxStmt,nx110rtg_rebuild(parent,dest,cid,other,view,nxo_law_select(String,String.eq(keep,a),a,b)),nx110rtg_ops(rest,view,"")),
        u => nx110rtg_fallback(ops,view,tag_word))
    case _: nx110rtg_fallback(ops,view,tag_word)

def nx110rtg_imports() -> List<&2,NxImport>:
  nxo_join(NxImport,
    [NxImport{"rt_ir_heap",[NxParam{"ctx",NxPtr{}}],NxPtr{}},
     NxImport{"rt_ir_alc",[NxParam{"ctx",NxPtr{}}],NxPtr{}},
     NxImport{"rt_ir_alloc0",[NxParam{"ctx",NxPtr{}}],NxU64{}},
     NxImport{"rt_ir_hand0",[NxParam{"ctx",NxPtr{}}],NxU32{}},
     NxImport{"rt_ir_hand1",[NxParam{"ctx",NxPtr{}}],NxU32{}},
     NxImport{"rt_ir_view",[NxParam{"ctx",NxPtr{}},NxParam{"loc",NxU64{}}],NxU64{}}],
    nxlib_runtime110_imports_policy("specialized"))
