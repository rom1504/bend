# P68-006 — Select intrinsic templates only when requested

- Owner: native compilation lane; independent reviewer: Phase68 method owner.
- User objective: faster B1/B2 compilation to C, preserving native output and
  keeping compiler mechanisms simple.
- Status: isolated source proposal; no candidate target or promotion yet.
- Baseline: actual Phase67 B1 `c76f1113…`, B2 `cbffd1f8…`; reference `0592662`.
- Evidence: closed `native-compilation01` baseline, summary
  `93137689aee246ba86fabe09bf8bd8ffb3e316345f64c4ede4b5bf00f00b0801`.
- Candidate: [manifest](../../selfhost/tools/performance/phase68/compilation/demand-templates/candidate-v1.json)
  `fdc4cd47…2002`; patch `3a6894fa…9d3e`. Source changes remain isolated.
- Independent source/data review passed: all 69 literal token pairs and four
  call-site changes match; substitution helpers are unchanged; lazy-branch and
  empty-key invariants hold. No target equivalence or speed result yet.

## Claim and cheapest disproof

The native backend constructs a complete 69-entry `ni_Op` list whenever it asks
for one intrinsic template or even tests intrinsic membership. In all three
actual B2 profiles, `ni_templates` is the largest named self-time function:
311.510 ms Numeric, 260.100 ms Array and 273.208 ms Lexer. These are diagnostic
CPU samples, not clean wall-time measurements. GC is another 354.575–531.286 ms,
but this experiment does not attribute all GC to template allocation.

Replace the eager list plus traversal with one pure lazy exact-name lookup.
All 69 template strings remain in one maintained production definition. An empty
key returns immediately because every catalog key is nonempty; native identity
misses commonly produce this key. Other keys follow the original ordered equality
cases and unknown names return the empty string. No mutable cache, host compiler
logic, additional export, new type, or persistence format is introduced.

The proposed gain is approximately 10–15% of affected B2 native-request time,
with uncertainty from remaining lookup/branch work, GC and JIT behavior. This is
a hypothesis. The source table's entire observed self-time is not a guaranteed
removable wall-time budget, and B1's trampolined profile has different attribution.

Stop or revise if any original template, scalar membership, substitution result,
unknown-name result, or complete C output changes; if the candidate adds material
resource cost; or if the clean paired request screen fails to show a useful gain.
Do not bundle the retained-bound export experiment with this first ablation.

## Derivation and invariant

`derive.py` consumes the complete old literal list, proves it contains exactly
69 unique nonempty names with nonempty templates, and copies the string tokens
verbatim into the new decision chain. A reconstructed old expression must equal
the entire original expression, preventing partial-regex extraction. Four
production call sites change: emission, scalar membership, native-definition
membership and primitive arity. The original substitution functions are unchanged.

For a matching name, the first equality branch returns the identical string.
For every other String, all equalities are false and the result is empty. The
empty-key shortcut follows from the checked nonempty-key invariant. This is a
finite literal dispatch, so unlike retaining arbitrary normalization results it
requires no request ownership or context certificate.

`ni_Op`, `ni_templates` and `ni_find` have no admitted public API roots or raw
native-control callers. The replacement removes one data type and replaces two
definitions with one. Formatting the previous one-line constructor catalog as
one lazy case per line adds 63 physical source lines; this is disclosed, not a
line-count reduction claim. The maintained template data is not duplicated.
The old table survives only as immutable experiment evidence and a test oracle.

## Controlled validation

1. Build the candidate through the ordinary strict checked-B1 workflow. Keep the
   99 public roots unchanged and bind actual source/API/derivation metadata.
2. Run `demand-templates/controls.mjs` under root's CPU3 resource guard with the
   proposal, actual baseline attempt, actual candidate attempt and fresh output.
   It exposes existing internal functions through append-only diagnostic exports,
   never substitutes a JS implementation for the Bend algorithm. The derivative
   contains the exact original API as its byte prefix and is not a new B1/B2 claim.
3. Compare all 69 template strings, scalar membership including the `f32_show` /
   `f32_read` exclusions, and seven substitution vectors per name. Also compare
   prefix/suffix/case variants, empty, NUL, Unicode, newline and long unknown
   names. Expected substitutions come from the unchanged literal catalog and an
   independent replacement oracle, as well as the actual baseline implementation.
4. Emit Numeric/Array/Lexer through the actual owned native driver; require
   complete C bytes equal to the selected pre-template candidate's C. If native
   program optimizations were selected first, use that new qualified C oracle,
   not old Phase67 bytes. No Clang rerun is needed merely to re-establish identical
   C, but changed C must receive independent native execution qualification.
5. Use fresh prepared request workers with role rotation for the clean screen.
   Profile separately to confirm reduced template/GC cost; exclude diagnostic
   clocks from timing. Broaden to actual B2 and the final native families only
   after the focused candidate survives.

The baseline method separates imports/API load, explicit Base preparation,
checked Bend-to-C request, Clang and executable runtime. The three-family,
single-sample native baseline is a discriminator, not a universal compilation
score or the historical JavaScript library benchmark. All existing raw evidence,
failed methods and earlier source proposals remain unchanged.
