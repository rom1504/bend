# Phase173 explicit wide-return ceiling; alternative module, not production.
# Derived from vertical-store.bend; algorithm and Array tuple ABI unchanged.
# Complete indexed consumer, with tuple results unpacked only by matching
# function parameters (the maintained parser deliberately requires that form).
# Store ownership is consumed at the terminal boundary, charging its release.

@unsafe
def p173v_finished(name: String, result: KTerm, references: List<&2,String>, valid: Bool,
  final: P173Return<Bool>) -> P173VBody:
  match final:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,ok}:
      P173VBody{name,result,references,
        nt_choose(String,valid && ok,u => "",u => "phase173 semantic store refused")}

@unsafe
def p173v_validated(name: String, result: KTerm, references: List<&2,String>,
  checked: P173Return<Bool>) -> P173VBody:
  match checked:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,valid}: p173v_finished(name,result,references,valid,p173s_ok(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok}))

@unsafe
def p173v_exported(name: String, references: List<&2,String>,
  exported: P173Return<KTerm>) -> P173VBody:
  match exported:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,result}: p173v_validated(name,result,references,p173s_valid(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},10000000))

@unsafe
def p173v_referenced(name: String, id: U32,
  referenced: P173Return<List<&2,String>>) -> P173VBody:
  match referenced:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,references}: p173v_exported(name,references,p173s_export(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},id,10000000))

@unsafe
def p173v_compacted(name: String, compacted: P173Return<U32>) -> P173VBody:
  match compacted:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,+id}: p173v_referenced(name,id,p173s_refs(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},id,10000000))

@unsafe
def p173v_imported(name: String, imported: P173Return<U32>) -> P173VBody:
  match imported:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,id}: p173v_compacted(name,p173s_compact(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},id,10000000))

@unsafe
def p173v_candidate_body(input: P173VInput) -> P173VBody:
  match input:
    case P173VInput{name,body}: p173v_imported(name,p173s_import(p173s_new(),body,10000000))

@unsafe
def p173v_candidate(inputs: List<&2,P173VInput>) -> List<&2,P173VBody>:
  match inputs:
    case Nil{}: []
    case Con{head,rest}: Con{p173v_candidate_body(head),p173v_candidate(rest)}

# Separate import/export gate before compaction intentionally removes metadata.
@unsafe
def p173v_roundtrip(input: P173VInput) -> P173VBody:
  match input:
    case P173VInput{name,body}: p173v_compacted(name,p173s_import(p173s_new(),body,10000000))

@unsafe
def p173v_compact_result(observation: P173VBody) -> KTerm:
  match observation:
    case P173VBody{name,result,references,error}:
      nt_choose(KTerm,String.is_empty(error),u => result,
        u => kt("Error","phase173 semantic compaction refused",0,0,[]))

@unsafe
def p173v_compact_export(compacted: P173Return<U32>) -> KTerm:
  match compacted:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,id}: p173v_compact_result(p173v_exported("",[],p173s_export(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},id,10000000)))

@unsafe
def p173v_compact_import(imported: P173Return<U32>) -> KTerm:
  match imported:
    case P173Return{p173r_nodes,p173r_edges,+p173r_used,+p173r_edgeUsed,+p173r_nodeCapacity,+p173r_edgeCapacity,+p173r_ok,id}: p173v_compact_export(p173s_compact(P173Store{p173r_nodes,p173r_edges,p173r_used,p173r_edgeUsed,p173r_nodeCapacity,p173r_edgeCapacity,p173r_ok},id,10000000))

# Full-request compatibility slice: legacy downstream reference discovery is
# still paid. No unused indexed refs are computed in this separate bridge.
@unsafe
def p173v_store_compact(body):
  p173v_compact_import(p173s_import(p173s_new(),body,10000000))
