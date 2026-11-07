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



# Module: src/core/term.bend:52
@unsafe
def tg(
  +t: KTerm,
) -> String:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      tag
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      "Lam"
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      "Lit"



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



# Replace only semantic children; every other immutable field is preserved.

# Module: src/core/term.bend:582
@unsafe
def k_with_children(+t: KTerm, +newKids: List<&2,KTerm>) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, oldKids, removed, originBegin, originEnd}:
      KTerm{tag, name, id, quant, newKids, removed, originBegin, originEnd}

# Explicit replacement does not guess or inherit an occurrence.
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      KLambda{name, id, quant, newKids, removed, begin, end, present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      t



# Module: src/core/term.bend:594
@unsafe
def k_with_span(+t: KTerm, +newBegin: U32, +newEnd: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, oldBegin, oldEnd}:
      KTerm{tag, name, id, quant, kids, removed, newBegin, newEnd}
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      KLambda{name, id, quant, kids, removed, newBegin, newEnd, present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      KLiteral{kind, number, text, newBegin, newEnd}



# Module: src/front/lexer.bend:48
@unsafe
def f_choose(
  -A: Type,
  +b: Bool,
  yes: Unit -> A,
  no: Unit -> A,
) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})



# Module: src/front/lexer.bend:61
@unsafe
def f_eq(
  +a: String,
  +b: String,
) -> Bool:
  p88_string_eq(a, b)



# Module: src/front/parser.bend:642
@unsafe
def f_span_created(+t: KTerm, +begin: U32, +end: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, oldBegin, oldEnd}:
      f_choose(KTerm, U32.is_eq(begin, 0) || U32.is_gt(oldBegin, 0), u => t,
        u => KTerm{tag, name, id, quant, f_spans_created(kids, begin, end), removed, begin, end})
    case KLambda{name, id, quant, kids, removed, oldBegin, oldEnd, present}:
      f_choose(KTerm, U32.is_eq(begin, 0) || U32.is_gt(oldBegin, 0), u => t,
        u => KLambda{name, id, quant, f_spans_created(kids, begin, end), removed, begin, end, present})
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      f_choose(KTerm, U32.is_eq(begin, 0) || U32.is_gt(literalBegin, 0), u => t, u => k_with_span(t, begin, end))



# Module: src/front/parser.bend:654
@unsafe
def f_spans_created(+terms: List<&2,KTerm>, +begin: U32, +end: U32) -> List<&2,KTerm>:
  match terms:
    case Nil{}: Nil{}
    case Con{term, rest}: Con{f_span_created(term, begin, end), f_spans_created(rest, begin, end)}



# Module: src/front/elaborate.bend:188
@unsafe
def f_pattern_sub(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  f_choose(KTerm, f_eq(tg(t), "Var") && U32.is_eq(ix(t), id),
    u => f_pattern_value(value, kb(t), ke(t)),
    u => k_with_children(t, f_pattern_subs(ks(t), id, value)))



# Module: src/front/elaborate.bend:194
@unsafe
def f_pattern_subs(+terms: List<&2,KTerm>, +id: U32, +value: KTerm) -> List<&2,KTerm>:
  match terms:
    case Nil{}: Nil{}
    case Con{head, rest}: Con{f_pattern_sub(head, id, value), f_pattern_subs(rest, id, value)}



# Module: src/front/elaborate.bend:200
@unsafe
def f_pattern_value(+t: KTerm, +begin: U32, +end: U32) -> KTerm:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, oldBegin, oldEnd}:
      KTerm{tag, name, id, quant, f_pattern_values(kids, begin, end), removed,
        f_choose(U32, U32.is_gt(begin, 0), u => begin, u => oldBegin),
        f_choose(U32, U32.is_gt(begin, 0), u => end, u => oldEnd)}
    case KLambda{name, id, quant, kids, removed, oldBegin, oldEnd, present}:
      KLambda{name, id, quant, f_pattern_values(kids, begin, end), removed,
        f_choose(U32, U32.is_gt(begin, 0), u => begin, u => oldBegin),
        f_choose(U32, U32.is_gt(begin, 0), u => end, u => oldEnd), present}
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      f_choose(KTerm, U32.is_gt(begin, 0), u => k_with_span(t, begin, end), u => t)



# Module: src/front/elaborate.bend:214
@unsafe
def f_pattern_values(+terms: List<&2,KTerm>, +begin: U32, +end: U32) -> List<&2,KTerm>:
  match terms:
    case Nil{}: Nil{}
    case Con{head, rest}: Con{f_pattern_value(head, begin, end), f_pattern_values(rest, begin, end)}


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


# Actual compiler computations and separate literal complete-value expectations.
# No hash, equality normalizer, or generated compiler output supplies the oracle.
type P175FrontendValues is Data:
  P175FrontendValues{+located: KTerm, +substituted: KTerm, +retained: KTerm}



def p175fv_original() -> KTerm:
  KTerm{"Ctr","Pair",4,2,
    [KTerm{"Var","x",7,1,[],["variable-note"],11,12},
     KLambda{"y",8,2,[KLiteral{"U32",3,"three",0,0}],[],0,0,True{}}],
    ["root-note"],0,0}



@unsafe
def p175fv_actual() -> P175FrontendValues:
  +original = p175fv_original()
  P175FrontendValues{
    f_span_created(original,20,30),
    f_pattern_sub(original,7,KLiteral{"U32",99,"replacement",1,2}),
    original}



def p175fv_expected() -> P175FrontendValues:
  P175FrontendValues{
    KTerm{"Ctr","Pair",4,2,
      [KTerm{"Var","x",7,1,[],["variable-note"],11,12},
       KLambda{"y",8,2,[KLiteral{"U32",3,"three",20,30}],[],20,30,True{}}],
      ["root-note"],20,30},
    KTerm{"Ctr","Pair",4,2,
      [KLiteral{"U32",99,"replacement",11,12},
       KLambda{"y",8,2,[KLiteral{"U32",3,"three",0,0}],[],0,0,True{}}],
      ["root-note"],0,0},
    KTerm{"Ctr","Pair",4,2,
      [KTerm{"Var","x",7,1,[],["variable-note"],11,12},
       KLambda{"y",8,2,[KLiteral{"U32",3,"three",0,0}],[],0,0,True{}}],
      ["root-note"],0,0}}
