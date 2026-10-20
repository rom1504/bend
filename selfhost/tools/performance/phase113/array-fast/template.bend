# Exact runtime04 uniform-ARR template. Every failure branch invokes the exact
# original call. Input words are snapshotted before any output or heap store.
# Pointer arithmetic is private generated IR, never admitted public raw memory.
@unsafe
def p113a_inputs(+id: U32, +input: N111Value, +n: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[N111Load{p113a_name(n,"array"),N111U64{},input,0}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),u => [],u =>
      nt_append(N111Stmt,[N111Load{p113a_name(n,"index"),N111U64{},input,8}],
        nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73) || U32.is_eq(id,74),
          v => [N111Load{p113a_name(n,"new"),N111U64{},input,16}],v => []))))

@unsafe
def p113a_class(+n: U32) -> List<&2,N111Stmt>:
  [N111Bin{p113a_name(n,"class"),N111U64{},"shr",p113a_value(n,"array"),N111Const{40,0}},
   N111Bin{p113a_name(n,"class"),N111U64{},"and",p113a_value(n,"class"),N111Const{31,0}},
   N111Bin{p113a_name(n,"size"),N111U64{},"shl",N111Const{1,0},p113a_value(n,"class")}]

@unsafe
def p113a_address(+n: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p113a_class(n),[
    N111Load{p113a_name(n,"heap"),N111Ptr{},N111Local{"state"},0},
    N111Bin{p113a_name(n,"mask"),N111U64{},"sub",p113a_value(n,"size"),N111Const{1,0}},
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),N111Const{4294967295,0}},
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),p113a_value(n,"mask")},
    N111Bin{p113a_name(n,"location"),N111U64{},"and",p113a_value(n,"array"),N111Const{4294967295,255}},
    N111Bin{p113a_name(n,"location"),N111U64{},"add",p113a_value(n,"location"),p113a_value(n,"index")},
    N111Bin{p113a_name(n,"bytes"),N111U64{},"shl",p113a_value(n,"location"),N111Const{3,0}},
    N111Offset{p113a_name(n,"cell"),p113a_value(n,"heap"),p113a_value(n,"bytes")},
    N111Load{p113a_name(n,"old"),N111U64{},p113a_value(n,"cell"),0}])

# Exact top-byte0/1 implies RFC clear and tag<=PAK: keep/sink/seal are identity.
# A full-word copy alone would not justify omitting reference counting.
@unsafe
def p113a_scalar_test(+n: U32, +role: String) -> List<&2,N111Stmt>:
  [N111Bin{p113a_name(n,role ++ "_tag"),N111U64{},"shr",p113a_value(n,role),N111Const{56,0}},
   N111Bin{p113a_name(n,role ++ "_scalar"),N111U64{},"ule",p113a_value(n,role ++ "_tag"),N111Const{1,0}}]

@unsafe
def p113a_scalar_guard(+id: U32, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,72),u => p113a_scalar_test(n,"old"),u =>
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,74),v => p113a_scalar_test(n,"new"),v =>
      nt_append(N111Stmt,p113a_scalar_test(n,"old"),nt_append(N111Stmt,p113a_scalar_test(n,"new"),[
        N111Bin{p113a_name(n,"both_scalar"),N111U32{},"and",p113a_value(n,"old_scalar"),p113a_value(n,"new_scalar")}]))))

@unsafe
def p113a_guard_value(+id: U32, +n: U32) -> N111Value:
  p113a_value(n,nt_choose(String,U32.is_eq(id,72),u => "old_scalar",
    u => nt_choose(String,U32.is_eq(id,74),v => "new_scalar",v => "both_scalar")))

@unsafe
def p113a_pair_store(+destination: String, +output: N111Value, +second: N111Value, +n: U32) -> List<&2,N111Stmt>:
  [N111Store{N111U64{},output,0,p113a_value(n,"array")},
   N111Store{N111U64{},output,8,second},
   N111Set{destination,N111U64{},N111Const{0,0}}]

@unsafe
def p113a_success(+id: U32, +destination: String, +output: N111Value, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,72),
    u => p113a_pair_store(destination,output,p113a_value(n,"old"),n),u =>
    nt_append(N111Stmt,[N111Store{N111U64{},p113a_value(n,"cell"),0,p113a_value(n,"new")}],
      nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),
        v => [N111Set{destination,N111U64{},p113a_value(n,"array")}],
        v => p113a_pair_store(destination,output,p113a_value(n,"old"),n))))

@unsafe
def p113a_raw(+id: U32, +destination: String, +output: N111Value, +original: N111Stmt, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
    u => nt_append(N111Stmt,p113a_class(n),p113a_pair_store(destination,output,p113a_value(n,"size"),n)),
    u => nt_append(N111Stmt,p113a_address(n),nt_append(N111Stmt,p113a_scalar_guard(id,n),[
      N111If{p113a_guard_value(id,n),p113a_success(id,destination,output,n),[original]}])))

@unsafe
def p113a_template(+original: N111Stmt, +n: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{+destination,N111U64{},+symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_choose(List<&2,N111Stmt>,U32.is_eq(id,0),u => [original],u =>
        nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),[
          N111Bin{p113a_name(n,"tag"),N111U64{},"shr",p113a_value(n,"array"),N111Const{56,0}},
          N111Bin{p113a_name(n,"raw"),N111U64{},"eq",p113a_value(n,"tag"),N111Const{6,0}},
          N111Bin{p113a_name(n,"location"),N111U64{},"and",p113a_value(n,"array"),N111Const{4294967295,255}},
          N111Bin{p113a_name(n,"dynamic"),N111U64{},"uge",p113a_value(n,"location"),N111Const{heap_min,0}},
          N111Bin{p113a_name(n,"admitted"),N111U32{},"and",p113a_value(n,"raw"),p113a_value(n,"dynamic")},
          N111If{p113a_value(n,"admitted"),p113a_raw(id,destination,p111v_arg(args,4),original,n),[original]}]))
    case _: [original]
