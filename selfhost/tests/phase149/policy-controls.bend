@unsafe
def p149pc_codes(+at: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_eq(at,12),u => [],
    u => Con{p113ft_row("policy-valid-" ++ U32.show(at),p149p_valid(at)),p149pc_codes(U32.inc(at))})

@unsafe
def p149p_controls() -> List<&2,String>:
  +request = p128rawc_request()
  nt_append(String,p149pc_codes(0),[
    p113ft_row("policy-invalid-12",Bool.not(p149p_valid(12))),
    p113ft_row("policy-invalid-max",Bool.not(p149p_valid(4294967295))),
    p113ft_row("policy-current-inline",p149p_enabled(0,1)),
    p113ft_row("policy-current-helpers",p149p_enabled(0,2)),
    p113ft_row("policy-skip-inline",Bool.not(p149p_enabled(1,1))),
    p113ft_row("policy-skip-helpers",Bool.not(p149p_enabled(2,2))),
    p113ft_row("policy-regions-current",U32.is_eq(p149p_regions(3),0)),
    p113ft_row("policy-regions-H",U32.is_eq(p149p_regions(7),1)),
    p113ft_row("policy-regions-generic",U32.is_eq(p149p_regions(11),2)),
    p113ft_row("policy-original-admission-error",p128rawc_same(
      p149p_emit_admitted(0,request,"control"),p128raw_emit_admitted(request,"control"))),
    p113ft_row("policy-disabled-admission-error",p128rawc_same(
      p149p_emit_admitted(11,request,"control"),p128raw_emit_admitted(request,"control"))),
    p113ft_row("policy-original-preparation-error",p128rawc_same(
      p149p_prepared(0,"x","",P86PreparationError{"control"}),p134e_prepared("x","",P86PreparationError{"control"}))),
    p113ft_row("policy-disabled-preparation-error",p128rawc_same(
      p149p_prepared(11,"x","",P86PreparationError{"control"}),p134e_prepared("x","",P86PreparationError{"control"}))),
    p113ft_row("policy-disabled-final-verifier-error",p128rawc_same(
      p149p_verified(11,request,[],p128rawc_original(),"control"),p128raw_verified(request,[],p128rawc_original(),"control"))),
    p113ft_row("policy-disabled-real-invalid-direct-refused",p149pc_refusal(
      p149p_closed(11,request,[],N111Ids{missing(),missing()},True{},P113ALowered{
        P113AProgram{P113DProgram{P112StaticProgram{p111_empty(),[]},
          [P113DFunction{"invalid",[],0,False{},[]}]},P113ACertificate{False{},False{}}},""})))])

@unsafe
def p149pc_refusal(result: P111Emission) -> Bool:
  match result:
    case P111Emission{chunks,error}: Bool.not(String.is_empty(error))
    case P134Planned{plan}: False{}
