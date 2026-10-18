# Linkable QBE data: exact words, byte arrays and explicit symbol relocations.
# This model describes output layout; it never embeds C source or C expressions.
type P111QDatum is Data:
  P111QByte{+value: U32}
  P111QWord{+value: U32}
  P111QLong{+lo: U32, +hi: U32}
  P111QReloc{+symbol: String, +offset: U32}
  P111QZeros{+bytes: U32}

type P111QData is Data:
  P111QData{+name: String, +alignment: U32, +exported: Bool, +items: List<&2,P111QDatum>}

@unsafe
def p111q_datum(+datum: P111QDatum) -> String:
  match datum:
    case P111QByte{value}: "b " ++ U32.show(value)
    case P111QWord{value}: "w " ++ U32.show(value)
    case P111QLong{lo,hi}: "l " ++ p111q_u64(lo,hi)
    case P111QReloc{symbol,offset}:
      "l $" ++ symbol ++ nt_choose(String,U32.is_eq(offset,0),u => "",u => " + " ++ U32.show(offset))
    case P111QZeros{bytes}: "z " ++ U32.show(bytes)

@unsafe
def p111q_data_items(+items: List<&2,P111QDatum>, +first: Bool, acc: List<&2,String>) -> List<&2,String>:
  match items:
    case Nil{}: acc
    case Con{head,rest}:
      p111q_data_items(rest,False{},Con{p111q_datum(head),Con{nt_choose(String,first,u => "",u => ", "),acc}})

@unsafe
def p111q_data(+data: P111QData) -> String:
  match data:
    case P111QData{name,alignment,exported,items}:
      nt_choose(String,exported,u => "export ",u => "") ++ "data $" ++ name ++ " = align " ++ U32.show(alignment) ++ " { " ++
      nt_text_finish(p111q_data_items(items,True{},[])," }\n")

@unsafe
def p111q_data_chunks_go(items: List<&2,P111QData>, acc: List<&2,String>) -> List<&2,String>:
  match items:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{head,rest}: p111q_data_chunks_go(rest,Con{p111q_data(head),acc})

@unsafe
def p111q_data_chunks(items: List<&2,P111QData>) -> List<&2,String>:
  p111q_data_chunks_go(items,[])
