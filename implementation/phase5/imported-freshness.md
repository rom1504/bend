# Imported declaration freshness after successful elaboration

A scoped frontend check now rejects a definition or family that redeclares an
already completed top-level name, including names supplied by Base. The isolated
candidate resolves18 acceptance/phase differences across45 selected observations,
with no new exact differences. One control exposed a real false acceptance:
the old checker accepted a user replacement for Base's unfilled native `F32.add`
law; the candidate and pinned TypeScript reject it during parsing.

This does not repair exact source rendering. The same28 exact diagnostic/report
differences remain in this selection; four acceptance/phase differences for two
imported-law-fill forms are explicitly deferred. Existing failed cases remain
failed cases, rather than being counted as conformance from a generic rejection.

## Change and ordering contract

Only `src/load/graph.bend` changes. After the existing complete graph parsing and
elaboration validation succeeds, a chronological declaration pass tracks the
latest prior top-level binding with the existing persistent exact-name index.
Each name is hashed once and used by `index_find`/`index_set`; it does not retain
or repeatedly filter an additional prefix book. Input declaration order and
terms are unchanged, and constructor names remain in their separate namespace.
Namespace-qualified declaration names are used directly; aliases are not
reinterpreted as declaration namespaces.

An ordinary unfilled law may acquire a body. Type/signature agreement remains
checker work. Base marks both its own laws and bodies native after parsing, so
native-to-native Base law filling remains valid; a later user definition cannot
fill a native declaration. Filled foreign definitions are not open laws.

Any existing parser, import or elaborator error is retained verbatim. Consequently
an earlier duplicate can still be hidden by a later parser/elaborator error. This
bounded post-success check does not reproduce the upstream context-aware parser's
full ordering. Existing imported law filling also remains incomplete: a valid
untyped fill is rejected by the standalone parser, while a malformed annotated
fill can pass parsing and later fail checking. Both limitations have concrete
unchanged controls. No broad parser rewrite was attempted.

## Evidence and failures retained

The baseline is genuine integration attempt02. Candidate02 is a genuine checked
build with only the graph module changed:

- API `186053a178a0a4219b0ced229235f78f38f3880a29562f8e781b46ff2a07b416`;
- assembled source `09dd3d0a524467a0c05052a855a1edbcc5d18d3917c10c32727a77766932e755`;
- graph source `ef8b93ca6822f3bf5e0696ba4166967bc10557f14fa357f88105753c31dbac6b`.

The final audit covers45 paired observations per compiler. Nine fixtures resolve
both parse/check phase comparisons: four existing upstream cases plus five local
Base/native/order witnesses. Eight positive fixtures match TypeScript exactly,
covering ordinary law filling, local scope shadowing, constructor/top-level
spelling overlap, foreign IO declarations, separate module constructors,
namespaced Base shadowing and list sorting. Earlier invalid patterns, later raw
parser errors and filled foreign duplicates retain their previous results.
All unchanged cases match the original compiler exactly. No infrastructure failure
or consumed-input drift occurred in the final gates.

Candidate01 used `book_put`, whose retained-list filtering on law replacement was
unnecessary work. It is preserved but superseded by the direct-index candidate.
Two fixture revisions are also retained: a qualified local binder and plain-U32
foreign return were invalid positive controls, and quoted top-level import paths
did not reach the intended imported-law-fill rule. Corrected controls and their
fresh baseline/candidate runs are the final evidence. Initial failures are not
included as successful rule coverage.

Compact_index independently reviewed the exact candidate02 source and gave a
scoped GO: latest-binding replacement, exact hash-collision lookup, separate
constructor namespace, Base accommodation and unchanged prior-error branch were
checked. The reviewer explicitly retained the parser-order and imported-law-fill
limitations; no additional compiler test is attributed to that review.

## Accepted-path cost gate

An exclusive CPU3 slot, with other intentional compiler/archive jobs paused,
ran23:47:04.224–23:47:50.961UTC on2026-09-22. The finite process had an external
120-second deadline, 4GiB heap and4MiB stack. Preparation verifies genuine builds
and the one-module source delta, copies one frozen host, separately prepares each
API's validated Base cache, and warms the two persistent APIs. Ten untimed graph
checks covering three sources confirm exact seeded/unseeded equality per API.
Thirty accepted parse/check requests then run in three alternating rounds; all
complete results match and every consumed identity is rechecked.

| Request | Baseline median | Candidate median |
| --- | ---: | ---: |
| Simple Base program, parse | 204.2ms | 195.6ms |
| Simple Base program, check | 400.8ms | 352.5ms |
| No-Base program, parse | 75.3ms | 70.8ms |
| No-Base program, check | 71.7ms | 71.4ms |
| List sort, check | 1049.4ms | 949.9ms |

This bounded test found no material accepted-path slowdown. The lower candidate
totals are retained, but **are not a claim that added validation speeds up the
compiler**: whole-image/JIT and warm-process effects are not separated. It is an
overhead falsifier, not a broad or fresh-process throughput comparison. The pass
still scans merged names, including Base; a future cached context requires a
separate ownership/invalidation design.

The reproducible cost command is:

```sh
timeout --kill-after=5s 120s taskset -c 3 node \
  --stack-size=4096 --max-old-space-size=4096 \
  tools/performance/phase5/freshness-cost.mjs CONFIG NEW_OUTPUT
```

CONFIG records genuine `baseline` and `candidate` attempt paths plus accepted
`cases` with `id`, `file` and `mode`; paths are relative to CONFIG. Restore the
recorded artifacts and reserve a comparable resource slot before rerunning.

Parent approved guarded promotion after report/archive. Only the graph module was
copied at 23:54:26 UTC, after checking original SHA
`0649ab4f02d6306a205439a8949eadae5f8b15b6d4d59167073c49070c77fe16`.
The existing binder freshening chain remains intact. The
[promotion record](imported-freshness-evidence/promotion.json) records the exact
copy; no full-suite result is claimed by this selected experiment.

See [preregistration](../../experiments/phase5/P5-020-imported-declaration-freshness.md),
[archive recovery](imported-freshness-evidence/README.md) and
[member manifest](imported-freshness-evidence/manifest.json).
