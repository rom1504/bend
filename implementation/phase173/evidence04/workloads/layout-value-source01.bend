import Base


# Phase88 native-host-only consuming string helpers.
# Consuming compiler-host helpers. No reconstructed input pair or host closure.
# Deliberately safe: checked ownership must suffice without @unsafe.
def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))



def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same



def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)



# Generated source assembly. Edit the individual src modules.

# Module: src/core/term.bend:25
type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}



# Module: src/core/graph.bend:6
type GHeap is Data:
  GEmpty{}
  GNode{+value: KTerm, +left: GHeap, +right: GHeap}



# Module: src/core/graph.bend:10
type GState is Data:
  GState{+heap: GHeap, +next: U32}



# Module: src/core/graph.bend:13
type GResult is Data:
  GResult{+state: GState, +term: KTerm}



# Module: src/core/term.bend:64
@unsafe
def nm(
  +t: KTerm,
) -> String:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      name
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      name
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      kind



# Module: src/core/term.bend:76
@unsafe
def ix(
  +t: KTerm,
) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      id
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      id
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      0



# Module: src/core/term.bend:88
@unsafe
def qt(
  +t: KTerm,
) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      quant
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      quant
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      0



# Module: src/core/term.bend:100
@unsafe
def ks(
  +t: KTerm,
) -> List<&2, KTerm>:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      kids
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      kids
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      Nil{}



# Module: src/core/term.bend:112
@unsafe
def rm(
  +t: KTerm,
) -> List<&2, String>:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      removed
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      removed
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      Nil{}



# Source ranges are non-semantic metadata. Zero/zero is absent; positive
# inclusive-start/exclusive-end coordinates belong to one source interval.

# Module: src/core/term.bend:557
@unsafe
def kb(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      originBegin
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      begin
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      literalBegin



# Module: src/core/term.bend:567
@unsafe
def ke(+t: KTerm) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      originEnd
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      end
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      literalEnd



# Field-changing structural rebuilds retain the input variant and syntax fact.

# Module: src/core/term.bend:652
@unsafe
def k_rebuild(+t: KTerm, +name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +begin: U32, +end: U32) -> KTerm:
  match t:
    case KTerm{tag, oldName, oldId, oldQuant, oldKids, oldRemoved, oldBegin, oldEnd}:
      KTerm{tag, name, id, quant, kids, removed, begin, end}
    case KLambda{oldName, oldId, oldQuant, oldKids, oldRemoved, oldBegin, oldEnd, present}:
      KLambda{name, id, quant, kids, removed, begin, end, present}
    case KLiteral{kind, number, text, oldBegin, oldEnd}: t



# Module: src/back/native/text.bend:2
@unsafe
def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})



# Ordinary subst invokes core_rebuild, which can beta-reduce applications.
# This substitution only rebuilds syntax and never evaluates a substituted term.

# Module: src/back/native/product-layout.bend:114
@unsafe
def nq_layout_subst(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm, p98_tag_eq(t, "Var"),
    u => nt_choose(KTerm, U32.is_eq(ix(t), id), v => value, v => t),
    u => k_rebuild(t, nm(t), ix(t), qt(t), nq_layout_subst_list(ks(t), id, value), rm(t), kb(t), ke(t)))



# Module: src/back/native/product-layout.bend:120
@unsafe
def nq_layout_subst_list(ts: List<&2, KTerm>, +id: U32, +value: KTerm) -> List<&2, KTerm>:
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{nq_layout_subst(h, id, value), nq_layout_subst_list(rest, id, value)}



# Phase98 fused scalar tag observation.
# Requires the production KTerm datatype and exact held equality/walker.
# Only the generic tag uses the borrowed walker; literals use held equality.
# The term remains live while the selected tag is compared.
def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      p88_string_eq_go(tag, key, True{})
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      p88_string_eq("Lam", key)
    case KLiteral{kind, number, text, begin, end}:
      p88_string_eq("Lit", key)



def p98_tag_eq_finish(same: Bool, term: KTerm, key: String) -> Bool:
  same



def p98_tag_eq(+term: KTerm, +key: String) -> Bool:
  p98_tag_eq_finish(p98_tag_eq_read(term, key), term, key)


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


def main() -> P173BWReport:
  p173blc_small()
