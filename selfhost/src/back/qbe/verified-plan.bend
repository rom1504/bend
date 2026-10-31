

@unsafe
def p113a_enabled(certificate: P113ACertificate) -> Bool:
  match certificate:
    case P113ACertificate{scalar,unshared}: scalar && unshared


@unsafe
def p113a_certificate(request: NR_Request) -> P113ACertificate:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      +scalar = ns_definitions(book,names)
      P113ACertificate{scalar,nt_choose(Bool,scalar,u => nr_unshared(book,names),u => False{})}


@unsafe
def p113a_finish(certificate: P113ACertificate, lowered: P113DLowering) -> P113ALowering:
  match lowered:
    case P113DLowered{program,error}: P113ALowered{P113AProgram{program,certificate},error}


@unsafe
def p113a_lower_request(+request: NR_Request) -> P113ALowering:
  p113a_finish(p113a_certificate(request),p113d_lower_request(request))


@unsafe
def p113a_name(n: U32, role: String) -> String:
  "p113a_" ++ U32.show(n) ++ "_" ++ role


@unsafe
def p113a_value(n: U32, role: String) -> N111Value:
  N111Local{p113a_name(n,role)}

# A zero means no rewrite. These checks are deliberately redundant with the
# original direct verifier; no unchecked call is made legal by this profile.


@unsafe
def p113a_pair_id(+symbol: String, +args: List<&2,N111Arg>) -> U32:
  +id = p111v_literal(p111v_arg(args,1))
  nt_choose(U32,p113p_array_call(symbol,args) &&
    (U32.is_eq(id,72) || U32.is_eq(id,74) || U32.is_eq(id,75)),u => id,u => 0)


@unsafe
def p113a_call_id(+symbol: String, +args: List<&2,N111Arg>) -> U32:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{73,0}},
      Con{N111Arg{N111Ptr{},N111Local{+input}},
      Con{N111Arg{N111U32{},N111Const{3,0}},Nil{}}}}}:
        nt_choose(U32,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
          Bool.not(String.eq(input,"state")),u => 73,u => p113a_pair_id(symbol,args))
    case _: p113a_pair_id(symbol,args)


@unsafe
def p113a_stmt_id(stmt: N111Stmt) -> U32:
  match stmt:
    case N111Call{name,N111U64{},symbol,args}: p113a_call_id(symbol,args)
    case _: 0


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
    N111Set{p113a_name(n,"heap"),N111Ptr{},N111Local{"p113a_heap_base"}},
    N111Bin{p113a_name(n,"mask"),N111U64{},"sub",p113a_value(n,"size"),N111Const{1,0}},
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),N111Const{4294967295,0}},
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),p113a_value(n,"mask")},
    N111Bin{p113a_name(n,"location"),N111U64{},"and",p113a_value(n,"array"),N111Const{4294967295,255}},
    N111Bin{p113a_name(n,"location"),N111U64{},"add",p113a_value(n,"location"),p113a_value(n,"index")},
    N111Bin{p113a_name(n,"bytes"),N111U64{},"shl",p113a_value(n,"location"),N111Const{3,0}},
    N111Offset{p113a_name(n,"cell"),p113a_value(n,"heap"),p113a_value(n,"bytes")},
    N111Load{p113a_name(n,"old"),N111U64{},p113a_value(n,"cell"),0}])

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
    nt_append(N111Stmt,[N111Store{N111U32{},p113a_value(n,"cell"),0,p113a_value(n,"new")}],
      nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),
        v => [N111Set{destination,N111U64{},p113a_value(n,"array")}],
        v => p113a_pair_store(destination,output,p113a_value(n,"old"),n))))

@unsafe
def p113a_raw(+id: U32, +destination: String, +output: N111Value, +original: N111Stmt, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
    u => nt_append(N111Stmt,p113a_class(n),p113a_pair_store(destination,output,p113a_value(n,"size"),n)),
    u => nt_append(N111Stmt,p117p_address(id,n),p113a_success(id,destination,output,n)))

@unsafe
def p113a_template(+original: N111Stmt, +n: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{+destination,N111U64{},+symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_choose(List<&2,N111Stmt>,U32.is_eq(id,0),u => [original],u =>
        nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),[
          N111Bin{p113a_name(n,"tag"),N111U64{},"shr",p113a_value(n,"array"),N111Const{56,0}},
          N111Bin{p113a_name(n,"raw"),N111U64{},"eq",p113a_value(n,"tag"),N111Const{4,0}},
          N111Bin{p113a_name(n,"location"),N111U64{},"and",p113a_value(n,"array"),N111Const{4294967295,255}},
          N111Bin{p113a_name(n,"dynamic"),N111U64{},"uge",p113a_value(n,"location"),N111Const{heap_min,0}},
          N111Bin{p113a_name(n,"admitted"),N111U32{},"and",p113a_value(n,"raw"),p113a_value(n,"dynamic")},
          N111If{p113a_value(n,"admitted"),p113a_raw(id,destination,p111v_arg(args,4),original,n),[original]}]))
    case _: [original]

# Explicit unsigned loads establish the full Term value before64-bit use.
# QBE permits a long temporary in word contexts; high bits are now defined0.

@unsafe
def p113a_local_name(name: String) -> Bool:
  Bool.not(String.starts_with(name,"p113a_"))


@unsafe
def p113a_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: p113a_local_name(name) && p113a_names(rest)


@unsafe
def p113a_params(params: List<&2,NC_Binding>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,word,kind},rest}: p113a_local_name(word) && p113a_params(rest)


@unsafe
def p113a_scalar_names(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p113a_local_name(name)
    case N111Bin{name,typ,op,left,right}: p113a_local_name(name)
    case N111Call{name,typ,symbol,args}: p113a_local_name(name)
    case N111If{condition,yes,no}: p113a_scalar_list_names(yes) && p113a_scalar_list_names(no)
    case N111Load{name,typ,base,offset}: p113a_local_name(name)
    case N111Offset{name,base,bytes}: p113a_local_name(name)
    case N111Alloca{name,bytes,align}: p113a_local_name(name)
    case _: True{}


@unsafe
def p113a_scalar_list_names(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p113a_scalar_names(head) && p113a_scalar_list_names(rest)


@unsafe
def p113a_body_names(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p113a_scalar_names(stmt) && p113a_body_names(rest)
    case Con{P113DIf{condition,yes,no},rest}: p113a_body_names(yes) && p113a_body_names(no) && p113a_body_names(rest)
    case Con{P113DCall{destinations,target,args},rest}: p113a_names(destinations) && p113a_body_names(rest)
    case Con{head,rest}: p113a_body_names(rest)


@unsafe
def p113a_function_names(functions: List<&2,P113DFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{P113DFunction{name,params,result,public,body},rest}:
      p113a_params(params) && p113a_body_names(body) && p113a_function_names(rest)


@unsafe
def p113a_namespace(program: P113DProgram) -> Bool:
  match program:
    case P113DProgram{original,functions}: p113a_function_names(functions)


@unsafe
def p113a_verify_after(+program: P113DProgram, +certificate: P113ACertificate, +error: String) -> String:
  nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
    nt_choose(String,Bool.not(p113a_enabled(certificate)) || p113a_namespace(program),
      v => "",v => "reserved private array-template local"))


@unsafe
def p113a_verify(+program: P113AProgram) -> String:
  p114t_verify_done(program,p114t_original_verify(program))

@unsafe
def p113a_prefix(prefix: List<&2,P113DStmt>, scan: P113ABody) -> P113ABody:
  match scan:
    case P113ABody{body,next}: P113ABody{nt_append(P113DStmt,prefix,body),next}


@unsafe
def p113a_scan(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      nt_choose(P113ABody,U32.is_gt(p113a_stmt_id(stmt),0),
        u => p113a_prefix(p113d_scalars(p113a_template(stmt,n,heap_min)),p113a_scan(rest,U32.inc(n),heap_min)),
        u => p113a_prefix([P113DScalar{stmt}],p113a_scan(rest,n,heap_min)))
    case Con{P113DIf{condition,yes,no},rest}:
      p113a_scan_yes(condition,no,rest,heap_min,p113a_scan(yes,n,heap_min))
    case Con{head,rest}: p113a_prefix([head],p113a_scan(rest,n,heap_min))


@unsafe
def p113a_scan_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: p113a_scan_no(condition,body,rest,heap_min,p113a_scan(no,next,heap_min))


@unsafe
def p113a_scan_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],p113a_scan(rest,next,heap_min))


@unsafe
def p113a_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113ABody) -> P113DFunction:
  match scan:
    case P113ABody{body,next}: P113DFunction{name,params,result,public,body}


@unsafe
def p113a_function(function: P113DFunction, +heap_min: U32) -> P113DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}: p113a_function_done(name,params,result,public,p113a_scan(body,0,heap_min))


@unsafe
def p113a_functions(functions: List<&2,P113DFunction>, +heap_min: U32) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{head,rest}: Con{p113a_function(head,heap_min),p113a_functions(rest,heap_min)}


@unsafe
def p113a_count_body(body: List<&2,P113DStmt>, count: U32) -> U32:
  match body:
    case Nil{}: count
    case Con{P113DScalar{stmt},rest}:
      p113a_count_body(rest,U32.add(count,nt_choose(U32,U32.is_gt(p113a_stmt_id(stmt),0),u => 1,u => 0)))
    case Con{P113DIf{condition,yes,no},rest}: p113a_count_body(rest,p113a_count_body(no,p113a_count_body(yes,count)))
    case Con{head,rest}: p113a_count_body(rest,count)


@unsafe
def p113a_count_functions(functions: List<&2,P113DFunction>, count: U32) -> U32:
  match functions:
    case Nil{}: count
    case Con{P113DFunction{name,params,result,public,body},rest}: p113a_count_functions(rest,p113a_count_body(body,count))


@unsafe
def p113a_heap_min(nodes: List<&2,P112SNode>) -> U32:
  U32.add(51413504,U32.and(U32.add(p112s_size(nodes,0),127),4294967168))

# Only the complete private worker bodies receive generated memory templates.
# Public fallback, static image, old private ABI and registration are unchanged.


@unsafe
def p113a_registered(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>,
    +index: P112FusionIndex, +ids: N111Ids, +heap_min: U32, registry: P112RegionRegistry) -> List<&2,String>:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      +direct = p113e_signatures(functions,missing())
      nt_append(String,p113ah_private_chunks(functions,ids,heap_min,[]),
        p112c_attach(p113e_public_chunks(segments,direct,index,ids,ready,[]),
          nt_join(p113e_old_private_chunks(entries,direct,ids,[]),"")))

@unsafe
def p113a_segment_chunks(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>,
    +ids: N111Ids, +heap_min: U32, +index: P112FusionIndex) -> List<&2,String>:
  p113a_registered(segments,functions,index,ids,heap_min,p112c_index_with(segments,index))


@unsafe
def p113a_bundle_chunks(+program: P111Program, +nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>) -> List<&2,String>:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      nt_append(String,p113a_segment_chunks(segments,functions,ids,p113a_heap_min(nodes),p112f_index(segments)),
        nt_append(String,p111q_data_chunks(p117p_tables(nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
          u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids)),[])),[p111q_main()]))

@unsafe
def p113a_admitted_chunks(+program: P113AProgram) -> List<&2,String>:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{raw,nodes},Con{head,rest}},certificate}:
      nt_choose(List<&2,String>,p118z_eligible(program),
        u => p118z_bundle(raw,nodes,Con{head,rest},p113a_enabled(certificate)),
        u => p118z_original_chunks(program))
    case _: p118z_original_chunks(program)

@unsafe
def p113a_enabled_chunks(program: P113DProgram) -> List<&2,String>:
  match program:
    case P113DProgram{original,Nil{}}: p112s_chunks(original)
    case P113DProgram{P112StaticProgram{program,nodes},functions}: p113a_bundle_chunks(program,nodes,functions)


@unsafe
def p113a_checked_chunks(+program: P113AProgram, +error: String) -> List<&2,String>:
  nt_choose(List<&2,String>,String.is_empty(error),u => p113a_admitted_chunks(program),
    u => ["INVALID_P113_ARRAY_PROGRAM: " ++ error ++ "\n"])


@unsafe
def p113a_chunks(+program: P113AProgram) -> List<&2,String>:
  p113a_checked_chunks(program,p113a_verify(program))


@unsafe
def p113a_text(program: P113AProgram) -> String:
  nt_text_finish(nt_reverse(String,p113a_chunks(program),[]),"")


@unsafe
def p113a_inspection(+program: P113AProgram, error: String) -> P113AInspection:
  match program:
    case P113AProgram{P113DProgram{original,+functions},P113ACertificate{+scalar,+unshared}}:
      P113AInspection{scalar,unshared,scalar && unshared,nt_count(P113DFunction,functions),
        nt_choose(U32,scalar && unshared,u => p113a_count_functions(functions,0),u => 0),error}


@unsafe
def p113a_inspect_lowered(lowered: P113ALowering) -> P113AInspection:
  match lowered:
    case P113ALowered{+program,+error}:
      p113a_inspection(program,nt_choose(String,String.is_empty(error),u => p113a_verify(program),u => error))


@unsafe
def p113a_inspect_request(request: NR_Request) -> P113AInspection:
  p113a_inspect_lowered(p113a_lower_request(request))


@unsafe
def p113a_emit_verified(+program: P113AProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P134Planned{P134Admitted{program}},
    u => P111Emission{[],"array structured IR: " ++ error})

@unsafe
def p113a_emit_lowered(lowered: P113ALowering) -> P111Emission:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => p113a_emit_verified(program,p113a_verify(program)),
        u => P111Emission{[],"array native lowering: " ++ error})


@unsafe
def p113ai_first(values: List<&2,N111Value>) -> N111Value:
  match values:
    case Con{value,rest}: value
    case Nil{}: N111Symbol{"invalid_array_identity"}


@unsafe
def p113ai_snapshot(+values: List<&2,N111Value>, +n: U32) -> N111Stmt:
  N111Set{"p113ai_array_" ++ U32.show(n),N111U64{},p113ai_first(values)}


@unsafe
def p113ai_set_done(+values: List<&2,N111Value>, +n: U32, original: P111ValueCode) -> P111ValueCode:
  match original:
    case P111ValueCode{body,value,error}:
      P111ValueCode{Con{p113ai_snapshot(values,n),nt_append(N111Stmt,body,[
        N111Set{"p113ai_result_" ++ U32.show(n),N111U64{},N111Local{"p113ai_array_" ++ U32.show(n)}}])},
        N111Local{"p113ai_result_" ++ U32.show(n)},error}


@unsafe
def p113ai_intrinsic(+name: String, +values: List<&2,N111Value>, +n: U32) -> P111ValueCode:
  nt_choose(P111ValueCode,String.eq(name,"array_set") && U32.is_eq(nt_count(N111Value,values),3),
    u => p113ai_set_done(values,n,p111_intrinsic(name,values)),
    u => p111_intrinsic(name,values))


@unsafe
def p113ah_loop(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, entry: P111QCode) -> P111QCode:
  match entry:
    case P111QCode{chunks,n,terminal,error}:
      p113e_stmts(body,params,ids,P111QCode{Con{"@p113_loop\n",Con{"jmp @p113_loop\n",chunks}},n,False{},error})


@unsafe
def p113ah_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p144e_body_tail(p113ah_loop(body,params,ids,
          p111q_stmt(N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},ids,P111QCode{allocas,0,False{},""})),"}\n")

@unsafe
def p113ah_function(+function: P113DFunction, +ids: N111Ids, +heap_min: U32) -> String:
  +table = p126s_emit(function)
  nt_choose(String,String.is_empty(table),u => p126s_prior_function(function,ids,heap_min),u => table)

@unsafe
def p113ah_private_chunks(+functions: List<&2,P113DFunction>, +ids: N111Ids, +heap_min: U32, +acc: List<&2,String>) -> List<&2,String>:
  p126i_chunks(functions,p126i_catalogue(functions,[]),ids,heap_min,acc)

@unsafe
def p113ah_control_text(+loop: Bool, +arrays: Bool) -> String:
  +body = nt_choose(List<&2,P113DStmt>,arrays,
    u => [P113DScalar{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"a"}}},
      P113DScalar{N111Store{N111U64{},N111Local{"scratch"},8,N111Const{0,0}}},
      P113DScalar{N111Alloca{"p113p_out_1",16,8}},
      P113DScalar{N111Call{"status",N111U64{},"p113_rt_array_pair",
        [p111_state(),p111_u32(72),p111_scratch(),p111_u32(2),N111Arg{N111Ptr{},N111Local{"p113p_out_1"}},p111_u32(2)]}},
      P113DScalar{N111Load{"a",N111U64{},N111Local{"p113p_out_1"},0}}],u => [])
  +tail = nt_choose(P113DStmt,loop,u => P113DAgain{[N111Local{"a"}]},u => P113DResult{[N111Local{"a"}]})
  p113ah_function(P113DFunction{"$product.heap_probe",[NC_Binding{0,"a",N_Box{}}],1,False{},nt_append(P113DStmt,body,[tail])},
    N111Ids{missing(),missing()},51413504)
