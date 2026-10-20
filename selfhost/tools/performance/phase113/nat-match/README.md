# Optional canonical Nat extraction

The observed products11 scalar-region QBE already has full-U64 comparisons for
Zero and Succ. In the complete direct `mit` body, line715 still calls
`p111_rt_special_take(kind4,count1)` and line716 loads its result from scratch,
once on each successful loop arm. The existing Phase112 special-tests module
has already removed the test helper. This module therefore changes only Succ
extraction, not the tests or the pattern decision tree.

The selected mature `nc_condition` uses `word==0` / `word!=0`, and
`nc_field_word("Succ")` uses `word-1`. Runtime04 special_take writes exactly
`out[0]=term-1` and returns the field count. Its return goes to the unused
`ignored` local. After the original successful Succ guard, the same subtraction
is emitted as one `N111Bin` into the exact existing field local. The operation
is U64, so 2^32, 2^40 and 2^48-1 remain intact; no arithmetic overflow checks are
removed or introduced. Zero still has no fields or extraction code.

Admission requires a checked canonical builtin Nat/Succ constructor, an exact
erased Mat with two arms, one field, arity marker2 and the original zero scalar
mask. Other shapes delegate to the unchanged p111_take. Two exact original
match declarations replace only their hit-arm extraction call. They retain
p111_test, p113df_field_env, ownership partitions, hit/miss environment transfer,
branch order, fresh counter and error handling. The product bundle match is
unchanged. This consumes source provenance; it is not an arbitrary-IR theorem.

Removing the scratch round trip assumes the generated match protocol: the
successor field is subsequently used through its local binding, and the old
helper's ignored return and scratch store have no independent observer. This
holds at these two authenticated source lowering sites. No global runtime or
p111_take override is installed.

Compose model.bend plus overrides-direct.bend and overrides-products.bend after
the direct-fields overrides. The Nat facts helper is a dependency. For test
APIs append controls.bend (also uses nat-facts/controls.bend) and export
p113_nat_match_control_report. Nineteen finite classification, refusal and
full-width code-shape controls are prepared, not executed by this agent.
Reuse the actual Nat high-values and overflow fixtures plus corrected
owned-record-v2 from nat-facts/fixtures/manifest-v2.json. Root should additionally
check that the qualified direct mit body loses the Succ helper call and retains
its full-word subtraction before drawing a performance conclusion.
