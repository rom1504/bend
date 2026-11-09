

@unsafe
def p134e_begin(plan: P134EmissionPlan) -> P134Cursor:
  match plan:
    case P134Raw{program}: p134e_prepare(program,[],[],False{},False{})
    case P134Static{P112StaticProgram{program,nodes}}: p134e_prepare(program,nodes,[],False{},False{})
    case P134Direct{P113DProgram{P112StaticProgram{program,nodes},functions}}:
      p134e_prepare(program,nodes,functions,False{},False{})
    case P134Admitted{+admitted}: p134e_admitted(admitted)


@unsafe
def p134e_admitted(+admitted: P113AProgram) -> P134Cursor:
  match admitted:
    case P113AProgram{P113DProgram{P112StaticProgram{program,nodes},Nil{}},certificate}:
      p134e_prepare(program,nodes,[],False{},False{})
    case P113AProgram{P113DProgram{P112StaticProgram{program,nodes},functions},certificate}:
      p134e_prepare(program,nodes,functions,p113a_enabled(certificate),p118z_eligible(admitted))


@unsafe
def p134e_prepare(+program: P111Program, +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, +arrays: Bool, +live: Bool) -> P134Cursor:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      +index = p112f_index(segments)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,
        u => nt_choose(U32,arrays,v => 2,v => 1))
      +tables = nt_choose(List<&2,P111QData>,arrays,u => p117p_tables(tables,[]),u => tables)
      +tables = nt_choose(List<&2,P111QData>,live,u => p118z_tables(tables),u => tables)
      p134e_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,
        p118c_tables(tables),p112c_index_with(segments,index))


@unsafe
def p134e_registered(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>, +ids: N111Ids, +index: P112FusionIndex,
    +heap: U32, +mode: U32, +tables: List<&2,P111QData>, registry: P112RegionRegistry) -> P134Cursor:
  match registry:
    case P112RegionRegistry{+ready,symbols,+entries,workers,fusions}:
      +direct = p113e_signatures(functions,missing())
      +lookups = nt_choose(List<&2,P126ITable>,U32.is_eq(mode,2),u => p126i_catalogue(functions,[]),u => [])
      +ids = p185cb_bind(ids,tables)
      +context : P134Context = P134Context{ids,index,direct,ready,p124r_view(ready,direct),lookups,heap,mode}
      +public : P134Cursor = P134Public{segments,context,P134Tables{tables}}
      +legacy = nt_choose(P134Cursor,List.is_empty(&2,N111Segment,segments),u => public,
        u => P134Legacy{nt_reverse(P112RegionEntry,entries,[]),context,public})
      P134Private{functions,context,legacy}


@unsafe
def p134e_private(+function: P113DFunction, context: P134Context) -> String:
  match context:
    case P134Context{+ids,index,direct,ready,view,+lookups,+heap,mode}:
      nt_choose(String,U32.is_eq(mode,2),u => p126i_emit_one(function,lookups,ids,heap),u => p113e_private(function,ids))


@unsafe
def p134e_legacy(entry: P112RegionEntry, context: P134Context) -> String:
  match entry context:
    case P112RegionEntry{+segment,+plan,rank,sites} P134Context{+ids,index,+direct,ready,view,lookups,heap,mode}:
      nt_choose(String,U32.is_eq(mode,0),u => p112w_private(segment,ids,plan),u => p113e_old_private(segment,plan,direct,ids))


@unsafe
def p134e_public(+segment: N111Segment, context: P134Context) -> String:
  match context:
    case P134Context{+ids,+index,+direct,+ready,+view,lookups,heap,mode}:
      nt_choose(String,U32.is_eq(mode,0),
        u => p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready)),
        u => p124r_public(segment,direct,index,ids,ready,view))


@unsafe
def p134e_next(cursor: P134Cursor) -> P134Step:
  match cursor:
    case P134Private{Nil{},context,next}: p134e_next(next)
    case P134Private{Con{head,rest},+context,next}:
      P134Piece{p134e_private(head,context),True{},P134Private{rest,context,next}}
    case P134Legacy{Nil{},context,next}: p134e_next(next)
    case P134Legacy{Con{head,rest},+context,next}:
      P134Piece{p134e_legacy(head,context),False{},P134Legacy{rest,context,next}}
    case P134Public{Nil{},context,next}: p134e_next(next)
    case P134Public{Con{head,rest},+context,next}:
      P134Piece{p134e_public(head,context),True{},P134Public{rest,context,next}}
    case P134Tables{Nil{}}: p134e_next(P134Main{})
    case P134Tables{Con{P111QData{name,alignment,exported,items},rest}}:
      P134Piece{nt_choose(String,exported,u => "export ",u => "") ++ "data $" ++ name ++ " = align " ++ U32.show(alignment) ++ " { ",
        False{},P134Data{items,True{},rest}}
    case P134Data{Nil{},first,rest}: P134Piece{" }\n",True{},P134Tables{rest}}
    case P134Data{items,first,rest}: p134e_data_next(p134e_data_slice(items,first,128,[]),rest)
    case P134Main{}: P134Piece{p111q_main(),True{},P134End{}}
    case P134End{}: P134Done{}


@unsafe
def p134e_data_next(slice: P134DataSlice, tables: List<&2,P111QData>) -> P134Step:
  match slice:
    case P134DataSlice{text,rest,first}: P134Piece{text,False{},P134Data{rest,first,tables}}


@unsafe
def p134e_data_slice(+items: List<&2,P111QDatum>, +first: Bool, +remaining: U32, +acc: List<&2,String>) -> P134DataSlice:
  match items:
    case Nil{}: P134DataSlice{nt_text_finish(acc,""),[],first}
    case Con{+head,+rest}:
      nt_choose(P134DataSlice,U32.is_eq(remaining,0),u => P134DataSlice{nt_text_finish(acc,""),items,first},
        u => p134e_data_slice(rest,False{},U32.sub(remaining,1),
          Con{p111q_datum(head),Con{nt_choose(String,first,v => "",v => ", "),acc}}))

# Compatibility path only. Native IO must consume p134e_next directly.

@unsafe
def p134e_collect(result: P111Emission) -> P111Emission:
  match result:
    case P111Emission{chunks,error}: P111Emission{chunks,error}
    case P134Planned{plan}: P111Emission{p134e_collect_cursor(p134e_begin(plan),[],[]),""}


@unsafe
def p134e_collect_cursor(cursor: P134Cursor, pending: List<&2,String>, chunks: List<&2,String>) -> List<&2,String>:
  p134e_collect_step(p134e_next(cursor),pending,chunks)


@unsafe
def p134e_collect_step(step: P134Step, pending: List<&2,String>, +chunks: List<&2,String>) -> List<&2,String>:
  match step:
    case P134Done{}: nt_reverse(String,chunks,[])
    case P134Piece{text,+legacy_end,+next}:
      +parts : List<&2,String> = Con{text,pending}
      nt_choose(List<&2,String>,legacy_end,
        u => p134e_collect_cursor(next,[],Con{nt_text_finish(parts,""),chunks}),
        u => p134e_collect_cursor(next,parts,chunks))


@unsafe
def p134e_compile_source(+path: String, +source: String, +base_path: String, +base: String,
    +carrier: String, +stamp: String, +cached: Bool) -> P111Emission:
  p134e_prepared(path,source,nt_choose(P86Preparation,cached,
    u => p88_cache_prepare(base_path,base,carrier,stamp),u => p86_prepare(base_path,base)))


@unsafe
def p134e_prepared(+path: String, +source: String, prepared: P86Preparation) -> P111Emission:
  match prepared:
    case P86PreparationError{error}: P111Emission{[],error}
    case P86PreparationReady{seed}: p134e_plan(p86_plan(seed,path,source))


@unsafe
def p134e_plan(plan: P86Plan) -> P111Emission:
  match plan:
    case P86PlanError{error}: P111Emission{[],error}
    case P86PlanReady{+request,verdict}: p128raw_emit_admitted(request,p111_runtime_admission(request))


@unsafe
def p134e_emission_chunks(emitted: P111Emission) -> List<&2,String>:
  match emitted:
    case P111Emission{chunks,+error}:
      nt_choose(List<&2,String>,String.is_empty(error),u => chunks,u => ["INVALID_P118_BORROW: " ++ error ++ "\n"])
    case P134Planned{plan}: ["INVALID_P134_UNCOLLECTED\n"]


@unsafe
def p134e_same(left: P111Emission, right: P111Emission) -> Bool:
  match left right:
    case P111Emission{a,ae} P111Emission{b,be}:
      String.eq(ae,be) && String.eq(nt_join(a,""),nt_join(b,""))
    case _ _: False{}

@unsafe
def p134w_written(pair: File & Result<&1,&1,U32 & String,Unit>, next: P134Cursor) -> IO(U32):
  (file, result) = pair
  match result:
    case Done{unit}: p134w_drain(file,next)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})


@unsafe
def p134wn_end(ending: Bool, file: File, next: P134Cursor) -> IO(U32):
  match ending:
    case False{}: p134w_drain(file,next)
    case True{}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,"\n")
        p134w_written(pair,next)


@unsafe
def p134wn_text(pair: File & Result<&1,&1,U32 & String,Unit>, ending: Bool, next: P134Cursor) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}: p134wn_end(ending,file,next)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})


@unsafe
def p134w_step(file: File, step: P134Step) -> IO(U32):
  match step:
    case P134Done{}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pure(U32,0)
    case P134Piece{text,legacy_end,next}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
        p134wn_text(pair,legacy_end,next)


@unsafe
def p134w_drain(file: File, cursor: P134Cursor) -> IO(U32):
  p134w_step(file,p134e_next(cursor))


@unsafe
def p134w_plan(plan: P134EmissionPlan) -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File,File.open("/dev/stdout","a"))
    p134w_drain(file,p134e_begin(plan))


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
   p113ft_row("stream-seal-error-preserved",p134ec_seal_error()),
   p113ft_row("stream-zero-public",p134ec_zero_public())]


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


@unsafe
def p134ec_zero_public() -> Bool:
  +program : P111Program = P111Program{[],[N_Constructor{"SNil",0,True{}}],[],[],[],True{}}
  +static : P112StaticProgram = P112StaticProgram{program,[P112SNode{0,"SNil",[]}]}
  p134ec_plan(P134Raw{program},p111q_chunks(program)) && p134ec_plan(P134Static{static},p112s_chunks(static))
