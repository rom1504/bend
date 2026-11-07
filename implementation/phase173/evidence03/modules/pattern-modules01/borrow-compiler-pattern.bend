# Actual canonical f_pattern_sub on owned, shared, present and absent paths.
# prepare-workload.py preserves the canonical function and dependencies exactly.
type P173BWReport is Data:
  P173BWReport{+located: List<&2,KTerm>, +shared: List<&2,GResult>, +replaced: KTerm}

def p173bfp_leaf_kind(kind: U32, +seed: U32) -> KTerm:
  match kind:
    case 0: KTerm{"Var","needle",4242,1,[],["retain-var-note"],seed,U32.add(seed,2)}
    case 1: KLiteral{"U32",seed,U32.show(seed),seed,U32.add(seed,2)}
    case _: KTerm{"Var","other",U32.add(seed,10000),2,[],["retain-other-note"],seed,U32.add(seed,2)}

@unsafe
def p173bfp_tree(+depth: Nat, +seed: U32) -> KTerm:
  match depth:
    case 0n: p173bfp_leaf_kind(U32.and(seed,3),seed)
    case 1n+p:
      KTerm{"Ctr",U32.show(seed),seed,U32.and(seed,1),
        [p173bfp_tree(p,U32.mul(seed,2)),p173bfp_tree(p,U32.inc(U32.mul(seed,2)))],
        ["retain-node-note"],seed,U32.inc(seed)}

def p173bfp_replacement() -> KTerm:
  KTerm{"Ctr","replacement",77,2,
    [KLiteral{"String",0,"payload",0,0},
      KLambda{"bound",88,0,[KTerm{"Var","bound",88,0,[],["binder-note"],0,0}],
        ["lambda-note"],0,0,True{}}],["replacement-note"],0,0}

# Unique input; separately shared input; absent ID; unchanged replacement;
# complete retained original alias. Every value is observed independently.
def p173bfp_small() -> P173BWReport:
  +original = p173bfp_tree(4n,3)
  +replacement = p173bfp_replacement()
  P173BWReport{[
    f_pattern_sub(p173bfp_tree(5n,2),4242,replacement),
    f_pattern_sub(original,4242,replacement),
    f_pattern_sub(p173bfp_tree(5n,4),900000000,replacement),
    replacement],[],original}

# 8,223 input nodes, including a small retained shared subtree. Even iteration
# seeds choose a missing ID; odd seeds replace one quarter of literal leaves.
# Original child lists remain genuinely live under canonical f_pattern_sub.
def p173bfp_target(odd: Bool) -> U32:
  match odd:
    case False{}: 900000000
    case True{}: 4242

def p173bfp_large(+seed: U32) -> P173BWReport:
  +alias = p173bfp_tree(4n,U32.add(seed,31))
  +replacement = p173bfp_replacement()
  P173BWReport{[f_pattern_sub(KTerm{"Ctr","root",seed,2,
      [alias,p173bfp_tree(12n,U32.inc(seed))],["retain-root-note"],7,12},
      p173bfp_target(U32.is_eq(U32.and(seed,1),1)),replacement),replacement],[],alias}
