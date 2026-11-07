# Extracted complete substitution workload. It is not a compiler speed proxy.
# Include phase175/frontend-digest.bend for its exact all-field digest definition.
def p177sw_leaf(kind: U32, +seed: U32) -> KTerm:
  match kind:
    case 0: KTerm{"Var","needle",4242,1,[],["var-note"],seed,U32.inc(seed)}
    case 1: KLiteral{"U32",seed,"literal",seed,U32.inc(seed)}
    case _: KTerm{"Var","other",U32.add(seed,10000),2,[],["other-note"],seed,U32.inc(seed)}

def p177sw_node(kind: U32, left: KTerm, right: KTerm, +seed: U32) -> KTerm:
  match kind:
    case 0: KTerm{"Ctr","Pair",seed,2,[left,right],["node-note"],seed,U32.inc(seed)}
    case 1: KTerm{"App","discarded",seed,1,
      [KTerm{"Ref","function",0,0,[],[],seed,U32.inc(seed)},
       KTerm{"Ctr","Pair",seed,2,[left,right],["node-note"],seed,U32.inc(seed)}],
      ["discarded"],seed,U32.inc(seed)}
    case 2: KLambda{"bound",U32.add(seed,500000),1,
      [KTerm{"Ctr","Pair",seed,2,[left,right],["node-note"],seed,U32.inc(seed)}],
      ["lambda-note"],seed,U32.inc(seed),False{}}
    case _: KTerm{"All","binder",U32.add(seed,700000),2,[left,right],["all-note"],seed,U32.inc(seed)}

@unsafe
def p177sw_tree(+depth: Nat, +seed: U32) -> KTerm:
  match depth:
    case 0n: p177sw_leaf(U32.and(seed,3),seed)
    case 1n+p:
      p177sw_node(U32.and(seed,3),p177sw_tree(p,U32.mul(seed,2)),
        p177sw_tree(p,U32.inc(U32.mul(seed,2))),seed)

def p177sw_replacement() -> KTerm:
  KTerm{"Ctr","replacement",77,2,
    [KLiteral{"String",0,"payload",1,2},
     KLambda{"bound",88,0,[KTerm{"Var","bound",88,0,[],["binder-note"],3,4}],
       ["lambda-note"],3,5,True{}}],["replacement-note"],1,6}

def p177sw_target(odd: Bool) -> U32:
  match odd:
    case False{}: 900000000
    case True{}: 4242

# Top-level aliases survive until after transformed output is observed. The
# varying target alternates true misses with hits; Apps normalize in both cases.
@unsafe
def p177sw_report(+seed: U32, hash: U32) -> U32:
  +alias = p177sw_tree(4n,U32.add(seed,31))
  +replacement = p177sw_replacement()
  result = subst(KTerm{"Ctr","root",seed,2,[alias,p177sw_tree(12n,U32.inc(seed))],
    ["root-note"],7,12},p177sw_target(U32.is_eq(U32.and(seed,1),1)),replacement)
  p175fd_term(alias,p175fd_term(replacement,p175fd_term(result,hash)))

@unsafe
def p177sw_repeat(n: Nat, +seed: U32, hash: U32) -> U32:
  match n:
    case 0n: hash
    case 1n+p: p177sw_repeat(p,U32.add(seed,7919),p177sw_report(seed,hash))

@unsafe
def p177sw_run() -> U32:
  p177sw_repeat(64n,1,2166136261)

def main() -> U32:
  p177sw_run()
