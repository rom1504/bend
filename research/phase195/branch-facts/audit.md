# Branch-facts semantic and fixture audit

Static review found no new semantic counterexample within the existing `X190Values` invariants. Passing incoming scalar aliases and zero32 facts into both arms, then retaining only incoming facts untouched by either original arm, is conservative. This is a bounded source review, not a proof or a machine-test result. No target, compiler, archive or cleanup job was executed for this audit.

## Semantic boundary

The hook replaces only the two `If` cases of `x190_v_plain`. A byte comparison confirmed that its non-branch tail is identical to `expression-reuse.bend`. The existing matcher, scalar rewriting, width checks, 32-alias bound, and recursively counted setup/body gate of at most 512 rows remain authoritative.

- **Rebindings and snapshots.** Both destination writes and aliases that directly reference a written source are killed by the existing `x190_v_written`. The join visits original `Set`, `Bin`, `Offset`, `Load`, and `Alloca` destinations in both arms, including nested branches. Original Set snapshots remain in the transformed IR until the existing backward dead-write pass separately proves them unused. Rewriting a use inside an arm therefore cannot retroactively change a saved value after its source is overwritten.
- **Transitive aliases.** Production insertion receives an already canonicalized value from `x190_v_scalar`; aliases are flattened. Thus `saved=a; copy=saved` records both aliases against `a`. Overwriting `a` removes both. Overwriting only `saved` may keep `copy→a`, which is correct while `a` itself is unchanged. The kill helper is not a general transitive-closure solver for arbitrarily constructed non-flattened states; its safety relies on the inherited insertion invariant.
- **Width and zero extension.** An unknown-width U32 assignment keeps its truncating snapshot and does not alias the wide source. Widening that Set to U64 and retaining an alias occurs only when the source already has a zero32 proof. Killing an overwritten source's width does not require killing the width of an independently saved destination: the old destination still contains its original zero-extended snapshot. Join processing sets written destinations to unknown width and never adds a fact learned inside an arm. Different-width arm definitions therefore cannot manufacture a post-join zero32 guarantee.
- **Original-arm kill set.** Join facts are computed from the incoming state and the original arms, not from either arm's exit state. Existing two-row arithmetic/mask folding writes the same destination, so scanning the original rows is conservative. Branch-local aliases and widths are not exported, even when both arms appear to establish the same value.
- **Calls and effects.** Scalar calls, direct calls and unsupported statement forms clear all facts. Call arguments may use valid incoming aliases before that barrier. Stores retain scalar facts under the inherited IR model: local values are explicit virtual-name assignments, not memory contents. No load-value cache or memory-equivalence fact is introduced. Arbitrary invalid pointer writes into backend-owned local storage remain outside this inherited assumption.
- **Termination and backedges.** `P113DResult`, `P113DAgain`, scalar `N111Return`, and unknown forms clear facts. Lexical rows after a terminal are transformed from an empty state. The join scans both arms even when one cannot fall through; killing additional facts on an unreachable path loses optimization but does not create an invalid fact. No incoming fact is propagated around a backedge or learned from the once-only setup region.

The two arm transforms receive independent logical copies of the incoming immutable analysis state. The nested kill walk only removes aliases/proofs; traversal order cannot add a fact. Repeated scanning of nested arms can increase compiler work, but the existing recursive 512-row gate bounds this experiment; this review makes no compiler-cost claim.

## Fixture finding and correction

The original `controls.bend` called `x191_ordinary` directly with `p195bf_body(mode)`. That entry proceeds through placement/frame/emission and never invokes `x190_local_values_body` or the new hook. Its machine observations would therefore exercise the untransformed fixture. The 13 compiler-data rows exercise join/width helpers, but do not repair that missing machine path. This issue was independently identified by another reviewer; the coordinator confirmed v1 was not acquired or run.

`controls-v2.bend` fixes the entry by calling `x185_function_setup`. The inspected call chain is:

```text
x185_function_setup
  -> x185_function_place
  -> x186_function_memory
  -> x190_local_values_body
  -> x190_v_body / replaced x190_v_plain / x195bf_if
  -> existing expression, copy, dead-write and machine selection passes
```

The frozen `branch-api-source02/manifest.json` identifies the sole `x190_v_plain` replacement and pins `branch-facts.bend`, `hook.bend` and `controls-v2.bend`. Their input hashes and the assembled source hash were reauthenticated without loading or executing the API. V2's production-path correction is semantically appropriate; this static review does not claim its parse/check admission.

### V3 delta review

`controls-v3.bend` retains the full `x185_function_setup` entry. Its match now scrutinizes the typed `N111Value` parameter of `p195bf_is_value`, with `x190_v_value` evaluated by the caller. Local analysis-state and statement-list declarations have explicit types. This addresses the identified computed-match fixture shape; syntax/type admission remains a separate compiler result. The optimization implementation and hook hashes are unchanged.

The v3 driver requires 20 exact helper labels, including seven additional checks: multi-result call barrier, scalar return barrier, binary/offset/alloca/load destination kills, and scalar-If source killing. A metadata check confirmed the ordered fixture/driver labels agree. The frozen `branch-api-source03/manifest.json` branch-facts input byte counts and hashes, and the assembled source byte count and hash, were reauthenticated. No API was loaded or executed for this check.

## Intended finite coverage, separate from execution

V3 defines thirteen modes × nine `a` values × nine `b` values × two conditions = 2,106 observations per machine route. Edges include zero, all 32-bit ones, values just above 2^32, the high 64-bit bit, all 64-bit ones and a mixed high/low value. The C observer checks the return and stored `saved`, `a`, and `result` values using unsigned 64-bit wraparound.

Modes 0–9 retain the prior coverage: both-arm saved-value use followed by source rebinding, writes in either arm, destination rebinding, narrowing snapshots, a copied narrowed snapshot, transitive aliases with a nested source write, mismatched arm widths, an external scalar call and a load rebinding. The three added modes address focused review requests:

| Mode | Added scenario | Independent C expectation |
| --- | --- | --- |
| 10 | Establish `a:U32` and `saved:U32=a`; both arms use `saved` through `inside:U64`; then overwrite `a` with `b`. Exercises incoming zero32/alias facts and retention of the narrowed snapshot. | `saved=result=(uint32_t)old_a`, final `a=b`. |
| 11 | Establish `saved=a; copy=saved`; overwrite only `saved` in the true arm, leaving the ultimate source `a` unchanged. | `saved=cond?b:old_a`, `result=old_a+saved` modulo 2^64, final `a=old_a`. |
| 12 | Supply the scalar `N111If` spelling with an `a=b` write in the true arm. | `saved=old_a`, final `a=cond?b:old_a`, `result=old_a+a` modulo 2^64. |

The observer calculations agree with these fixture statements by inspection. Mode 12 exercises scalar-If input through the full production pipeline; earlier normalization can convert it to `P113DIf` before the new hook. It therefore does not independently prove execution of the hook's scalar-If clause. The new scalar-If helper directly covers the kill walker for that spelling.

The driver expects the exact `checks=2106 failures=0` observer line and compares direct ELF and rendered GNU-as routes. Both routes derive from one typed selection; they are not independent compiler semantics. The C calculation is the independent value observer. No successful machine or helper execution is asserted here.

Actual early-return and backedge machine paths, and an in-arm Store followed by alias use, remain outside this finite machine fixture. Terminal/backedge/store helper assertions cover analysis metadata only. These gaps limit coverage; they do not establish an unsoundness in the reviewed kill-only algorithm. Source checking, machine controls, broad runtime comparisons and native qualification remain separate decisions.

## Reviewed identities

| File | SHA-256 |
| --- | --- |
| `branch-facts.bend` | `93e978d128cf5627ae4ec95028efab1a4e1cd9b3d7541ca6ff6e5fa10b068dab` |
| `hook.bend` | `89843874754bd0c684696f34b9d9f64966e60399dd2643f304f5e2bad476c2a3` |
| `controls.bend` (v1) | `c0d4c08051b2baf16369b646f7002ddb26d2955ae090c42bb1fd7898206bcb95` |
| `controls-v2.bend` | `3ad40f7346d79d468a93d092711e433b67276c4218656d45712b8c246cf505a1` |
| `controls.c` | `706f478a85a809e4985aa8ef077c84282f5d294db44163136a2ff98f1c55c57c` |
| `driver-v2.mjs` | `91677c8e72e9245009a66dd1d74c43a1d0b8cf222c7489fb97d79ac7048555e7` |
| `expression-reuse.bend` | `116e834fa858487a150049f3c7d145b0c3a845cfd1ebe294146ec42e6bc529ce` |
| `branch-api-source02/manifest.json` | `5eecc57a9e253b1c5f9401388f42379fb6c882da3b9a38de647973b7feb53a4d` |
| `controls-v3.bend` | `bedc28c4b461199dd4c6bc47d24802a79a76780efd5c3650029b08aaef9712fa` |
| `controls-v3.c` | `3bbd4ab54e9879f6b923963e1f84714ef71e3287b10e797ec2bc2effa0539c72` |
| `driver-v3.mjs` | `973e19fee1dc481ca784e847c2909de2adbba108de11c367c76252b90c165255` |
| `branch-api-source03/manifest.json` | `53c9783aa8f4a14f2fba0fd613328f9d08571584857b4002095cfeb9678b8df4` |
| `branch-api-source03/compiler.bend` | `0980d433363c12fe676827dd14010082dbffe67ad7e10347917582bed25d44e7` |
