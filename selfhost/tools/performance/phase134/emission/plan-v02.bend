# Phase134: verified output selection remains unchanged; rendering is deferred.
# A plan is an internal success continuation, not a substitute for verification.
type P111Emission is Data:
  P111Emission{+chunks: List<&2,String>, +error: String}
  P134Planned{+plan: P134EmissionPlan}

type P134EmissionPlan is Data:
  P134Raw{+program: P111Program}
  P134Static{+program: P112StaticProgram}
  P134Direct{+program: P113DProgram}
  P134Admitted{+program: P113AProgram}

type P134Context is Data:
  P134Context{+ids: N111Ids, +index: P112FusionIndex, +direct: KDef,
    +ready: KDef, +view: KDef, +lookups: List<&2,P126ITable>, +heap: U32, +mode: U32}

type P134Cursor is Data:
  P134Private{+functions: List<&2,P113DFunction>, +context: P134Context, +next: P134Cursor}
  P134Legacy{+entries: List<&2,P112RegionEntry>, +context: P134Context, +next: P134Cursor}
  P134Public{+segments: List<&2,N111Segment>, +context: P134Context, +next: P134Cursor}
  P134Tables{+tables: List<&2,P111QData>}
  P134Data{+items: List<&2,P111QDatum>, +first: Bool, +rest: List<&2,P111QData>}
  P134Main{}
  P134End{}

type P134Step is Data:
  P134Done{}
  P134Piece{+text: String, +legacy_end: Bool, +next: P134Cursor}

type P134DataSlice is Data:
  P134DataSlice{+text: String, +rest: List<&2,P111QDatum>, +first: Bool}

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
    +heap: U32, +mode: U32, tables: List<&2,P111QData>, registry: P112RegionRegistry) -> P134Cursor:
  match registry:
    case P112RegionRegistry{+ready,symbols,+entries,workers,fusions}:
      +direct = p113e_signatures(functions,missing())
      +lookups = nt_choose(List<&2,P126ITable>,U32.is_eq(mode,2),u => p126i_catalogue(functions,[]),u => [])
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
def p111_emit_admitted(+request: NR_Request, +error: String) -> P111Emission:
  p134e_collect(p128raw_emit_admitted(request,error))

@unsafe
def p118b_emission_chunks(emitted: P111Emission) -> List<&2,String>:
  p134e_emission_chunks(p134e_collect(emitted))

@unsafe
def p134e_emission_chunks(emitted: P111Emission) -> List<&2,String>:
  match emitted:
    case P111Emission{chunks,+error}:
      nt_choose(List<&2,String>,String.is_empty(error),u => chunks,u => ["INVALID_P118_BORROW: " ++ error ++ "\n"])
    case P134Planned{plan}: ["INVALID_P134_UNCOLLECTED\n"]

@unsafe
def p128rawc_same(left: P111Emission, right: P111Emission) -> Bool:
  p134e_same(p134e_collect(left),p134e_collect(right))

@unsafe
def p134e_same(left: P111Emission, right: P111Emission) -> Bool:
  match left right:
    case P111Emission{a,ae} P111Emission{b,be}:
      String.eq(ae,be) && String.eq(nt_join(a,""),nt_join(b,""))
    case _ _: False{}
