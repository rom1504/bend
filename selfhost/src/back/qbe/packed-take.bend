# Ordinary match lowering already supplies the checked constructor identity
# and its field count. Unlike a late runtime-call recognizer, this factory has
# the expected CID; the unchanged verifier resolves its N111CtorId. Neither
# a source constructor spelling nor a tag alone is sufficient to take a word.
# The same structured IR reaches both QBE and direct x86.

@unsafe
def p185pt_previous(+name: String, +word: N111Value, +count: U32, +n: U32) -> List<&2,N111Stmt>:
  +kind = p111_special(name)
  nt_choose(List<&2,N111Stmt>,U32.is_eq(count,0),u => Nil{},
    u => Con{nt_choose(N111Stmt,U32.is_eq(kind,0),
      v => N111Call{"ignored",N111U64{},"p111_rt_take",[p111_state(),p111_word(word),p111_scratch(),p111_u32(count)]},
      v => N111Call{"ignored",N111U64{},"p111_rt_special_take",[p111_state(),p111_u32(kind),p111_word(word),p111_scratch(),p111_u32(count)]}),p111_load_fields(count,0,n)})

@unsafe
def p185pt_word(word: N111Value) -> Bool:
  match word:
    case N111Local{name}: Bool.not(String.starts_with(name,"p185pt_"))
    case N111Const{lo,hi}: True{}
    case _: False{}

@unsafe
def p185pt_admitted(+name: String, word: N111Value, +count: U32) -> Bool:
  p114p_ordinary(name) && U32.is_eq(count,1) && p185pt_word(word)

@unsafe
def p185pt_name(site: U32, role: String) -> String:
  "p185pt_" ++ U32.show(site) ++ "_" ++ role

@unsafe
def p185pt_local(site: U32, role: String) -> N111Value:
  N111Local{p185pt_name(site,role)}

# Extract tag and auxiliary bits together, masking only RFC. This is exactly
# term_tag==TAG_PAK AND term_aux==expectedCID; all 40 payload bits survive.
# Snapshot before any temporary assignment, scratch write or output binding.
# Generated source locals are v_<id>; the fresh lowering counter distinguishes
# these temporaries, and explicit reserved-prefix input aliases decline.
@unsafe
def p185pt_single(+name: String, +word: N111Value, +n: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,
    [N111Set{p185pt_name(n,"word"),N111U64{},word},
     N111Bin{p185pt_name(n,"bits"),N111U64{},"shr",p185pt_local(n,"word"),N111Const{40,0}},
     N111Bin{p185pt_name(n,"shape"),N111U64{},"and",p185pt_local(n,"bits"),N111Const{8388607,0}},
     N111Bin{p185pt_name(n,"expected"),N111U64{},"or",N111CtorId{name},N111Const{65536,0}},
     N111Bin{p185pt_name(n,"guard"),N111U64{},"eq",p185pt_local(n,"shape"),p185pt_local(n,"expected")},
     N111If{p185pt_local(n,"guard"),[
       N111Bin{p185pt_name(n,"payload"),N111U64{},"and",p185pt_local(n,"word"),N111Const{4294967295,255}},
       N111Store{N111U64{},N111Local{"scratch"},0,p185pt_local(n,"payload")},
       N111Set{"ignored",N111U64{},N111Const{1,0}}],[
       N111Call{"ignored",N111U64{},"p111_rt_take",[p111_state(),p111_word(word),p111_scratch(),p111_u32(1)]}]}],
    p111_load_fields(1,0,n))

@unsafe
def p185pt_take(+name: String, +word: N111Value, +count: U32, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,p185pt_admitted(name,word,count),
    u => p185pt_single(name,word,n),u => p185pt_previous(name,word,count,n))
