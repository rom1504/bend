# Affine-wrapper successor: raw arrays are borrowed explicitly; enclosing
# Tape/Unit/VS/VF wrappers are consumed once and never shared.
# Private compact direct-admission consumer. Only well-formed P148Good units
# produced by pack/optimizer enter here. No decoded statements or argument lists.
# schema slots: width (zero=undeclared), allocation kind, declared capacity.
# live slots: assigned (separate from zero capacity), dynamic capacity.
type P148VS is Type:
  P148VS{data: Array<U32>, +count: U32, +error: String}

type P148VF is Type:
  P148VF{data: Array<U32>, +terminal: Bool, +error: String}

@unsafe
def p148v_w(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, at: U32) -> U32:
  p148w_get(words,at)

@unsafe
def p148v_n(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +id: U32) -> String:
  p148n_get(names,id)

@unsafe
def p148v_v(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, +field: U32) -> U32:
  nt_choose(U32,U32.is_ge(valueUsed,3) && U32.is_le(ref,U32.sub(valueUsed,3)),u => p148w_get(values,U32.add(ref,field)),u => 0)

@unsafe
def p148v_size(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32) -> U32:
  nameUsed

@unsafe
def p148v_end(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32) -> U32:
  used

@unsafe
def p148v_name_id(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, word: String) -> U32:
  p148c_find_name(names,nameUsed,word)

@unsafe
def p148v_s(+schema: Array<U32>, +id: U32, field: U32) -> U32:
  p148w_get(schema,U32.add(U32.mul(id,3),field))

@unsafe
def p148v_l(+live: Array<U32>, +id: U32, field: U32) -> U32:
  p148w_get(live,U32.add(U32.mul(id,2),field))

@unsafe
def p148v_live(live: Array<U32>, +id: U32, capacity: U32) -> Array<U32>:
  p148w_set(p148w_set(live,U32.mul(id,2),1),U32.inc(U32.mul(id,2)),capacity)

@unsafe
def p148v_decl(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +id: U32, +width: U32, +capacity: U32, +alloca: Bool, scan: P148VS) -> P148VS:
  match scan:
    case P148VS{+data,+count,+error}: p148v_decl_flat(words,values,names,used,valueUsed,nameUsed,id,width,capacity,alloca,data,count,error)

@unsafe
def p148v_decl_flat(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +id: U32, +width: U32, +capacity: U32, +alloca: Bool, +data: Array<U32>, +count: U32, +error: String) -> P148VS:
  +old = p148v_s(data,id,0)
  +name = p148v_n(words,values,names,used,valueUsed,nameUsed,id)
  nt_choose(P148VS,Bool.not(String.is_empty(error)),u => P148VS{data,count,error},u =>
  nt_choose(P148VS,Bool.not(p111v_name_chars(name,0)) || String.eq(name,"state"),u => P148VS{data,count,"invalid/reserved local name: " ++ name},u =>
  nt_choose(P148VS,U32.is_gt(old,0) && (alloca || U32.is_eq(p148v_s(data,id,1),1) || Bool.not(U32.is_eq(old,width))),
    u => P148VS{data,count,"local width/allocation changes: " ++ name},u =>
    P148VS{p148w_set(p148w_set(p148w_set(data,U32.mul(id,3),width),U32.inc(U32.mul(id,3)),Bool.to_u32(alloca)),U32.add(U32.mul(id,3),2),capacity),
      nt_choose(U32,U32.is_eq(old,0),v => U32.inc(count),v => count),""})))

@unsafe
def p148v_seed_params(params: List<&2,NC_Binding>, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, scan: P148VS) -> P148VS:
  match scan:
    case P148VS{+data,+count,+error}: p148v_seed_params_flat(params,words,values,names,used,valueUsed,nameUsed,data,count,error)

@unsafe
def p148v_seed_params_flat(params: List<&2,NC_Binding>, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +data: Array<U32>, +count: U32, +error: String) -> P148VS:
  match params:
    case Nil{}: P148VS{data,count,error}
    case Con{NC_Binding{id,+word,kind},rest}:
      +key = p148v_name_id(words,values,names,used,valueUsed,nameUsed,word)
      nt_choose(P148VS,U32.is_ge(key,p148v_size(words,values,names,used,valueUsed,nameUsed)),u => P148VS{data,count,"compact parameter missing from private dictionary"},u =>
      nt_choose(P148VS,U32.is_gt(p148v_s(data,key,0),0),u => P148VS{data,count,"duplicate/reserved direct parameter: " ++ word},u =>
        p148v_seed_params(rest,words,values,names,used,valueUsed,nameUsed,p148v_decl_flat(words,values,names,used,valueUsed,nameUsed,key,2,0,False{},data,count,error))))

@unsafe
def p148v_seed(params: List<&2,NC_Binding>, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32) -> P148VS:
  p148v_seed_params(params,words,values,names,used,valueUsed,nameUsed,P148VS{
    p148w_set(p148w_set(p148w_set(p148w_set(p148w_set(p148w_set(p148w_new(U32.mul(p148v_size(words,values,names,used,valueUsed,nameUsed),3)),0,3),1,2),2,2088),3,3),4,1),5,2048),2,""})

@unsafe
def p148v_schema_names(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +left: U32, scan: P148VS) -> P148VS:
  match scan:
    case P148VS{+data,+count,+error}: p148v_schema_names_flat(words,values,names,used,valueUsed,nameUsed,at,left,data,count,error)

@unsafe
def p148v_schema_names_flat(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +left: U32, +data: Array<U32>, +count: U32, +error: String) -> P148VS:
  nt_choose(P148VS,U32.is_eq(left,0),u => P148VS{data,count,error},u =>
    p148v_schema_names(words,values,names,used,valueUsed,nameUsed,U32.inc(at),U32.sub(left,1),p148v_decl_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,at),2,0,False{},data,count,error)))

@unsafe
def p148v_schema_tag(+tag: U32, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, scan: P148VS) -> P148VS:
  match scan:
    case P148VS{+data,+count,+error}: p148v_schema_tag_flat(tag,words,values,names,used,valueUsed,nameUsed,at,data,count,error)

@unsafe
def p148v_schema_tag_flat(+tag: U32, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +data: Array<U32>, +count: U32, +error: String) -> P148VS:
  match tag:
    case 1: p148v_decl_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),0,False{},data,count,error)
    case 2: p148v_decl_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),nt_choose(U32,p111v_comparison(p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)))),u => 1,u => U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256)),0,False{},data,count,error)
    case 3: p148v_decl_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),0,False{},data,count,error)
    case 4: p148v_schema(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),True{},p148v_schema_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),True{},data,count,error))
    case 6: p148v_decl_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),0,False{},data,count,error)
    case 8: p148v_decl_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),3,0,False{},data,count,error)
    case 9: p148v_decl_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),3,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),True{},data,count,error)
    case 10: p148v_schema(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),False{},p148v_schema_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),False{},data,count,error))
    case 11: p148v_schema_names_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,6)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),data,count,error)
    case _: P148VS{data,count,error}

@unsafe
def p148v_schema_step(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, +raw: Bool, +tag: U32, scan: P148VS) -> P148VS:
  match scan:
    case P148VS{+data,+count,+error}: p148v_schema_step_flat(words,values,names,used,valueUsed,nameUsed,at,end,raw,tag,data,count,error)

@unsafe
def p148v_schema_step_flat(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, +raw: Bool, +tag: U32, +data: Array<U32>, +count: U32, +error: String) -> P148VS:
  match tag:
    case 15: p148v_schema_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),end,raw,data,count,error)
    case 14: p148v_schema(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),end,raw,p148v_schema_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),raw,data,count,error))
    case _:
      nt_choose(P148VS,raw && (Bool.not(String.is_empty(error)) || U32.is_gt(count,65535)),
        u => P148VS{data,count,nt_choose(String,String.is_empty(error),v => "too many segment locals",v => error)},
        u => p148v_schema(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),end,raw,p148v_schema_tag_flat(tag,words,values,names,used,valueUsed,nameUsed,at,data,count,error)))

@unsafe
def p148v_schema(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, +raw: Bool, scan: P148VS) -> P148VS:
  match scan:
    case P148VS{+data,+count,+error}: p148v_schema_flat(words,values,names,used,valueUsed,nameUsed,at,end,raw,data,count,error)

@unsafe
def p148v_schema_flat(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, +raw: Bool, +data: Array<U32>, +count: U32, +error: String) -> P148VS:
  nt_choose(P148VS,U32.is_ge(at,end),u => P148VS{data,count,error},u => p148v_schema_step_flat(words,values,names,used,valueUsed,nameUsed,at,end,raw,U32.mod(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),data,count,error))

@unsafe
def p148v_literal(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32) -> U32:
  nt_choose(U32,U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,0),2) && U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,2),0),u => p148v_v(words,values,names,used,valueUsed,nameUsed,ref,1),u => 4294967295)

@unsafe
def p148v_value_kind(kind: U32, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, +width: U32, +schema: Array<U32>, +live: Array<U32>, ids: N111Ids) -> Bool:
  match kind ids:
    case 1 _: U32.is_eq(p148v_s(schema,p148v_v(words,values,names,used,valueUsed,nameUsed,ref,1),0),width) && U32.is_eq(p148v_l(live,p148v_v(words,values,names,used,valueUsed,nameUsed,ref,1),0),1)
    case 2 _: nt_choose(Bool,U32.is_eq(width,1),u => U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,2),0),u => nt_choose(Bool,U32.is_eq(width,3),v => U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,1),0) && U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,2),0),v => U32.is_eq(width,2)))
    case 4 N111Ids{functions,constructors}: U32.is_le(width,2) && Bool.not(String.eq(dk(p111v_get(functions,p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_v(words,values,names,used,valueUsed,nameUsed,ref,1)))),"Absent"))
    case 5 N111Ids{functions,constructors}: U32.is_le(width,2) && Bool.not(String.eq(dk(p111v_get(constructors,p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_v(words,values,names,used,valueUsed,nameUsed,ref,1)))),"Absent"))
    case _ _: False{}

@unsafe
def p148v_value(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, width: U32, schema: Array<U32>, live: Array<U32>, ids: N111Ids) -> Bool:
  p148v_value_kind(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,0),words,values,names,used,valueUsed,nameUsed,ref,width,schema,live,ids)

@unsafe
def p148v_capacity(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, +live: Array<U32>) -> U32:
  nt_choose(U32,U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,0),1),u => p148v_l(live,p148v_v(words,values,names,used,valueUsed,nameUsed,ref,1),1),u => 0)

@unsafe
def p148v_memory(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, +offset: U32, width: U32, +schema: Array<U32>, +live: Array<U32>, ids: N111Ids) -> Bool:
  +bytes = nt_choose(U32,U32.is_eq(width,1),u => 4,u => 8)
  +capacity = p148v_capacity(words,values,names,used,valueUsed,nameUsed,ref,live)
  p148v_value(words,values,names,used,valueUsed,nameUsed,ref,3,schema,live,ids) && U32.is_ge(capacity,bytes) && U32.is_le(offset,U32.sub(capacity,bytes)) && U32.is_eq(U32.mod(offset,bytes),0)

@unsafe
def p148v_assign(+id: U32, schema: Array<U32>, live: Array<U32>) -> Array<U32>:
  p148v_live(live,id,p148v_s(schema,id,2))

@unsafe
def p148v_step(ok: Bool, +id: U32, assign: Bool, schema: Array<U32>, +live: Array<U32>, message: String) -> P148VF:
  match ok assign:
    case False{} _: P148VF{live,False{},message}
    case True{} False{}: P148VF{live,False{},""}
    case True{} True{}: P148VF{p148v_assign(id,schema,live),False{},""}

@unsafe
def p148v_arg(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +position: U32) -> U32:
  nt_choose(U32,U32.is_lt(position,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5))),u => p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(U32.add(p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,6)),U32.mul(position,2)))),u => 4294967295)

@unsafe
def p148v_arg_type(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +position: U32) -> U32:
  nt_choose(U32,U32.is_lt(position,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5))),u => p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,6)),U32.mul(position,2))),u => 0)

@unsafe
def p148v_args(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +position: U32, sig: List<&2,U32>, +schema: Array<U32>, +live: Array<U32>, +ids: N111Ids) -> Bool:
  match sig:
    case Nil{}: U32.is_eq(position,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)))
    case Con{+width,rest}: U32.is_eq(p148v_arg_type(words,values,names,used,valueUsed,nameUsed,at,position),width) && p148v_value(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,position),width,schema,live,ids) && p148v_args(words,values,names,used,valueUsed,nameUsed,at,U32.inc(position),rest,schema,live,ids)

@unsafe
def p148v_local_ref(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, +state: Bool) -> Bool:
  U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,0),1) && U32.is_eq(Bool.to_u32(U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,1),0)),Bool.to_u32(state))

@unsafe
def p148v_buffers(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +position: U32) -> Bool:
  nt_choose(Bool,U32.is_ge(position,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5))),u => True{},u =>
    (Bool.not(U32.is_eq(p148v_arg_type(words,values,names,used,valueUsed,nameUsed,at,position),3)) || p148v_local_ref(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,position),False{})) && p148v_buffers(words,values,names,used,valueUsed,nameUsed,at,U32.inc(position)))

@unsafe
def p148v_runtime_args(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32) -> Bool:
  U32.is_eq(p148v_arg_type(words,values,names,used,valueUsed,nameUsed,at,0),3) && p148v_local_ref(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,0),True{}) && p148v_buffers(words,values,names,used,valueUsed,nameUsed,at,1)

@unsafe
def p148v_target(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, constructor: Bool, ids: N111Ids) -> KDef:
  match constructor ids:
    case True{} N111Ids{functions,constructors}: nt_choose(KDef,U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,0),5),u => p111v_get(constructors,p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_v(words,values,names,used,valueUsed,nameUsed,ref,1))),u => missing())
    case False{} N111Ids{functions,constructors}: nt_choose(KDef,U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,0),4),u => p111v_get(functions,p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_v(words,values,names,used,valueUsed,nameUsed,ref,1))),u => missing())

@unsafe
def p148v_buffer(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, position: U32, +count: U32, live: Array<U32>) -> Bool:
  U32.is_le(count,255) && U32.is_ge(p148v_capacity(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,position),live),U32.mul(count,8))

@unsafe
def p148v_counted(+symbol: String, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +live: Array<U32>, ids: N111Ids) -> Bool:
  +count = p148v_literal(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,3))
  +target = p148v_target(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,1),String.eq(symbol,"p111_rt_ctor"),ids)
  p148v_buffer(words,values,names,used,valueUsed,nameUsed,at,2,count,live) &&
    nt_choose(Bool,String.eq(symbol,"p111_rt_ctor"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(count,da(target)),u =>
    nt_choose(Bool,String.eq(symbol,"p111_rt_jump"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(count,da(target)),u =>
    nt_choose(Bool,String.eq(symbol,"p111_rt_closure"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(U32.inc(count),da(target)),u =>
    nt_choose(Bool,String.eq(symbol,"p111_rt_frame"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_gt(dx(target),0) && U32.is_eq(U32.add(count,dx(target)),da(target)),u => True{}))))

@unsafe
def p148v_contract(+symbol: String, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +live: Array<U32>, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  +id = p148v_literal(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,1))
  +count = p148v_literal(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,3))
  nt_choose(Bool,String.eq(symbol,"p111_rt_ctor") || String.eq(symbol,"p111_rt_take") || String.eq(symbol,"p111_rt_closure") || String.eq(symbol,"p111_rt_frame") || String.eq(symbol,"p111_rt_jump"),u => p148v_counted(symbol,words,values,names,used,valueUsed,nameUsed,at,live,ids),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_return"),u => U32.is_eq(p148v_literal(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,2)),result) && p148v_buffer(words,values,names,used,valueUsed,nameUsed,at,1,result,live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_reg_get"),u => U32.is_lt(id,nt_choose(U32,U32.is_gt(incoming,0),v => incoming,v => arity)),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_stack_get"),u => U32.is_gt(incoming,0) && U32.is_lt(id,U32.sub(arity,incoming)),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_stack_pop"),u => U32.is_gt(incoming,0) && U32.is_eq(id,U32.sub(arity,incoming)),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_op"),u => U32.is_gt(id,0) && U32.is_lt(id,86) && U32.is_eq(count,p111v_at(p111v_primitive_arities(),id)) && p148v_buffer(words,values,names,used,valueUsed,nameUsed,at,2,count,live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_special_ctor"),u => U32.is_eq(count,p111v_special_arity(id)) && p148v_buffer(words,values,names,used,valueUsed,nameUsed,at,2,count,live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_special_take"),u => U32.is_eq(p148v_literal(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,4)),p111v_special_arity(id)) && p148v_buffer(words,values,names,used,valueUsed,nameUsed,at,3,p148v_literal(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,4)),live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_special_test"),u => U32.is_gt(id,0) && U32.is_lt(id,10),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_fail"),u => U32.is_gt(id,0) && U32.is_le(id,8),u => True{}))))))))))

@unsafe
def p148v_runtime(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +schema: Array<U32>, +live: Array<U32>, +ids: N111Ids, arity: U32, result: U32) -> Bool:
  +symbol = p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)))
  +sig = p111v_signature(symbol)
  Bool.not(List.is_empty(&2,U32,sig)) && U32.is_eq(U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),2) &&
    U32.is_eq(p148v_arg_type(words,values,names,used,valueUsed,nameUsed,at,0),3) && p148v_local_ref(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,0),True{}) &&
    p148v_args(words,values,names,used,valueUsed,nameUsed,at,0,sig,schema,live,ids) && p148v_contract(symbol,words,values,names,used,valueUsed,nameUsed,at,live,ids,arity,0,result)

@unsafe
def p148v_local_word(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32) -> String:
  nt_choose(String,U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,ref,0),1),u => p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_v(words,values,names,used,valueUsed,nameUsed,ref,1)),u => "")

@unsafe
def p148v_array_shape(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32) -> Bool:
  +id = p148v_literal(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,1))
  U32.is_eq(p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),6) &&
    U32.is_eq(p148v_arg_type(words,values,names,used,valueUsed,nameUsed,at,0),3) && p148v_local_ref(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,0),True{}) &&
    U32.is_eq(p148v_arg_type(words,values,names,used,valueUsed,nameUsed,at,1),1) && U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,1),0),2) && U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,1),2),0) &&
    U32.is_eq(p148v_arg_type(words,values,names,used,valueUsed,nameUsed,at,2),3) && U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,2),0),1) &&
    U32.is_eq(p148v_arg_type(words,values,names,used,valueUsed,nameUsed,at,3),1) && U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,3),0),2) && U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,3),2),0) &&
    U32.is_eq(p148v_arg_type(words,values,names,used,valueUsed,nameUsed,at,4),3) && U32.is_eq(p148v_v(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,4),0),1) &&
    U32.is_eq(p148v_arg_type(words,values,names,used,valueUsed,nameUsed,at,5),1) && U32.is_eq(p148v_literal(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,5)),2) &&
    p113j_buffer_origin(p148v_local_word(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,2)),True{}) &&
    p113j_buffer_origin(p148v_local_word(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,4)),False{}) &&
    U32.is_gt(p113p_array_arity(id),0) && U32.is_eq(p113p_array_arity(id),p148v_literal(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,3)))

@unsafe
def p148v_safe_call(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +symbol: String) -> Bool:
  U32.is_eq(U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),2) && p148v_runtime_args(words,values,names,used,valueUsed,nameUsed,at) &&
    (String.eq(symbol,"p126_rt_nat_divmod") || String.eq(symbol,"p125_rt_concat_typed") || p118t_import(symbol) ||
     (String.eq(symbol,"p113_rt_array_pair") && p148v_array_shape(words,values,names,used,valueUsed,nameUsed,at)) || p112t_runtime_call(symbol) || String.eq(symbol,"p111_rt_fail"))

@unsafe
def p148v_safe_tag(+tag: U32, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32) -> Bool:
  match tag:
    case 1: Bool.not(U32.is_eq(U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),3))
    case 2: Bool.not(U32.is_eq(U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),3))
    case 3: p148v_safe_call(words,values,names,used,valueUsed,nameUsed,at,p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4))))
    case 4: p148v_safe_block(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5))) && p148v_safe_block(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)))
    case 6: Bool.not(U32.is_eq(U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),3)) && p148v_local_ref(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,2)),False{})
    case 7: Bool.not(U32.is_eq(U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),3)) && p148v_local_ref(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,2)),False{})
    case 9: True{}
    case _: False{}

@unsafe
def p148v_safe_next(+tag: U32, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32) -> Bool:
  match tag:
    case 15: p148v_safe_block(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),end)
    case 14: p148v_safe_block(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5))) && p148v_safe_block(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),end)
    case _: p148v_safe_tag(tag,words,values,names,used,valueUsed,nameUsed,at) && p148v_safe_block(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),end)

@unsafe
def p148v_safe_block(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32) -> Bool:
  nt_choose(Bool,U32.is_ge(at,end),u => True{},u => p148v_safe_next(U32.mod(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),words,values,names,used,valueUsed,nameUsed,at,end))

@unsafe
def p148v_import_extend(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +schema: Array<U32>, +live: Array<U32>, +ids: N111Ids) -> Bool:
  +count = p148v_literal(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,4))
  +constructor = p148v_target(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,2),True{},ids)
  p148v_args(words,values,names,used,valueUsed,nameUsed,at,0,[3,2,1,3,1],schema,live,ids) && U32.is_ge(count,1) && U32.is_le(count,7) &&
    Bool.not(String.eq(dk(constructor),"Absent")) && U32.is_eq(da(constructor),U32.inc(count)) && p148v_buffer(words,values,names,used,valueUsed,nameUsed,at,3,count,live)

@unsafe
def p148v_import_concat(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +schema: Array<U32>, +live: Array<U32>, +ids: N111Ids) -> Bool:
  +empty = p148v_target(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,3),True{},ids)
  +link = p148v_target(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,4),True{},ids)
  p148v_args(words,values,names,used,valueUsed,nameUsed,at,0,[3,2,2,1,1],schema,live,ids) &&
    Bool.not(String.eq(dk(empty),"Absent")) && U32.is_eq(da(empty),0) &&
    Bool.not(String.eq(dk(link),"Absent")) && U32.is_eq(da(link),2) && Bool.not(String.eq(dn(empty),dn(link)))

@unsafe
def p148v_import(+symbol: String, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +schema: Array<U32>, +live: Array<U32>, +ids: N111Ids, arity: U32, result: U32) -> P148VF:
  +prefix = U32.is_eq(U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),2) && p148v_runtime_args(words,values,names,used,valueUsed,nameUsed,at)
  +name = p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at))
  nt_choose(P148VF,String.eq(symbol,"p126_rt_nat_divmod"),u =>
    p148v_step(prefix && p148v_args(words,values,names,used,valueUsed,nameUsed,at,0,[3,2,2,3],schema,live,ids) && p148v_memory(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,3),8,2,schema,live,ids),name,True{},schema,live,"Nat.divmod product import signature/output capacity mismatch"),u =>
  nt_choose(P148VF,String.eq(symbol,"p125_rt_concat_typed"),u =>
    p148v_step(prefix && p148v_import_concat(words,values,names,used,valueUsed,nameUsed,at,schema,live,ids),name,True{},schema,live,"concat value import signature/constructor mismatch"),u =>
  nt_choose(P148VF,p118t_import(symbol),u =>
    p148v_step(prefix && nt_choose(Bool,String.eq(symbol,"p118_rt_extend"),v => p148v_import_extend(words,values,names,used,valueUsed,nameUsed,at,schema,live,ids),v => p148v_args(words,values,names,used,valueUsed,nameUsed,at,0,[3,2,2,2],schema,live,ids)),name,True{},schema,live,"TRMC import signature/constructor/capacity mismatch"),u =>
  nt_choose(P148VF,String.eq(symbol,"p113_rt_array_pair"),u =>
    p148v_step(prefix && p148v_array_shape(words,values,names,used,valueUsed,nameUsed,at) && p148v_args(words,values,names,used,valueUsed,nameUsed,at,0,[3,1,3,1,3,1],schema,live,ids) && p148v_buffer(words,values,names,used,valueUsed,nameUsed,at,2,p148v_literal(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,3)),live) && p148v_memory(words,values,names,used,valueUsed,nameUsed,p148v_arg(words,values,names,used,valueUsed,nameUsed,at,4),8,2,schema,live,ids),name,True{},schema,live,"product array import signature/count/capacity mismatch"),u =>
    p148v_checked_scalar(p148v_safe_tag(3,words,values,names,used,valueUsed,nameUsed,at),3,words,values,names,used,valueUsed,nameUsed,at,schema,live,ids,missing(),arity,result)))))

@unsafe
def p148v_distinct_from(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, +id: U32) -> Bool:
  nt_choose(Bool,U32.is_ge(at,end),u => True{},u => Bool.not(U32.is_eq(p148v_w(words,values,names,used,valueUsed,nameUsed,at),id)) && p148v_distinct_from(words,values,names,used,valueUsed,nameUsed,U32.inc(at),end,id))

@unsafe
def p148v_distinct(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32) -> Bool:
  nt_choose(Bool,U32.is_ge(at,end),u => True{},u => p148v_distinct_from(words,values,names,used,valueUsed,nameUsed,U32.inc(at),end,p148v_w(words,values,names,used,valueUsed,nameUsed,at)) && p148v_distinct(words,values,names,used,valueUsed,nameUsed,U32.inc(at),end))

@unsafe
def p148v_values(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +count: U32, +schema: Array<U32>, +live: Array<U32>, +ids: N111Ids) -> Bool:
  nt_choose(Bool,U32.is_eq(count,0),u => True{},u => p148v_value(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,at),2,schema,live,ids) && p148v_values(words,values,names,used,valueUsed,nameUsed,U32.inc(at),U32.sub(count,1),schema,live,ids))

@unsafe
def p148v_assign_names(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +count: U32, +schema: Array<U32>, +live: Array<U32>) -> Array<U32>:
  nt_choose(Array<U32>,U32.is_eq(count,0),u => live,u => p148v_assign_names(words,values,names,used,valueUsed,nameUsed,U32.inc(at),U32.sub(count,1),schema,p148v_assign(p148v_w(words,values,names,used,valueUsed,nameUsed,at),schema,live)))

@unsafe
def p148v_direct_call_done(ok: Bool, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, at: U32, +count: U32, schema: Array<U32>, +live: Array<U32>, target: String) -> P148VF:
  match ok:
    case True{}: P148VF{p148v_assign_names(words,values,names,used,valueUsed,nameUsed,at,count,schema,live),False{},""}
    case False{}: P148VF{live,False{},"unknown/cyclic direct call or argument/result mismatch: " ++ target}

@unsafe
def p148v_direct_call(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +schema: Array<U32>, +live: Array<U32>, +ids: N111Ids, ready: KDef) -> P148VF:
  +target = p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)))
  +signature = p111v_get(ready,target)
  +dest = p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4))
  +args = p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5))
  +payload = p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,6))
  p148v_direct_call_done(String.eq(dk(signature),"P113Direct") && U32.is_eq(da(signature),args) && U32.is_eq(dx(signature),dest) &&
    p148v_distinct(words,values,names,used,valueUsed,nameUsed,payload,U32.add(payload,dest)) && p148v_values(words,values,names,used,valueUsed,nameUsed,U32.add(payload,dest),args,schema,live,ids),words,values,names,used,valueUsed,nameUsed,payload,dest,schema,live,target)

@unsafe
def p148v_vector_done(ok: Bool, +live: Array<U32>) -> P148VF:
  match ok:
    case True{}: P148VF{live,True{},""}
    case False{}: P148VF{live,False{},"direct terminal vector has wrong arity/type or undefined value"}

@unsafe
def p148v_vector(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +count: U32, schema: Array<U32>, +live: Array<U32>, ids: N111Ids) -> P148VF:
  p148v_vector_done(U32.is_eq(p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),count) && p148v_values(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,6)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),schema,live,ids),live)

# Observe a row completely before mutating its backing array.
@unsafe
def p148v_join_row(+left: Array<U32>, +at: U32, +both: Bool, equal: Bool, capacity: U32) -> Array<U32>:
  p148w_set(p148w_set(left,U32.mul(at,2),Bool.to_u32(both)),U32.inc(U32.mul(at,2)),nt_choose(U32,both && equal,u => capacity,u => 0))

@unsafe
def p148v_join_rows(+left: Array<U32>, +right: Array<U32>, +at: U32, +end: U32) -> Array<U32>:
  nt_choose(Array<U32>,U32.is_ge(at,end),u => left,u =>
    p148v_join_rows(p148v_join_row(left,at,U32.is_eq(p148v_l(left,at,0),1) && U32.is_eq(p148v_l(right,at,0),1),
      U32.is_eq(p148v_l(left,at,1),p148v_l(right,at,1)),p148v_l(left,at,1)),right,U32.inc(at),end))

@unsafe
def p148v_join(yes: P148VF, no: P148VF, size: U32) -> P148VF:
  match yes no:
    case P148VF{+yl,+yt,+ye} P148VF{+nl,+nt,+ne}:
      nt_choose(P148VF,Bool.not(String.is_empty(ye)),u => P148VF{yl,yt,ye},u =>
      nt_choose(P148VF,Bool.not(String.is_empty(ne)),u => P148VF{nl,nt,ne},u =>
      nt_choose(P148VF,yt,u => nt_choose(P148VF,nt,v => P148VF{yl,True{},""},v => P148VF{nl,nt,ne}),u =>
      nt_choose(P148VF,nt,u => P148VF{yl,yt,ye},u => P148VF{p148v_join_rows(yl,nl,0,size),False{},""}))))

@unsafe
def p148v_branches(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, at: U32, +raw: Bool, schema: Array<U32>, copies: Array<U32> & Array<U32>, ids: N111Ids, ready: KDef, arity: U32, result: U32) -> P148VF:
  (a,b) = copies
  p148v_branches_separate(words,values,names,used,valueUsed,nameUsed,at,raw,schema,a,b,ids,ready,arity,result)

@unsafe
def p148v_branches_separate(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +raw: Bool, +schema: Array<U32>, yes: Array<U32>, no: Array<U32>, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P148VF:
  p148v_join(
    p148v_body(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),raw,schema,P148VF{yes,False{},""},ids,ready,arity,result),
    p148v_body(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),raw,schema,P148VF{no,False{},""},ids,ready,arity,result),p148v_size(words,values,names,used,valueUsed,nameUsed))

@unsafe
def p148v_branch_done(ok: Bool, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, at: U32, +raw: Bool, schema: Array<U32>, +live: Array<U32>, ids: N111Ids, ready: KDef, arity: U32, result: U32) -> P148VF:
  match ok:
    case True{}: p148v_branches(words,values,names,used,valueUsed,nameUsed,at,raw,schema,p148w_clone(live),ids,ready,arity,result)
    case False{}: P148VF{live,False{},nt_choose(String,raw,u => "condition must be a definitely assigned U32",u => "direct condition must be a definitely assigned U32")}

@unsafe
def p148v_branch(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +raw: Bool, +schema: Array<U32>, +live: Array<U32>, +ids: N111Ids, ready: KDef, arity: U32, result: U32) -> P148VF:
  p148v_branch_done(p148v_value(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,2)),1,schema,live,ids),words,values,names,used,valueUsed,nameUsed,at,raw,schema,live,ids,ready,arity,result)

@unsafe
def p148v_offset_done(ok: Bool, name: U32, capacity: U32, +offset: U32, +live: Array<U32>) -> P148VF:
  match ok:
    case True{}: P148VF{p148v_live(live,name,U32.sub(capacity,offset)),False{},""}
    case False{}: P148VF{live,False{},"unbounded or ill-typed pointer offset"}

@unsafe
def p148v_offset(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +schema: Array<U32>, +live: Array<U32>, +ids: N111Ids) -> P148VF:
  +base = p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,2))
  +bytes = p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,3))
  +offset = p148v_literal(words,values,names,used,valueUsed,nameUsed,bytes)
  +capacity = p148v_capacity(words,values,names,used,valueUsed,nameUsed,base,live)
  p148v_offset_done(p148v_value(words,values,names,used,valueUsed,nameUsed,base,3,schema,live,ids) && p148v_value(words,values,names,used,valueUsed,nameUsed,bytes,2,schema,live,ids) && U32.is_le(offset,capacity),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),capacity,offset,live)

@unsafe
def p148v_return_done(ok: Bool, +live: Array<U32>) -> P148VF:
  match ok:
    case True{}: P148VF{live,True{},""}
    case False{}: P148VF{live,False{},"segment return must be U64"}

@unsafe
def p148v_scalar(+tag: U32, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +schema: Array<U32>, +live: Array<U32>, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P148VF:
  match tag:
    case 1: p148v_step(p148v_value(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,2)),U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),schema,live,ids),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),True{},schema,live,"ill-typed or undefined assignment")
    case 2: p148v_step(U32.is_le(U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),2) && p111v_operator(p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)))) && p148v_value(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,2)),U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),schema,live,ids) && p148v_value(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,3)),U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),schema,live,ids),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),True{},schema,live,"invalid binary operation or operand")
    case 3: p148v_step(p148v_runtime(words,values,names,used,valueUsed,nameUsed,at,schema,live,ids,arity,result),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),True{},schema,live,"runtime import signature/count/capacity mismatch: " ++ p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4))))
    case 4: p148v_branch(words,values,names,used,valueUsed,nameUsed,at,True{},schema,live,ids,ready,arity,result)
    case 5: p148v_return_done(p148v_value(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,2)),2,schema,live,ids),live)
    case 6: p148v_step(p148v_memory(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,2)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),schema,live,ids),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),True{},schema,live,"unbounded, unaligned or ill-typed load")
    case 7: p148v_step(p148v_memory(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,2)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),schema,live,ids) && p148v_value(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,3)),U32.div(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),schema,live,ids),0,False{},schema,live,"unbounded, unaligned or ill-typed store")
    case 8: p148v_offset(words,values,names,used,valueUsed,nameUsed,at,schema,live,ids)
    case 9: p148v_step(U32.is_gt(p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),0) && U32.is_le(p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),2048) && (U32.is_eq(p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),4) || U32.is_eq(p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),8) || U32.is_eq(p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),16)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.inc(at)),True{},schema,live,"unsupported stack allocation size/alignment")
    case _: P148VF{live,False{},"compact scalar tag outside private contract"}

@unsafe
def p148v_checked_scalar(ok: Bool, +tag: U32, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, at: U32, schema: Array<U32>, +live: Array<U32>, ids: N111Ids, ready: KDef, arity: U32, result: U32) -> P148VF:
  match ok:
    case True{}: p148v_scalar(tag,words,values,names,used,valueUsed,nameUsed,at,schema,live,ids,ready,arity,result)
    case False{}: P148VF{live,False{},"scheduler/state/terminal operation in direct scalar block"}

@unsafe
def p148v_stmt(+tag: U32, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +raw: Bool, +schema: Array<U32>, +live: Array<U32>, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P148VF:
  match tag raw:
    case _ True{}: p148v_scalar(tag,words,values,names,used,valueUsed,nameUsed,at,schema,live,ids,ready,arity,result)
    case 3 False{}: p148v_import(p148v_n(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4))),words,values,names,used,valueUsed,nameUsed,at,schema,live,ids,arity,result)
    case 10 False{}: p148v_branch(words,values,names,used,valueUsed,nameUsed,at,False{},schema,live,ids,ready,arity,result)
    case 11 False{}: p148v_direct_call(words,values,names,used,valueUsed,nameUsed,at,schema,live,ids,ready)
    case 12 False{}: p148v_vector(words,values,names,used,valueUsed,nameUsed,at,result,schema,live,ids)
    case 13 False{}: p148v_vector(words,values,names,used,valueUsed,nameUsed,at,arity,schema,live,ids)
    case _ False{}: p148v_checked_scalar(p148v_safe_tag(tag,words,values,names,used,valueUsed,nameUsed,at),tag,words,values,names,used,valueUsed,nameUsed,at,schema,live,ids,ready,arity,result)

@unsafe
def p148v_body_step(+tag: U32, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, +raw: Bool, +schema: Array<U32>, flow: P148VF, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P148VF:
  match flow:
    case P148VF{+live,+terminal,+error}: p148v_body_step_flat(tag,words,values,names,used,valueUsed,nameUsed,at,end,raw,schema,live,terminal,error,ids,ready,arity,result)

@unsafe
def p148v_body_step_flat(+tag: U32, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, +raw: Bool, +schema: Array<U32>, +live: Array<U32>, +terminal: Bool, +error: String, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P148VF:
  match tag:
    case 15: p148v_body_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),end,raw,schema,live,terminal,error,ids,ready,arity,result)
    case 14: p148v_body(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),end,raw,schema,p148v_body_flat(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,4)),p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,5)),raw,schema,live,terminal,error,ids,ready,arity,result),ids,ready,arity,result)
    case _:
      nt_choose(P148VF,Bool.not(String.is_empty(error)),u => P148VF{live,terminal,error},u =>
      nt_choose(P148VF,terminal,u => P148VF{live,True{},nt_choose(String,raw,v => "statement follows terminal path",v => "statement follows direct terminal edge")},u =>
        p148v_body(words,values,names,used,valueUsed,nameUsed,p148v_w(words,values,names,used,valueUsed,nameUsed,U32.add(at,7)),end,raw,schema,p148v_stmt(tag,words,values,names,used,valueUsed,nameUsed,at,raw,schema,live,ids,ready,arity,result),ids,ready,arity,result)))

@unsafe
def p148v_body(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, +raw: Bool, +schema: Array<U32>, flow: P148VF, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P148VF:
  match flow:
    case P148VF{+live,+terminal,+error}: p148v_body_flat(words,values,names,used,valueUsed,nameUsed,at,end,raw,schema,live,terminal,error,ids,ready,arity,result)

@unsafe
def p148v_body_flat(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +end: U32, +raw: Bool, +schema: Array<U32>, +live: Array<U32>, +terminal: Bool, +error: String, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P148VF:
  nt_choose(P148VF,U32.is_ge(at,end),u => P148VF{live,terminal,error},u => p148v_body_step_flat(U32.mod(p148v_w(words,values,names,used,valueUsed,nameUsed,at),256),words,values,names,used,valueUsed,nameUsed,at,end,raw,schema,live,terminal,error,ids,ready,arity,result))

@unsafe
def p148v_finish(flow: P148VF) -> String:
  match flow:
    case P148VF{live,terminal,+error}: nt_choose(String,Bool.not(String.is_empty(error)),u => error,u => nt_choose(String,terminal,v => "",v => "segment has a nonterminal path"))

@unsafe
def p148v_live_params(params: List<&2,NC_Binding>, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +live: Array<U32>) -> Array<U32>:
  match params:
    case Nil{}: live
    case Con{NC_Binding{id,word,kind},rest}: p148v_live_params(rest,words,values,names,used,valueUsed,nameUsed,p148v_live(live,p148v_name_id(words,values,names,used,valueUsed,nameUsed,word),0))

@unsafe
def p148v_flow(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, params: List<&2,NC_Binding>, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32, scan: P148VS) -> String:
  match scan:
    case P148VS{+data,+count,+error}: p148v_flow_flat(words,values,names,used,valueUsed,nameUsed,params,ids,ready,arity,result,data,count,error)

@unsafe
def p148v_flow_flat(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, params: List<&2,NC_Binding>, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32, +data: Array<U32>, +count: U32, +error: String) -> String:
  nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
    nt_choose(String,U32.is_gt(count,65535),u => "too many direct locals",u =>
      p148v_finish(p148v_body(words,values,names,used,valueUsed,nameUsed,0,p148v_end(words,values,names,used,valueUsed,nameUsed),False{},data,P148VF{p148v_live_params(params,words,values,names,used,valueUsed,nameUsed,p148v_live(p148v_live(p148w_new(U32.mul(p148v_size(words,values,names,used,valueUsed,nameUsed),2)),0,2088),1,2048)),False{},""},ids,ready,arity,result))))

type P148Checked is Type:
  P148Checked{unit: P148Unit, +error: String}

@unsafe
def p148v_header(+name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +original: KDef, +constructors: KDef, +ready: KDef) -> String:
  +old = p111v_get(original,name)
  +arity = nt_count(NC_Binding,params)
  nt_choose(String,Bool.not(p111v_raw_name(name)) || Bool.not(String.eq(dk(p111v_get(ready,name)),"Absent")),u => "invalid/duplicate direct function identity",u =>
  nt_choose(String,U32.is_gt(arity,255) || U32.is_lt(result,1) || U32.is_gt(result,8),u => "direct signature exceeds ABI boundary",u =>
  nt_choose(String,public && (String.eq(dk(old),"Absent") || Bool.not(U32.is_eq(arity,da(old))) || Bool.not(U32.is_eq(result,1)) || Bool.not(U32.is_eq(dx(old),0)) || Bool.not(U32.is_eq(ix(dv(old)),0)) || Bool.not(U32.is_eq(qt(dv(old)),1))),u => "public direct wrapper does not preserve original scalar ABI",u =>
  nt_choose(String,U32.is_lt(p148v_size(words,values,names,used,valueUsed,nameUsed),2) || U32.is_gt(p148v_size(words,values,names,used,valueUsed,nameUsed),349525),u => "compact admission storage bound exceeded",u =>
    p148v_flow(words,values,names,used,valueUsed,nameUsed,params,N111Ids{original,constructors},ready,arity,result,p148v_schema(words,values,names,used,valueUsed,nameUsed,0,p148v_end(words,values,names,used,valueUsed,nameUsed),False{},p148v_seed(params,words,values,names,used,valueUsed,nameUsed)))))))

@unsafe
def p148v_checked_unit(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, words: Array<U32>, values: Array<U32>, names: Array<String>, used: U32, valueUsed: U32, nameUsed: U32, error: String) -> P148Checked:
  P148Checked{P148Good{name,params,result,public,P148Tape{words,values,names,used,valueUsed,nameUsed}},error}

@unsafe
def p148v_check_arrays(+name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, ids: N111Ids, +ready: KDef) -> P148Checked:
  match ids:
    case N111Ids{original,constructors}:
      p148v_checked_unit(name,params,result,public,words,values,names,used,valueUsed,nameUsed,p148v_header(name,params,result,public,words,values,names,used,valueUsed,nameUsed,original,constructors,ready))

@unsafe
def p148v_check_tape(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, tape: P148Tape, ids: N111Ids, ready: KDef) -> P148Checked:
  match tape:
    case P148Tape{words,values,names,used,valueUsed,nameUsed}: p148v_check_arrays(name,params,result,public,words,values,names,used,valueUsed,nameUsed,ids,ready)

@unsafe
def p148v_check(unit: P148Unit, +ids: N111Ids, +ready: KDef) -> P148Checked:
  match unit:
    case P148Bad{+error}: P148Checked{P148Bad{error},"compact unit unavailable: " ++ error}
    case P148Good{name,params,result,public,tape}: p148v_check_tape(name,params,result,public,tape,ids,ready)

@unsafe
def p148v_checked_error(checked: P148Checked) -> String:
  match checked:
    case P148Checked{unit,error}: error

@unsafe
def p148v_function(unit: P148Unit, +ids: N111Ids, +ready: KDef) -> String:
  p148v_checked_error(p148v_check(unit,ids,ready))
