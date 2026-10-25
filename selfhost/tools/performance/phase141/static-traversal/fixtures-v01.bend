# Exact finite fixtures copied from the previously qualified Phase140 controls.
# Test data only; no replacement comparator bodies. See manifest-v01.json.

def p140tc_values() -> List<&2,N111Value>:
  [N111Local{"x"},N111Local{"y"},N111Const{0,0},N111Const{1,0},N111Const{0,1},N111Symbol{"x"},N111FuncId{"x"},N111CtorId{"x"}]

def p140tc_args() -> List<&2,N111Arg>:
  [N111Arg{N111U32{},N111Local{"x"}},N111Arg{N111U64{},N111Local{"x"}},N111Arg{N111Ptr{},N111Symbol{"x"}},N111Arg{N111U32{},N111Const{7,0}}]

def p140tc_bindings() -> List<&2,NC_Binding>:
  [NC_Binding{0,"a",N_W32{}},NC_Binding{0,"a",N_W64{}},NC_Binding{0,"a",N_Box{}},NC_Binding{0,"a",N_Imm64{}},NC_Binding{1,"a",N_W32{}},NC_Binding{0,"b",N_W32{}}]

def p140tc_scalars() -> List<&2,N111Stmt>:
  [N111Set{"x",N111U64{},N111Const{0,0}},
   N111Bin{"x",N111U32{},"eq",N111Local{"a"},N111Const{1,0}},
   N111Call{"x",N111U64{},"helper",p140tc_args()},
   N111If{N111Local{"c"},[N111Return{N111Const{1,0}}],[N111Return{N111Const{0,0}}]},
   N111Return{N111Const{0,0}},N111Load{"x",N111U64{},N111Local{"p"},8},
   N111Store{N111U64{},N111Local{"p"},8,N111Local{"x"}},
   N111Offset{"x",N111Local{"p"},N111Const{8,0}},N111Alloca{"p",16,8},
   N111If{N111Local{"c"},[N111If{N111Local{"d"},[N111Return{N111Const{1,0}}],[]}],[]},
   N111If{N111Local{"c"},[N111If{N111Local{"d"},[N111Return{N111Const{2,0}}],[]}],[]}]

def p140tc_stmts() -> List<&2,P113DStmt>:
  [P113DScalar{N111Return{N111Const{0,0}}},
   P113DIf{N111Local{"c"},[P113DResult{[N111Const{1,0}]}],[P113DResult{[N111Const{0,0}]}]},
   P113DCall{["x","y"],"helper",p140tc_values()},
   P113DResult{[N111Const{0,0}]},P113DAgain{[N111Local{"x"}]},
   P113DIf{N111Local{"c"},[P113DIf{N111Local{"d"},[P113DResult{[N111Const{1,0}]}],[]}],[]},
   P113DIf{N111Local{"c"},[P113DIf{N111Local{"d"},[P113DResult{[N111Const{2,0}]}],[]}],[]}]

def p140tc_functions() -> List<&2,P113DFunction>:
  [P113DFunction{"f",p140tc_bindings(),1,False{},p140tc_stmts()},
   P113DFunction{"f",p140tc_bindings(),1,True{},p140tc_stmts()},
   P113DFunction{"g",p140tc_bindings(),1,False{},p140tc_stmts()},
   P113DFunction{"f",p140tc_bindings(),2,False{},p140tc_stmts()},
   P113DFunction{"f",p140tc_bindings(),1,False{},[]}]

def p140tc_raw_headers() -> List<&2,N111Segment>:
  [N111Segment{"a",1,1,0,0,[]},N111Segment{"a",1,1,0,1,[]},
   N111Segment{"a",1,1,1,0,[]},N111Segment{"a",1,2,0,0,[]},
   N111Segment{"b",1,1,0,0,[]},N111Segment{"a",2,1,0,0,[]},
   N111Segment{"a",1,1,0,0,p140tc_scalars()}]

def p140tc_ctors() -> List<&2,N_Constructor>:
  [N_Constructor{"A",1,False{}},N_Constructor{"A",2,False{}},N_Constructor{"A",1,True{}},N_Constructor{"B",1,False{}}]
