# Explicit additive runtime capability. Run AFTER p117p_tables, which writes
# capability3. No descriptor slot is repurposed; only existing hot bytes change.
@unsafe
def p118c_zero_byte(items: List<&2,P111QDatum>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{P111QByte{value},rest}: U32.is_eq(value,0) || p118c_zero_byte(rest)
    case Con{item,rest}: p118c_zero_byte(rest)

@unsafe
def p118c_has_cold(tables: List<&2,P111QData>) -> Bool:
  match tables:
    case Nil{}: False{}
    case Con{P111QData{+name,alignment,exported,items},rest}:
      (String.eq(name,"p111_cid_hot") && p118c_zero_byte(items)) || p118c_has_cold(rest)

@unsafe
def p118c_cap_item(item: P111QDatum) -> P111QDatum:
  match item:
    case P111QLong{lo,hi}: P111QLong{U32.or(lo,8),hi}
    case _: item

@unsafe
def p118c_cap_items(items: List<&2,P111QDatum>, +index: U32) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: []
    case Con{+head,rest}: Con{nt_choose(P111QDatum,U32.is_eq(index,11),u => p118c_cap_item(head),u => head),p118c_cap_items(rest,U32.inc(index))}

@unsafe
def p118c_cap_tables(tables: List<&2,P111QData>) -> List<&2,P111QData>:
  match tables:
    case Nil{}: []
    case Con{P111QData{+name,alignment,exported,+items},rest}:
      Con{P111QData{name,alignment,exported,nt_choose(List<&2,P111QDatum>,String.eq(name,"p111_program"),
        u => p118c_cap_items(items,0),u => items)},p118c_cap_tables(rest)}

@unsafe
def p118c_tables(+tables: List<&2,P111QData>) -> List<&2,P111QData>:
  nt_choose(List<&2,P111QData>,p118c_has_cold(tables),u => p118c_cap_tables(tables),u => tables)
