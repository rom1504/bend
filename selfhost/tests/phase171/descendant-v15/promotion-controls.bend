# Evaluate the ACTUAL four emitted scalar operations with the maintained exact
# scalar-facts evaluator. Literal expected predicates are independent. These
# numeric boundary inputs are compiler data, never forged runtime Terms.

@unsafe
def p171dp_fact(fact: P113KFact, want: U32) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: exact && U32.is_eq(lo,want) && U32.is_eq(hi,0)

@unsafe
def p171dp_fold_done(result: P113KScalar, want: U32) -> Bool:
  match result:
    case P113KScalar{body,facts}: p171dp_fact(p113k_get(facts,"p171desc_promote"),want)

@unsafe
def p171dp_fold(old: U32, lo: U32, hi: U32, want: U32) -> Bool:
  p171dp_fold_done(p113k_scalars(p171d_promote_ops(),
    p113k_put(p113k_put(missing(),"p171desc_result",p113k_exact(lo,hi)),"p171desc_escape",p113k_exact(old,0))),want)

@unsafe
def p171dp_wrapper() -> Bool:
  +params : List<&2,NC_Binding> = [NC_Binding{1,"left",N_W64{}},NC_Binding{2,"right",N_W64{}}]
  +args : List<&2,N111Value> = [N111Local{"left"},N111Local{"right"}]
  +fallback : List<&2,P113DStmt> = [P113DCall{["p171desc_fallback"],"owner",args},P113DResult{[N111Local{"p171desc_fallback"}]}]
  p134v_function(p171d_wrapper("owner",params,"reader",[0,1]),
    P113DFunction{"$p171desc.entry.owner",params,1,False{},[
      P113DScalar{N111Call{"p171desc_roots",N111U64{},"p118_rt_borrow_scalar_safe",[p111_state(),p111_word(N111Local{"left"}),p111_word(N111Local{"right"}),p111_u32(2)]}},
      P113DScalar{N111Bin{"p171desc_roots_bool",N111U64{},"ne",N111Local{"p171desc_roots"},N111Const{0,0}}},
      P113DIf{N111Local{"p171desc_roots_bool"},[
        P113DCall{["p171desc_accepted","p171desc_result"],"reader",args},
        P113DScalar{N111Bin{"p171desc_accepted_bool",N111U64{},"ne",N111Local{"p171desc_accepted"},N111Const{0,0}}},
        P113DIf{N111Local{"p171desc_accepted_bool"},[
          P113DScalar{N111Call{"p171desc_escape",N111U64{},"p118_rt_borrow_scalar_safe",[p111_state(),p111_word(N111Local{"p171desc_result"}),p111_word(N111Const{0,0}),p111_u32(1)]}},
          P113DScalar{N111Bin{"p171desc_escape_bool",N111U64{},"ne",N111Local{"p171desc_escape"},N111Const{0,0}}},
          P113DScalar{N111Bin{"p171desc_rfc_bits",N111U64{},"and",N111Local{"p171desc_result"},N111Const{0,2147483648}}},
          P113DScalar{N111Bin{"p171desc_rfc_bool",N111U64{},"ne",N111Local{"p171desc_rfc_bits"},N111Const{0,0}}},
          P113DScalar{N111Bin{"p171desc_promote",N111U32{},"or",N111Local{"p171desc_escape_bool"},N111Local{"p171desc_rfc_bool"}}},
          P113DIf{N111Local{"p171desc_promote"},[
            P113DScalar{N111Call{"p171desc_owned",N111U64{},"p111_rt_keep",[p111_state(),p111_word(N111Local{"p171desc_result"})]}},
            P113DScalar{N111Call{"p128bs_drop_0",N111U64{},"p111_rt_sink",[p111_state(),p111_word(N111Local{"left"})]}},
            P113DScalar{N111Call{"p128bs_drop_1",N111U64{},"p111_rt_sink",[p111_state(),p111_word(N111Local{"right"})]}},
            P113DResult{[N111Local{"p171desc_owned"}]}],fallback}],fallback}],fallback}]} )

@unsafe
def p171d_promotion_controls() -> List<&2,String>:
  [p171dc_row("result-guard-keeps-before-both-drops-and-exact-fallback",p171dp_wrapper()),
   p171dc_row("old-false-zero-stays-false",p171dp_fold(0,0,0,0)),
   p171dc_row("old-true-zero-stays-true",p171dp_fold(1,0,0,1)),
   p171dc_row("low-word-all-ones-does-not-set-RFC",p171dp_fold(0,4294967295,0,0)),
   p171dc_row("bit62-and-below-do-not-set-RFC",p171dp_fold(0,4294967295,2147483647,0)),
   p171dc_row("exact-bit63-sets-RFC",p171dp_fold(0,0,2147483648,1)),
   p171dc_row("bit63-plus-low-one-sets-RFC",p171dp_fold(0,1,2147483648,1)),
   p171dc_row("all64-bits-one-sets-RFC",p171dp_fold(0,4294967295,4294967295,1)),
   p171dc_row("old-true-nonRFC-stays-true",p171dp_fold(1,4294967295,2147483647,1)),
   p171dc_row("old-true-RFC-stays-true",p171dp_fold(1,0,2147483648,1))]

@unsafe
def p171d_all_controls() -> List<&2,String>:
  nt_append(String,p171d_controls(),
    nt_append(String,p171d_constant_controls(),
      nt_append(String,p171d_scalar_if_controls(),
        nt_append(String,p171d_buffer_controls(),
          nt_append(String,p171d_sink_controls(),p171d_promotion_controls())))))
