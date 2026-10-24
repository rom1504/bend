# v01 preserved: emitter constructor IDs encode ID/width differently from
# the independent verifier catalogue. Use the original verifier table ABI here.
@unsafe
def p131w_verifier_ids() -> N111Ids:
  N111Ids{missing(),p111v_put(p111v_put(p111v_put(p111v_put(missing(),
    "eight","constructor",8,0),"nine","constructor",9,0),
    "sixteen","constructor",16,0),"seventeen","constructor",17,0)}

@unsafe
def p131w_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids([
    N_Constructor{"eight",8,False{}},N_Constructor{"nine",9,False{}},
    N_Constructor{"sixteen",16,False{}},N_Constructor{"seventeen",17,False{}}],0,missing())}

@unsafe
def p131w_project(ctor: String, count: U32, state: String, typ: N111Type) -> Bool:
  String.is_empty(p113d_error(p118b_project_borrow("result",typ,
    [N111Arg{N111Ptr{},N111Local{state}},p111_word(N111Local{"root"}),
     N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111CtorId{ctor}},p111_u32(count)],p131w_verifier_ids())))

@unsafe
def p131w_controls() -> List<&2,String>:
  +args : List<&2,N111Arg> = [N111Arg{N111Ptr{},N111Local{"buffer"}}]
  +small = p111v_put(missing(),"buffer","alloca",3,64)
  +large = p111v_put(missing(),"buffer","alloca",3,128)
  [p128bs_control_row("wide-eight",p131rg_width(8)),
   p128bs_control_row("wide-nine",p131rg_width(9)),
   p128bs_control_row("wide-sixteen",p131rg_width(16)),
   p128bs_control_row("wide-seventeen-refused",Bool.not(p131rg_width(17))),
   p128bs_control_row("wide-packed-refused",Bool.not(p131rg_width(1))),
   p128bs_control_row("wide-import-eight",p131w_project("eight",8,"state",N111U64{})),
   p128bs_control_row("wide-import-nine",p131w_project("nine",9,"state",N111U64{})),
   p128bs_control_row("wide-import-sixteen",p131w_project("sixteen",16,"state",N111U64{})),
   p128bs_control_row("wide-import-seventeen-refused",Bool.not(p131w_project("seventeen",17,"state",N111U64{}))),
   p128bs_control_row("wide-import-mismatch-refused",Bool.not(p131w_project("nine",8,"state",N111U64{}))),
   p128bs_control_row("wide-import-unknown-refused",Bool.not(p131w_project("unknown",9,"state",N111U64{}))),
   p128bs_control_row("wide-import-state-refused",Bool.not(p131w_project("nine",9,"other",N111U64{}))),
   p128bs_control_row("wide-import-result-refused",Bool.not(p131w_project("nine",9,"state",N111Ptr{}))),
   p128bs_control_row("wide-buffer-nine-small-refused",Bool.not(p111v_buffer(args,0,9,small))),
   p128bs_control_row("wide-buffer-sixteen-128",p111v_buffer(args,0,16,large)),
   p128bs_control_row("wide-buffer-unknown-refused",Bool.not(p111v_buffer(args,0,9,missing()))),
   p128bs_control_row("wide-late-template-stays-refused",Bool.not(p128bf_test_admitted(p128bf_test_ordinary("nine",9),p131w_ids(),0)))]
