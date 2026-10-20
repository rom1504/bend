# CPU one-context qualification. No allocator handoff is implemented here:
# queue-boundary cases call the original helper before any store or ownership
# transfer. Dynamic parent and last-owner wrapper fields are loaded first.
@unsafe
def p114rt_free_wrapper(+n: U32) -> List<&2,N111Stmt>:
  [N111Load{p114rt_name(n,"hot0"),N111U64{},p114rt_value(n,"alc"),0},
   N111Store{N111U64{},p114rt_value(n,"wrapper"),0,p114rt_value(n,"hot0")},
   N111Store{N111U64{},p114rt_value(n,"alc"),0,p114rt_value(n,"loc")},
   N111Bin{p114rt_name(n,"len0"),N111U64{},"add",p114rt_value(n,"len0"),N111Const{1,0}},
   N111Store{N111U64{},p114rt_value(n,"alc"),256,p114rt_value(n,"len0")}]

@unsafe
def p114rt_free_shell(+n: U32) -> List<&2,N111Stmt>:
  [N111Load{p114rt_name(n,"hot1"),N111U64{},p114rt_value(n,"alc"),8},
   N111Store{N111U64{},p114rt_value(n,"shell"),0,p114rt_value(n,"hot1")},
   N111Store{N111U64{},p114rt_value(n,"alc"),8,p114rt_value(n,"src")},
   N111Bin{p114rt_name(n,"len1"),N111U64{},"add",p114rt_value(n,"len1"),N111Const{2,0}},
   N111Store{N111U64{},p114rt_value(n,"alc"),264,p114rt_value(n,"len1")}]

@unsafe
def p114rt_take_commit(+destination: String, +output: N111Value, +n: U32, +wrapped: Bool) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p114rt_address(n,"shell",p114rt_value(n,"src")),
    nt_append(N111Stmt,[
      N111Load{p114rt_name(n,"first"),N111U64{},p114rt_value(n,"shell"),0},
      N111Load{p114rt_name(n,"second"),N111U64{},p114rt_value(n,"shell"),8},
      N111Store{N111U64{},output,0,p114rt_value(n,"first")},
      N111Store{N111U64{},output,8,p114rt_value(n,"second")}],
      nt_append(N111Stmt,nt_choose(List<&2,N111Stmt>,wrapped,u => p114rt_free_wrapper(n),u => []),
        nt_append(N111Stmt,p114rt_free_shell(n),[N111Set{destination,N111U64{},N111Const{2,0}}]))))

@unsafe
def p114rt_take_queues(+original: N111Stmt, +destination: String, +output: N111Value, +n: U32, +wrapped: Bool) -> List<&2,N111Stmt>:
  [N111Load{p114rt_name(n,"alc"),N111Ptr{},N111Local{"state"},8},
   N111Load{p114rt_name(n,"len1"),N111U64{},p114rt_value(n,"alc"),264},
   N111Bin{p114rt_name(n,"room1"),N111U64{},"ult",p114rt_value(n,"len1"),N111Const{32766,0}},
   N111If{p114rt_value(n,"room1"),
     nt_choose(List<&2,N111Stmt>,wrapped,u => [
       N111Load{p114rt_name(n,"len0"),N111U64{},p114rt_value(n,"alc"),256},
       N111Bin{p114rt_name(n,"room0"),N111U64{},"ult",p114rt_value(n,"len0"),N111Const{32767,0}},
       N111If{p114rt_value(n,"room0"),p114rt_take_commit(destination,output,n,wrapped),[original]}],
       u => p114rt_take_commit(destination,output,n,wrapped)),[original]}]

@unsafe
def p114rt_take_dynamic(+original: N111Stmt, +destination: String, +output: N111Value, +n: U32, +heap_min: U32, +wrapped: Bool) -> List<&2,N111Stmt>:
  [N111Bin{p114rt_name(n,"dynamic"),N111U64{},"uge",p114rt_value(n,"src"),N111Const{heap_min,0}},
   N111If{p114rt_value(n,"dynamic"),p114rt_take_queues(original,destination,output,n,wrapped),[original]}]

@unsafe
def p114rt_take_redirect(+original: N111Stmt, +destination: String, +output: N111Value, +n: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p114rt_address(n,"wrapper",p114rt_value(n,"loc")),[
    N111Load{p114rt_name(n,"cell"),N111U64{},p114rt_value(n,"wrapper"),0},
    N111Bin{p114rt_name(n,"count"),N111U64{},"and",p114rt_value(n,"cell"),N111Const{16777215,0}},
    N111Bin{p114rt_name(n,"last"),N111U64{},"eq",p114rt_value(n,"count"),N111Const{1,0}},
    N111If{p114rt_value(n,"last"),
      Con{N111Bin{p114rt_name(n,"src"),N111U64{},"shr",p114rt_value(n,"cell"),N111Const{24,0}},
        p114rt_take_dynamic(original,destination,output,n,heap_min,True{})},[original]}])

@unsafe
def p114rt_take_classify(+original: N111Stmt, +destination: String, +output: N111Value, +n: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  [N111Bin{p114rt_name(n,"loc"),N111U64{},"and",p114rt_value(n,"term"),N111Const{4294967295,255}},
   N111Bin{p114rt_name(n,"rfc"),N111U64{},"shr",p114rt_value(n,"term"),N111Const{63,0}},
   N111If{p114rt_value(n,"rfc"),p114rt_take_redirect(original,destination,output,n,heap_min),
     Con{N111Set{p114rt_name(n,"src"),N111U64{},p114rt_value(n,"loc")},
       p114rt_take_dynamic(original,destination,output,n,heap_min,False{})}}]

@unsafe
def p114rt_take_metadata(+original: N111Stmt, +destination: String, +output: N111Value, +n: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  [N111Bin{p114rt_name(n,"cid_bytes"),N111U64{},"shl",p114rt_value(n,"cid"),N111Const{3,0}},
   N111Offset{p114rt_name(n,"arity_ptr"),N111Symbol{"p114rt_arity2"},p114rt_value(n,"cid_bytes")},
   N111Load{p114rt_name(n,"arity_two"),N111U64{},p114rt_value(n,"arity_ptr"),0},
   N111If{p114rt_value(n,"arity_two"),p114rt_take_classify(original,destination,output,n,heap_min),[original]}]

@unsafe
def p114rt_template(+original: N111Stmt, +n: U32, +heap_min: U32, +constructors: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{+destination,N111U64{},symbol,+args}:
      nt_choose(List<&2,N111Stmt>,p114rt_take2(original),u => [
        N111Set{p114rt_name(n,"term"),N111U64{},p111v_arg(args,1)},
        N111Bin{p114rt_name(n,"tag"),N111U64{},"shr",p114rt_value(n,"term"),N111Const{56,0}},
        N111Bin{p114rt_name(n,"tag"),N111U64{},"and",p114rt_value(n,"tag"),N111Const{127,0}},
        N111Bin{p114rt_name(n,"is_ctr"),N111U64{},"eq",p114rt_value(n,"tag"),N111Const{2,0}},
        N111Bin{p114rt_name(n,"cid"),N111U64{},"shr",p114rt_value(n,"term"),N111Const{40,0}},
        N111Bin{p114rt_name(n,"cid"),N111U64{},"and",p114rt_value(n,"cid"),N111Const{65535,0}},
        N111Bin{p114rt_name(n,"cid_bound"),N111U64{},"ult",p114rt_value(n,"cid"),N111Const{constructors,0}},
        N111Bin{p114rt_name(n,"metadata"),N111U32{},"and",p114rt_value(n,"is_ctr"),p114rt_value(n,"cid_bound")},
        N111If{p114rt_value(n,"metadata"),p114rt_take_metadata(original,destination,p111v_arg(args,2),n,heap_min),[original]}],u => [original])
    case _: [original]
