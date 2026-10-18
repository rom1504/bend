# Checked first-order scalar KTerm -> backend-neutral Nx IR. No C inspection.
# Caller supplies a checked, annotated, reachable book from the pinned compiler.
# Refusal is explicit; this is not a second checker or an untrusted graph API.
type NxkBinding is Data:
  NxkBinding{+id: U32, +word: NxExpr}

type NxkCode is Data:
  NxkCode{+locals: List<&2,NxParam>, +body: List<&2,NxStmt>, +value: NxExpr, +next: U32, +error: String}

type NxkArgs is Data:
  NxkArgs{+locals: List<&2,NxParam>, +body: List<&2,NxStmt>, +values: List<&2,NxExpr>, +next: U32, +error: String}

type NxkResult is Data:
  NxkResult{+program: NxProgram, +error: String}

@unsafe
def nxk_join(-A: Data, +xs: List<&2,A>, +ys: List<&2,A>) -> List<&2,A>:
  match xs:
    case Nil{}: ys
    case Con{h,t}: Con{h,nxk_join(A,t,ys)}

@unsafe
def nxk_find(+book: List<&2,KDef>, +name: String) -> KDef:
  match book:
    case Nil{}: KDef{"", "Absent", 0, 0, atom("Absent"), atom("Absent"), [], False{}, False{}}
    case Con{h,t}: nx_choose(KDef, String.eq(dn(h),name), u => h, u => nxk_find(t,name))

@unsafe
def nxk_unann(+t: KTerm) -> KTerm:
  nx_choose(KTerm,String.eq(tg(t),"Ann"),u => nxk_unann(kid(t,0)),u => t)

@unsafe
def nxk_type(+t: KTerm, +book: List<&2,KDef>) -> Bool:
  (String.eq(tg(t),"Ref") || String.eq(tg(t),"ADT")) &&
    (String.eq(nm(t),"U32") || String.eq(nm(t),"Bool")) && db(nxk_find(book,nm(t))) && String.eq(dk(nxk_find(book,nm(t))),"ADT") && U32.is_eq(nxk_count(ks(t)),0)

@unsafe
def nxk_name(+name: String) -> String:
  "f" ++ nxk_name_chars(name)

@unsafe
def nxk_name_chars(+name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{c,rest}: "_" ++ U32.show(Char.to_u32(c)) ++ nxk_name_chars(rest)

@unsafe
def nxk_lookup(+env: List<&2,NxkBinding>, +id: U32) -> NxExpr:
  match env:
    case Nil{}: NxVar{"unbound"}
    case Con{NxkBinding{key,word},rest}: nx_choose(NxExpr,U32.is_eq(key,id),u => word,u => nxk_lookup(rest,id))

def nxk_fail(+reason: String, n: U32) -> NxkCode:
  NxkCode{[],[],NxConst{NxU32{},0},n,reason}

def nxk_atom(word: NxExpr, n: U32) -> NxkCode:
  NxkCode{[],[],word,n,""}

@unsafe
def nxk_bind(value: NxExpr, +n: U32) -> NxkCode:
  +name = "v" ++ U32.show(n)
  NxkCode{[NxParam{name,NxU32{}}],[NxSet{name,value}],NxVar{name},U32.inc(n),""}

@unsafe
def nxk_then(+a: NxkCode, +b: NxkCode) -> NxkCode:
  match a b:
    case NxkCode{al,ab,av,an,ae} NxkCode{bl,bb,bv,bn,be}:
      NxkCode{nxk_join(NxParam,al,bl),nxk_join(NxStmt,ab,bb),bv,bn,nx_choose(String,String.eq(ae,""),u => be,u => ae)}

@unsafe
def nxk_expr(+t: KTerm, +env: List<&2,NxkBinding>, +book: List<&2,KDef>, +n: U32) -> NxkCode:
  nx_choose(NxkCode,String.eq(tg(t),"Ann"),u =>
    nx_choose(NxkCode,nxk_type(kid(t,1),book),u => nxk_expr(kid(t,0),env,book,n),u => nxk_fail("non-scalar expression annotation",n)),u =>
  nx_choose(NxkCode,String.eq(tg(t),"Lit") && String.eq(nm(t),"U32"),u => nxk_atom(NxConst{NxU32{},kl_number(t)},n),u =>
  nx_choose(NxkCode,String.eq(tg(t),"Var"),u => nxk_atom(nxk_lookup(env,ix(t)),n),u =>
  nx_choose(NxkCode,String.eq(tg(t),"Ctr") && (String.eq(nm(t),"True") || String.eq(nm(t),"False")),u => nxk_atom(NxConst{NxU32{},nx_bool32(String.eq(nm(t),"True"))},n),u =>
  nx_choose(NxkCode,String.eq(tg(t),"Let") && String.eq(tg(kid(t,0)),"Bind") && U32.is_eq(nxk_count(ks(t)),2),u => nx_choose(NxkCode,U32.is_eq(qt(kid(t,0)),0),v => nxk_expr(kid(t,1),env,book,n),v => nxk_let(t,env,book,nxk_expr(kid(kid(t,0),0),env,book,n))),u =>
  nx_choose(NxkCode,String.eq(tg(t),"App"),u => nxk_application(t,[],env,book,n),u =>
  nx_choose(NxkCode,String.eq(tg(t),"Ref"),u => nxk_call(nm(t),NxkArgs{[],[],[],n,""},book),u =>
    nxk_fail("unsupported core node: " ++ tg(t),n))))))))

@unsafe
def nxk_let(+t: KTerm, +env: List<&2,NxkBinding>, +book: List<&2,KDef>, +value: NxkCode) -> NxkCode:
  match value:
    case NxkCode{locals,body,word,n,error}:
      nx_choose(NxkCode,String.eq(error,""),u => nxk_then(value,nxk_expr(kid(t,1),Con{NxkBinding{ix(kid(t,0)),word},env},book,n)),u => value)

# Every annotated application identifies the quantity of exactly its argument.
@unsafe
def nxk_application(+t: KTerm, +args: List<&2,KTerm>, +env: List<&2,NxkBinding>, +book: List<&2,KDef>, +n: U32) -> NxkCode:
  +head = nxk_unann(t)
  nx_choose(NxkCode,String.eq(tg(head),"App"),u =>
    nx_choose(NxkCode,String.eq(tg(kid(head,0)),"Ann") && String.eq(tg(kid(kid(head,0),1)),"All"),u =>
      nxk_application(kid(head,0),nx_choose(List<&2,KTerm>,U32.is_eq(qt(kid(kid(head,0),1)),0),v => args,v => Con{kid(head,1),args}),env,book,n),u => nxk_fail("application lacks checked telescope",n)),u =>
    nx_choose(NxkCode,String.eq(tg(head),"Ref"),u => nxk_call(nm(head),nxk_args(args,env,book,n),book),u => nxk_fail("indirect application is not in scalar surface",n)))

@unsafe
def nxk_args(+args: List<&2,KTerm>, +env: List<&2,NxkBinding>, +book: List<&2,KDef>, +n: U32) -> NxkArgs:
  match args:
    case Nil{}: NxkArgs{[],[],[],n,""}
    case Con{head,rest}: nxk_args_head(rest,env,book,nxk_expr(head,env,book,n))

@unsafe
def nxk_args_head(+rest: List<&2,KTerm>, +env: List<&2,NxkBinding>, +book: List<&2,KDef>, +head: NxkCode) -> NxkArgs:
  match head:
    case NxkCode{locals,body,value,n,error}:
      nx_choose(NxkArgs,String.eq(error,""),u => nxk_args_tail(head,nxk_args(rest,env,book,n)),u => NxkArgs{locals,body,[],n,error})

@unsafe
def nxk_args_tail(+head: NxkCode, +tail: NxkArgs) -> NxkArgs:
  match head tail:
    case NxkCode{hl,hb,hv,hn,he} NxkArgs{tl,tb,tv,tn,te}:
      NxkArgs{nxk_join(NxParam,hl,tl),nxk_join(NxStmt,hb,tb),Con{hv,tv},tn,te}

@unsafe
def nxk_call(+name: String, +args: NxkArgs, +book: List<&2,KDef>) -> NxkCode:
  match args:
    case NxkArgs{locals,body,values,n,error}:
      nx_choose(NxkCode,String.eq(error,""),u =>
        nxk_then(NxkCode{locals,body,NxConst{NxU32{},0},n,""},
          nx_choose(NxkCode,db(nxk_find(book,name)),v => nx_choose(NxkCode,String.eq(tg(nxk_unann(dv(nxk_find(book,name)))),"Foreign"),w => nxk_fail("foreign intrinsic replacement refused: " ++ name,n),w => nxk_primitive(name,values,n)),v =>
            nx_choose(NxkCode,String.eq(dk(nxk_find(book,name)),"Def"),w => nxk_bind(NxCall{nxk_name(name),values},n),w => nxk_fail("unknown direct function: " ++ name,n)))),u => nxk_fail(error,n))

@unsafe
def nxk_binary(+op: String, +args: List<&2,NxExpr>, n: U32) -> NxkCode:
  match args:
    case Con{a,Con{b,Nil{}}}: nxk_bind(NxBin{op,a,b},n)
    case _: nxk_fail("primitive binary arity",n)

@unsafe
def nxk_primitive(+name: String, +args: List<&2,NxExpr>, +n: U32) -> NxkCode:
  nx_choose(NxkCode,String.eq(name,"U32.add"),u => nxk_binary("add",args,n),u =>
  nx_choose(NxkCode,String.eq(name,"U32.sub"),u => nxk_binary("sub",args,n),u =>
  nx_choose(NxkCode,String.eq(name,"U32.mul"),u => nxk_binary("mul",args,n),u =>
  nx_choose(NxkCode,String.eq(name,"U32.and") || String.eq(name,"Bool.and"),u => nxk_binary("and",args,n),u =>
  nx_choose(NxkCode,String.eq(name,"U32.or") || String.eq(name,"Bool.or"),u => nxk_binary("or",args,n),u =>
  nx_choose(NxkCode,String.eq(name,"U32.xor"),u => nxk_binary("xor",args,n),u =>
  nx_choose(NxkCode,String.eq(name,"U32.is_eq"),u => nxk_binary("eq",args,n),u =>
  nx_choose(NxkCode,String.eq(name,"U32.is_lt"),u => nxk_binary("ult",args,n),u =>
  nx_choose(NxkCode,String.eq(name,"U32.is_gt"),u => nxk_reverse("ult",args,n),u =>
  nx_choose(NxkCode,String.eq(name,"U32.is_ne"),u => nxk_negated(nxk_binary("eq",args,n)),u =>
  nx_choose(NxkCode,String.eq(name,"U32.is_le"),u => nxk_negated(nxk_reverse("ult",args,n)),u =>
  nx_choose(NxkCode,String.eq(name,"U32.is_ge"),u => nxk_negated(nxk_binary("ult",args,n)),u =>
    nxk_unary(name,args,n)))))))))))))

@unsafe
def nxk_reverse(+op: String, +args: List<&2,NxExpr>, n: U32) -> NxkCode:
  match args:
    case Con{a,Con{b,Nil{}}}: nxk_binary(op,[b,a],n)
    case _: nxk_fail("primitive reversed arity",n)

@unsafe
def nxk_negated(+code: NxkCode) -> NxkCode:
  match code:
    case NxkCode{locals,body,value,n,error}:
      nxk_then(code,nxk_bind(NxBin{"xor",value,NxConst{NxU32{},1}},n))

@unsafe
def nxk_unary(+name: String, +args: List<&2,NxExpr>, +n: U32) -> NxkCode:
  match args:
    case Con{a,Nil{}}:
      nx_choose(NxkCode,String.eq(name,"U32.inc"),u => nxk_binary("add",[a,NxConst{NxU32{},1}],n),u =>
      nx_choose(NxkCode,String.eq(name,"U32.dec"),u => nxk_binary("sub",[a,NxConst{NxU32{},1}],n),u =>
      nx_choose(NxkCode,String.eq(name,"U32.shl"),u => nxk_binary("shl",[a,NxConst{NxU32{},1}],n),u =>
      nx_choose(NxkCode,String.eq(name,"U32.shr"),u => nxk_binary("lshr",[a,NxConst{NxU32{},1}],n),u =>
      nx_choose(NxkCode,String.eq(name,"U32.is_zero"),u => nxk_binary("eq",[a,NxConst{NxU32{},0}],n),u =>
      nx_choose(NxkCode,String.eq(name,"Bool.not"),u => nxk_binary("xor",[a,NxConst{NxU32{},1}],n),u => nxk_fail("unsupported native primitive: " ++ name,n)))))))
    case _: nxk_fail("unsupported native primitive: " ++ name,n)

# Parameters use a stable positional namespace. Binder IDs only index the env.
@unsafe
def nxk_params(+ty: KTerm, +i: U32) -> List<&2,NxParam>:
  nx_choose(List<&2,NxParam>,String.eq(tg(ty),"All"),u =>
    nx_choose(List<&2,NxParam>,U32.is_eq(qt(ty),0),v => nxk_params(kid(ty,1),i),v => Con{NxParam{"p" ++ U32.show(i),NxU32{}},nxk_params(kid(ty,1),U32.inc(i))}),u => [])

@unsafe
def nxk_signature(+ty: KTerm, +book: List<&2,KDef>) -> Bool:
  nx_choose(Bool,String.eq(tg(ty),"All"),u =>
    (U32.is_eq(qt(ty),0) || nxk_type(kid(ty,0),book)) && nxk_signature(kid(ty,1),book),u => nxk_type(ty,book))

@unsafe
def nxk_function_body(+value: KTerm, +ty: KTerm, +i: U32, +env: List<&2,NxkBinding>, +book: List<&2,KDef>, +n: U32) -> NxkCode:
  +v = nxk_unann(value)
  nx_choose(NxkCode,String.eq(tg(ty),"All"),u =>
    nx_choose(NxkCode,String.eq(tg(v),"Lam"),w =>
      nx_choose(NxkCode,U32.is_eq(qt(ty),0),z => nxk_function_body(kid(v,0),kid(ty,1),i,env,book,n),z =>
        nxk_function_body(kid(v,0),kid(ty,1),U32.inc(i),Con{NxkBinding{ix(v),NxVar{"p" ++ U32.show(i)}},env},book,n)),w =>
      nx_choose(NxkCode,String.eq(tg(v),"Mat") && Bool.not(U32.is_eq(qt(ty),0)) && String.eq(nm(kid(ty,0)),"Bool"),z => nxk_match(v,ty,i,env,book,n),z => nxk_fail("unsupported function binder: " ++ tg(v),n))),u => nxk_expr(value,env,book,n))

# A default arm is a lambda that still consumes the matched Bool parameter.
# Constructor arms have already consumed it and start at the remaining telescope.
@unsafe
def nxk_match_code(+mat: KTerm, +name: String, +ty: KTerm, +i: U32, +env: List<&2,NxkBinding>, +book: List<&2,KDef>, +n: U32) -> NxkCode:
  +m = nxk_unann(mat)
  nx_choose(NxkCode,String.eq(tg(m),"Mat"),u =>
    nx_choose(NxkCode,String.eq(nm(m),name),v =>
      nxk_function_body(kid(m,0),kid(ty,1),U32.inc(i),env,book,n),v =>
      nxk_match_code(kid(m,1),name,ty,i,env,book,n)),u =>
    nx_choose(NxkCode,String.eq(tg(m),"Lam"),v =>
      nxk_function_body(m,ty,i,env,book,n),v => nxk_fail("missing Bool match arm",n)))

@unsafe
def nxk_match(+mat: KTerm, +ty: KTerm, +i: U32, +env: List<&2,NxkBinding>, +book: List<&2,KDef>, +n: U32) -> NxkCode:
  nxk_match_yes(mat,ty,i,env,book,nxk_match_code(mat,"True",ty,i,env,book,n))

@unsafe
def nxk_match_yes(+mat: KTerm, +ty: KTerm, +i: U32, +env: List<&2,NxkBinding>, +book: List<&2,KDef>, +yes: NxkCode) -> NxkCode:
  match yes:
    case NxkCode{locals,body,value,n,error}:
      nxk_branch(NxVar{"p" ++ U32.show(i)},yes,nxk_match_code(mat,"False",ty,i,env,book,n))

@unsafe
def nxk_branch(+condition: NxExpr, +yes: NxkCode, +no: NxkCode) -> NxkCode:
  match yes no:
    case NxkCode{yl,yb,yv,yn,ye} NxkCode{nl,nb,nv,nn,ne}:
      +dest = "v" ++ U32.show(nn)
      NxkCode{Con{NxParam{dest,NxU32{}},nxk_join(NxParam,yl,nl)},
        [NxIf{condition,nxk_join(NxStmt,yb,[NxSet{dest,yv}]),nxk_join(NxStmt,nb,[NxSet{dest,nv}])}],NxVar{dest},U32.inc(nn),nx_choose(String,String.eq(ye,""),u => ne,u => ye)}

@unsafe
def nxk_functions(+defs: List<&2,KDef>, +book: List<&2,KDef>, +entry: String) -> NxkResult:
  match defs:
    case Nil{}: NxkResult{NxProgram{nxk_name(entry),[]},""}
    case Con{d,rest}:
      nx_choose(NxkResult,db(d),u => nxk_functions(rest,book,entry),u =>
        nx_choose(NxkResult,String.eq(dk(d),"Def") && nxk_signature(dt(d),book),v =>
          nxk_function_done(d,nxk_function_body(dv(d),dt(d),0,[],book,0),nxk_functions(rest,book,entry)),v =>
          NxkResult{NxProgram{nxk_name(entry),[]},"unsupported declaration/signature: " ++ dn(d)}))

@unsafe
def nxk_function_done(+d: KDef, +code: NxkCode, +tail: NxkResult) -> NxkResult:
  match code tail:
    case NxkCode{locals,body,value,n,error} NxkResult{NxProgram{entry,fs},te}:
      NxkResult{NxProgram{entry,Con{NxFunction{nxk_name(dn(d)),nxk_params(dt(d),0),NxU32{},locals,nxk_join(NxStmt,body,[NxReturn{value}])},fs}},nx_choose(String,String.eq(error,""),u => te,u => dn(d) ++ ": " ++ error)}

@unsafe
def nxk_entry_abi(+ty: KTerm) -> Bool:
  nx_choose(Bool,String.eq(tg(ty),"All"),u =>
    (U32.is_eq(qt(ty),0) || Bool.not(String.eq(nm(kid(ty,0)),"Bool"))) && nxk_entry_abi(kid(ty,1)),u => True{})

# The external integer runner does not encode a Bool input domain. Internal
# Boolean arguments remain canonical 0/1; refuse exporting a live Bool input.
@unsafe
def nxk_lower(+defs: List<&2,KDef>, +entry: String) -> NxkResult:
  nx_choose(NxkResult,nxk_entry_abi(dt(nxk_find(defs,entry))),u => nxk_finish(nxk_functions(defs,defs,entry)),u =>
    NxkResult{NxProgram{nxk_name(entry),[]},"external Bool parameter requires an explicit Bool ABI"})

@unsafe
def nxk_finish(+result: NxkResult) -> NxkResult:
  match result:
    case NxkResult{program,error}:
      nx_choose(NxkResult,String.eq(error,""),u => nx_choose(NxkResult,nx_verify(program),v => result,v => NxkResult{program,"lowered IR verifier refused"}),u => result)

@unsafe
def nxk_count(+xs: List<&2,KTerm>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{h,t}: U32.inc(nxk_count(t))
