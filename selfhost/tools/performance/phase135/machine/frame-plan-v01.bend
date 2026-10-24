# UNCHECKED interface sketch; no existing declaration overridden.
# The text is still produced by the original checked cursor. A complete public
# bundle can contain several function declarations; never call it one function.
type P135MFrame is Data:
  P135MDone{}
  P135MFrame{+family: U32, +complete: Bool, +text: String, +legacy_end: Bool, +next: P134Cursor}

@unsafe
def p135m_wrap(family: U32, complete: Bool, step: P134Step) -> P135MFrame:
  match step:
    case P134Done{}: P135MDone{}
    case P134Piece{text,legacy_end,next}: P135MFrame{family,complete,text,legacy_end,next}

# Family0: complete function bundle. Family1: one data declaration, potentially
# many pieces. Family2: final main. The original legacy_end flag is independent.
@unsafe
def p135m_next(+cursor: P134Cursor) -> P135MFrame:
  match cursor:
    case P134Private{Nil{},context,next}: p135m_next(next)
    case P134Private{Con{head,rest},context,next}: p135m_wrap(0,True{},p134e_next(cursor))
    case P134Legacy{Nil{},context,next}: p135m_next(next)
    case P134Legacy{Con{head,rest},context,next}: p135m_wrap(0,True{},p134e_next(cursor))
    case P134Public{Nil{},context,next}: p135m_next(next)
    case P134Public{Con{head,rest},context,next}: p135m_wrap(0,True{},p134e_next(cursor))
    case P134Tables{Nil{}}: p135m_next(P134Main{})
    case P134Tables{Con{table,rest}}: p135m_wrap(1,False{},p134e_next(cursor))
    case P134Data{Nil{},first,rest}: p135m_wrap(1,True{},p134e_next(cursor))
    case P134Data{Con{head,tail},first,rest}: p135m_wrap(1,False{},p134e_next(cursor))
    case P134Main{}: p135m_wrap(2,True{},p134e_next(cursor))
    case P134End{}: P135MDone{}
