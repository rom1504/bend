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
  +args = [p99_borrow_fixture_entry(0), p99_borrow_fixture_entry(1), noa_atom("Bool", kt("OArg", "", 2, 0, Nil{}), kt("NWord", "1", 0, 0, Nil{}))]
  +product = NO_Schema{[var("String", nc_id(0)), var("String", nc_id(1)), var("Bool", nc_id(2))], [0, 1], kt("Ctr", "Tuple", 0, 0, [var("String", nc_id(0)), kt("Ctr", "Tuple", 0, 0, [var("String", nc_id(1)), var("Bool", nc_id(3))])]), nc_id(3), "Bool", Nil{}, 4, ""}
  p98_tag_eq(nob_call_args(ctx, p99_borrow_fixture_schema(), args), "NO_Args") && p98_tag_eq(nob_call_args(ctx, product, args), "Absent")
