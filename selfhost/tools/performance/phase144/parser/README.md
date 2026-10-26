# Exact parser prior view

Experimental source packaging only; the qualified compiler remains unchanged.
See [the source audit](../../../../../research/phase144/parser.md) for the
duplicate-order and missing-value contract.

Current modules are `prior-v01.bend` and `controls-v02.bend`.
`prepare-v03.py --out selfhost/build/phase144/FRESH_SOURCE_DIRECTORY` reproduces
the candidate from the exact selected Phase143 source. Source01 and its failed
test-fixture affinity check remain retained; source02 adds the missing `+` on
the fixture's repeated version parameter.

The checked APIs must export `f_load_graph`, `p88_cache_prepare`, `p86_plan`,
`p134e_plan`, `p134e_begin`, and `p134e_next`. The candidate must additionally
export `p144pc_controls`. The coordinator also exports `f_source_body` and
`f_body_header` for optional subsequent attribution.

After those checks, the coordinator can run the bounded differential under the
existing process guard:

```sh
selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase144/parser/parse-screen-v02.mjs \
  selfhost/build/phase111/p144-parent-api01/report.json \
  selfhost/build/phase111/p144-parser-api02/report.json \
  selfhost/build/phase144/parser-screen02
```

The output directory must be fresh. The method writes its exact fixture texts,
pins all observed inputs, compares 27 finite controls, 10 raw parser cases,
7 complete frontend cases and three real frontend/generated-QBE products.
Its 110-second soft deadline does not replace the external resource guard.
Reported frontend timings are hosted measurements; they do not establish native
ownership cost, full-compiler throughput or bootstrap qualification.

Screen01's first nine raw products agreed, but its missing-marked-type expected
verdict incorrectly demanded raw-parser rejection. V02 corrects that test-stage
expectation; source02 and all 27 finite controls already passed the checked API.

For the separate native complete-parser experiment, `prepare-native-v04.py`
accepts `--candidate SOURCE_MANIFEST --out FRESH_DIRECTORY`. The resulting
manifest freezes 8.7K-line old/new slices, exact fixed Phase142 request path, and
required API exports. Its `jobs.json` contains guarded, same-producer native
build commands; packaging does not execute them. After checking both slices:

```sh
selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase144/parser/native-oracle-v01.mjs \
  selfhost/build/phase144/parser-native-source04/manifest.json \
  ORIGINAL_SLICE_CHECKED_REPORT CANDIDATE_SLICE_CHECKED_REPORT FRESH_ORACLE_DIR
```

Only after complete hosted trace equality and the independent checksum pass
should the coordinator run the two native binaries, with the frozen request and
authenticated Base/carrier/stamp, under the ordinary CPU3/resource guard:

```text
PROGRAM --threads 1 --gpu off -- phase144-parser INPUT BASE CARRIER STAMP
```

Compare `parse_ms`, charging `prepare_ms`, `observe_ms`, file IO and whole process
time separately. Both slices use identical diagnostic entry code and toolchain.

Native source02 was rejected during checking because its extractor omitted an
earlier law declaration when keeping the later definition of the same name.
Source03 computes dependencies from all associated declarations and copies their
original ordered spans, including `@unsafe`. Its manifest records span hashes and
asserts exact grouped declaration bytes. The failed source02/API are retained.
Source03 then exposed the old extractor's incorrect handling of a quote character
literal, which hid a lexer dependency. Source04 uses the existing Phase141
string/character/comment masker and independently audits all packaged references
against the original declaration and constructor-owner sets. Both failures remain
retained; source04 has 8,726 original and 8,777 candidate lines.

`prepare-native-gates-v01.py --source-manifest SOURCE04_MANIFEST --out FRESH_DIR`
freezes the three serial root-owned commands: original API check, candidate API
check, then complete full-input structural oracle. The current plan is
`selfhost/build/phase144/parser-native-gates01/jobs.json`. Stop after any failed
receipt. It additionally audits exact inverse mapping of the six copied prefix
functions, unchanged Base/prefix helpers, identical diagnostic code in both
variants, and checksum placement after the parse clock. It does not execute a
compiler, and does not assert that lexical completeness replaces source checking.

Both source04 APIs and the full-input oracle have now passed. Native paired
timing now uses `parser-native-gates01/timing-jobs-v03.json` and
`native-timing-v02.py`, requesting one pair only. Both native build receipts exist.
A quiet CPU3 lane and the root resource guard are mandatory. The runner never
builds an image or changes source.

Timing01 passed receipt admission but the native program immediately rejected
its arguments: this runtime's `IO.args` excludes `argv[0]`, while the frozen
entry consumes an ignored first token followed by the four input fields. V02
supplies the explicit `phase144-parser` token; it keeps the same native images.
The original failed run is retained. The root guard requires at least 64MiB for
its file bound; the current command satisfies that existing constraint.

The corrected one-pair run passed in
`selfhost/build/phase144/parser-native-timing02/report.json`: parse time
44.572→31.175s (30.06% lower), complete process 45.449→32.055s (29.47% lower),
with the expected full-result checksum in both runs. This is a single clean
native pair on the exact compiler input, not a whole-build percentage. The
full diagnostic compiler independently shows its parse/load interval falling
47.950→35.906s; see the source audit for timing scopes and acquisition costs.
