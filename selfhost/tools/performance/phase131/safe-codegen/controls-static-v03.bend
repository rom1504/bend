# Static-image classifier controls are ordinary Bend data only. No synthetic
# marker is executed as a native program; the final image verifier stays intact.
@unsafe
def p131sc_control_book(+fact: KDef, constructors: KDef) -> List<&2,KDef>:
  match p112s_attach_book(book_cached([],0),[fact],0,[],constructors,""):
    case P112SPrepared{book,nodes,error}: book

@unsafe
def p131sc_controls_static_v03() -> List<&2,String>:
  +constructors = p112s_ctors([N_Constructor{"Unit",0,True{}},N_Constructor{"True",0,True{}},N_Constructor{"$ctor.Item",1,True{}}],0,missing())
  +unit = kt("NStatic","Unit",0,1,[])
  +source = kt("Ctr","Unit",0,0,[])
  +fact = KDef{"dispatch","NativeStaticBody",0,0,atom("Absent"),unit,[],False{},False{}}
  +book = p131sc_control_book(fact,constructors)
  List.append(&2,String,p131sc_controls_v02(),
    [p131sc_row("selector-static-unit-admitted",p131sc_static_terms(constructors,[unit])),
     p131sc_row("selector-static-unknown-refused",Bool.not(p131sc_static_terms(constructors,[kt("NStatic","Unknown",0,1,[])]))),
     p131sc_row("selector-static-special-refused",Bool.not(p131sc_static_terms(constructors,[kt("NStatic","True",0,1,[])]))),
     p131sc_row("selector-static-one-field-refused",Bool.not(p131sc_static_terms(constructors,[kt("NStatic","$ctor.Item",0,1,[])]))),
     p131sc_row("selector-static-box-refused",Bool.not(p131sc_static_terms(constructors,[kt("NStatic","Unit",0,0,[])]))),
     p131sc_row("selector-static-payload-refused",Bool.not(p131sc_static_terms(constructors,[kt("NStatic","Unit",1,1,[])]))),
     p131sc_row("selector-static-child-refused",Bool.not(p131sc_static_terms(constructors,[kt("NStatic","Unit",0,1,[source])]))),
     p131sc_row("selector-static-prepared-reused",p98_tag_eq(p131sc_prepared_body(book,"dispatch",source,fact),"NStatic")),
     p131sc_row("selector-static-no-context-fallback",p98_tag_eq(p131sc_prepared_body([],"dispatch",source,fact),"Ctr")),
     p131sc_row("selector-static-name-mismatch-fallback",p98_tag_eq(p131sc_prepared_body(book,"other",source,fact),"Ctr")),
     p131sc_row("selector-static-empty-fact-fallback",p98_tag_eq(p131sc_prepared_body(book,"dispatch",source,missing()),"Ctr"))])
