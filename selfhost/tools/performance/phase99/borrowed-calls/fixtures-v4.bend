# Internal finite admission controls, appended only to the test API source.
# These synthetic values test predicates; they do not mint production authority.
@unsafe
def p99_borrow_fixture_schema() -> NO_Schema:
  NO_Schema{[var("String", nc_id(0)), var("String", nc_id(1)), var("Bool", nc_id(2))], [0, 1], var("Bool", nc_id(3)), nc_id(3), "Bool", Nil{}, 4, ""}

@unsafe
def p99_borrow_fixture_ctx() -> NO_Context:
  NO_Context{Nil{}, "FixtureCaller", p99_borrow_fixture_schema(), Nil{}}

@unsafe
def p99_borrow_fixture_root(origin: KTerm, word: U32) -> KTerm:
  noa_atom("String", origin, var("", nc_id(word)))

@unsafe
def p99_borrow_fixture_entry(+i: U32) -> KTerm:
  p99_borrow_fixture_root(kt("OArg", "", i, 0, Nil{}), i)

@unsafe
def p99_borrow_fixture_word(actual: KTerm) -> KTerm:
  nob_arg_word(p99_borrow_fixture_ctx(), var("String", nc_id(9)), actual, True{})

@unsafe
def p99_borrow_entry() -> Bool:
  p98_tag_eq(p99_borrow_fixture_word(p99_borrow_fixture_entry(0)), "Var")

@unsafe
def p99_borrow_reordered() -> Bool:
  p98_tag_eq(p99_borrow_fixture_word(p99_borrow_fixture_entry(1)), "Var")

@unsafe
def p99_borrow_descendant() -> Bool:
  p98_tag_eq(p99_borrow_fixture_word(p99_borrow_fixture_root(kt("OField", "SCon", 1, 0, [kt("OArg", "", 0, 0, Nil{}), ref("String")]), 4)), "Var")

@unsafe
def p99_borrow_alias() -> Bool:
  p98_tag_eq(nob_arg_words(p99_borrow_fixture_ctx(), [var("String", 0), var("String", 1)], [p99_borrow_fixture_entry(0), p99_borrow_fixture_entry(0)], [0, 1], 0), "NO_Args")

@unsafe
def p99_borrow_wrong_type() -> Bool:
  p98_tag_eq(p99_borrow_fixture_word(noa_atom("Nat", kt("OArg", "", 0, 0, Nil{}), var("", nc_id(0)))), "Absent")

@unsafe
def p99_borrow_unrooted() -> Bool:
  p98_tag_eq(p99_borrow_fixture_word(p99_borrow_fixture_root(kt("OUnique", "", 7, 0, Nil{}), 4)), "Absent")

@unsafe
def p99_borrow_scalar_origin() -> Bool:
  p98_tag_eq(p99_borrow_fixture_word(p99_borrow_fixture_entry(2)), "Absent")

@unsafe
def p99_borrow_missing_origin() -> Bool:
  p98_tag_eq(p99_borrow_fixture_word(p99_borrow_fixture_entry(7)), "Absent")

@unsafe
def p99_borrow_virtual() -> Bool:
  p98_tag_eq(p99_borrow_fixture_word(kt("OC", "SNil", 0, 0, Nil{})), "Absent")

@unsafe
def p99_borrow_nonvar() -> Bool:
  p98_tag_eq(p99_borrow_fixture_word(noa_atom("String", kt("OArg", "", 0, 0, Nil{}), kt("NWord", "0", 0, 0, Nil{}))), "Absent")

@unsafe
def p99_borrow_short_arity() -> Bool:
  p98_tag_eq(nob_arg_words(p99_borrow_fixture_ctx(), [var("String", 0), var("String", 1)], [p99_borrow_fixture_entry(0)], [0, 1], 0), "Absent")

@unsafe
def p99_borrow_long_arity() -> Bool:
  p98_tag_eq(nob_arg_words(p99_borrow_fixture_ctx(), [var("String", 0)], [p99_borrow_fixture_entry(0), p99_borrow_fixture_entry(1)], [0], 0), "Absent")

@unsafe
def p99_borrow_missing_certificate() -> Bool:
  Bool.not(p88_string_eq(no_schema_error(nob_find("FixtureCallee", Nil{})), ""))

@unsafe
def p99_borrow_legacy_emitter() -> Bool:
  Bool.not(p88_string_eq(nc_error(no_emit(kt("NO_Call", "FixtureCallee", 0, 0, [kt("NO_Args", "", 0, 0, Nil{}), kt("NO_Return", "", 0, 0, [kt("NWord", "1", 0, 0, Nil{})])]), Nil{}, Nil{}, Nil{}, 0)), ""))

@unsafe
def p99_borrow_permission_off() -> Bool:
  Bool.not(p88_string_eq(noa_error(noa_analyze_calls(Nil{}, "FixtureCaller", p99_borrow_fixture_schema(), False{}, [NO_Callee{"FixtureCallee", p99_borrow_fixture_schema()}])), ""))

# Additional finite controls. The tiny synthetic Bool book makes the positive
# scalar counterpart pass, so product-result refusal is not a missing-type pass.
@unsafe
def p99_borrow_fixture_bool_book() -> List<&2, KDef>:
  +b = kt("ADT", "Bool", 0, 0, Nil{})
  [KDef{"Bool", "ADT", 0, 0, atom("Absent"), atom("Absent"), [KDef{"False", "Ctr", 0, 0, b, atom("Absent"), Nil{}, False{}, False{}}, KDef{"True", "Ctr", 0, 0, b, atom("Absent"), Nil{}, False{}, False{}}], True{}, False{}}]

@unsafe
def p99_borrow_fixture_typed_ctx() -> NO_Context:
  NO_Context{p99_borrow_fixture_bool_book(), "FixtureCaller", p99_borrow_fixture_schema(), Nil{}}

@unsafe
def p99_borrow_scalar_type() -> Bool:
  +ctx = p99_borrow_fixture_typed_ctx()
  +param = var("Bool", nc_id(2))
  +good = noa_atom("Bool", kt("OArg", "", 2, 0, Nil{}), kt("NWord", "1", 0, 0, Nil{}))
  p98_tag_eq(nob_arg_word(ctx, param, good, False{}), "NWord") && p98_tag_eq(nob_arg_word(ctx, param, p99_borrow_fixture_entry(0), False{}), "Absent")

@unsafe
def p99_borrow_unrooted_descendant() -> Bool:
  p98_tag_eq(p99_borrow_fixture_word(p99_borrow_fixture_root(kt("OField", "SCon", 1, 0, [kt("OUnique", "", 7, 0, Nil{}), ref("String")]), 4)), "Absent")

@unsafe
def p99_borrow_product_result() -> Bool:
  +ctx = p99_borrow_fixture_typed_ctx()
  +args : List<&2, KTerm> = [p99_borrow_fixture_entry(0), p99_borrow_fixture_entry(1), noa_atom("Bool", kt("OArg", "", 2, 0, Nil{}), kt("NWord", "1", 0, 0, Nil{}))]
  +product : NO_Schema = NO_Schema{[var("String", nc_id(0)), var("String", nc_id(1)), var("Bool", nc_id(2))], [0, 1], kt("Ctr", "Tuple", 0, 0, [var("String", nc_id(0)), kt("Ctr", "Tuple", 0, 0, [var("String", nc_id(1)), var("Bool", nc_id(3))])]), nc_id(3), "Bool", Nil{}, 4, ""}
  p98_tag_eq(nob_call_args(ctx, p99_borrow_fixture_schema(), args), "NO_Args") && p98_tag_eq(nob_call_args(ctx, product, args), "Absent")
