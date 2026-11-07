# Pair with borrow-compiler-pattern.bend for the unchanged shape generator and
# complete result schema. This executes actual canonical nq_layout_subst.
def p173blc_small() -> P173BWReport:
  +original = p173bfp_tree(4n,3)
  +replacement = p173bfp_replacement()
  P173BWReport{[
    nq_layout_subst(p173bfp_tree(5n,2),4242,replacement),
    nq_layout_subst(original,4242,replacement),
    nq_layout_subst(p173bfp_tree(5n,4),900000000,replacement),
    nq_layout_subst(KTerm{"Var","miss-with-kids",99,2,
      [KTerm{"Var","must-remain-unvisited",4242,1,[],["child-note"],21,25}],
      ["retained-parent-note"],7,9},4242,replacement),
    nq_layout_subst(KTerm{"Var","hit-with-kids",4242,0,
      [KTerm{"Var","discarded-child",4242,1,[],[],21,25}],[],17,19},4242,replacement),
    nq_layout_subst(KLiteral{"Var",4242,"not-a-variable",4,9},4242,replacement),
    nq_layout_subst(KLiteral{"arbitrary-kind",4294967295,"opaque-payload",0,0},4242,replacement),
    nq_layout_subst(KTerm{"Lam","legacy-lambda",4242,0,
      [KTerm{"Var","body-hit",4242,1,[],[],31,35}],["legacy-note"],2,6},4242,replacement),
    nq_layout_subst(KLambda{"explicit-lambda",4242,2,
      [KTerm{"Var","body-hit",4242,1,[],[],31,35}],["lambda-note"],2,6,True{}},4242,replacement),
    nq_layout_subst(KLambda{"implicit-lambda",4242,0,
      [KTerm{"Var","body-hit",4242,1,[],[],0,0}],["implicit-note"],0,0,False{}},4242,replacement),
    nq_layout_subst(KTerm{"unknown-tag","opaque-node",123,2,
      [KLiteral{"String",0,"preserve-string",8,13}],["opaque-note"],7,14},4242,replacement),
    replacement],[],original}

def p173blc_large(+seed: U32) -> P173BWReport:
  +alias = p173bfp_tree(4n,U32.add(seed,31))
  +replacement = p173bfp_replacement()
  P173BWReport{[nq_layout_subst(KTerm{"Ctr","root",seed,2,
      [alias,p173bfp_tree(12n,U32.inc(seed))],["retain-root-note"],7,12},
      p173bfp_target(U32.is_eq(U32.and(seed,1),1)),replacement),replacement],[],alias}
