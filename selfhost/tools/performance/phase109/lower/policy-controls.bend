@unsafe
def nxo_p_available(+ops: List<&2,NxoOp>) -> Bool:
  nxo_p_available_result(nxo_p_try_fusion(ops))

def nxo_p_available_result(result: Maybe<&2,List<&2,NxStmt>>) -> Bool:
  match result:
    case Some{body}: True{}
    case None{}: False{}

def nxo_p_fixture(+kept: String, +other: String, +tail: List<&2,String>) -> List<&2,NxoOp>:
  [NxoTake{"p0",["v0","v1"]},NxoBuild{"v2",1,[kept,other]},NxoTail{tail}]

@unsafe
def nxo_p_case(+name: String, +value: Bool, +expected: Bool) -> String:
  name ++ ":" ++ nx_choose(String,U32.is_eq(nx_bool32(value),nx_bool32(expected)),u => "pass",u => "FAIL") ++ "\n"

@unsafe
def nxo_p_calls_expr(+expr: NxExpr, +name: String) -> U32:
  match expr:
    case NxCall{target,args}: nx_bool32(String.eq(name,target))
    case _: 0

@unsafe
def nxo_p_calls(+body: List<&2,NxStmt>, +name: String) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: U32.add(nxo_p_calls_op(head,name),nxo_p_calls(rest,name))

@unsafe
def nxo_p_calls_op(+stmt: NxStmt, +name: String) -> U32:
  match stmt:
    case NxSet{dest,value}: nxo_p_calls_expr(value,name)
    case NxIf{condition,yes,no}: U32.add(nxo_p_calls(yes,name),nxo_p_calls(no,name))
    case NxWhile{condition,body}: nxo_p_calls(body,name)
    case _: 0

def nxo_p_chain() -> List<&2,NxoOp>:
  [NxoBranch{"p0",0,[NxoFail{1}],[NxoBranch{"p0",1,[NxoFail{1}],[NxoFail{1}]}]}]

@unsafe
def nxo_policy_report() -> String:
  nxo_p_case("fuse_head",nxo_p_available(nxo_p_fixture("v0","p1",["v1","v2"])),True{}) ++
  nxo_p_case("fuse_second_field",nxo_p_available(nxo_p_fixture("v1","p1",["v0","v2"])),True{}) ++
  nxo_p_case("fuse_permuted_tail",nxo_p_available(nxo_p_fixture("v0","p1",["v2","v1"])),True{}) ++
  nxo_p_case("reject_other_parent",nxo_p_available(nxo_p_fixture("v0","p0",["v1","v2"])),False{}) ++
  nxo_p_case("reject_other_first_child",nxo_p_available(nxo_p_fixture("v0","v0",["v1","v2"])),False{}) ++
  nxo_p_case("reject_other_second_child",nxo_p_available(nxo_p_fixture("v0","v1",["v1","v2"])),False{}) ++
  nxo_p_case("reject_missing_remaining",nxo_p_available(nxo_p_fixture("v0","p1",["v2","v2"])),False{}) ++
  nxo_p_case("reject_kept_escape",nxo_p_available(nxo_p_fixture("v0","p1",["v0","v2"])),False{}) ++
  nxo_p_case("reject_unknown_keep",nxo_p_available(nxo_p_fixture("p1","p1",["v1","v2"])),False{}) ++
  nxo_p_case("reject_intervening_keep",nxo_p_available([NxoTake{"p0",["v0","v1"]},NxoKeep{"v0"},NxoBuild{"v2",1,["v0","p1"]},NxoTail{["v1","v2"]}]),False{}) ++
  nxo_p_case("reject_extra_tail_op",nxo_p_available([NxoTake{"p0",["v0","v1"]},NxoBuild{"v2",1,["v0","p1"]},NxoTail{["v1","v2"]},NxoFail{1}]),False{}) ++
  nxo_p_case("reject_nullary_output",nxo_p_available([NxoTake{"p0",["v0","v1"]},NxoBuild{"v2",0,["v0","p1"]},NxoTail{["v1","v2"]}]),False{}) ++
  nxo_p_case("reject_destination_alias",nxo_p_available([NxoTake{"p0",["v0","v1"]},NxoBuild{"v0",1,["v0","p1"]},NxoTail{["v1","v0"]}]),False{}) ++
  nxo_p_case("raw_checks_two_tags",U32.is_eq(nxo_p_calls(nxo_nx_ops(nxo_p_chain()),"rt_id"),2),True{}) ++
  nxo_p_case("trusted_reuses_tag",U32.is_eq(nxo_p_calls(nxo_p_ops(nxo_p_chain(),"trusted",""),"rt_fast_id"),1),True{}) ++
  nxo_p_case("intervening_keep_invalidates_tag",U32.is_eq(nxo_p_calls(nxo_p_ops([NxoKeep{"p0"},NxoBranch{"p0",0,[NxoFail{1}],[NxoFail{1}]}],"trusted","p0"),"rt_fast_id"),1),True{}) ++
  nxo_p_case("fused_has_one_rebuild",U32.is_eq(nxo_p_calls(nxo_p_ops(nxo_p_fixture("v0","p1",["v1","v2"]),"fused",""),"rt_rebuild2"),1),True{}) ++
  nxo_p_case("fused_has_one_field_transfer",U32.is_eq(nxo_p_calls(nxo_p_ops(nxo_p_fixture("v0","p1",["v1","v2"]),"fused",""),"rt_fast_field"),1),True{}) ++
  nxo_p_case("fused_has_no_take_call",U32.is_eq(nxo_p_calls(nxo_p_ops(nxo_p_fixture("v0","p1",["v1","v2"]),"fused",""),"rt_fast_take2"),0),True{})
