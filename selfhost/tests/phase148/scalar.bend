# Compact scalar facts. Each name owns16 scalar cells:
# present,bits,exact,lo,hi,epoch; relation(present,subject,subjectEpoch,
# ownerEpoch,truth); predicate(present,root,rootEpoch,ownerEpoch,invert).
# The instruction/value arrays stay compact throughout this pass. P113KFact
# is only the unchanged small arithmetic result, never an IR/fact-map wrapper.
type P148OOrigin is Data:
  P148OOrigin{+valid: Bool, +subject: U32, +epoch: U32, +truth: U32}

type P148OHistory is Data:
  P148OHistory{+relation: P148OOrigin, +predicate: P148OOrigin, +comparison: Bool}

type P148ODiamond is Data:
  P148ODiamond{+valid: Bool, +name: U32, +invert: U32}

type P148OValue is Type:
  P148OValue{tape: P148Tape, +ref: U32}

type P148OScan is Type:
  P148OScan{tape: P148Tape, facts: Array<U32>, +terminal: Bool}

@unsafe
def p148o_read(+words: Array<U32>, at: U32) -> U32:
  p148w_get(words, at)


@unsafe
def p148o_value_word(+values: Array<U32>, at: U32) -> U32:
  p148w_get(values, at)


@unsafe
def p148o_name(+names: Array<String>, id: U32) -> String:
  p148n_get(names, id)


@unsafe
def p148o_write(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, at: U32, value: U32) -> P148Tape:
  P148Tape{p148w_set(words, at, value),values,names,used,valueUsed,nameUsed}


@unsafe
def p148o_fword(+facts: Array<U32>, id: U32, field: U32) -> U32:
  p148w_get(facts, U32.add(U32.mul(id, 16), field))


@unsafe
def p148o_fwrite(facts: Array<U32>, id: U32, field: U32, value: U32) -> Array<U32>:
  p148w_set(facts, U32.add(U32.mul(id, 16), field), value)


@unsafe
def p148o_version(+facts: Array<U32>, id: U32) -> U32:
  p148o_fword(facts, id, 5)


@unsafe
def p148o_get(+facts: Array<U32>, +id: U32) -> P113KFact:
  nt_choose(P113KFact, U32.is_eq(p148o_fword(facts, id, 0), 1), u => P113KFact{p148o_fword(facts, id, 1),U32.is_eq(p148o_fword(facts, id, 2), 1),p148o_fword(facts, id, 3),p148o_fword(facts, id, 4)}, u => p113k_bound(64))


@unsafe
def p148o_put(facts: Array<U32>, +id: U32, fact: P113KFact) -> Array<U32>:
  p148o_put_result(id, fact, Array.get(U32, facts, U32.add(U32.mul(id, 16), 5)))


@unsafe
def p148o_put_result(+id: U32, fact: P113KFact, result: Array<U32> & U32) -> Array<U32>:
  match fact result:
    case P113KFact{bits,exact,lo,hi} Tuple{facts,epoch}:
      p148o_fwrite(p148o_fwrite(p148o_fwrite(p148o_fwrite(p148o_fwrite(p148o_fwrite(facts, id, 0, 1), id, 1, bits), id, 2, Bool.to_u32(exact)), id, 3, lo), id, 4, hi), id, 5, U32.inc(epoch))


@unsafe
def p148o_fact(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, +facts: Array<U32>) -> P113KFact:
  p148o_fact_kind(words, values, names, used, valueUsed, nameUsed, ref, facts, p148o_value_word(values, ref))


@unsafe
def p148o_fact_kind(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, +facts: Array<U32>, kind: U32) -> P113KFact:
  match kind:
    case 1: p148o_get(facts, p148o_value_word(values, U32.inc(ref)))
    case 2: p113k_exact(p148o_value_word(values, U32.inc(ref)), p148o_value_word(values, U32.add(ref, 2)))
    case _: p113k_bound(64)


@unsafe
def p148o_append(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, kind: U32, lo: U32, hi: U32) -> P148OValue:
  P148OValue{P148Tape{words,
    p148w_set(p148w_set(p148w_set(values, valueUsed, kind), U32.inc(valueUsed), lo), U32.add(valueUsed, 2), hi),
    names,used,U32.add(valueUsed, 3),nameUsed},valueUsed}


@unsafe
def p148o_replace_fact(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, fact: P113KFact) -> P148OValue:
  match fact:
    case P113KFact{bits,+exact,lo,hi}:
      nt_choose(P148OValue, exact, u => p148o_append(words, values, names, used, valueUsed, nameUsed, 2, lo, hi), u => P148OValue{P148Tape{words,values,names,used,valueUsed,nameUsed},ref})


@unsafe
def p148o_replace(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, +facts: Array<U32>) -> P148OValue:
  # Existing constants already express their fact; do not append another copy.
  nt_choose(P148OValue, U32.is_eq(p148o_value_word(values, ref), 2), u => P148OValue{P148Tape{words,values,names,used,valueUsed,nameUsed},ref}, u => p148o_replace_fact(words, values, names, used, valueUsed, nameUsed, ref, p148o_fact(words, values, names, used, valueUsed, nameUsed, ref, facts)))


@unsafe
def p148o_replace_at(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +facts: Array<U32>) -> P148Tape:
  p148o_replace_written(at, p148o_replace(words, values, names, used, valueUsed, nameUsed, p148o_read(words, at), facts))


@unsafe
def p148o_replace_written(at: U32, value: P148OValue) -> P148Tape:
  match value:
    case P148OValue{P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed},ref}: p148o_write(words, values, names, used, valueUsed, nameUsed, at, ref)


@unsafe
def p148o_width(typ: U32) -> U32:
  nt_choose(U32, U32.is_eq(typ, 1), u => 32, u => 64)


@unsafe
def p148o_bin_fact(+typ: U32, +op: String, left: P113KFact, right: P113KFact) -> P113KFact:
  +width = p148o_width(typ)
  p113k_limit(p113k_binary(op, p113k_limit(left, width), p113k_limit(right, width), width), width)


@unsafe
def p148o_origin_none() -> P148OOrigin:
  P148OOrigin{False{},0,0,0}


@unsafe
def p148o_origin(+facts: Array<U32>, +id: U32, +base: U32) -> P148OOrigin:
  +subject = p148o_fword(facts, id, U32.inc(base))
  +epoch = p148o_fword(facts, id, U32.add(base, 2))
  P148OOrigin{U32.is_eq(p148o_fword(facts, id, base), 1) &&
    U32.is_eq(epoch, p148o_version(facts, subject)) &&
    U32.is_eq(p148o_fword(facts, id, U32.add(base, 3)), p148o_version(facts, id)),
    subject,epoch,p148o_fword(facts, id, U32.add(base, 4))}


@unsafe
def p148o_origin_value(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +ref: U32, +facts: Array<U32>, +base: U32) -> P148OOrigin:
  nt_choose(P148OOrigin, U32.is_eq(p148o_value_word(values, ref), 1), u => p148o_origin(facts, p148o_value_word(values, U32.inc(ref)), base), u => p148o_origin_none())


@unsafe
def p148o_origin_invert(origin: P148OOrigin, invert: U32) -> P148OOrigin:
  match origin:
    case P148OOrigin{valid,subject,epoch,truth}: P148OOrigin{valid,subject,epoch,U32.xor(truth, invert)}


@unsafe
def p148o_origin_store(facts: Array<U32>, +id: U32, +base: U32, origin: P148OOrigin) -> Array<U32>:
  p148o_origin_stored(id, base, origin, Array.get(U32, facts, U32.add(U32.mul(id, 16), 5)))


@unsafe
def p148o_origin_stored(+id: U32, +base: U32, origin: P148OOrigin, result: Array<U32> & U32) -> Array<U32>:
  match origin result:
    case P148OOrigin{+valid,subject,epoch,truth} Tuple{+facts,ownerEpoch}:
      nt_choose(Array<U32>, valid, u =>
        p148o_fwrite(p148o_fwrite(p148o_fwrite(p148o_fwrite(p148o_fwrite(facts, id, base, 1), id, U32.inc(base), subject), id, U32.add(base, 2), epoch), id, U32.add(base, 3), ownerEpoch), id, U32.add(base, 4), truth), u => facts)


@unsafe
def p148o_copy_predicate(+facts: Array<U32>, +id: U32, origin: P148OOrigin) -> Array<U32>:
  match origin:
    case P148OOrigin{+valid,+subject,+epoch,+truth}:
      nt_choose(Array<U32>, valid && U32.is_eq(epoch, p148o_version(facts, subject)), u => p148o_origin_store(facts, id, 11, P148OOrigin{True{},subject,epoch,truth}), u => facts)


@unsafe
def p148o_record_done(+facts: Array<U32>, +id: U32, history: P148OHistory) -> Array<U32>:
  match history:
    case P148OHistory{relation,predicate,+comparison}:
      p148o_record_predicate(p148o_origin_store(facts, id, 6, relation), id, predicate, comparison)


@unsafe
def p148o_record_predicate(+facts: Array<U32>, +id: U32, predicate: P148OOrigin, comparison: Bool) -> Array<U32>:
  nt_choose(Array<U32>, comparison, u => p148o_origin_store(facts, id, 11, P148OOrigin{True{},id,p148o_version(facts, id),0}), u => p148o_copy_predicate(facts, id, predicate))


@unsafe
def p148o_relation_compare(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +left: U32, +right: U32, +facts: Array<U32>, +op: String, lf: P113KFact, rf: P113KFact) -> P148OOrigin:
  match lf rf:
    case P113KFact{lb,+le,ll,lh} P113KFact{rb,+re,+rl,+rh}:
      +subject = p148o_value_word(values, U32.inc(left))
      nt_choose(P148OOrigin, U32.is_eq(p148o_value_word(values, left), 1) && Bool.not(le) && re &&
        (String.eq(op, "eq") || String.eq(op, "ne")) && U32.is_eq(rh, 0) && U32.is_le(rl, 1), u => nt_choose(P148OOrigin, U32.is_le(p113k_bits_of(p148o_get(facts, subject)), 1), v => P148OOrigin{True{},subject,p148o_version(facts, subject),U32.xor(rl, Bool.to_u32(String.eq(op, "ne")))}, v => p148o_origin_none()), u => p148o_origin_none())


@unsafe
def p148o_relation_bin(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +left: U32, +right: U32, +facts: Array<U32>, +op: String, +lf: P113KFact, +rf: P113KFact) -> P148OOrigin:
  +copy = String.eq(op, "or") || String.eq(op, "xor") || String.eq(op, "add")
  nt_choose(P148OOrigin, copy && p113k_zero(rf), u => p148o_origin_value(words, values, names, used, valueUsed, nameUsed, left, facts, 6), u =>
  nt_choose(P148OOrigin, copy && p113k_zero(lf), u => p148o_origin_value(words, values, names, used, valueUsed, nameUsed, right, facts, 6), u =>
  nt_choose(P148OOrigin, String.eq(op, "xor") && p113l_exact_one(rf), u => p148o_origin_invert(p148o_origin_value(words, values, names, used, valueUsed, nameUsed, left, facts, 6), 1), u => p148o_relation_compare(words, values, names, used, valueUsed, nameUsed, left, right, facts, op, lf, rf))))


@unsafe
def p148o_predicate_test(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +left: U32, +right: U32, +facts: Array<U32>, +op: String) -> P148OOrigin:
  +lo = p148o_value_word(values, U32.inc(right))
  nt_choose(P148OOrigin, (String.eq(op, "eq") || String.eq(op, "ne")) &&
    U32.is_eq(p148o_value_word(values, left), 1) && U32.is_eq(p148o_value_word(values, right), 2) &&
    U32.is_eq(p148o_value_word(values, U32.add(right, 2)), 0) && U32.is_le(lo, 1), u => p148o_origin_invert(p148o_origin_value(words, values, names, used, valueUsed, nameUsed, left, facts, 11), U32.xor(lo, Bool.to_u32(String.eq(op, "eq")))), u => p148o_origin_none())


@unsafe
def p148o_predicate_pick(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +left: U32, +right: U32, +facts: Array<U32>, +op: String) -> P148OOrigin:
  p148o_predicate_forward(words, values, names, used, valueUsed, nameUsed, left, right, facts, op, p148o_predicate_test(words, values, names, used, valueUsed, nameUsed, left, right, facts, op))


@unsafe
def p148o_predicate_forward(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +left: U32, +right: U32, +facts: Array<U32>, +op: String, +forward: P148OOrigin) -> P148OOrigin:
  match forward:
    case P148OOrigin{valid,subject,epoch,truth}:
      nt_choose(P148OOrigin, valid, u => forward, u => p148o_predicate_test(words, values, names, used, valueUsed, nameUsed, right, left, facts, op))


@unsafe
def p148o_set_ref(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, typ: U32, ref: U32) -> P148Tape:
  p148o_write_affine(p148o_write(words, values, names, used, valueUsed, nameUsed, at, U32.add(1, U32.mul(typ, 256))), U32.add(at, 2), ref)


@unsafe
def p148o_set_value(at: U32, typ: U32, value: P148OValue) -> P148Tape:
  match value:
    case P148OValue{P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed},ref}: p148o_set_ref(words, values, names, used, valueUsed, nameUsed, at, typ, ref)


@unsafe
def p148o_bin_regular(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +typ: U32, +op: String, +left: U32, +right: U32, +facts: Array<U32>, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> P148Tape:
  match answer:
    case P113KFact{bits,+exact,lo,hi}:
      nt_choose(P148Tape, exact, u => p148o_set_value(at, nt_choose(U32, p111v_comparison(op), v => 1, v => typ), p148o_append(words, values, names, used, valueUsed, nameUsed, 2, lo, hi)), u =>
      nt_choose(P148Tape, (String.eq(op, "and") && p113k_mask_covers(p113k_bits_of(lf), rf)) ||
        ((String.eq(op, "or") || String.eq(op, "xor") || String.eq(op, "add") || String.eq(op, "sub")) && p113k_zero(rf)), u => p148o_set_value(at, typ, p148o_replace(words, values, names, used, valueUsed, nameUsed, left, facts)), u =>
      nt_choose(P148Tape, (String.eq(op, "and") && p113k_mask_covers(p113k_bits_of(rf), lf)) ||
        ((String.eq(op, "or") || String.eq(op, "xor") || String.eq(op, "add")) && p113k_zero(lf)), u => p148o_set_value(at, typ, p148o_replace(words, values, names, used, valueUsed, nameUsed, right, facts)), u => p148o_replace_at_affine(p148o_replace_at(words, values, names, used, valueUsed, nameUsed, U32.add(at, 2), facts), U32.add(at, 3), facts))))


@unsafe
def p148o_bin_predicate(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, root: U32, +invert: U32) -> P148Tape:
  p148o_bin_predicate_value(at, invert, p148o_append(words, values, names, used, valueUsed, nameUsed, 1, root, 0))


@unsafe
def p148o_bin_predicate_value(+at: U32, +invert: U32, value: P148OValue) -> P148Tape:
  match value:
    case P148OValue{P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed},+ref}:
      nt_choose(P148Tape, U32.is_eq(invert, 0), u => p148o_set_ref(words, values, names, used, valueUsed, nameUsed, at, 1, ref), u =>
        p148o_bin_xor(at, ref, p148o_append(words, values, names, used, valueUsed, nameUsed, 2, 1, 0)))


@unsafe
def p148o_bin_xor(+at: U32, ref: U32, value: P148OValue) -> P148Tape:
  match value:
    case P148OValue{P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed},one}:
      p148o_write_affine(p148o_write_affine(p148o_write_affine(p148o_write(words, values, names, used, valueUsed, nameUsed, at, 258), U32.add(at, 2), ref), U32.add(at, 3), one), U32.add(at, 4), 2)


@unsafe
def p148o_bin_rewrite(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +typ: U32, +op: String, +left: U32, +right: U32, +facts: Array<U32>, +lf: P113KFact, +rf: P113KFact, +answer: P113KFact, predicate: P148OOrigin) -> P148Tape:
  match predicate:
    case P148OOrigin{valid,root,epoch,invert}:
      nt_choose(P148Tape, valid, u => p148o_bin_predicate(words, values, names, used, valueUsed, nameUsed, at, root, invert), u => p148o_bin_regular(words, values, names, used, valueUsed, nameUsed, at, typ, op, left, right, facts, lf, rf, answer))


@unsafe
def p148o_bin_finish(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, facts: Array<U32>, +id: U32, answer: P113KFact, history: P148OHistory) -> P148OScan:
  P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},p148o_record_done(p148o_put(facts, id, answer), id, history),False{}}


@unsafe
def p148o_bin_ready(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +facts: Array<U32>, +at: U32, +id: U32, +typ: U32, +op: String, +left: U32, +right: U32, +lf: P113KFact, +rf: P113KFact, +answer: P113KFact, history: P148OHistory, predicate: P148OOrigin) -> P148OScan:
  p148o_bin_finish_affine(p148o_bin_rewrite(words, values, names, used, valueUsed, nameUsed, at, typ, op, left, right, facts, lf, rf, answer, predicate), facts, id, answer, history)


@unsafe
def p148o_bin_facts(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +facts: Array<U32>, +at: U32, +id: U32, +typ: U32, +op: String, +left: U32, +right: U32, +lf: P113KFact, +rf: P113KFact) -> P148OScan:
  p148o_bin_ready(words, values, names, used, valueUsed, nameUsed, facts, at, id, typ, op, left, right, lf, rf, p148o_bin_fact(typ, op, lf, rf), P148OHistory{p148o_relation_bin(words, values, names, used, valueUsed, nameUsed, left, right, facts, op, lf, rf),p148o_origin_none(),p111v_comparison(op)}, p148o_predicate_pick(words, values, names, used, valueUsed, nameUsed, left, right, facts, op))


@unsafe
def p148o_set_finish(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, facts: Array<U32>, +id: U32, fact: P113KFact, history: P148OHistory) -> P148OScan:
  P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},p148o_record_done(p148o_put(facts, id, fact), id, history),False{}}


@unsafe
def p148o_set_ready(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +facts: Array<U32>, +at: U32, +id: U32, +typ: U32, +ref: U32, history: P148OHistory) -> P148OScan:
  p148o_set_finish_affine(p148o_replace_at(words, values, names, used, valueUsed, nameUsed, U32.add(at, 2), facts), facts, id, p113k_limit(p148o_fact(words, values, names, used, valueUsed, nameUsed, ref, facts), p148o_width(typ)), history)


@unsafe
def p148o_payload(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +facts: Array<U32>, +at: U32, +count: U32, +typed: Bool) -> P148Tape:
  nt_choose(P148Tape, U32.is_eq(count, 0), u => P148Tape{words,values,names,used,valueUsed,nameUsed}, u =>
    p148o_payload_affine(nt_choose(P148Tape, typed, v => nt_choose(P148Tape, U32.is_eq(p148o_read(words, at), 3), w => P148Tape{words,values,names,used,valueUsed,nameUsed}, w => p148o_replace_at(words, values, names, used, valueUsed, nameUsed, U32.inc(at), facts)), v => p148o_replace_at(words, values, names, used, valueUsed, nameUsed, at, facts)), facts, U32.add(at, nt_choose(U32, typed, v => 2, v => 1)), U32.sub(count, 1), typed))


@unsafe
def p148o_kill(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +facts: Array<U32>, +at: U32, +count: U32) -> Array<U32>:
  nt_choose(Array<U32>, U32.is_eq(count, 0), u => facts, u =>
    p148o_kill(words, values, names, used, valueUsed, nameUsed, p148o_put(facts, p148o_read(words, at), p113k_bound(64)), U32.inc(at), U32.sub(count, 1)))


@unsafe
def p148o_join(+left: Array<U32>, +right: Array<U32>, +out: Array<U32>, +at: U32, +count: U32) -> Array<U32>:
  nt_choose(Array<U32>, U32.is_eq(at, count), u => out, u =>
    p148o_join(left, right, nt_choose(Array<U32>, U32.is_eq(p148o_fword(left, at, 0), 1) && U32.is_eq(p148o_fword(right, at, 0), 1), v => p148o_put(out, at, p113k_join_fact(p148o_get(left, at), p148o_get(right, at))), v => out), U32.inc(at), count))


@unsafe
def p148o_assume_origin(+facts: Array<U32>, +truth: Bool, origin: P148OOrigin) -> Array<U32>:
  match origin:
    case P148OOrigin{+valid,+subject,epoch,+value}:
      nt_choose(Array<U32>, valid && U32.is_le(p113k_bits_of(p148o_get(facts, subject)), 1), u => p148o_put(facts, subject, p113k_exact(U32.xor(value, Bool.to_u32(Bool.not(truth))), 0)), u => facts)


@unsafe
def p148o_assume(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +condition: U32, +facts: Array<U32>, truth: Bool) -> Array<U32>:
  p148o_assume_origin(facts, truth, p148o_origin_value(words, values, names, used, valueUsed, nameUsed, condition, facts, 6))


@unsafe
def p148o_diamond_values(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +yes: U32, +no: U32, +left: U32, +right: U32) -> P148ODiamond:
  +lo = p148o_value_word(values, U32.inc(left))
  +ro = p148o_value_word(values, U32.inc(right))
  P148ODiamond{U32.is_eq(p148o_read(words, yes), 513) && U32.is_eq(p148o_read(words, no), 513) &&
    U32.is_eq(p148o_read(words, U32.inc(yes)), p148o_read(words, U32.inc(no))) &&
    U32.is_eq(p148o_value_word(values, left), 2) && U32.is_eq(p148o_value_word(values, right), 2) &&
    U32.is_eq(p148o_value_word(values, U32.add(left, 2)), 0) && U32.is_eq(p148o_value_word(values, U32.add(right, 2)), 0) &&
    ((U32.is_eq(lo, 1) && U32.is_eq(ro, 0)) || (U32.is_eq(lo, 0) && U32.is_eq(ro, 1))),
    p148o_read(words, U32.inc(yes)),Bool.to_u32(U32.is_eq(lo, 0))}


@unsafe
def p148o_diamond(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +yes: U32, +no: U32, +end: U32) -> P148ODiamond:
  nt_choose(P148ODiamond, U32.is_lt(yes, no) && U32.is_lt(no, end), u =>
    nt_choose(P148ODiamond, U32.is_eq(p148o_read(words, U32.add(yes, 7)), no) && U32.is_eq(p148o_read(words, U32.add(no, 7)), end), v => p148o_diamond_values(words, values, names, used, valueUsed, nameUsed, yes, no, p148o_read(words, U32.add(yes, 2)), p148o_read(words, U32.add(no, 2))), v => P148ODiamond{False{},0,0}), u => P148ODiamond{False{},0,0})


@unsafe
def p148o_diamond_done(scan: P148OScan, diamond: P148ODiamond, origin: P148OOrigin) -> P148OScan:
  match scan diamond origin:
    case P148OScan{P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed},+facts,terminal} P148ODiamond{+valid,+id,+invert} P148OOrigin{+found,+root,epoch,+value}:
      P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},nt_choose(Array<U32>, valid && found && U32.is_ne(id, root), u => p148o_origin_store(facts, id, 11, P148OOrigin{True{},root,p148o_version(facts, root),U32.xor(value, invert)}), u => facts),terminal}


@unsafe
def p148o_branch_join(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +yesFacts: Array<U32>, +noFacts: Array<U32>, +yesTerminal: Bool, +noTerminal: Bool, +direct: Bool) -> P148OScan:
  P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},
    nt_choose(Array<U32>, direct && yesTerminal, u => noFacts, u =>
      nt_choose(Array<U32>, direct && noTerminal, v => yesFacts, v => p148o_join(yesFacts, noFacts, p148w_new(U32.mul(nameUsed, 16)), 0, nameUsed))),
    direct && yesTerminal && noTerminal}


@unsafe
def p148o_branch_no(yesFacts: Array<U32>, yesTerminal: Bool, direct: Bool, scan: P148OScan) -> P148OScan:
  match scan:
    case P148OScan{P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed},noFacts,noTerminal}: p148o_branch_join(words, values, names, used, valueUsed, nameUsed, yesFacts, noFacts, yesTerminal, noTerminal, direct)


@unsafe
def p148o_branch_yes(scan: P148OScan, +noFacts: Array<U32>, +condition: U32, no: U32, end: U32, direct: Bool) -> P148OScan:
  match scan:
    case P148OScan{P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed},yesFacts,yesTerminal}:
      p148o_branch_no(yesFacts, yesTerminal, direct, p148o_body(no, end, words, values, names, used, valueUsed, nameUsed, p148o_assume(words, values, names, used, valueUsed, nameUsed, condition, noFacts, False{})))


@unsafe
def p148o_branch_both(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, facts: Array<U32>, +condition: U32, yes: U32, +no: U32, +end: U32, direct: Bool) -> P148OScan:
  p148o_branch_cloned(words, values, names, used, valueUsed, nameUsed, condition, yes, no, end, direct, p148w_clone(facts))


@unsafe
def p148o_branch_cloned(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +condition: U32, yes: U32, +no: U32, +end: U32, direct: Bool, branches: Array<U32> & Array<U32>) -> P148OScan:
  (yesFacts,noFacts) = branches
  p148o_branch_yes(p148o_body(yes, no, words, values, names, used, valueUsed, nameUsed, p148o_assume(words, values, names, used, valueUsed, nameUsed, condition, yesFacts, True{})), noFacts, condition, no, end, direct)


@unsafe
def p148o_splice(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +at: U32, +first: U32, +end: U32, facts: Array<U32>) -> P148OScan:
  p148o_body_affine(first, end, p148o_write_affine(p148o_write_affine(p148o_write(words, values, names, used, valueUsed, nameUsed, at, 14), U32.add(at, 4), first), U32.add(at, 5), end), facts)


@unsafe
def p148o_branch_fact(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +facts: Array<U32>, +at: U32, +condition: U32, +yes: U32, +no: U32, +end: U32, +direct: Bool, fact: P113KFact) -> P148OScan:
  match fact:
    case P113KFact{bits,exact,+lo,hi}:
      nt_choose(P148OScan, exact, u => nt_choose(P148OScan, U32.is_eq(lo, 0), v => p148o_splice(words, values, names, used, valueUsed, nameUsed, at, no, end, facts), v => p148o_splice(words, values, names, used, valueUsed, nameUsed, at, yes, no, facts)), u => p148o_branch_both(words, values, names, used, valueUsed, nameUsed, facts, condition, yes, no, end, direct))


@unsafe
def p148o_branch_ready(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +facts: Array<U32>, +at: U32, +condition: U32, +yes: U32, +no: U32, +end: U32, +direct: Bool, diamond: P148ODiamond, origin: P148OOrigin) -> P148OScan:
  p148o_diamond_done(p148o_branch_fact(words, values, names, used, valueUsed, nameUsed, facts, at, condition, yes, no, end, direct, p148o_fact(words, values, names, used, valueUsed, nameUsed, condition, facts)), diamond, origin)


@unsafe
def p148o_branch(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +facts: Array<U32>, +at: U32, +direct: Bool) -> P148OScan:
  +condition = p148o_read(words, U32.add(at, 2))
  +yes = p148o_read(words, U32.add(at, 4))
  +no = p148o_read(words, U32.add(at, 5))
  +end = p148o_read(words, U32.add(at, 7))
  p148o_branch_ready(words, values, names, used, valueUsed, nameUsed, facts, at, condition, yes, no, end, direct, nt_choose(P148ODiamond, direct, u => P148ODiamond{False{},0,0}, u => p148o_diamond(words, values, names, used, valueUsed, nameUsed, yes, no, end)), p148o_origin_value(words, values, names, used, valueUsed, nameUsed, condition, facts, 11))


@unsafe
def p148o_call_done(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, facts: Array<U32>, id: U32) -> P148OScan:
  P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},p148o_put(facts, id, p113k_bound(64)),False{}}


@unsafe
def p148o_direct_call_done(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, facts: Array<U32>, payload: U32, count: U32) -> P148OScan:
  P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},p148o_kill(words, values, names, used, valueUsed, nameUsed, facts, payload, count),False{}}


@unsafe
def p148o_stmt(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +facts: Array<U32>, +at: U32, tag: U32) -> P148OScan:
  p148o_stmt_fields(words, values, names, used, valueUsed, nameUsed, facts, at, p148o_read(words, U32.inc(at)), U32.shrn(p148o_read(words, at), 8n), p148o_read(words, U32.add(at, 2)), p148o_read(words, U32.add(at, 3)), tag)


@unsafe
def p148o_stmt_fields(+words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +facts: Array<U32>, +at: U32, +id: U32, +typ: U32, +left: U32, +right: U32, tag: U32) -> P148OScan:
  match tag:
    case 1: p148o_set_ready(words, values, names, used, valueUsed, nameUsed, facts, at, id, typ, left, P148OHistory{p148o_origin_value(words, values, names, used, valueUsed, nameUsed, left, facts, 6),p148o_origin_value(words, values, names, used, valueUsed, nameUsed, left, facts, 11),False{}})
    case 2:
      p148o_bin_facts(words, values, names, used, valueUsed, nameUsed, facts, at, id, typ, p148o_name(names, p148o_read(words, U32.add(at, 4))), left, right, p148o_fact(words, values, names, used, valueUsed, nameUsed, left, facts), p148o_fact(words, values, names, used, valueUsed, nameUsed, right, facts))
    case 3:
      p148o_call_done_affine(p148o_payload(words, values, names, used, valueUsed, nameUsed, facts, p148o_read(words, U32.add(at, 6)), p148o_read(words, U32.add(at, 5)), True{}), facts, id)
    case 4: p148o_branch(words, values, names, used, valueUsed, nameUsed, facts, at, False{})
    case 5: P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},facts,False{}}
    case 6: P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},p148o_put(facts, id, p113k_bound(64)),False{}}
    case 7: P148OScan{p148o_replace_at(words, values, names, used, valueUsed, nameUsed, U32.add(at, 3), facts),facts,False{}}
    case 8: P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},p148o_put(facts, id, p113k_bound(64)),False{}}
    case 9: P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},p148o_put(facts, id, p113k_bound(64)),False{}}
    case 10: p148o_branch(words, values, names, used, valueUsed, nameUsed, facts, at, True{})
    case 11:
      +payload = p148o_read(words, U32.add(at, 6))
      +count = p148o_read(words, U32.add(at, 4))
      p148o_direct_call_done_affine(p148o_payload(words, values, names, used, valueUsed, nameUsed, facts, U32.add(payload, count), p148o_read(words, U32.add(at, 5)), False{}), facts, payload, count)
    case 12: P148OScan{p148o_payload(words, values, names, used, valueUsed, nameUsed, facts, p148o_read(words, U32.add(at, 6)), p148o_read(words, U32.add(at, 4)), False{}),facts,True{}}
    case 13: P148OScan{p148o_payload(words, values, names, used, valueUsed, nameUsed, facts, p148o_read(words, U32.add(at, 6)), p148o_read(words, U32.add(at, 4)), False{}),facts,True{}}
    case _: P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},facts,False{}}


@unsafe
def p148o_body_next(scan: P148OScan, +next: U32, +end: U32) -> P148OScan:
  match scan:
    case P148OScan{P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed},+facts,+terminal}:
      nt_choose(P148OScan, terminal, u => P148OScan{nt_choose(P148Tape, U32.is_lt(next, end), v => p148o_write_affine(p148o_write(words, values, names, used, valueUsed, nameUsed, next, 15), U32.add(next, 7), end), v => P148Tape{words,values,names,used,valueUsed,nameUsed}),facts,True{}}, u => p148o_body(next, end, words, values, names, used, valueUsed, nameUsed, facts))


@unsafe
def p148o_body(+at: U32, +end: U32, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, +facts: Array<U32>) -> P148OScan:
  nt_choose(P148OScan, U32.is_ge(at, end), u => P148OScan{P148Tape{words,values,names,used,valueUsed,nameUsed},facts,False{}}, u => p148o_body_next(p148o_stmt(words, values, names, used, valueUsed, nameUsed, facts, at, U32.and(p148o_read(words, at), 255)), p148o_read(words, U32.add(at, 7)), end))


@unsafe
def p148o_names(+names: Array<String>, +at: U32, +count: U32) -> Bool:
  nt_choose(Bool, U32.is_eq(at, count), u => True{}, u =>
    nt_choose(Bool, String.starts_with(p148n_get(names, at), "@condition:") || String.starts_with(p148n_get(names, at), "@p123predicate:"), v => False{}, v => p148o_names(names, U32.inc(at), count)))


@unsafe
def p148o_finished(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P148OScan) -> P148Unit:
  match scan:
    case P148OScan{P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed},facts,terminal}: P148Good{name,params,result,public,P148Tape{words,values,names,used,valueUsed,nameUsed}}


@unsafe
def p148o_enter(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32) -> P148Unit:
  p148o_enter_sized(name, params, result, public, words, names, used, valueUsed, nameUsed, Array.size(U32, values))


@unsafe
def p148o_enter_sized(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, words: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32, sized: Array<U32> & U32) -> P148Unit:
  (values,capacity) = sized
  nt_choose(P148Unit, U32.is_le(nameUsed, 65536) && U32.is_le(valueUsed, 524288) && U32.is_le(U32.mul(valueUsed, 2), capacity) && p148o_names(names, 0, nameUsed), u => p148o_finished(name, params, result, public, p148o_body(0, used, words, values, names, used, valueUsed, nameUsed, p148w_new(U32.mul(nameUsed, 16)))), u => P148Bad{"phase148 scalar fact capacity or reserved metadata name"})


@unsafe
def p148o_function(unit: P148Unit) -> P148Unit:
  match unit:
    case P148Good{name,params,result,public,P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed}}: p148o_function_tape(name, params, result, public, words, values, names, used, valueUsed, nameUsed)
    case P148Bad{error}: P148Bad{error}


@unsafe
def p148o_function_tape(+name: String, +params: List<&2,NC_Binding>, +result: U32, +public: Bool, +words: Array<U32>, +values: Array<U32>, +names: Array<String>, +used: U32, +valueUsed: U32, +nameUsed: U32) -> P148Unit:
  nt_choose(P148Unit, U32.is_lt(p148c_stmt_count(words, values, names, used, valueUsed, nameUsed, 0, used), 4096), u => p148o_enter(name, params, result, public, words, values, names, used, valueUsed, nameUsed), u => P148Good{name,params,result,public,P148Tape{words,values,names,used,valueUsed,nameUsed}})


@unsafe
def p148o_bin_finish_affine(tape: P148Tape, facts: Array<U32>, +id: U32, answer: P113KFact, history: P148OHistory) -> P148OScan:
  match tape:
    case P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed}: p148o_bin_finish(words, values, names, used, valueUsed, nameUsed, facts, id, answer, history)


@unsafe
def p148o_body_affine(+at: U32, +end: U32, tape: P148Tape, +facts: Array<U32>) -> P148OScan:
  match tape:
    case P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed}: p148o_body(at, end, words, values, names, used, valueUsed, nameUsed, facts)


@unsafe
def p148o_call_done_affine(tape: P148Tape, facts: Array<U32>, id: U32) -> P148OScan:
  match tape:
    case P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed}: p148o_call_done(words, values, names, used, valueUsed, nameUsed, facts, id)


@unsafe
def p148o_direct_call_done_affine(tape: P148Tape, facts: Array<U32>, payload: U32, count: U32) -> P148OScan:
  match tape:
    case P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed}: p148o_direct_call_done(words, values, names, used, valueUsed, nameUsed, facts, payload, count)


@unsafe
def p148o_payload_affine(tape: P148Tape, +facts: Array<U32>, +at: U32, +count: U32, +typed: Bool) -> P148Tape:
  match tape:
    case P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed}: p148o_payload(words, values, names, used, valueUsed, nameUsed, facts, at, count, typed)


@unsafe
def p148o_replace_at_affine(tape: P148Tape, +at: U32, +facts: Array<U32>) -> P148Tape:
  match tape:
    case P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed}: p148o_replace_at(words, values, names, used, valueUsed, nameUsed, at, facts)


@unsafe
def p148o_set_finish_affine(tape: P148Tape, facts: Array<U32>, +id: U32, fact: P113KFact, history: P148OHistory) -> P148OScan:
  match tape:
    case P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed}: p148o_set_finish(words, values, names, used, valueUsed, nameUsed, facts, id, fact, history)


@unsafe
def p148o_write_affine(tape: P148Tape, at: U32, value: U32) -> P148Tape:
  match tape:
    case P148Tape{+words,+values,+names,+used,+valueUsed,+nameUsed}: p148o_write(words, values, names, used, valueUsed, nameUsed, at, value)

