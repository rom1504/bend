# Structured counterparts of the mature generic bridge utilities.
@unsafe
def p111_body(+code: P111Code) -> List<&2, N111Stmt>:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: body

@unsafe
def p111_segments(+code: P111Code) -> List<&2, N111Segment>:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: segments

@unsafe
def p111_fresh(+code: P111Code) -> U32:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: fresh

@unsafe
def p111_error(+code: P111Code) -> String:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: error

@unsafe
def p111_first(+a: String, +b: String) -> String:
  nt_choose(String, String.eq(a, ""), u => b, u => a)

@unsafe
def p111_prepend(prefix: List<&2, N111Stmt>, code: P111Code) -> P111Code:
  match code:
    case P111Code{+body, +segments, +fresh, +error}: P111Code{nt_append(N111Stmt, prefix, body), segments, fresh, error}

@unsafe
def p111_fail(+error: String, +n: U32) -> P111Code:
  P111Code{Nil{}, Nil{}, n, error}

@unsafe
def p111_state() -> N111Arg:
  N111Arg{N111Ptr{}, N111Local{"state"}}

@unsafe
def p111_u32(+value: U32) -> N111Arg:
  N111Arg{N111U32{}, N111Const{value, 0}}

@unsafe
def p111_word(+value: N111Value) -> N111Arg:
  N111Arg{N111U64{}, value}

@unsafe
def p111_scratch() -> N111Arg:
  N111Arg{N111Ptr{}, N111Local{"scratch"}}

@unsafe
def p111_env_words(env: List<&2, NC_Binding>) -> List<&2, N111Value>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}: Con{N111Local{word}, p111_env_words(rest)}

@unsafe
def p111_values(args: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> List<&2, N111Value>:
  match args:
    case Nil{}: Nil{}
    case Con{+h, +rest}: Con{N111Local{nc_word(ix(h), env)}, p111_values(rest, env)}

@unsafe
def p111_head(values: List<&2, N111Value>) -> N111Value:
  match values:
    case Nil{}: N111Const{0, 0}
    case Con{+head, +rest}: head

@unsafe
def p111_tail(values: List<&2, N111Value>) -> List<&2, N111Value>:
  match values:
    case Nil{}: Nil{}
    case Con{+head, +rest}: rest

@unsafe
def p111_store(values: List<&2, N111Value>, +index: U32) -> List<&2, N111Stmt>:
  match values:
    case Nil{}: Nil{}
    case Con{+head, +rest}: Con{N111Store{N111U64{}, N111Local{"scratch"}, U32.mul(index, 8), head}, p111_store(rest, U32.inc(index))}

@unsafe
def p111_return(+value: N111Value, +n: U32) -> P111Code:
  P111Code{[N111Store{N111U64{}, N111Local{"scratch"}, 0, value}, N111Call{"reply", N111U64{}, "p111_rt_return", [p111_state(), p111_scratch(), p111_u32(1)]}, N111Return{N111Local{"reply"}}], Nil{}, n, ""}

@unsafe
def p111_jump(+name: String, +values: List<&2, N111Value>, +n: U32) -> P111Code:
  P111Code{nt_append(N111Stmt, p111_store(values, 0), [N111Call{"reply", N111U64{}, "p111_rt_jump", [p111_state(), N111Arg{N111U32{}, N111FuncId{name}}, p111_scratch(), p111_u32(nt_count(N111Value, values))]}, N111Return{N111Local{"reply"}}]), Nil{}, n, ""}

@unsafe
def p111_partition_step(+id: U32, +word: String, +kind: N_WordKind, +used: Bool, parts: P111Partition) -> P111Partition:
  match parts:
    case P111Partition{+live, +drop}:
      nt_choose(P111Partition, used, u => P111Partition{Con{NC_Binding{id, word, kind}, live}, drop}, u => P111Partition{live, Con{N111Call{"ignored", N111U64{}, "p111_rt_sink", [p111_state(), p111_word(N111Local{word})]}, drop}})

@unsafe
def p111_partition(env: List<&2, NC_Binding>, +uses: NU_Set) -> P111Partition:
  match env:
    case Nil{}: P111Partition{Nil{}, Nil{}}
    case Con{NC_Binding{+id, +word, +kind}, +rest}: p111_partition_step(id, word, kind, nc_uses_has(uses, id), p111_partition(rest, uses))

@unsafe
def p111_keep(env: List<&2, NC_Binding>, +uses: NU_Set) -> List<&2, N111Stmt>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}:
      nt_choose(List<&2, N111Stmt>, nc_uses_has(uses, id), u => Con{N111Call{word, N111U64{}, "p111_rt_keep", [p111_state(), p111_word(N111Local{word})]}, p111_keep(rest, uses)}, u => p111_keep(rest, uses))

@unsafe
def p111_name(+n: U32) -> String:
  "$p111.k." ++ U32.show(n)

@unsafe
def p111_params(params: List<&2, NC_Binding>, +held: U32, +capture: U32, +reg: U32) -> List<&2, N111Stmt>:
  match params:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word, +kind}, +rest}:
      nt_choose(List<&2, N111Stmt>, U32.is_lt(capture, held),
        u => Con{N111Call{word, N111U64{}, "p111_rt_stack_get", [p111_state(), p111_u32(capture)]}, p111_params(rest, held, U32.inc(capture), reg)},
        u => Con{N111Call{word, N111U64{}, "p111_rt_reg_get", [p111_state(), p111_u32(reg)]}, p111_params(rest, held, capture, U32.inc(reg))})

@unsafe
def p111_segment(+name: String, +params: List<&2, NC_Binding>, +held: U32, +incoming: U32, +body: List<&2, N111Stmt>) -> N111Segment:
  +start = nt_choose(List<&2, N111Stmt>, U32.is_eq(held, 0), u => Nil{}, u => [N111Call{"ignored", N111U64{}, "p111_rt_stack_pop", [p111_state(), p111_u32(held)]}])
  N111Segment{name, nt_count(NC_Binding, params), 1, incoming, 0, Con{N111Alloca{"scratch", 2048, 8}, nt_append(N111Stmt, start, nt_append(N111Stmt, p111_params(params, held, 0, 0), body))}}

@unsafe
def p111_frame(+held: List<&2, NC_Binding>, +next: String) -> List<&2, N111Stmt>:
  nt_append(N111Stmt, p111_store(p111_env_words(held), 0), [N111Call{"ignored", N111U64{}, "p111_rt_frame", [p111_state(), N111Arg{N111U32{}, N111FuncId{next}}, p111_scratch(), p111_u32(nt_count(NC_Binding, held))]}])

@unsafe
def p111_uint(parsed: Maybe<&2, U32>) -> P111ValueCode:
  match parsed:
    case None{}: P111ValueCode{Nil{}, N111Const{0, 0}, "invalid native U32 literal"}
    case Some{+value}: P111ValueCode{Nil{}, N111Const{value, 0}, ""}

@unsafe
def p111_value_return(value: P111ValueCode, +n: U32) -> P111Code:
  match value:
    case P111ValueCode{+body, +word, +error}:
      nt_choose(P111Code, String.eq(error, ""), u => p111_prepend(body, p111_return(word, n)), u => p111_fail(error, n))
