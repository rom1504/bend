# Phase181 raw ABI controls. These are executable private direct functions,
# admitted by the real verifier; no fake original segments or runtime imports.
# The observation runner supplies state, which every function leaves untouched.
# Parameters/results use the existing U64 direct ABI. Narrowing and widening
# are explicit typed memory operations, never implicit cross-width assignments.

def p181c_v(name: String) -> N111Value:
  N111Local{name}

def p181c_bin(name: String, typ: N111Type, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,typ,op,left,right}}

@unsafe
def p181c_params(names: List<&2,String>, +index: U32) -> List<&2,NC_Binding>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{NC_Binding{index,name,N_W64{}},p181c_params(rest,U32.inc(index))}

def p181c_low32() -> List<&2,P113DStmt>:
  [P113DScalar{N111Store{N111U64{},p181c_v("scratch"),0,p181c_v("a")}},
   P113DScalar{N111Store{N111U64{},p181c_v("scratch"),8,p181c_v("b")}},
   P113DScalar{N111Load{"a32",N111U32{},p181c_v("scratch"),0}},
   P113DScalar{N111Load{"b32",N111U32{},p181c_v("scratch"),8}}]

@unsafe
def p181c_widen(names: List<&2,String>) -> List<&2,P113DStmt>:
  match names:
    case Nil{}: []
    case Con{+name,rest}:
      nt_append(P113DStmt,
        [P113DScalar{N111Store{N111U64{},p181c_v("scratch"),32,N111Const{0,0}}},
         P113DScalar{N111Store{N111U32{},p181c_v("scratch"),32,p181c_v(name)}},
         P113DScalar{N111Load{"z_" ++ name,N111U64{},p181c_v("scratch"),32}}],p181c_widen(rest))

@unsafe
def p181c_binary(name: String, op: String) -> P113DFunction:
  P113DFunction{name,p181c_params(["a","b"],0),1,False{},
    [p181c_bin("r",N111U64{},op,p181c_v("a"),p181c_v("b")),P113DResult{[p181c_v("r")]}]}

@unsafe
def p181c_bits() -> P113DFunction:
  P113DFunction{"p181d",p181c_params(["a","b"],0),3,False{},
    [p181c_bin("r",N111U64{},"and",p181c_v("a"),p181c_v("b")),
     p181c_bin("s",N111U64{},"or",p181c_v("a"),p181c_v("b")),
     p181c_bin("t",N111U64{},"xor",p181c_v("a"),p181c_v("b")),
     P113DResult{[p181c_v("r"),p181c_v("s"),p181c_v("t")]}]}

@unsafe
def p181c_arith32() -> P113DFunction:
  P113DFunction{"p181e",p181c_params(["a","b"],0),3,False{},
    nt_append(P113DStmt,p181c_low32(),nt_append(P113DStmt,
      [p181c_bin("r",N111U32{},"add",p181c_v("a32"),p181c_v("b32")),
       p181c_bin("s",N111U32{},"sub",p181c_v("a32"),p181c_v("b32")),
       p181c_bin("t",N111U32{},"mul",p181c_v("a32"),p181c_v("b32"))],
      nt_append(P113DStmt,p181c_widen(["r","s","t"]),
        [P113DResult{[p181c_v("z_r"),p181c_v("z_s"),p181c_v("z_t")]}])))}

@unsafe
def p181c_shift64() -> P113DFunction:
  P113DFunction{"p181f",p181c_params(["a","b"],0),4,False{},
    [p181c_bin("r",N111U64{},"shl",p181c_v("a"),p181c_v("b")),
     p181c_bin("s",N111U64{},"shr",p181c_v("a"),p181c_v("b")),
     p181c_bin("t",N111U64{},"sar",p181c_v("a"),p181c_v("b")),
     P113DResult{[p181c_v("r"),p181c_v("s"),p181c_v("t"),p181c_v("a")]}]}

@unsafe
def p181c_shift32() -> P113DFunction:
  P113DFunction{"p181g",p181c_params(["a","b"],0),4,False{},
    nt_append(P113DStmt,p181c_low32(),nt_append(P113DStmt,
      [p181c_bin("r",N111U32{},"shl",p181c_v("a32"),p181c_v("b32")),
       p181c_bin("s",N111U32{},"shr",p181c_v("a32"),p181c_v("b32")),
       p181c_bin("t",N111U32{},"sar",p181c_v("a32"),p181c_v("b32"))],
      nt_append(P113DStmt,p181c_widen(["r","s","t"]),
        [P113DResult{[p181c_v("z_r"),p181c_v("z_s"),p181c_v("z_t"),p181c_v("a")]}])))}

# Result order: eq, ne, ult, ule, ugt, uge, slt, sge. Every comparison
# result is U32 even when its operands are U64. Observe all 64 result bits.
@unsafe
def p181c_comparisons(+typ: N111Type, +a: N111Value, +b: N111Value) -> List<&2,P113DStmt>:
  [p181c_bin("r0",typ,"eq",a,b),p181c_bin("r1",typ,"ne",a,b),
   p181c_bin("r2",typ,"ult",a,b),p181c_bin("r3",typ,"ule",a,b),
   p181c_bin("r4",typ,"ugt",a,b),p181c_bin("r5",typ,"uge",a,b),
   p181c_bin("r6",typ,"slt",a,b),p181c_bin("r7",typ,"sge",a,b)]

@unsafe
def p181c_compare_end() -> List<&2,P113DStmt>:
  nt_append(P113DStmt,p181c_widen(["r0","r1","r2","r3","r4","r5","r6","r7"]),
    [P113DResult{[p181c_v("z_r0"),p181c_v("z_r1"),p181c_v("z_r2"),p181c_v("z_r3"),
      p181c_v("z_r4"),p181c_v("z_r5"),p181c_v("z_r6"),p181c_v("z_r7")]}])

@unsafe
def p181c_compare64() -> P113DFunction:
  P113DFunction{"p181h",p181c_params(["a","b"],0),8,False{},
    nt_append(P113DStmt,p181c_comparisons(N111U64{},p181c_v("a"),p181c_v("b")),p181c_compare_end())}

@unsafe
def p181c_compare32() -> P113DFunction:
  P113DFunction{"p181i",p181c_params(["a","b"],0),8,False{},
    nt_append(P113DStmt,p181c_low32(),nt_append(P113DStmt,
      p181c_comparisons(N111U32{},p181c_v("a32"),p181c_v("b32")),p181c_compare_end()))}

def p181c_args8() -> List<&2,N111Value>:
  [p181c_v("a"),p181c_v("b"),p181c_v("c"),p181c_v("d"),
   p181c_v("e"),p181c_v("f"),p181c_v("g"),p181c_v("h")]

@unsafe
def p181c_weighted() -> P113DFunction:
  P113DFunction{"p181j",p181c_params(["a","b","c","d","e","f","g","h"],0),1,False{},
    [p181c_bin("r",N111U64{},"mul",p181c_v("b"),N111Const{2,0}),
     p181c_bin("sum",N111U64{},"add",p181c_v("a"),p181c_v("r")),
     p181c_bin("r",N111U64{},"mul",p181c_v("c"),N111Const{3,0}),
     p181c_bin("sum",N111U64{},"add",p181c_v("sum"),p181c_v("r")),
     p181c_bin("r",N111U64{},"mul",p181c_v("d"),N111Const{4,0}),
     p181c_bin("sum",N111U64{},"add",p181c_v("sum"),p181c_v("r")),
     p181c_bin("r",N111U64{},"mul",p181c_v("e"),N111Const{5,0}),
     p181c_bin("sum",N111U64{},"add",p181c_v("sum"),p181c_v("r")),
     p181c_bin("r",N111U64{},"mul",p181c_v("f"),N111Const{6,0}),
     p181c_bin("sum",N111U64{},"add",p181c_v("sum"),p181c_v("r")),
     p181c_bin("r",N111U64{},"mul",p181c_v("g"),N111Const{7,0}),
     p181c_bin("sum",N111U64{},"add",p181c_v("sum"),p181c_v("r")),
     p181c_bin("r",N111U64{},"mul",p181c_v("h"),N111Const{8,0}),
     p181c_bin("sum",N111U64{},"add",p181c_v("sum"),p181c_v("r")),
     P113DResult{[p181c_v("sum")]}]}

@unsafe
def p181c_call8() -> P113DFunction:
  P113DFunction{"p181k",p181c_params(["a","b","c","d","e","f","g","h"],0),1,False{},
    [P113DCall{["r"],"p181j",p181c_args8()},
     p181c_bin("r",N111U64{},"add",p181c_v("r"),p181c_v("a")),
     p181c_bin("r",N111U64{},"add",p181c_v("r"),p181c_v("h")),
     P113DResult{[p181c_v("r")]}]}

@unsafe
def p181c_triple5() -> P113DFunction:
  P113DFunction{"p181l",p181c_params(["a","b","c","d","e"],0),3,False{},
    [p181c_bin("sum",N111U64{},"add",p181c_v("a"),p181c_v("d")),
     P113DResult{[p181c_v("e"),p181c_v("sum"),N111Const{1,1}]}]}

@unsafe
def p181c_multi8() -> P113DFunction:
  P113DFunction{"p181m",p181c_params(["a","b","c","d","e","f","g","h"],0),3,False{},
    [P113DCall{["r","s","t"],"p181l",[p181c_v("a"),p181c_v("b"),p181c_v("c"),p181c_v("d"),p181c_v("e")]},
     P113DCall{["u","v","w"],"p181l",[p181c_v("d"),p181c_v("e"),p181c_v("f"),p181c_v("g"),p181c_v("h")]},
     p181c_bin("r",N111U64{},"add",p181c_v("r"),p181c_v("u")),
     p181c_bin("s",N111U64{},"add",p181c_v("s"),p181c_v("v")),
     p181c_bin("t",N111U64{},"add",p181c_v("t"),p181c_v("w")),
     P113DResult{[p181c_v("r"),p181c_v("s"),p181c_v("t")]}]}

@unsafe
def p181c_tail9() -> P113DFunction:
  P113DFunction{"p181n",p181c_params(["n","a","b","c","d","e","f","g","h"],0),1,False{},
    [p181c_bin("done",N111U64{},"eq",p181c_v("n"),N111Const{0,0}),
     P113DIf{p181c_v("done"),
       [P113DCall{["r"],"p181j",p181c_args8()},P113DResult{[p181c_v("r")]}],
       [p181c_bin("next",N111U64{},"sub",p181c_v("n"),N111Const{1,0}),
        P113DAgain{[p181c_v("next"),p181c_v("h"),p181c_v("b"),p181c_v("c"),p181c_v("d"),
          p181c_v("e"),p181c_v("f"),p181c_v("g"),p181c_v("a")]}]}]}

# The direct scalar contract rejects N111Offset and pointer loads/stores.
# Exercise byte offsets through admitted load/store fields instead. The alloca
# requests alignment 16; this control observes its memory contents, not its
# address alignment, because the unchanged direct ABI forbids pointer escape.
@unsafe
def p181c_memory() -> P113DFunction:
  P113DFunction{"p181o",p181c_params(["a","b"],0),3,False{},
    [P113DScalar{N111Alloca{"buffer",32,16}},
     P113DScalar{N111Store{N111U64{},p181c_v("buffer"),0,p181c_v("a")}},
     P113DScalar{N111Store{N111U64{},p181c_v("buffer"),8,N111Const{1985229328,4275878552}}},
     P113DScalar{N111Store{N111U64{},p181c_v("scratch"),0,p181c_v("b")}},
     P113DScalar{N111Load{"b32",N111U32{},p181c_v("scratch"),0}},
     P113DScalar{N111Store{N111U32{},p181c_v("buffer"),4,p181c_v("b32")}},
     P113DScalar{N111Load{"r",N111U64{},p181c_v("buffer"),0}},
     P113DScalar{N111Load{"s",N111U32{},p181c_v("buffer"),4}},
     P113DScalar{N111Load{"t",N111U64{},p181c_v("buffer"),8}},
     P113DScalar{N111Store{N111U64{},p181c_v("scratch"),8,N111Const{0,0}}},
     P113DScalar{N111Store{N111U32{},p181c_v("scratch"),8,p181c_v("s")}},
     P113DScalar{N111Load{"z_s",N111U64{},p181c_v("scratch"),8}},
     P113DResult{[p181c_v("r"),p181c_v("z_s"),p181c_v("t")]}]}

@unsafe
def p181c_join() -> P113DFunction:
  P113DFunction{"p181p",p181c_params(["a"],0),1,False{},
    [p181c_bin("zero",N111U64{},"eq",p181c_v("a"),N111Const{0,0}),
     P113DIf{p181c_v("zero"),[P113DResult{[N111Const{99,0}]}],[]},
     p181c_bin("small",N111U64{},"ult",p181c_v("a"),N111Const{128,0}),
     P113DIf{p181c_v("small"),
       [P113DScalar{N111Set{"value",N111U64{},N111Const{7,0}}}],
       [P113DScalar{N111Set{"value",N111U64{},N111Const{11,0}}}]},
     p181c_bin("value",N111U64{},"add",p181c_v("value"),p181c_v("a")),
     P113DResult{[p181c_v("value")]}]}

# Hidden state/output plus six user arguments put d/e on the incoming stack.
# The nested three-result call overwrites a/b/c only after consuming their old
# values. Again then swaps the updated a/b and the stack arguments d/e, while
# retaining the caller's hidden output pointer independently of call scratch.
@unsafe
def p181c_multi_again() -> P113DFunction:
  P113DFunction{"p181q",p181c_params(["n","a","b","c","d","e"],0),3,False{},
    [p181c_bin("done",N111U64{},"eq",p181c_v("n"),N111Const{0,0}),
     P113DIf{p181c_v("done"),
       [P113DResult{[p181c_v("a"),p181c_v("b"),p181c_v("c")]}],
       [P113DCall{["a","b","c"],"p181l",[p181c_v("a"),p181c_v("b"),p181c_v("c"),p181c_v("d"),p181c_v("e")]},
        p181c_bin("next",N111U64{},"sub",p181c_v("n"),N111Const{1,0}),
        P113DAgain{[p181c_v("next"),p181c_v("b"),p181c_v("a"),p181c_v("c"),p181c_v("e"),p181c_v("d")]}]}]}

@unsafe
def p181c_functions() -> List<&2,P113DFunction>:
  [p181c_binary("p181a","add"),p181c_binary("p181b","sub"),p181c_binary("p181c","mul"),
   p181c_bits(),p181c_arith32(),p181c_shift64(),p181c_shift32(),p181c_compare64(),p181c_compare32(),
   p181c_weighted(),p181c_call8(),p181c_triple5(),p181c_multi8(),p181c_tail9(),p181c_memory(),p181c_join(),p181c_multi_again()]

@unsafe
def p181c_validate() -> String:
  p113e_functions(p181c_functions(),N111Ids{missing(),missing()},missing())
