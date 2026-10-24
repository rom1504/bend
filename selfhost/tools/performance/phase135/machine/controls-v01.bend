@unsafe
def p135m_row(ok: Bool, +name: String) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":fail")

@unsafe
def p135m_done(frame: P135MFrame) -> Bool:
  match frame:
    case P135MDone{}: True{}
    case P135MFrame{kind,complete,text,ending,next}: False{}

@unsafe
def p135m_main(frame: P135MFrame) -> Bool:
  match frame:
    case P135MDone{}: False{}
    case P135MFrame{kind,complete,text,ending,next}:
      U32.is_eq(kind,2) && complete && ending && String.eq(text,p111q_main()) && p135m_done(p135m_next(next))

@unsafe
def p135m_data_end(frame: P135MFrame) -> Bool:
  match frame:
    case P135MDone{}: False{}
    case P135MFrame{kind,complete,text,ending,next}:
      U32.is_eq(kind,1) && complete && ending && String.eq(text," }\n") && p135m_main(p135m_next(next))

@unsafe
def p135m_empty_data(frame: P135MFrame) -> Bool:
  match frame:
    case P135MDone{}: False{}
    case P135MFrame{kind,complete,text,ending,next}:
      U32.is_eq(kind,1) && Bool.not(complete) && Bool.not(ending) && String.eq(text,"data $empty = align 1 { ") && p135m_data_end(p135m_next(next))

@unsafe
def p135m_controls() -> List<&2,String>:
  [p135m_row(p135m_done(p135m_next(P134End{})),"empty-stream"),
   p135m_row(p135m_main(p135m_next(P134Main{})),"main-bundle"),
   p135m_row(p135m_main(p135m_next(P134Tables{[]})),"empty-tables-to-main"),
   p135m_row(p135m_empty_data(p135m_next(P134Tables{[P111QData{"empty",1,False{},[]}]})),"data-boundary-not-legacy-lf"),
   p135m_row(p135m_rotate(0,3,0),"first-group"),
   p135m_row(Bool.not(p135m_rotate(0,0,999)),"complete-bundle-before-limit"),
   p135m_row(p135m_rotate(0,0,1000),"complete-bundle-at-limit"),
   p135m_row(Bool.not(p135m_rotate(1,1,1001)),"never-split-data-by-function-count"),
   p135m_row(p135m_rotate(1,0,1),"data-group-separate"),
   p135m_row(p135m_rotate(2,1,2),"main-group-separate"),
   p135m_row(String.eq(p135m_marker("BEGIN",0,42),"# P135/1 BEGIN 0 42\n"),"frame-header"),
   p135m_row(String.eq(p135m_marker("END",1,7),"# P135/1 END 1 7\n"),"frame-trailer")]
