# P142-003: retain completed freshened user prefixes

The Phase140 parser can reuse a raw declaration prefix, but completion then
freshens every user declaration. Test a narrow retained product containing the
exact completed prefix, actual starting/ending counter and freshened output.
Freshen only the changed suffix when the complete prefix and input counter
match. Keep original completion, validation, checking and downstream gates.

The initial checked observer compares actual pre-freshening products from
Lexer/Map and literal128/512/1024-declaration prefixes of the qualified compiler.
These latter workloads are parser/freshener fixtures, not complete executable
compiler variants. Full definitions, final next counter and complete loader
products match. Guarded/full median paired ratios are approximately0.68/0.49/0.34
for those compiler prefixes. Unguarded suffix-only timings are ceilings only.

The integrated Bend prototype uses `p140p_defs`, which distinguishes KDef from
index variants as well as comparing all freshener-relevant fields. A private
session carries the fixed seed and publishes the new cache only after complete
request success. On mismatch or unsupported completion shape, retain the old
loader/freshener route. No public Boolean or hash grants reuse authority.

Required finite controls: fresh composition and manual binder numbering;
children, All/Lam/Let, quantities/flags/spans; suffix binder changes; exact
counter/cut mismatches; relative path changes and absolute-path invariance;
invalid cuts; failed edits and recovery. Full loader products and complete QBE
must match the original route. Measure comparison, split/join, retention and
cold acquisition, not only suffix work. Do not promote from a component speedup.

Source01 failed checking because `p142ff_cold` reused an unannotated `start`.
Source02 fixes the sharing annotation. Preserve both; execution status belongs
in the report/receipts, not this hypothesis.
