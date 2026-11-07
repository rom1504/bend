# Native workload includes construction, freshening, every output field,
# preservation/observation of the original aliased tree, and final destruction.
# Include phase175/frontend-digest.bend; this is not a parser latency claim.

law p177fn_node:
  for choice: U32
  for +seed: U32
  for left: KTerm
  for right: KTerm
  KTerm

@unsafe
def p177fn_tree(+depth: Nat, +seed: U32) -> KTerm:
  match depth:
    case 0n:
      KTerm{"Ctr","Leaf",seed,2,
        [KTerm{"Var","x",U32.mod(seed,17),1,[],["var-note"],seed,U32.add(seed,1)},
         KLiteral{"U32",seed,"literal",seed,U32.add(seed,2)}],
        ["leaf-note"],seed,U32.add(seed,3)}
    case 1n+rest:
      p177fn_node(U32.mod(seed,3),seed,p177fn_tree(rest,U32.add(seed,1)),p177fn_tree(rest,U32.add(seed,17)))

@unsafe
def p177fn_node(choice,seed,left,right):
  match choice:
    case 0:
      KTerm{"All","x",U32.mod(seed,17),2,[left,right],["all-note"],seed,U32.add(seed,1)}
    case 1:
      KLambda{"x",U32.mod(seed,17),1,
        [KTerm{"Ctr","Pair",0,1,[left,right],["pair-note"],seed,U32.add(seed,2)}],
        ["lambda-note"],seed,U32.add(seed,1),False{}}
    case _:
      KTerm{"Let","ignored",0,2,
        [KTerm{"Bind","x",U32.mod(seed,17),1,[left],["bind-note"],seed,U32.add(seed,1)},right],
        ["let-note"],seed,U32.add(seed,2)}

@unsafe
def p177fn_observe(original: KTerm, result: FFresh, hash: U32) -> U32:
  match result:
    case FFresh{term,next}:
      p175fd_term(original,p175fd_term(term,p175fd_word(hash,next)))

@unsafe
def p177fn_one(+original: KTerm, seed: U32, hash: U32) -> U32:
  p177fn_observe(original,f_fresh_term(original,[],seed),hash)

@unsafe
def p177fn_repeat(n: Nat, +seed: U32, hash: U32) -> U32:
  match n:
    case 0n: hash
    case 1n+rest:
      p177fn_repeat(rest,U32.add(seed,7919),p177fn_one(p177fn_tree(9n,seed),seed,hash))

@unsafe
def p177fn_run() -> U32:
  p177fn_repeat(64n,1,2166136261)

def main() -> U32:
  p177fn_run()
