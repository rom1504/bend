# Reuse the Phase177 fixture module and its unchanged whole-parser controls.
@unsafe
def p178pc_input(source: String, +scope: FParseScope) -> FInput:
  f_context_scope(f_input(f_lex_cursor(source,1,0,0,[],1,1)),scope)

def p178pc_nodes() -> List<&2,KTerm>:
  [kt("Tele","",0,0,[]),
   kt("Tele","",0,0,[kt_span("Bind","x",17,2,[atom("Qnt")],11,12)]),
   kt("Tele","",0,0,[kt_span("Bind","x",17,2,[atom("Typ")],11,12)]),
   kt_span("Error","boundary error",0,0,[],21,22),
   atom("Typ"),atom("Absent"),kt("ImportLaw","f",0,0,[]),
   KLiteral{"U32",9,"malformed signature",31,32}]

@unsafe
def p178pc_olds() -> List<&2,KDef>:
  [f_find("f",[]),p177dc_law(),p177dc_definition(),
   KDef{"unrelated","Def",1,2,atom("Typ"),atom("Absent"),[],False{},False{}}]

@unsafe
def p178pc_alias_scope() -> FParseScope:
  FParseScope{[KDef{"A.f","Def",0,0,atom("Typ"),atom("Absent"),[],False{},False{}},
    KDef{"child:f","Def",0,0,atom("Typ"),atom("Absent"),[],False{},False{}}],
    missing(),missing(),"",[kt("Import","child",0,0,[ref("A")])],None{}}

# Each entry starts at a distinct public continuation boundary. The explicit
# old value is intentionally independent of both the raw book and scope index.
@unsafe
def p178pc_boundary(entry: U32, +source: String, +node: KTerm,
    +book: List<&2,KDef>, +scope: FParseScope, +old: KDef, +stop: U32) -> P140PStop:
  +input = p178pc_input(source,scope)
  +pars = [kt_span("Bind","x",17,2,[atom("Qnt")],11,12)]
  match entry:
    case 0: p140p_def_context_header(stop,input,f_space(f_tl(input)),book,[],False{},old,scope)
    case 1: p140p_def_header_prior(stop,input,f_space(f_tl(input)),book,[],False{},old,scope)
    case 2: p140p_def_prior(stop,"f",FParsed{node,input},book,[],False{},old,p178pc_input("f",scope),scope)
    case 3: p140p_def_base(stop,"f",FParsed{node,input},book,[],False{},scope)
    case 4: p140p_def_type(stop,"f",pars,FParsed{node,input},book,[],False{},scope)
    case _: p140p_def_body(stop,"f",pars,atom("Typ"),FParsed{node,input},book,[],False{},scope)
