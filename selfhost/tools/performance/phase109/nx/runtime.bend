# bend-runtime-109-v1. The context is opaque NxPtr; owned/borrowed Terms occupy
# NxU64 and are never treated as addresses. All eight calls are effect barriers.
# Runtime ids: Nil=0, Con=1, SNil=2, SCon=3. id borrows; keep returns a possibly
# changed owning word; sink consumes. take2 consumes parent; field transfers each
# scratch field once before another take2. build2 consumes both children.
def nxlib_runtime_named(+prefix: String) -> List<&2, NxImport>:
  [NxImport{prefix ++ "id", [NxParam{"ctx", NxPtr{}}, NxParam{"term", NxU64{}}], NxU32{}},
   NxImport{prefix ++ "keep", [NxParam{"ctx", NxPtr{}}, NxParam{"term", NxU64{}}], NxU64{}},
   NxImport{prefix ++ "sink", [NxParam{"ctx", NxPtr{}}, NxParam{"term", NxU64{}}], NxU32{}},
   NxImport{prefix ++ "take2", [NxParam{"ctx", NxPtr{}}, NxParam{"term", NxU64{}}], NxU32{}},
   NxImport{prefix ++ "field", [NxParam{"ctx", NxPtr{}}, NxParam{"index", NxU32{}}], NxU64{}},
   NxImport{prefix ++ "build2", [NxParam{"ctx", NxPtr{}}, NxParam{"cid", NxU32{}}, NxParam{"head", NxU64{}}, NxParam{"tail", NxU64{}}], NxU64{}},
   NxImport{prefix ++ "zero", [NxParam{"ctx", NxPtr{}}, NxParam{"cid", NxU32{}}], NxU64{}},
   NxImport{"rt_fail", [NxParam{"ctx", NxPtr{}}, NxParam{"reason", NxU32{}}], NxU64{}}]

def nxlib_runtime_imports() -> List<&2, NxImport>:
  nxlib_runtime_named("rt_")

def nxlib_runtime_policy_valid(+policy: String) -> Bool:
  String.eq(policy,"raw") || String.eq(policy,"trusted") || String.eq(policy,"fused")

# These catalogues stay disjoint: an unchecked public entry never silently
# acquires trusted imports. Caller must admit the policy before choosing it.
# Invalid policy has no declarations and is explicitly rejected by the caller.
def nxlib_runtime_imports_policy(+policy: String) -> List<&2, NxImport>:
  nx_choose(List<&2,NxImport>,String.eq(policy,"raw"),u => nxlib_runtime_imports(),u =>
  nx_choose(List<&2,NxImport>,String.eq(policy,"trusted"),u => nxlib_runtime_named("rt_fast_"),u =>
  nx_choose(List<&2,NxImport>,String.eq(policy,"fused"),u =>
    Con{NxImport{"rt_rebuild2",[NxParam{"ctx",NxPtr{}},NxParam{"parent",NxU64{}},NxParam{"cid",NxU32{}},NxParam{"keep_index",NxU32{}},NxParam{"other",NxU64{}}],NxU64{}},nxlib_runtime_named("rt_fast_")},u => [])))
