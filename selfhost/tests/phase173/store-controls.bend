# Finite complete-record controls. The reference functions are unchanged core
# operations; this does not claim a proof or substitute for the final verifier.
type P173StoreObservation is Data:
  P173StoreObservation{+mode: U32, +input: KTerm, +roundtrip: KTerm, +expected: KTerm, +actual: KTerm, +expectedRefs: List<&2,String>, +actualRefs: List<&2,String>, +importValid: Bool, +compactValid: Bool, +ok: Bool, +nodes: U32}

type P173StoreRefusal is Data:
  P173StoreRefusal{+mode: U32, +ok: Bool, +valid: Bool}


@unsafe
def p173st_ref(+name: String) -> KTerm:
  KTerm{"Ref",name,73,2,[],["ref-removal"],81,89}

@unsafe
def p173st_fixture(mode: U32) -> KTerm:
  match mode:
    case 0: atom("Absent")
    case 1: KTerm{"Var","all-fields",17,2,[p173st_ref("child")],["removed","", "last"],3,19}
    case 2: KLambda{"lambda",19,2,[p173st_ref("inside")],["lambda-removed"],11,31,False{}}
    case 3: KLambda{"lambda",19,0,[p173st_ref("inside")],["lambda-removed"],11,31,True{}}
    case 4: KLiteral{"U32",4294967295,"0xffffffff",7,17}
    case 5: KLiteral{"F32",2147483648,"-0.0",13,17}
    case 6: KLiteral{"Nat",0,"0n",2,4}
    case 7: KLiteral{"Nat",4294967295,"4294967295n",2,13}
    case 8: KLiteral{"String",33,"aλ😀\n",50,61}
    case 9: KTerm{"NStatic","static",9,1,[KLiteral{"String",1,"kept",4,9},p173st_ref("static-child")],["static-origin"],3,12}
    case 10: KTerm{"App","unusual",8,2,[KLambda{"f",9,0,[KLiteral{"Nat",12,"12n",4,7}],["x"],1,8,False{}},p173st_ref("g")],["app"],1,20}
    case 11: KTerm{"Ctr","Succ",7,2,[KLiteral{"Nat",4294967295,"max",3,7}],["overflow"],1,9}
    case 12: KTerm{"Ctr","Succ",0,1,[KTerm{"Ctr","Succ",0,1,[p173st_ref("tail")],[],7,11}],[],1,13}
    case 13: KTerm{"Ctr","Succ",0,1,[KLiteral{"Nat",4,"4n",3,5},p173st_ref("ignored-malformed")],[],1,8}
    case 14: KTerm{"Ctr","U32",0,1,[core_literal_word(4294967295,32,5,8)],["word"],1,9}
    case 15: KTerm{"Ctr","F32",0,1,[KTerm{"Ctr","WNil",0,1,[p173st_ref("ignored")],[],2,8}],[],1,9}
    case 16: KTerm{"Ctr","U32",0,1,[KTerm{"Ctr","WCon",0,1,[p173st_ref("not-bool"),atom("Absent")],[],1,8}],[],1,9}
    case 17: KTerm{"Lam","legacy",44,2,[p173st_ref("legacy-child")],["legacy-removed"],5,11}
    case 18:
      +shared : KTerm = KTerm{"Ctr","Pair",0,1,[p173st_ref("first"),p173st_ref("second")],[],2,4}
      KTerm{"Ctr","Pair",0,1,[shared,shared],[],1,5}
    case 19: KTerm{"Ctr","List",0,1,[p173st_ref("a"),KTerm{"Ctr","Nest",0,1,[p173st_ref("b"),p173st_ref("a")],[],1,5},p173st_ref("c")],[],1,9}
    case 20: KTerm{"Ctr","Succ",0,1,[],[],1,9}
    case 21: KLiteral{"UnknownLiteral",73,"unknown",1,7}
    case 22: KTerm{"Ctr","Zero",0,1,[p173st_ref("ignored-zero-child")],[],1,9}
    case 23: KLiteral{"String",0,"",1,3}
    case 24: KTerm{"Lit","Nat",44,1,[],["generic-lit-is-not-literal"],3,9}
    case _: KTerm{"Ctr","Succ",0,1,[KTerm{"Ctr","Succ",0,1,[p173st_ref("tail"),p173st_ref("not-single")],[],1,8}],[],1,9}

@unsafe
def p173take_50(+mode: U32, +term: KTerm, +importValid: Bool, +roundtrip: KTerm, +compactValid: Bool, +actualRefs: List<&2,String>, +actual: KTerm, +nodes: U32, pair: P173Store & Bool) -> P173StoreObservation:
  match pair:
    case Tuple{store,+ok}:
      +expected = nc_compact(term)
      P173StoreObservation{mode,term,roundtrip,expected,actual,nc_refs(expected),actualRefs,importValid,compactValid,ok,nodes}

@unsafe
def p173take_49(+mode: U32, +term: KTerm, +importValid: Bool, +roundtrip: KTerm, +compactValid: Bool, +actualRefs: List<&2,String>, +actual: KTerm, pair: P173Store & U32) -> P173StoreObservation:
  match pair:
    case Tuple{store,+nodes}:
      p173take_50(mode,term,importValid,roundtrip,compactValid,actualRefs,actual,nodes,p173s_ok(store))

@unsafe
def p173take_48(+mode: U32, +term: KTerm, +importValid: Bool, +roundtrip: KTerm, +compactValid: Bool, +actualRefs: List<&2,String>, pair: P173Store & KTerm) -> P173StoreObservation:
  match pair:
    case Tuple{store,+actual}:
      p173take_49(mode,term,importValid,roundtrip,compactValid,actualRefs,actual,p173s_size(store))

@unsafe
def p173take_47(+mode: U32, +term: KTerm, +importValid: Bool, +roundtrip: KTerm, +result: U32, +compactValid: Bool, pair: P173Store & List<&2,String>) -> P173StoreObservation:
  match pair:
    case Tuple{store,+actualRefs}:
      p173take_48(mode,term,importValid,roundtrip,compactValid,actualRefs,p173s_export(store,result,100000))

@unsafe
def p173take_46(+mode: U32, +term: KTerm, +importValid: Bool, +roundtrip: KTerm, +result: U32, pair: P173Store & Bool) -> P173StoreObservation:
  match pair:
    case Tuple{store,+compactValid}:
      p173take_47(mode,term,importValid,roundtrip,result,compactValid,p173s_refs(store,result,100000))

@unsafe
def p173take_45(+mode: U32, +term: KTerm, +importValid: Bool, +roundtrip: KTerm, pair: P173Store & U32) -> P173StoreObservation:
  match pair:
    case Tuple{store,+result}:
      p173take_46(mode,term,importValid,roundtrip,result,p173s_valid(store,100000))

@unsafe
def p173take_44(+mode: U32, +term: KTerm, +root: U32, +importValid: Bool, pair: P173Store & KTerm) -> P173StoreObservation:
  match pair:
    case Tuple{store,+roundtrip}:
      p173take_45(mode,term,importValid,roundtrip,p173s_compact(store,root,100000))

@unsafe
def p173take_43(+mode: U32, +term: KTerm, +root: U32, pair: P173Store & Bool) -> P173StoreObservation:
  match pair:
    case Tuple{store,+importValid}:
      p173take_44(mode,term,root,importValid,p173s_export(store,root,100000))

@unsafe
def p173take_42(+mode: U32, +term: KTerm, pair: P173Store & U32) -> P173StoreObservation:
  match pair:
    case Tuple{store,+root}:
      p173take_43(mode,term,root,p173s_valid(store,100000))

@unsafe
def p173st_observe(+mode: U32) -> P173StoreObservation:
  +term = p173st_fixture(mode)
  p173take_42(mode,term,p173s_import(p173s_new(),term,100000))

@unsafe
def p173take_53(+mode: U32, +valid: Bool, pair: P173Store & Bool) -> P173StoreRefusal:
  match pair:
    case Tuple{store,+ok}:
      P173StoreRefusal{mode,ok,valid}

@unsafe
def p173take_52(+mode: U32, pair: P173Store & Bool) -> P173StoreRefusal:
  match pair:
    case Tuple{store,+valid}:
      p173take_53(mode,valid,p173s_ok(store))

@unsafe
def p173take_51(+mode: U32, pair: P173Store & P173Node) -> P173StoreRefusal:
  match pair:
    case Tuple{store,+node}:
      p173take_52(mode,p173s_valid(store,100000))

@unsafe
def p173st_refuse_read(store: P173Store, +mode: U32) -> P173StoreRefusal:
  p173take_51(mode,p173s_node(store,4294967295))

@unsafe
def p173take_56(+mode: U32, +valid: Bool, pair: P173Store & Bool) -> P173StoreRefusal:
  match pair:
    case Tuple{store,+ok}:
      P173StoreRefusal{mode,ok,valid}

@unsafe
def p173take_55(+mode: U32, pair: P173Store & Bool) -> P173StoreRefusal:
  match pair:
    case Tuple{store,+valid}:
      p173take_56(mode,valid,p173s_ok(store))

@unsafe
def p173take_54(+mode: U32, pair: P173Store & U32) -> P173StoreRefusal:
  match pair:
    case Tuple{store,+root}:
      p173take_55(mode,p173s_valid(store,100000))

@unsafe
def p173st_refuse_import(+mode: U32) -> P173StoreRefusal:
  p173take_54(mode,p173s_import(p173s_new(),p173st_fixture(19),1))

@unsafe
def p173take_60(+mode: U32, +valid: Bool, pair: P173Store & Bool) -> P173StoreRefusal:
  match pair:
    case Tuple{store,+ok}:
      P173StoreRefusal{mode,ok,valid}

@unsafe
def p173take_59(+mode: U32, pair: P173Store & Bool) -> P173StoreRefusal:
  match pair:
    case Tuple{store,+valid}:
      p173take_60(mode,valid,p173s_ok(store))

@unsafe
def p173take_58(+mode: U32, pair: P173Store & U32) -> P173StoreRefusal:
  match pair:
    case Tuple{store,+root}:
      p173take_59(mode,p173s_valid(store,100000))

@unsafe
def p173take_57(+mode: U32, pair: P173Store & U32) -> P173StoreRefusal:
  match pair:
    case Tuple{store,+root}:
      p173take_58(mode,p173s_compact(store,root,1))

@unsafe
def p173st_refuse_compact(+mode: U32) -> P173StoreRefusal:
  p173take_57(mode,p173s_import(p173s_new(),p173st_fixture(19),100000))

@unsafe
def p173st_refusal(mode: U32) -> P173StoreRefusal:
  match mode:
    case 0: p173st_refuse_read(p173s_new(),0)
    case 1: p173st_refuse_import(1)
    case _: p173st_refuse_compact(2)
