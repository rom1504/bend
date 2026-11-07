# Complete indexed consumer, with tuple results unpacked only by matching
# function parameters (the maintained parser deliberately requires that form).
# Store ownership is consumed at the terminal boundary, charging its release.

@unsafe
def p173v_finished(name: String, result: KTerm, references: List<&2,String>, valid: Bool,
  final: P173Store & Bool) -> P173VBody:
  match final:
    case Tuple{store,ok}:
      P173VBody{name,result,references,
        nt_choose(String,valid && ok,u => "",u => "phase173 semantic store refused")}

@unsafe
def p173v_validated(name: String, result: KTerm, references: List<&2,String>,
  checked: P173Store & Bool) -> P173VBody:
  match checked:
    case Tuple{store,valid}: p173v_finished(name,result,references,valid,p173s_ok(store))

@unsafe
def p173v_exported(name: String, references: List<&2,String>,
  exported: P173Store & KTerm) -> P173VBody:
  match exported:
    case Tuple{store,result}: p173v_validated(name,result,references,p173s_valid(store,10000000))

@unsafe
def p173v_referenced(name: String, id: U32,
  referenced: P173Store & List<&2,String>) -> P173VBody:
  match referenced:
    case Tuple{store,references}: p173v_exported(name,references,p173s_export(store,id,10000000))

@unsafe
def p173v_compacted(name: String, compacted: P173Store & U32) -> P173VBody:
  match compacted:
    case Tuple{store,+id}: p173v_referenced(name,id,p173s_refs(store,id,10000000))

@unsafe
def p173v_imported(name: String, imported: P173Store & U32) -> P173VBody:
  match imported:
    case Tuple{store,id}: p173v_compacted(name,p173s_compact(store,id,10000000))

@unsafe
def p173v_candidate_body(input: P173VInput) -> P173VBody:
  match input:
    case P173VInput{name,body}: p173v_imported(name,p173s_import(p173s_new(),body,10000000))

@unsafe
def p173v_candidate(inputs: List<&2,P173VInput>) -> List<&2,P173VBody>:
  p173o_candidate(inputs)

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
def p173v_compact_export(compacted: P173Store & U32) -> KTerm:
  match compacted:
    case Tuple{store,id}: p173v_compact_result(p173v_exported("",[],p173s_export(store,id,10000000)))

@unsafe
def p173v_compact_import(imported: P173Store & U32) -> KTerm:
  match imported:
    case Tuple{store,id}: p173v_compact_export(p173s_compact(store,id,10000000))

# Full-request compatibility slice: legacy downstream reference discovery is
# still paid. No unused indexed refs are computed in this separate bridge.
@unsafe
def p173v_store_compact(body):
  p173v_compact_import(p173s_import(p173s_new(),body,10000000))
