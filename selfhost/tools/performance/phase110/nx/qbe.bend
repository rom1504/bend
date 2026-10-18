# QBE aggregate ABI is a machine lowering, never the semantic pair model.
# :nx110_pair is two aligned integer eightbytes. On amd64 SysV QBE returns it
# in RAX/RDX; QBE represents the result internally as a private return-pad
# pointer. That pointer does not enter Nx110 and cannot escape into Terms.
@unsafe
def nx110_qbe_pair(+first: String, +second: String, +name: String, +args: NxqArgs) -> NxqCode:
  match args:
    case NxqArgs{code,words,n}:
      +pair = nxq_tmp(n)
      +a = nxq_tmp(U32.add(n,1))
      +at = nxq_tmp(U32.add(n,2))
      +b = nxq_tmp(U32.add(n,3))
      NxqCode{code ++ pair ++ " =:nx110_pair call $nx_" ++ name ++ "(" ++ words ++ ")\n" ++
        a ++ " =l loadl " ++ pair ++ "\n" ++ at ++ " =l add " ++ pair ++ ", 8\n" ++
        b ++ " =l loadl " ++ at ++ "\nstorel " ++ a ++ ", %slot_" ++ first ++
        "\nstorel " ++ b ++ ", %slot_" ++ second ++ "\n",U32.add(n,4),False{}}

@unsafe
def nx110_qbe_stmt(+stmt: Nx110Stmt, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>, +n: U32) -> NxqCode:
  match stmt:
    case Nx110Scalar{base}: nxq_stmt(base,env,fs,n)
    case Nx110If{condition,yes,no}: nx110_qbe_if(yes,no,env,fs,nxq_expr(condition,env,fs,n))
    case Nx110While{condition,body}: nx110_qbe_loop(n,body,env,fs,nxq_expr(condition,env,fs,U32.add(n,3)))
    case Nx110CallPair{first,second,name,args}: nx110_qbe_pair(first,second,name,nxq_args(args,env,fs,n))

@unsafe
def nx110_qbe_stmts(+body: List<&2,Nx110Stmt>, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>, +n: U32) -> NxqCode:
  match body:
    case Nil{}: NxqCode{"",n,False{}}
    case Con{head,rest}: nx110_qbe_next(rest,env,fs,nx110_qbe_stmt(head,env,fs,n))

@unsafe
def nx110_qbe_next(+rest: List<&2,Nx110Stmt>, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>, +head: NxqCode) -> NxqCode:
  match head:
    case NxqCode{code,n,terminal}:
      nx_choose(NxqCode,terminal,u => head,u => nxq_prefix_code(code,nx110_qbe_stmts(rest,env,fs,n)))

@unsafe
def nx110_qbe_if(+yes: List<&2,Nx110Stmt>, +no: List<&2,Nx110Stmt>, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>, +condition: NxqValue) -> NxqCode:
  match condition:
    case NxqValue{code,word,typ,n}:
      nx110_qbe_if_yes(code ++ "jnz " ++ word ++ ", " ++ nxq_label(n) ++ ", " ++ nxq_label(U32.add(n,1)) ++ "\n",n,no,env,fs,nx110_qbe_stmts(yes,env,fs,U32.add(n,3)))

@unsafe
def nx110_qbe_if_yes(+prefix: String, +label: U32, +no: List<&2,Nx110Stmt>, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>, +yes: NxqCode) -> NxqCode:
  match yes:
    case NxqCode{code,n,terminal}:
      nxq_if_done(prefix ++ nxq_label(label) ++ "\n" ++ code ++ nxq_jump_if(terminal,U32.add(label,2)),label,terminal,nx110_qbe_stmts(no,env,fs,n))

@unsafe
def nx110_qbe_loop(+label: U32, +body: List<&2,Nx110Stmt>, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>, +condition: NxqValue) -> NxqCode:
  match condition:
    case NxqValue{code,word,typ,n}:
      nxq_loop_done("jmp " ++ nxq_label(label) ++ "\n" ++ nxq_label(label) ++ "\n" ++ code ++ "jnz " ++ word ++ ", " ++ nxq_label(U32.add(label,1)) ++ ", " ++ nxq_label(U32.add(label,2)) ++ "\n" ++ nxq_label(U32.add(label,1)) ++ "\n",label,nx110_qbe_stmts(body,env,fs,n))

@unsafe
def nx110_qbe_function(+function: Nx110Function, +fs: List<&2,NxFunction>) -> String:
  match function:
    case Nx110Function{name,params,result,locals,body}:
      +env = nx_params_join(params,locals)
      "function " ++ nxq_type(result) ++ " $nx_" ++ name ++ "(" ++ nxq_params(params) ++ ") {\n@entry\n" ++
      nxq_slots(env) ++ nxq_init(params,True{}) ++ nxq_init(locals,False{}) ++ nxq_code(nx110_qbe_stmts(body,env,fs,0)) ++ "}\n"

@unsafe
def nx110_qbe_functions(+items: List<&2,Nx110Function>, +fs: List<&2,NxFunction>, +exports: List<&2,String>) -> String:
  match items:
    case Nil{}: ""
    case Con{head,rest}:
      match head:
        case Nx110Function{name,params,result,locals,body}:
          nx_choose(String,nxlib_has_name(name,exports),u => "export ",u => "") ++
          nx110_qbe_function(head,fs) ++ nx110_qbe_functions(rest,fs,exports)

@unsafe
def nx110_qbe_verified(+library: Nx110Library) -> String:
  match library:
    case Nx110Library{imports,pairs,functions,exports}:
      "type :nx110_pair = { l, l }\n" ++ nx110_qbe_functions(functions,nxlib_signatures(imports,nx110_signatures(functions)),exports)

@unsafe
def nx110_qbe(+library: Nx110Library) -> String:
  nx_choose(String,nx110_verify(library),u => nx110_qbe_verified(library),u => "INVALID_NX110_LIBRARY\n")
