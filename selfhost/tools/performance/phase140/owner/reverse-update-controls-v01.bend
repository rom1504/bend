@unsafe
def p140qu_case(+before: List<&2,P140OEdge>, +after: List<&2,P140OEdge>, changed: List<&2,String>, +seed: List<&2,String>) -> Bool:
  p140qu_changed(before,after,p140qc_seed(changed,P140ODirty{missing(),0}),p140qc_seed(seed,P140ODirty{missing(),0}))

@unsafe
def p140qu_changed(+before: List<&2,P140OEdge>, +after: List<&2,P140OEdge>, changed: P140ODirty, +initial: P140ODirty) -> Bool:
  match changed:
    case P140ODirty{names,count}:
      p140qc_equal(p140o_fix(after,initial,U32.inc(nt_count(P140OEdge,after))),
        p140oq_with(p140oq_refresh(before,p140oq_build(before),P140OAnalysis{True{},names,after,count}),initial))

@unsafe
def p140qu_controls() -> List<&2,String>:
  [p140oc_row("reverse-update-removes-old-dependency",p140qu_case([P140OEdge{"a",["b"]},P140OEdge{"b",["c"]}],[P140OEdge{"a",[]},P140OEdge{"b",["c"]}],["a"],["b"])),
   p140oc_row("reverse-update-adds-new-dependency",p140qu_case([P140OEdge{"a",[]},P140OEdge{"b",["c"]}],[P140OEdge{"a",["b"]},P140OEdge{"b",["c"]}],["a"],["c"])),
   p140oc_row("reverse-update-duplicate-owner-preserved",p140qu_case([P140OEdge{"a",["b"]},P140OEdge{"a",["b"]}],[P140OEdge{"a",[]},P140OEdge{"a",["b"]}],["a"],["b"])),
   p140oc_row("reverse-update-duplicate-owner-removed",p140qu_case([P140OEdge{"a",["b"]},P140OEdge{"a",["b"]}],[P140OEdge{"a",[]},P140OEdge{"a",[]}],["a"],["b"])),
   p140oc_row("reverse-update-unknown-reference",p140qu_case([P140OEdge{"a",["old"]}],[P140OEdge{"a",["new"]}],["a"],["new"])),
   p140oc_row("reverse-update-hash-collision",p140qu_case([P140OEdge{"a",["costarring"]},P140OEdge{"b",["liquid"]}],[P140OEdge{"a",["liquid"]},P140OEdge{"b",["liquid"]}],["a"],["costarring"])),
   p140oc_row("reverse-update-fallback-builds-current",p140qu_fallback())]

@unsafe
def p140qu_fallback() -> Bool:
  +old: List<&2,P140OEdge> = [P140OEdge{"a",["old"]}]
  +next: List<&2,P140OEdge> = [P140OEdge{"a",["new"]},P140OEdge{"b",["a"]}]
  +initial = p140qc_seed(["new"],P140ODirty{missing(),0})
  p140qc_equal(p140o_fix(next,initial,3),p140oq_with(p140oq_refresh(old,p140oq_build(old),P140OAnalysis{False{},missing(),next,0}),initial))
