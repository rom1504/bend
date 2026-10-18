# Structural controls only. Runtime ownership/lifetime has separate witnesses.
type NxLibControl is Data:
  NxLibControl{+name: String, +library: NxLibrary, +expected: Bool}

def nxlib_control_worker(body: List<&2, NxStmt>) -> NxFunction:
  NxFunction{"worker", [NxParam{"ctx", NxPtr{}}, NxParam{"term", NxU64{}}], NxU64{},
    [NxParam{"status", NxU32{}}, NxParam{"out", NxU64{}}], body}

def nxlib_control_library(body: List<&2, NxStmt>) -> NxLibrary:
  NxLibrary{nxlib_runtime_imports(), [nxlib_control_worker(body)], ["worker"]}

def nxlib_control_keep() -> NxExpr:
  NxCall{"rt_keep", [NxVar{"ctx"}, NxVar{"term"}]}

def nxlib_control_cases() -> List<&2, NxLibControl>:
  [NxLibControl{"identity", nxlib_control_library([NxReturn{NxVar{"term"}}]), True{}},
   NxLibControl{"explicit-import", nxlib_control_library([NxReturn{nxlib_control_keep()}]), True{}},
   NxLibControl{"effect-sequence", nxlib_control_library([
     NxSet{"out", nxlib_control_keep()},
     NxSet{"status", NxCall{"rt_sink", [NxVar{"ctx"}, NxVar{"out"}]}},
     NxReturn{NxVar{"out"}}]), True{}},
   NxLibControl{"missing-import", NxLibrary{[], [nxlib_control_worker([NxReturn{nxlib_control_keep()}])], ["worker"]}, False{}},
   NxLibControl{"duplicate-import", NxLibrary{[
     NxImport{"rt_keep", [NxParam{"ctx", NxPtr{}}, NxParam{"term", NxU64{}}], NxU64{}},
     NxImport{"rt_keep", [NxParam{"ctx", NxPtr{}}, NxParam{"term", NxU64{}}], NxU64{}}],
     [nxlib_control_worker([NxReturn{NxVar{"term"}}])], ["worker"]}, False{}},
   NxLibControl{"import-definition-collision", NxLibrary{[
     NxImport{"worker", [NxParam{"ctx", NxPtr{}}, NxParam{"term", NxU64{}}], NxU64{}}],
     [nxlib_control_worker([NxReturn{NxVar{"term"}}])], ["worker"]}, False{}},
   NxLibControl{"bad-import-parameter", NxLibrary{[
     NxImport{"rt_keep", [NxParam{"ctx", NxBad{}}], NxU64{}}],
     [nxlib_control_worker([NxReturn{NxVar{"term"}}])], ["worker"]}, False{}},
   NxLibControl{"bad-import-result", NxLibrary{[NxImport{"rt_keep", [], NxBad{}}],
     [nxlib_control_worker([NxReturn{NxVar{"term"}}])], ["worker"]}, False{}},
   NxLibControl{"wrong-term-width", nxlib_control_library([NxReturn{NxCall{"rt_keep", [NxVar{"ctx"}, NxConst{NxU32{}, 0}]}}]), False{}},
   NxLibControl{"wrong-context-type", nxlib_control_library([NxReturn{NxCall{"rt_keep", [NxVar{"term"}, NxVar{"term"}]}}]), False{}},
   NxLibControl{"wrong-import-arity", nxlib_control_library([NxReturn{NxCall{"rt_keep", [NxVar{"ctx"}]}}]), False{}},
   NxLibControl{"effect-in-operand", nxlib_control_library([NxReturn{NxBin{"add", nxlib_control_keep(), NxConst{NxU64{}, 0}}}]), False{}},
   NxLibControl{"effect-in-condition", nxlib_control_library([
     NxIf{NxCall{"rt_id", [NxVar{"ctx"}, NxVar{"term"}]}, [NxReturn{NxVar{"term"}}], [NxReturn{NxVar{"term"}}]}]), False{}},
   NxLibControl{"raw-allocation", NxLibrary{[], [NxFunction{"worker", [NxParam{"ctx", NxPtr{}}, NxParam{"term", NxU64{}}], NxU64{},
     [NxParam{"ptr", NxPtr{}}], [NxSet{"ptr", NxAlloc{NxConst{NxU32{}, 16}}}, NxReturn{NxVar{"term"}}]}], ["worker"]}, False{}},
   NxLibControl{"raw-context-load", nxlib_control_library([NxReturn{NxLoad{NxU64{}, NxVar{"ctx"}, 0}}]), False{}},
   NxLibControl{"raw-context-store", nxlib_control_library([NxStore{NxU64{}, NxVar{"ctx"}, 0, NxVar{"term"}}, NxReturn{NxVar{"term"}}]), False{}},
   NxLibControl{"raw-context-free", nxlib_control_library([NxFree{NxVar{"ctx"}}, NxReturn{NxVar{"term"}}]), False{}},
   NxLibControl{"indirect-import", nxlib_control_library([NxReturn{NxICall{NxFunc{"rt_keep"}, [NxVar{"ctx"}, NxVar{"term"}], [NxPtr{}, NxU64{}], NxU64{}}}]), False{}},
   NxLibControl{"no-export", NxLibrary{[], [nxlib_control_worker([NxReturn{NxVar{"term"}}])], []}, False{}},
   NxLibControl{"missing-export", NxLibrary{[], [nxlib_control_worker([NxReturn{NxVar{"term"}}])], ["absent"]}, False{}},
   NxLibControl{"duplicate-export", NxLibrary{[], [nxlib_control_worker([NxReturn{NxVar{"term"}}])], ["worker", "worker"]}, False{}},
   NxLibControl{"import-is-not-export", NxLibrary{nxlib_runtime_imports(), [nxlib_control_worker([NxReturn{NxVar{"term"}}])], ["rt_keep"]}, False{}},
   NxLibControl{"u32-result-is-not-term", NxLibrary{[], [NxFunction{"worker", [NxParam{"ctx", NxPtr{}}], NxU32{}, [], [NxReturn{NxConst{NxU32{}, 0}}]}], ["worker"]}, False{}},
   NxLibControl{"scalar-context-is-not-pointer", NxLibrary{[], [NxFunction{"worker", [NxParam{"ctx", NxU64{}}], NxU64{}, [], [NxReturn{NxVar{"ctx"}}]}], ["worker"]}, False{}},
   NxLibControl{"trusted-import",NxLibrary{nxlib_runtime_imports_policy("trusted"),[nxlib_control_worker([NxReturn{NxCall{"rt_fast_keep",[NxVar{"ctx"},NxVar{"term"}]}}])],["worker"]},True{}},
   NxLibControl{"raw-forbids-trusted-import",NxLibrary{nxlib_runtime_imports_policy("raw"),[nxlib_control_worker([NxReturn{NxCall{"rt_fast_keep",[NxVar{"ctx"},NxVar{"term"}]}}])],["worker"]},False{}},
   NxLibControl{"trusted-forbids-checked-import",NxLibrary{nxlib_runtime_imports_policy("trusted"),[nxlib_control_worker([NxReturn{nxlib_control_keep()}])],["worker"]},False{}},
   NxLibControl{"fused-import",NxLibrary{nxlib_runtime_imports_policy("fused"),[nxlib_control_worker([NxReturn{NxCall{"rt_rebuild2",[NxVar{"ctx"},NxVar{"term"},NxConst{NxU32{},1},NxConst{NxU32{},0},NxVar{"term"}]}}])],["worker"]},True{}},
   NxLibControl{"trusted-forbids-fused-import",NxLibrary{nxlib_runtime_imports_policy("trusted"),[nxlib_control_worker([NxReturn{NxCall{"rt_rebuild2",[NxVar{"ctx"},NxVar{"term"},NxConst{NxU32{},1},NxConst{NxU32{},0},NxVar{"term"}]}}])],["worker"]},False{}},
   NxLibControl{"fused-index-width",NxLibrary{nxlib_runtime_imports_policy("fused"),[nxlib_control_worker([NxReturn{NxCall{"rt_rebuild2",[NxVar{"ctx"},NxVar{"term"},NxConst{NxU32{},1},NxConst{NxU64{},0},NxVar{"term"}]}}])],["worker"]},False{}}]

def nxlib_control_result(name: String, ok: Bool) -> String:
  name ++ nx_choose(String, ok, u => " PASS\n", u => " FAIL\n")

@unsafe
def nxlib_control_report_cases(+cases: List<&2, NxLibControl>) -> String:
  match cases:
    case Nil{}: ""
    case Con{NxLibControl{name, library, expected}, rest}:
      nxlib_control_result(name, U32.is_eq(nx_bool32(nxlib_verify(library)), nx_bool32(expected))) ++ nxlib_control_report_cases(rest)

@unsafe
def nxlib_control_report() -> String:
  nxlib_control_report_cases(nxlib_control_cases()) ++
  nxlib_control_result("imports-remain-effectful", Bool.not(nx_pure(nxlib_control_keep()))) ++
  nxlib_control_result("scalar-entry-rule-unchanged", Bool.not(nx_verify(NxProgram{"worker", [nxlib_control_worker([NxReturn{NxVar{"term"}}])]}))) ++
  nxlib_control_result("fold-keeps-imports", String.eq(
    nxlib_qbe(nxlib_control_library([NxReturn{nxlib_control_keep()}])),
    nxlib_qbe(nxlib_optimize(nxlib_control_library([NxReturn{nxlib_control_keep()}]))))) ++
  nxlib_control_result("unknown-runtime-policy-refused",Bool.not(nxlib_runtime_policy_valid("unknown"))) ++
  nxlib_control_result("trusted-imports-remain-effectful",Bool.not(nx_pure(NxCall{"rt_fast_keep",[NxVar{"ctx"},NxVar{"term"}]})))
