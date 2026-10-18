# Exact private ownership templates over the existing Nx machine IR. Public
# NxLibrary continues to reject memory. This builder is entered only after
# checked source admission and independent Nxo ownership verification.
def nx110rt_u(+n: U32) -> NxExpr:
  NxConst{NxU64{},n}

def nx110rt_v(+name: String) -> NxExpr:
  NxVar{name}

def nx110rt_loc(+word: NxExpr) -> NxExpr:
  NxBin{"and",word,NxBin{"sub",NxBin{"shl",nx110rt_u(1),nx110rt_u(40)},nx110rt_u(1)}}

def nx110rt_addr(+loc: NxExpr) -> NxExpr:
  NxOffset{NxVar{"ir_heap"},NxBin{"shl",loc,nx110rt_u(3)}}

def nx110rt_dynamic(+loc: NxExpr) -> NxExpr:
  NxBin{"eq",NxBin{"ult",loc,nx110rt_u(51413376)},NxConst{NxU32{},0}}

def nx110rt_view_valid(+view: String) -> Bool:
  String.eq(view,"single") || String.eq(view,"atomic")

# Identical class0 hot-list state transition to production heap_free(e,0,r).
# The CPU err_seen predicate is constant false in the authenticated runtime.
# The uncommon handoff remains the actual production helper.
def nx110rt_free_wrapper() -> List<&2,NxStmt>:
  [NxSet{"ir_free",NxLoad{NxU64{},NxVar{"ir_alc"},0}},
   NxStore{NxU64{},nx110rt_addr(NxVar{"ir_loc"}),0,NxVar{"ir_free"}},
   NxStore{NxU64{},NxVar{"ir_alc"},0,NxVar{"ir_loc"}},
   NxSet{"ir_len",NxLoad{NxU64{},NxVar{"ir_alc"},256}},
   NxSet{"ir_len",NxBin{"add",NxVar{"ir_len"},nx110rt_u(1)}},
   NxStore{NxU64{},NxVar{"ir_alc"},256,NxVar{"ir_len"}},
   NxIf{NxBin{"ult",NxVar{"ir_len"},nx110rt_u(32768)},[],[NxSet{"ir_status",NxCall{"rt_ir_hand0",[NxVar{"ctx"}]}}]}]

# Identical class0 hot allocation; only the existing miss path is imported.
def nx110rt_alloc_wrapper() -> List<&2,NxStmt>:
  [NxSet{"ir_wrap",NxLoad{NxU64{},NxVar{"ir_alc"},0}},
   NxIf{NxBin{"eq",NxVar{"ir_wrap"},nx110rt_u(0)},
     [NxSet{"ir_wrap",NxCall{"rt_ir_alloc0",[NxVar{"ctx"}]}}],
     [NxSet{"ir_free",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_wrap"}),0}},
      NxStore{NxU64{},NxVar{"ir_alc"},0,NxVar{"ir_free"}},
      NxSet{"ir_len",NxLoad{NxU64{},NxVar{"ir_alc"},256}},
      NxSet{"ir_len",NxBin{"sub",NxVar{"ir_len"},nx110rt_u(1)}},
      NxStore{NxU64{},NxVar{"ir_alc"},256,NxVar{"ir_len"}}]}]

# rfc_seal only wraps a non-RFC constructor. The rfc_wrap invalid closure/task
# check is impossible after this exact tag test. Both fields remain sealed.
@unsafe
def nx110rt_seal(+word: String) -> List<&2,NxStmt>:
  [NxIf{NxBin{"and",
      NxBin{"eq",NxBin{"and",NxBin{"lshr",NxVar{word},nx110rt_u(56)},nx110rt_u(127)},nx110rt_u(2)},
      NxBin{"eq",NxBin{"lshr",NxVar{word},nx110rt_u(63)},nx110rt_u(0)}},
    nxo_join(NxStmt,nx110rt_alloc_wrapper(),
      [NxStore{NxU64{},nx110rt_addr(NxVar{"ir_wrap"}),0,NxBin{"or",NxBin{"shl",nx110rt_loc(NxVar{word}),nx110rt_u(24)},nx110rt_u(1)}},
       NxSet{word,NxBin{"or",NxBin{"or",NxBin{"shl",NxBin{"lshr",NxVar{word},nx110rt_u(40)},nx110rt_u(40)},NxBin{"shl",nx110rt_u(1),nx110rt_u(63)}},NxVar{"ir_wrap"}}}]),[] }]

@unsafe
def nx110rt_classify(+parent: String, +view: String) -> List<&2,NxStmt>:
  [NxSet{"ir_ok",NxConst{NxU32{},0}},
   NxSet{"ir_loc",nx110rt_loc(NxVar{parent})},
   NxSet{"ir_src",NxVar{"ir_loc"}},
   NxSet{"ir_rfc",NxBin{"lshr",NxVar{parent},nx110rt_u(63)}},
   NxIf{NxBin{"eq",NxVar{"ir_rfc"},nx110rt_u(1)},
     [NxSet{"ir_cell",nx_choose(NxExpr,String.eq(view,"atomic"),u => NxCall{"rt_ir_view",[NxVar{"ctx"},NxVar{"ir_loc"}]},u => NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_loc"}),0})},
      NxIf{NxBin{"eq",NxBin{"and",NxVar{"ir_cell"},nx110rt_u(16777215)},nx110rt_u(1)},
        [NxSet{"ir_src",NxBin{"lshr",NxVar{"ir_cell"},nx110rt_u(24)}},NxSet{"ir_ok",nx110rt_dynamic(NxVar{"ir_src"})}],[]}],
     [NxSet{"ir_ok",nx110rt_dynamic(NxVar{"ir_src"})}]}]

@unsafe
def nx110rt_rebuild_fast(+dest: String, +remaining: String, +cid: U32, +index: U32) -> List<&2,NxStmt>:
  nxo_join(NxStmt,
    [NxSet{"ir_old0",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0}},
     NxSet{"ir_old1",NxLoad{NxU64{},nx110rt_addr(NxVar{"ir_src"}),8}},
     NxIf{NxBin{"eq",NxVar{"ir_rfc"},nx110rt_u(1)},nx110rt_free_wrapper(),[]},
     NxSet{"ir_head",NxVar{nx_choose(String,U32.is_eq(index,0),u => "ir_old0",u => "ir_old1")}},
     NxSet{remaining,NxVar{nx_choose(String,U32.is_eq(index,0),u => "ir_old1",u => "ir_old0")}}],
    nxo_join(NxStmt,nx110rt_seal("ir_head"),nxo_join(NxStmt,nx110rt_seal("ir_tail"),
      [NxStore{NxU64{},nx110rt_addr(NxVar{"ir_src"}),0,NxVar{"ir_head"}},
       NxStore{NxU64{},nx110rt_addr(NxVar{"ir_src"}),8,NxVar{"ir_tail"}},
       NxSet{dest,NxBin{"or",NxBin{"or",NxBin{"shl",nx110rt_u(2),nx110rt_u(56)},NxBin{"shl",nx110rt_u(cid),nx110rt_u(40)}},NxVar{"ir_src"}}} ])))

@unsafe
def nx110rt_rebuild_selected(+parent: String, +dest: String, +cid: U32, +other: String, +tail: List<&2,String>, +view: String, +selection: NxoLawSelection<String>) -> List<&2,NxStmt>:
  match selection:
    case NxoLawSelection{index,retained,remaining}:
      nxo_join(NxStmt,nx110rt_classify(parent,view),
        nxo_join(NxStmt,[NxIf{NxVar{"ir_ok"},
          Con{NxSet{"ir_tail",NxVar{other}},nx110rt_rebuild_fast(dest,remaining,cid,index)},
          [NxSet{dest,NxCall{nxo110_rebuild_name(cid,index),[NxVar{"ctx"},NxVar{parent},NxVar{other}]}},
           NxSet{remaining,NxCall{"rt_fast_field",[NxVar{"ctx"},NxConst{NxU32{},0}]}}]}],
          nxo_join(NxStmt,nxo_nx_moves(tail,0,True{}),nxo_nx_moves(tail,0,False{}))))

@unsafe
def nx110rt_try_fusion(+ops: List<&2,NxoOp>, +view: String) -> Maybe<&2,List<&2,NxStmt>>:
  match ops:
    case Con{NxoTake{parent,Con{a,Con{b,Nil{}}}},Con{NxoBuild{dest,cid,Con{keep,Con{other,Nil{}}}},Con{NxoTail{tail},Nil{}}}}:
      nx_choose(Maybe<&2,List<&2,NxStmt>>,nxo_p_fusion_shape(parent,a,b,dest,cid,keep,other,tail),u => Some{nx110rt_rebuild_selected(parent,dest,cid,other,tail,view,nxo_law_select(String,String.eq(keep,a),a,b))},u => None{})
    case _: None{}

@unsafe
def nx110rt_op(+op: NxoOp, +view: String, +tag_word: String) -> List<&2,NxStmt>:
  match op:
    case NxoBranch{word,cid,yes,no}:
      nxo_join(NxStmt,nx_choose(List<&2,NxStmt>,String.eq(word,tag_word),u => [],u => [NxSet{"tag110",nxo110_tag(word)}]),
        [NxIf{NxBin{"eq",NxVar{"tag110"},nx110rt_u(cid)},nx110rt_ops(yes,view,word),nx110rt_ops(no,view,word)}])
    case _: nxo_p_op(op,"trusted",tag_word)

@unsafe
def nx110rt_fallback(+ops: List<&2,NxoOp>, +view: String, +tag_word: String) -> List<&2,NxStmt>:
  match ops:
    case Nil{}: []
    case Con{head,rest}: nxo_join(NxStmt,nx110rt_op(head,view,tag_word),nx110rt_ops(rest,view,""))

@unsafe
def nx110rt_select(+candidate: Maybe<&2,List<&2,NxStmt>>, +ops: List<&2,NxoOp>, +view: String, +tag_word: String) -> List<&2,NxStmt>:
  match candidate:
    case Some{body}: body
    case None{}: nx110rt_fallback(ops,view,tag_word)

@unsafe
def nx110rt_ops(+ops: List<&2,NxoOp>, +view: String, +tag_word: String) -> List<&2,NxStmt>:
  nx110rt_select(nx110rt_try_fusion(ops,view),ops,view,tag_word)

def nx110rt_locals() -> List<&2,NxParam>:
  [NxParam{"ir_heap",NxPtr{}},NxParam{"ir_alc",NxPtr{}},NxParam{"ir_status",NxU32{}},NxParam{"ir_ok",NxU32{}},
   NxParam{"ir_loc",NxU64{}},NxParam{"ir_src",NxU64{}},NxParam{"ir_rfc",NxU64{}},NxParam{"ir_cell",NxU64{}},
   NxParam{"ir_old0",NxU64{}},NxParam{"ir_old1",NxU64{}},NxParam{"ir_head",NxU64{}},NxParam{"ir_tail",NxU64{}},
   NxParam{"ir_free",NxU64{}},NxParam{"ir_len",NxU64{}},NxParam{"ir_wrap",NxU64{}}]

@unsafe
def nx110rt_function(+name: String, +arity: U32, +next: U32, +body: List<&2,NxoOp>, +view: String) -> NxFunction:
  NxFunction{name,Con{NxParam{"ctx",NxPtr{}},nxo_params("p",0,arity)},NxU64{},
    nxo_join(NxParam,nxo_params("v",0,next),nxo_join(NxParam,nxo_params("next",0,arity),
      nxo_join(NxParam,[NxParam{"status",NxU32{}},NxParam{"tag110",NxU64{}},NxParam{"failed",NxU64{}}],nx110rt_locals()))),
    [NxSet{"ir_heap",NxCall{"rt_ir_heap",[NxVar{"ctx"}]}},NxSet{"ir_alc",NxCall{"rt_ir_alc",[NxVar{"ctx"}]}},
     NxWhile{NxConst{NxU32{},1},nx110rt_ops(body,view,"")},NxReturn{nx110rt_u(0)}]}
