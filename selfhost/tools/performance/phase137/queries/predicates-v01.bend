# Whole scalar observers: preserve each original operand order and all variants.
@unsafe
def p137q_name_eq(record: KDef, key: String) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(name,key)
    case KIndexLeaf{hash,bucket}: p88_string_eq("",key)
    case KIndexNode{hash,mask,left,right}: p88_string_eq("",key)

@unsafe
def p137q_key_eq(key: String, record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(key,name)
    case KIndexLeaf{hash,bucket}: p88_string_eq(key,"")
    case KIndexNode{hash,mask,left,right}: p88_string_eq(key,"")

@unsafe
def p137q_kind_eq(record: KDef, key: String) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(kind,key)
    case KIndexLeaf{hash,bucket}: p88_string_eq("IndexLeaf",key)
    case KIndexNode{hash,mask,left,right}: p88_string_eq("IndexNode",key)
