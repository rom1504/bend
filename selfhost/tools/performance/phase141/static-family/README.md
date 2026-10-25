# Static comparator-family consolidation

Prepared candidate only. No source checking, native execution or integration is
claimed by this preparation. The coordinator's separate small static-traversal
experiment is the performance admission gate; this full family still needs its
own checked, differential and native gates.

`contract-v02.json` binds the exact Phase140 source18, replacement module,
deletions, public API roots, protected verifier declarations and independent
reference API. `callers-v01.json` inventories all existing generic/typed
comparator calls, including controls. Use `core-v01.bend` as the one overlay;
`controls-v01.bend` is its separately reviewable source subset, not an additional
module to append.

The replacement is deliberately small in concepts:

1. `p134v_list` becomes `(~A: Data, ~eq: A -> A -> Bool, a, b)`. All template
   parameters lead the signature and every current caller supplies closed named
   arguments. Runtime lists and comparator element arguments are unchanged.
2. The 22 `p140e_*` definitions are removed. Scalar/record callers use the
   canonical `p134v_*` comparison; raw headers/constructors use the already
   identical `p140v_header`/`p140v_ctor`. Typed-list calls instantiate the shared
   static traversal. No replacement runtime callback is introduced.
3. The 18 duplicated finite matrix helpers are replaced with three small
   test-only helpers. `p140tc_controls` retains its 19 row names and501 pair
   checks. Expected equality is supplied by fixture index, not by another
   invocation of the comparator under test. All fixtures are distinct except
   direct-header indices0/4 and raw-header indices0/6, which intentionally
   differ only in ignored bodies. Ordinary list controls retain independent
   equal/empty/length/mismatch expectations.

The entire structured comparator bodies match their canonical counterparts
after only the declared identifier/list-call rewrites. The contract records
those exact normalized-body hashes. This is source evidence for field order,
quantity preservation, Boolean combination and fallback identity; it is not a
proof of specialization or generated-code equivalence.

The complete family contains35 definitions and220 nonblank code lines before
replacement, and13 definitions/83 lines afterwards: **62.3% fewer lines**, or
2.65× smaller. Including caller changes and test migration, the complete source
loses213 code lines. There are40 deleted definitions,26 overridden definitions
and3 added test helpers. These counts include the new testing logic; no old
comparator implementation is retained under a hidden candidate prefix.

## API and verification boundary

`p134v_list` is now a private template, **not a runtime-callable API function**.
Do not request it as a stage0 API export for the candidate. It is absent from
the108 supported typed-driver roots and the selected checked API exports, all
of which retain their names. Ordinary scalar comparators may be exported for
an isolated differential gate if desired.

No `p111v_*`, `p113a_*`, `p113d_*`, `p113e_*`, protected entry gate or qualified
proof declaration is modified or deleted. Normal verifier invocation order and
failed-candidate fallback remain intact. The new comparison is only a test of
immutable equality, never permission to skip an independently required final
verifier.

The old comparator remains in the frozen original checked API, outside the
candidate. Preserve independent full-request comparisons against that API.
The rewritten control matrix avoids the unsound shortcut of replacing both
sides of an old/new assertion with the same new function.

## Composition and required gates

The Phase141 composer with ordered insertion support understands this contract:

```sh
python3 selfhost/tools/performance/phase141/prepare-v02.py \
  --out selfhost/build/phase141/static-family-source01 \
  --contract selfhost/tools/performance/phase141/static-family/contract-v02.json \
  --module selfhost/tools/performance/phase141/static-family/core-v01.bend
```

Use a fresh output directory. This command assembles declarations and checks
identities only; it does not check or compile Bend. To combine with the parser
experiment, the coordinator must create an explicit combined contract after
verifying disjoint overrides/deletions, rather than pretending this contract
already authenticates that composition.

The first composition, retained as `contract-v01.json`, appended all new
declarations after the old source. Checking rejected the first `~` call from
`p140tc_controls`, because its template had not yet been declared. V02 makes
the source order explicit: insert `p141sf_expected`, `p141sf_row`, then
`p141sf_matrix` immediately before `p140tc_controls`. All existing static
`p134v_list` call sites already follow its definition;88 rewritten static call
sites were audited. No Bend implementation or semantic rule changed in this
ordering correction.

Next gates: complete checked API, all existing finite controls plus the revised
matrix, old/new pure and cursor product equality on real requests, actual
specialized QBE inspection, and a bounded native request comparison. Record
specialized-instance count and compiler cost: one maintained traversal can
still generate many concrete functions. Full native qualification follows only
after these smaller checks justify it.

The three new matrix helpers use the same existing closed-template mechanism,
but their expected truth table is fixed independently. This is a finite test
migration, not an additional search or verification framework.
