# Finite immediate-selection controls. The unchanged direct verifier admits
# these functions before the current x86 emitter produces machine code.
# x86-controls.c observes full result words through the external SysV ABI.

def p185x_v(name: String) -> N111Value:
  N111Local{name}

def p185x_bin(name: String, typ: N111Type, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,typ,op,left,right}}

def p185x_params() -> List<&2,NC_Binding>:
  [NC_Binding{0,"a",N_W64{}}]

@unsafe
def p185x_widen(names: List<&2,String>) -> List<&2,P113DStmt>:
  match names:
    case Nil{}: []
    case Con{+name,rest}:
      nt_append(P113DStmt,
        [P113DScalar{N111Store{N111U64{},p185x_v("scratch"),32,N111Const{0,0}}},
         P113DScalar{N111Store{N111U32{},p185x_v("scratch"),32,p185x_v(name)}},
         P113DScalar{N111Load{"z_" ++ name,N111U64{},p185x_v("scratch"),32}}],p185x_widen(rest))

def p185x_mask() -> P113DFunction:
  P113DFunction{"p185a",p185x_params(),1,False{},
    [p185x_bin("r",N111U64{},"and",p185x_v("a"),N111Const{4294967295,0}),
     P113DResult{[p185x_v("r")]}]}

def p185x_shift64() -> P113DFunction:
  P113DFunction{"p185b",p185x_params(),6,False{},
    [p185x_bin("r0",N111U64{},"shl",p185x_v("a"),N111Const{64,0}),
     p185x_bin("r1",N111U64{},"shr",p185x_v("a"),N111Const{63,0}),
     p185x_bin("r2",N111U64{},"sar",p185x_v("a"),N111Const{63,0}),
     p185x_bin("r3",N111U64{},"shl",p185x_v("a"),N111Const{255,0}),
     p185x_bin("r4",N111U64{},"shr",p185x_v("a"),N111Const{32,0}),
     p185x_bin("r5",N111U64{},"sar",p185x_v("a"),N111Const{32,0}),
     P113DResult{[p185x_v("r0"),p185x_v("r1"),p185x_v("r2"),p185x_v("r3"),p185x_v("r4"),p185x_v("r5")]}]}

@unsafe
def p185x_immediate32() -> P113DFunction:
  P113DFunction{"p185c",p185x_params(),8,False{},
    nt_append(P113DStmt,
      [P113DScalar{N111Store{N111U64{},p185x_v("scratch"),0,p185x_v("a")}},
       P113DScalar{N111Load{"a32",N111U32{},p185x_v("scratch"),0}},
       p185x_bin("r0",N111U32{},"mul",p185x_v("a32"),N111Const{4294967295,0}),
       p185x_bin("r1",N111U32{},"shl",p185x_v("a32"),N111Const{64,0}),
       p185x_bin("r2",N111U32{},"shr",p185x_v("a32"),N111Const{255,0}),
       p185x_bin("r3",N111U32{},"sar",p185x_v("a32"),N111Const{255,0}),
       p185x_bin("r4",N111U32{},"ult",p185x_v("a32"),N111Const{4294967295,0}),
       p185x_bin("r5",N111U32{},"slt",p185x_v("a32"),N111Const{4294967295,0}),
       p185x_bin("r6",N111U32{},"and",p185x_v("a32"),N111Const{4294967295,0}),
       p185x_bin("r7",N111U32{},"eq",p185x_v("a32"),N111Const{0,0})],
      nt_append(P113DStmt,p185x_widen(["r0","r1","r2","r3","r4","r5","r6","r7"]),
        [P113DResult{[p185x_v("z_r0"),p185x_v("z_r1"),p185x_v("z_r2"),p185x_v("z_r3"),
          p185x_v("z_r4"),p185x_v("z_r5"),p185x_v("z_r6"),p185x_v("z_r7")]}]))}

@unsafe
def p185x_large64() -> P113DFunction:
  P113DFunction{"p185d",p185x_params(),4,False{},
    nt_append(P113DStmt,
      [p185x_bin("r0",N111U64{},"ult",p185x_v("a"),N111Const{2147483648,0}),
       p185x_bin("r1",N111U64{},"slt",p185x_v("a"),N111Const{2147483648,0}),
       p185x_bin("r2",N111U64{},"and",p185x_v("a"),N111Const{2147483648,0}),
       p185x_bin("r3",N111U64{},"mul",p185x_v("a"),N111Const{2147483648,0})],
      nt_append(P113DStmt,p185x_widen(["r0","r1"]),
        [P113DResult{[p185x_v("z_r0"),p185x_v("z_r1"),p185x_v("r2"),p185x_v("r3")]}]))}

def p185x_functions() -> List<&2,P113DFunction>:
  [p185x_mask(),p185x_shift64(),p185x_immediate32(),p185x_large64()]

@unsafe
def p185x_validate() -> String:
  p113e_functions(p185x_functions(),N111Ids{missing(),missing()},missing())
