# Pure differential controls retain the existing emitters as independent reference.
# Synthetic IR below is never executed; end-to-end checked requests test the gates.
@unsafe
def p134ec_chunks(left: List<&2,String>, right: List<&2,String>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,arest} Con{b,brest}: String.eq(a,b) && p134ec_chunks(arest,brest)
    case _ _: False{}

@unsafe
def p134ec_plan(+plan: P134EmissionPlan, expected: List<&2,String>) -> Bool:
  p134ec_chunks(p134e_collect_cursor(p134e_begin(plan),[],[]),expected)

@unsafe
def p134ec_program() -> P111Program:
  P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{7,0}}]}],[],[],[],[],True{}}

@unsafe
def p134ec_function() -> P113DFunction:
  P113DFunction{"main",[],1,False{},[P113DResult{[N111Const{7,0}]}]}

@unsafe
def p134ec_datum_rows(+count: U32, +acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  nt_choose(List<&2,P111QDatum>,U32.is_eq(count,0),u => acc,
    u => p134ec_datum_rows(U32.sub(count,1),Con{P111QWord{count},acc}))

@unsafe
def p134ec_tables() -> Bool:
  +tables : List<&2,P111QData> = [P111QData{"empty",1,False{},[]},
    P111QData{"mixed",8,True{},[P111QByte{255},P111QWord{4294967295},P111QLong{4294967295,4294967295},P111QReloc{"a_b",0},P111QReloc{"a_b",8},P111QZeros{32}]},
    P111QData{"boundary",4,False{},p134ec_datum_rows(257,[])}]
  p134ec_chunks(p134e_collect_cursor(P134Tables{tables},[],[]),
    nt_append(String,p111q_data_chunks_go(tables,[]),[p111q_main()]))

@unsafe
def p134ec_legacy() -> Bool:
  +program = p134ec_program()
  +ids = p111q_ids(program)
  +segment : N111Segment = N111Segment{"first",0,1,0,0,[]}
  +segment2 : N111Segment = N111Segment{"second",0,1,0,0,[]}
  +plan : P112WorkerPlan = P112WorkerPlan{True{},0,[],[P112WorkerScalar{N111Return{N111Const{9,0}}}]}
  +entries : List<&2,P112RegionEntry> = [P112RegionEntry{segment,plan,0,0},P112RegionEntry{segment2,plan,0,0}]
  +context : P134Context = P134Context{ids,p112f_index([]),missing(),missing(),missing(),[],0,0}
  p134ec_chunks(p134e_collect_cursor(P134Legacy{nt_reverse(P112RegionEntry,entries,[]),context,P134Main{}},[],[]),
    [nt_join(p112c_private_chunks(entries,ids,[]),"") ++ p111q_main()])

@unsafe
def p134ec_error() -> Bool:
  p134ec_same_error(p134e_collect(P111Emission{[],"frozen-refusal"}))

@unsafe
def p134ec_same_error(value: P111Emission) -> Bool:
  match value:
    case P111Emission{chunks,error}: List.is_empty(&2,String,chunks) && String.eq(error,"frozen-refusal")
    case P134Planned{plan}: False{}

@unsafe
def p134ec_controls() -> List<&2,String>:
  +program = p134ec_program()
  +static : P112StaticProgram = P112StaticProgram{program,[]}
  +empty : P113DProgram = P113DProgram{static,[]}
  +direct : P113DProgram = P113DProgram{static,[p134ec_function()]}
  +arrays : P113AProgram = P113AProgram{direct,P113ACertificate{True{},True{}}}
  +boxed : P113AProgram = P113AProgram{direct,P113ACertificate{False{},False{}}}
  +none : P113AProgram = P113AProgram{empty,P113ACertificate{True{},True{}}}
  [p113ft_row("stream-raw-chunk-identity",p134ec_plan(P134Raw{program},p111q_chunks(program))),
   p113ft_row("stream-static-empty-chunk-identity",p134ec_plan(P134Static{static},p112s_chunks(static))),
   p113ft_row("stream-direct-empty-chunk-identity",p134ec_plan(P134Direct{empty},p113e_admitted_chunks(empty))),
   p113ft_row("stream-direct-chunk-identity",p134ec_plan(P134Direct{direct},p113e_admitted_chunks(direct))),
   p113ft_row("stream-admitted-array-chunk-identity",p134ec_plan(P134Admitted{arrays},p113a_admitted_chunks(arrays))),
   p113ft_row("stream-admitted-boxed-chunk-identity",p134ec_plan(P134Admitted{boxed},p113a_admitted_chunks(boxed))),
   p113ft_row("stream-admitted-no-private-chunk-identity",p134ec_plan(P134Admitted{none},p113a_admitted_chunks(none))),
   p113ft_row("stream-data-257-and-empty-boundaries",p134ec_tables()),
   p113ft_row("stream-legacy-prefix-one-chunk",p134ec_legacy()),
   p113ft_row("stream-error-preserved",p134ec_error()),
   p113ft_row("stream-static-nonempty-chunk-identity",p134ec_static()),
   p113ft_row("stream-livebank-refusal-selection",p134ec_live_refusal()),
   p113ft_row("stream-data-slice-limit",p134ec_slice_limit()),
   p113ft_row("stream-seal-error-preserved",p134ec_seal_error())]

@unsafe
def p134ec_static() -> Bool:
  +program : P111Program = P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{7,0}}]}],
    [N_Constructor{"SNil",0,True{}}],[],[],[],True{}}
  +static : P112StaticProgram = P112StaticProgram{program,[P112SNode{0,"SNil",[]}]}
  p134ec_plan(P134Static{static},p112s_chunks(static))

@unsafe
def p134ec_live_refusal() -> Bool:
  +function : P113DFunction = P113DFunction{"main",[],1,False{},
    [P113DScalar{N111Load{"probe",N111U64{},N111Local{"state"},48}},P113DResult{[N111Const{7,0}]}]}
  +admitted : P113AProgram = P113AProgram{P113DProgram{P112StaticProgram{p134ec_program(),[]},[function]},P113ACertificate{True{},True{}}}
  Bool.not(p118z_eligible(admitted)) && p134ec_plan(P134Admitted{admitted},p113a_admitted_chunks(admitted))

@unsafe
def p134ec_slice_limit() -> Bool:
  p134ec_slice_result(p134e_data_slice(p134ec_datum_rows(129,[]),True{},128,[]))

@unsafe
def p134ec_slice_result(slice: P134DataSlice) -> Bool:
  match slice:
    case P134DataSlice{text,Con{P111QWord{last},Nil{}},first}:
      U32.is_eq(last,129) && Bool.not(first) &&
      String.eq(text,nt_text_finish(p111q_data_items(p134ec_datum_rows(128,[]),True{},[]),""))
    case _: False{}

@unsafe
def p134ec_seal_error() -> Bool:
  p134ec_seal_result(p111_emit_verified(p134ec_program(),"denied"))

@unsafe
def p134ec_seal_result(value: P111Emission) -> Bool:
  match value:
    case P111Emission{chunks,error}: List.is_empty(&2,String,chunks) && String.eq(error,"structured IR: denied")
    case P134Planned{plan}: False{}
