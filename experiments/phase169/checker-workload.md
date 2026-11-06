# Nonempty loader/checker transfer workload

This is source preparation, not a measured result. The fixed 32-round program
executes 320 real `f_load_graph_trace` and `p143cp_check(..., True{})` calls on
ten varied, nonempty Phase156 publication fixtures. Its extracted closure is
469,012 bytes / 1,601 declarations, slightly above the requested 200–400KB band.
It retains the actual parser, loader, normalization, checker and diagnostics.
The old Phase156 `inputs/checker.bend` empty main is not used.

The fixtures cover consecutive datatypes, dirty publication followed by clean
checking, successful and failing templates, errors before/after instantiation,
filled and open laws, and a datatype following a function body. Exact historical
`/phase156/<name>.bend` paths preserve source ranges. These finite inputs have no
Base import, so they isolate actual small-program checking rather than repeatedly
checking the whole Base. The acquired workload still uses the normal compiler
and runtime, with no special runtime or host implementation of checking.

## Independent correctness gates

`experiments/phase156/publication/fixtures.json` supplies the source-level
expectations: six empty checker errors and four exact `bad: type mismatch`
errors per round. An open law is a successful checker result here; it does not
claim the unchanged driver's separate proof-completeness/TODO verdict succeeds.
The empty fixture is excluded. `duplicate-definition` is also excluded because
its documented parser refusal was incorrectly expected to parse successfully in
the original fixture suite. The whole historical suite remains `passed:false`;
all ten selected rows are explicitly `passed:true`.

Before timing, `checker-controls.mjs` compares each complete parsed book and
`DChecking` value against `controls02/fixture-*.graph.json`'s frozen **original**
result. That historical original was the independent publication reference,
also checked against the legacy error verdict, not a Phase169 candidate output.
The new gate preserves physical variants and every field; it does not normalize
away diagnostics, paths, IDs, ownership state, world indexes or specialization
memos. Current-baseline/candidate agreement alone is insufficient.

Each timed round checks its expected error string and consumes the full parsed
book, complete `KChecking`, world, memo, freshness state and diagnostic. The
existing `p163r_scan` explicitly visits every nested KDef/KTerm field, string
character and terminator. New product/list tags delimit the additional checker
fields. The output is `[cases, accepted, rejected, mismatches, KDefVisits, hash1,
hash2]`. The hashes supplement the complete-value gate; they are not a proof of
collision freedom. Allocating/retaining the parsed book and consuming all outputs
is charged to the runtime workload, including shared field traversals.

`checker-expected.py` is an independent Python observer of frozen graph data. It
does not parse/check Bend or call any compiler. It authenticates fixture literals,
selected passed rows and graph hashes, then computes the finite expected result:

| Rounds | Expected complete output |
| --- | --- |
| 0 | `[0,0,0,0,0,2166136261,5381]` |
| 1 | `[10,6,4,0,327,1484639426,3327092978]` |
| 32 | `[320,192,128,0,10464,2377378021,2469680293]` |
| 64 | `[640,384,256,0,20928,3783135877,2029524037]` |

## Reproduction and measurement boundary

The source-only preparations already produced `checker-api-source01`,
`checker-source01` (32 rounds), and `checker-oracle01` under
`selfhost/build/phase169`. To create fresh equivalents:

```sh
python3 -B experiments/phase169/tools/prepare-checker.py --api --out FRESH_API_SOURCE
python3 -B experiments/phase169/tools/prepare-checker.py --rounds 32 --out FRESH_SOURCE
python3 -B experiments/phase169/tools/checker-expected.py --out FRESH_ORACLE
```

The maintained extraction authenticates the qualified parent, introduces zero
overrides and records all declaration/source pins. `--rounds 64` selects the
other committed main; neither main embeds a computed checker answer. API exports
are `p169c_result(index)`, `p169c_run(rounds)` and `p169c_fixtures()`.

Root acquires the API through the normal checked hosted builder, then runs this
payload under the existing serial CPU3/resource guard:

```sh
selfhost/.assets/bin/bun experiments/phase169/tools/checker-controls.mjs --api-receipt CHECKED_API_REPORT --source-manifest FRESH_API_SOURCE/manifest.json --oracle FRESH_ORACLE/report.json --out FRESH_CONTROLS
```

Only after all twelve rows pass should both compilers build the identical fixed
main source with identical Base policy/runtime/toolchain. Use the native source
to executable pipeline clock for complete compilation; separately run the
resulting programs with exact full stdout gates. Begin with fixed 32 rounds;
64 rounds is available if clean elapsed time is below the existing useful-time
floor. Freeze the selected count before comparing roles, use balanced serial
fresh processes, and charge startup, checking, allocation, consumer and teardown.
The intended 0.1–1 second runtime band is unmeasured, not guaranteed.

This broadens the verifier/lookup transfer evidence with actual nonempty checker
work. It still does not represent full compiler self-execution or authorize
promotion. The full canonical source self-build, generated-language conformance,
independent runtime controls and existing stack bound remain separate gates.
