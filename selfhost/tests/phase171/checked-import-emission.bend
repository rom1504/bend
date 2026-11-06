# Load after checked-imports.bend. Late capability experiment only.
# The public cursor intercept is keyed solely by independently revalidated imports.
# All generic families remain in the ORIGINAL verifier and emitted FID catalogue.

type P171Emission is Data:
  P171Emission{+prefix: List<&2,String>, +cursor: P134Cursor, +imports: List<&2,P171Import>, +error: String}

@unsafe
def p171e_has(+imports: List<&2,P171Import>, +name: String) -> Bool:
  match imports:
    case Nil{}: False{}
    case Con{P171Import{source,N111Segment{owner,arity,result,incoming,flags,body},family,plan,dependencies,rank},rest}:
      nt_choose(Bool,String.eq(name,owner),u => True{},u => p171e_has(rest,name))

@unsafe
def p171e_forward(+name: String, +arity: U32) -> String:
  "function l $" ++ p113e_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ") {\n@entry\n" ++
  "%p171_frame_result =l call $" ++ p114r_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ")\nret %p171_frame_result\n}\n"

@unsafe
def p171e_prefix(+imports: List<&2,P171Import>, +ids: N111Ids) -> List<&2,String>:
  match imports:
    case Nil{}: []
    case Con{P171Import{source,N111Segment{+name,+arity,result,incoming,flags,body},family,plan,dependencies,rank},rest}:
      Con{p171e_forward(name,arity),Con{p114h_private(name,ids,plan),p171e_prefix(rest,ids)}}

@unsafe
def p171e_public(+imports: List<&2,P171Import>, +segment: N111Segment, +context: P134Context) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(String,p171e_has(imports,name),u => p113e_public(name,arity),u => p134e_public(segment,context))

# Do not delegate empty transitions: p134e_next could otherwise enter Public
# internally and emit a second/differently-selected recursive worker.
law p171e_next:
  for +imports: List<&2,P171Import>
  for cursor: P134Cursor
  P134Step

@unsafe
def p171e_next(imports,cursor):
  match cursor:
    case P134Private{Nil{},context,next}: p171e_next(imports,next)
    case P134Legacy{Nil{},context,next}: p171e_next(imports,next)
    case P134Public{Nil{},context,next}: p171e_next(imports,next)
    case P134Public{Con{head,rest},+context,next}:
      P134Piece{p171e_public(imports,head,context),True{},P134Public{rest,context,next}}
    case _: p134e_next(cursor)

law p171e_collect:
  for +imports: List<&2,P171Import>
  for cursor: P134Cursor
  for pending: List<&2,String>
  for chunks: List<&2,String>
  List<&2,String>

@unsafe
def p171e_collect_step(+imports: List<&2,P171Import>, +step: P134Step, +pending: List<&2,String>, +chunks: List<&2,String>) -> List<&2,String>:
  match step:
    case P134Done{}: nt_reverse(String,chunks,[])
    case P134Piece{text,+ending,next}:
      +parts : List<&2,String> = Con{text,pending}
      nt_choose(List<&2,String>,ending,
        u => p171e_collect(imports,next,[],Con{nt_text_finish(parts,""),chunks}),
        u => p171e_collect(imports,next,parts,chunks))

@unsafe
def p171e_collect(imports,cursor,pending,chunks):
  p171e_collect_step(imports,p171e_next(imports,cursor),pending,chunks)

@unsafe
def p171e_ready(+imports: List<&2,P171Import>, +original: P111Program, +prepared: P169Prepared) -> P171Emission:
  match prepared:
    case P169Prepared{prefix,cursor,error}:
      P171Emission{nt_append(String,p171e_prefix(imports,p111q_ids(original)),prefix),cursor,imports,error}

@unsafe
def p171e_admitted(+admitted: P113AProgram, +imports: List<&2,P171Import>, +live: Bool) -> P171Emission:
  match admitted:
    case P113AProgram{P113DProgram{P112StaticProgram{original,nodes},functions},certificate}:
      p171e_ready(imports,original,p169c_output(admitted,live))

@unsafe
def p171e_namespace(+request: NR_Request, +imports: List<&2,P171Import>, +program: P113DProgram,
    +certificate: P113ACertificate, +error: String) -> P171Emission:
  nt_choose(P171Emission,String.is_empty(error),
    u => p171e_admitted(p169c_selected(request,P113AProgram{program,certificate}),imports,p167live_eligible(program)),
    u => P171Emission{[],P134End{},[],error})

@unsafe
def p171e_program(+request: NR_Request, +imports: List<&2,P171Import>, +original: P111Program,
    +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, +certificate: P113ACertificate) -> P171Emission:
  p171e_namespace(request,imports,P113DProgram{P112StaticProgram{original,nodes},functions},certificate,
    nt_choose(String,p113a_enabled(certificate),
      u => p169a_namespace(original,nodes,functions,certificate),u => ""))

@unsafe
def p171e_verified(+request: NR_Request, +program: P171Program, +error: String) -> P171Emission:
  match program:
    case P171Program{P113DProgram{P112StaticProgram{original,nodes},functions},adapters,imports,added,old_error}:
      nt_choose(P171Emission,String.is_empty(error),u =>
        p171e_program(request,imports,original,nodes,nt_append(P113DFunction,p168v_functions(functions,adapters),added),p113a_certificate(request)),
        u => P171Emission{[],P134End{},[],error})

@unsafe
def p171_emit(+request: NR_Request, +program: P171Program) -> P171Emission:
  p171e_verified(request,program,p171_verify(request,program))

@unsafe
def p171_prepare(+request: NR_Request) -> P171Emission:
  p171_emit(request,p171_request(request))

@unsafe
def p171e_text(+emission: P171Emission) -> NC_Result:
  match emission:
    case P171Emission{prefix,cursor,imports,+error}:
      nt_choose(NC_Result,String.is_empty(error),
        u => NC_Result{nt_join_chunks(nt_append(String,prefix,p171e_collect(imports,cursor,[],[])),"\n",True{},[]),""},
        u => NC_Result{"",error})

@unsafe
def p171_compile(+request: NR_Request) -> NC_Result:
  p171e_text(p171_prepare(request))

@unsafe
def p171c_summary(+program: P171Program) -> List<&2,U32>:
  match program:
    case P171Program{P113DProgram{original,functions},adapters,imports,added,error}:
      [nt_count(P113DFunction,functions),nt_count(P171Import,imports),nt_count(P113DFunction,added),Bool.to_u32(String.is_empty(error))]

# Exact maintained native protocol admission/error ordering.
@unsafe
def p171p_admitted(+request: NR_Request, +error: String) -> P171Emission:
  nt_choose(P171Emission,String.is_empty(error),u => p171_prepare(request),
    u => P171Emission{[],P134End{},[],"compile: " ++ error})

@unsafe
def p171_plan(plan: P86Plan) -> P171Emission:
  match plan:
    case P86PlanError{error}: P171Emission{[],P134End{},[],error}
    case P86PlanReady{+request,verdict}: p171p_admitted(request,p111_runtime_admission(request))

@unsafe
def p171_plan_text(plan: P86Plan) -> NC_Result:
  p171e_text(p171_plan(plan))
