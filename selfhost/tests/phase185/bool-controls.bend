# Append to the extracted compiler API. These controls call the real intrinsic
# lowering and unchanged direct verifier. The machine runner must cross every
# pair of p185bc_words with the independent truth labels below and check full
# U64 results: OR = max(a,b), XOR = a != b. True deliberately has CID 42.

@unsafe
def p185bc_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids([N_Constructor{"True",0,False{}}],42,missing())}

@unsafe
def p185bc_function(name: String, +left: String, +right: String, code: P111ValueCode) -> P113DFunction:
  match code:
    case P111ValueCode{body,word,error}:
      P113DFunction{name,[NC_Binding{0,left,N_W64{}},NC_Binding{1,right,N_W64{}}],1,False{},
        nt_append(P113DStmt,p113d_scalars(body),[P113DResult{[word]}])}

@unsafe
def p185bc_binary(name: String, op: String, +left: String, +right: String) -> P113DFunction:
  p185bc_function(name,left,right,p112_intrinsic(op,[N111Local{left},N111Local{right}]))

@unsafe
def p185bc_functions() -> List<&2,P113DFunction>:
  [p185bc_binary("p185bc_or","bool_or","a","b"),
   p185bc_binary("p185bc_xor","bool_xor","a","b"),
   p185bc_binary("p185bc_or_output_alias","bool_or","value","match_condition"),
   p185bc_binary("p185bc_xor_output_alias","bool_xor","match_condition","value"),
   p185bc_binary("p185bc_or_helper_alias","bool_or","p112_b_raw","p112_b_bits"),
   p185bc_binary("p185bc_xor_helper_alias","bool_xor","p112_b_boxed","p112_b_expected"),
   p185bc_binary("p185bc_or_nearby_prefix","bool_or","p185_boolean_a","p185_boolean_b")]

@unsafe
def p185bc_validate() -> String:
  p113e_functions(p185bc_functions(),p185bc_ids(),missing())

# Raw 0/1, noncanonical nonzero, high bits on raw 1, packed True with changing
# locations/RFC, wrong tags/aux, RFC-only, and all bits set. The final packed
# False has the neighboring CID 41 and maximal location with RFC set.
def p185bc_words() -> List<&2,N111Value>:
  [N111Const{0,0},N111Const{1,0},N111Const{2,0},N111Const{4294967295,0},
   N111Const{1,1},N111Const{0,2147483648},N111Const{1,2147483648},
   N111Const{0,16787968},N111Const{4294967295,16788223},
   N111Const{0,2164271616},N111Const{4294967295,2164271871},
   N111Const{0,10752},N111Const{0,33565184},N111Const{0,16787712},
   N111Const{0,16788224},N111Const{4294967295,4294967295},
   N111Const{4294967295,2164271615}]

def p185bc_truths() -> List<&2,U32>:
  [0,1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0]

@unsafe
def p185bc_has_call(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{N111Call{name,typ,symbol,args},rest}: True{}
    case Con{N111If{condition,yes,no},rest}: p185bc_has_call(yes) || p185bc_has_call(no) || p185bc_has_call(rest)
    case Con{head,rest}: p185bc_has_call(rest)

@unsafe
def p185bc_native(code: P111ValueCode) -> Bool:
  match code:
    case P111ValueCode{body,word,error}: String.is_empty(error) && Bool.not(p185bc_has_call(body))

@unsafe
def p185bc_fallback(code: P111ValueCode) -> Bool:
  match code:
    case P111ValueCode{body,word,error}: String.is_empty(error) && p185bc_has_call(body)

@unsafe
def p185bc_reserved(+name: String) -> Bool:
  p185bc_fallback(p112_intrinsic("bool_or",[N111Local{name},N111Const{1,0}])) &&
  p185bc_fallback(p112_intrinsic("bool_xor",[N111Const{0,0},N111Local{name}]))

@unsafe
def p185bc_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

# Every row must end in =1. Wrong arities retain the old fallback; these rows
# observe admission only and never execute malformed runtime calls.
@unsafe
def p185bc_controls() -> List<&2,String>:
  [p185bc_row("verified-functions",String.is_empty(p185bc_validate())),
   p185bc_row("or-native",p185bc_native(p112_intrinsic("bool_or",[N111Local{"a"},N111Local{"b"}]))),
   p185bc_row("xor-native",p185bc_native(p112_intrinsic("bool_xor",[N111Local{"a"},N111Local{"b"}]))),
   p185bc_row("literal-native",p185bc_native(p112_intrinsic("bool_or",[N111Const{1,0},N111Const{0,0}]))),
   p185bc_row("old-temporary-alias",p185bc_native(p112_intrinsic("bool_xor",[N111Local{"p112_b_raw"},N111Local{"match_condition"}]))),
   p185bc_row("reserved-left-snapshot",p185bc_reserved("p185_bool_a_local_input")),
   p185bc_row("reserved-right-snapshot",p185bc_reserved("p185_bool_b_local_input")),
   p185bc_row("reserved-left-normalizer",p185bc_reserved("p185_bool_a_local_p112_b_raw")),
   p185bc_row("reserved-right-normalizer",p185bc_reserved("p185_bool_b_local_p112_b_bits")),
   p185bc_row("reserved-left-condition",p185bc_reserved("p185_bool_a_local_match_condition")),
   p185bc_row("reserved-right-condition",p185bc_reserved("p185_bool_b_local_match_condition")),
   p185bc_row("reserved-combined-condition",p185bc_reserved("p185_bool_test")),
   p185bc_row("reserved-future-prefix",p185bc_reserved("p185_bool_future")),
   p185bc_row("nearby-prefix",p185bc_native(p112_intrinsic("bool_or",[N111Local{"p185_boolean_a"},N111Local{"b"}]))),
   p185bc_row("arity-zero",p185bc_fallback(p112_intrinsic("bool_or",[]))),
   p185bc_row("arity-one",p185bc_fallback(p112_intrinsic("bool_xor",[N111Const{1,0}]))),
   p185bc_row("arity-three",p185bc_fallback(p112_intrinsic("bool_or",[N111Const{1,0},N111Const{0,0},N111Const{1,0}]))),
   p185bc_row("unrelated-fallback",p185bc_fallback(p112_intrinsic("nat_add",[N111Const{1,0},N111Const{2,0}])))]
