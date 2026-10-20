type P114TExpansion is Data:
  P114TExpansion{+body: List<&2,N111Stmt>, +changed: Bool}

@unsafe
def p114t_name(site: U32, role: String) -> String:
  "p114t_" ++ U32.show(site) ++ "_" ++ role

@unsafe
def p114t_local(site: U32, role: String) -> N111Value:
  N111Local{p114t_name(site,role)}

# Only stack allocations from the authenticated ordinary/fusion/inlining
# factories are supported. This is not an arbitrary pointer-alias certificate.
@unsafe
def p114t_fusion_buffer(+name: String, +site: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(site,8),u => False{},u =>
    nt_choose(Bool,String.eq(name,"p112f_" ++ U32.show(site) ++ "_local_scratch"),
      v => True{},v => p114t_fusion_buffer(name,U32.inc(site))))

@unsafe
def p114t_buffer(+name: String) -> Bool:
  p113j_buffer_origin(name,True{}) || p114t_fusion_buffer(name,0)

@unsafe
def p114t_known_fid(+name: String, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      String.eq(dk(index_find(functions,name,index_hash(name,2166136261),32)),"N111Id")

# Exact unsigned two's complement byte offset. Count zero must have high zero.
@unsafe
def p114t_negative_bytes(+count: U32) -> N111Value:
  nt_choose(N111Value,U32.is_eq(count,0),u => N111Const{0,0},
    u => N111Const{U32.sub(0,U32.mul(count,8)),4294967295})

# Preserve the runtime's ordered source-load/destination-store pairs. We do not
# replace this loop with memmove or reorder all loads ahead of all stores.
@unsafe
def p114t_captures(+buffer: String, +count: U32, +index: U32, +site: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Load{p114t_name(site,"capture"),N111U64{},N111Local{buffer},U32.mul(index,8)},
    Con{N111Store{N111U64{},p114t_local(site,"sp"),U32.mul(index,8),p114t_local(site,"capture")},
      p114t_captures(buffer,count,U32.inc(index),site)}})

@unsafe
def p114t_frame(+dest: String, fid: String, buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  Con{N111Load{p114t_name(site,"sp"),N111Ptr{},N111Local{"state"},16},
    nt_append(N111Stmt,p114t_captures(buffer,count,0,site),[
      N111Store{N111U64{},p114t_local(site,"sp"),U32.mul(count,8),N111FuncId{fid}},
      N111Offset{p114t_name(site,"next_sp"),p114t_local(site,"sp"),N111Const{U32.mul(U32.inc(count),8),0}},
      N111Store{N111Ptr{},N111Local{"state"},16,p114t_local(site,"next_sp")},
      N111Set{dest,N111U64{},N111Const{0,0}}])}

@unsafe
def p114t_pop(dest: String, count: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"sp"),N111Ptr{},N111Local{"state"},16},
   N111Offset{p114t_name(site,"next_sp"),p114t_local(site,"sp"),p114t_negative_bytes(count)},
   N111Store{N111Ptr{},N111Local{"state"},16,p114t_local(site,"next_sp")},
   N111Set{dest,N111U64{},N111Const{0,0}}]

@unsafe
def p114t_get(dest: String, index: U32, +site: U32) -> List<&2,N111Stmt>:
  [N111Load{p114t_name(site,"sp"),N111Ptr{},N111Local{"state"},16},
   N111Load{dest,N111U64{},p114t_local(site,"sp"),U32.mul(index,8)}]

@unsafe
def p114t_expand(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111FuncId{+fid}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") &&
          U32.is_eq(high,0) && U32.is_lt(count,256) && p114t_buffer(buffer) && p114t_known_fid(fid,ids),
          u => P114TExpansion{p114t_frame(dest,fid,buffer,count,site),True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}:
        nt_choose(P114TExpansion,String.eq(state,"state") && U32.is_eq(high,0) && U32.is_lt(count,256),
          u => nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_stack_pop"),
            v => P114TExpansion{p114t_pop(dest,count,site),True{}},
            v => nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_stack_get"),
              w => P114TExpansion{p114t_get(dest,count,site),True{}},
              w => P114TExpansion{[stmt],False{}})),
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}
