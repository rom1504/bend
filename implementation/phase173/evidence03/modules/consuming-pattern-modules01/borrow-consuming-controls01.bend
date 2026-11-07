# Complete-value boundary cases for source-level consuming substitution.
# Use the original compiler independently as the semantic oracle; no duplicated
# substitution implementation or native representation assumptions appear here.
def p173bfc_result() -> P173BWReport:
  +replacement = p173bfp_replacement()
  P173BWReport{[
    f_pattern_sub(KLiteral{"Var",4242,"looks-like-variable",4,9},4242,replacement),
    f_pattern_sub(KLiteral{"arbitrary-kind",4294967295,"opaque-payload",0,0},4242,replacement),
    f_pattern_sub(KTerm{"Var","hit-with-kids",4242,0,
      [KTerm{"Var","unvisited-child",4242,1,[],["child-note"],21,25}],
      ["discarded-original-note"],17,19},4242,replacement),
    f_pattern_sub(KTerm{"Var","miss-with-kids",99,2,
      [KTerm{"Var","visited-child",4242,1,[],["child-note"],21,25}],
      ["retained-original-note"],7,9},4242,replacement),
    f_pattern_sub(KTerm{"Lam","legacy-lambda",4242,0,
      [KTerm{"Var","body-hit",4242,1,[],[],31,35}],["legacy-note"],2,6},4242,replacement),
    f_pattern_sub(KLambda{"explicit-lambda",4242,2,
      [KTerm{"Var","body-hit",4242,1,[],[],31,35}],["lambda-note"],2,6,True{}},4242,replacement),
    f_pattern_sub(KLambda{"implicit-lambda",4242,0,
      [KTerm{"Var","body-hit",4242,1,[],[],0,0}],["implicit-note"],0,0,False{}},4242,replacement),
    f_pattern_sub(KTerm{"unknown-tag","opaque-node",123,2,
      [KLiteral{"String",0,"preserve-string",8,13}],["opaque-note"],7,14},4242,replacement)],
    [],replacement}
