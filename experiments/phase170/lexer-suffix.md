# Preserve the original String after lookahead

This experiment addresses a concrete difference between the scalar lexer and its
previous implementation. The upstream-generated B1 code returns `head + rest`
from `p150l_word` when an identifier ends, although the Bend source returns `s`.
Match refinement reconstructs the matched value. Symbol lookahead similarly
reconstructs one- or two-character prefixes of the remaining source. The old
`f_scan_word` returned the original JS string directly. Repeated reconstruction
and later slicing of large string suffixes could explain allocation growth while
loading the complete compiler. This is a source-level hypothesis, not measured
allocation attribution.

[The experimental overlay](../../selfhost/tests/phase170/lexer-suffix.bend)
changes exactly `p150l_word`, `p150l_other`, `p150l_symbol`, `p150l_plus_at` and
`p150l_greater_at`. Each wrapper passes the same suffix as two separate helper
parameters. The helper matches one parameter and returns the other when
lookahead consumes no characters. Predicates, consuming tails, token text,
metadata arithmetic and error behavior remain the original expressions.

[Preparation](../../selfhost/tests/phase170/prepare-lexer-suffix.py) compares the
frozen source with the maintained assembly, checks original signatures, and
verifies that substituting the two equal helper parameters recovers each old
body literally. Inverting the five byte replacements recovers the original
source exactly. The candidate adds five helpers and 1,147 bytes; all 8,404 other
original declarations are untouched. This audit is not a Bend typecheck or a
native performance result.

The full candidate is
`selfhost/build/phase170/lexer-suffix-source/compiler.bend`, SHA256
`e372dab66ab3a557feb881f563ffe1ecfbe9634724133b1f434776e95c59e257`.
Its baseline is the full Phase170 source with SHA256
`5903812cda7f23f4e25dfbe88b8717ad1b9c5fbe9f342d52fe00e179317b5e9e`.
The preparation report and two-root export manifest are in the same directory.

Acquire separate upstream-checked APIs from those two full sources using
maintained `hosted.mjs acquire` and the prepared `exports.json`. Then run,
inside one root-owned resource guard:

```sh
ENGINE selfhost/tests/phase170/lexer-suffix-controls.mjs \
  --baseline BASELINE_API/report.json \
  --candidate CANDIDATE_API/report.json \
  --audit selfhost/build/phase170/lexer-suffix-source/report.json \
  --out FRESH_OUTPUT \
  --sizes 16384,32768,65536 --larger 262144 --load-size 65536
```

The [runner](../../selfhost/tests/phase170/lexer-suffix-controls.mjs) authenticates
both APIs and their acquisition inputs. Its 63 literals exactly reproduce the
retained Phase150 inputs; five cursor/accumulator states yield 315 comparisons
of all seven token fields and complete list shape. Ten independent comparator
controls include field and shape mutants. Size probes generate complete valid
declarations, and the optional loader probe compares the entire Bend-produced
graph against the baseline plus an independent declaration count. Host code
constructs fixtures and observes results; all lexer/parser work remains in Bend.

The root's separate upstream B1 acquisitions checked both full sources in
8.217s and 8.239s. Both
[Bun](../../selfhost/build/phase170/lexer-controls-bun/report.json) and
[Node](../../selfhost/build/phase170/lexer-controls-node/report.json) passed all
315 exact token pairs, ten comparator controls, the 16/32/64KiB complete token
streams, and the 64KiB complete loader-graph comparison. These are finite
equivalence controls, not an independent compiler-correctness proof.

The Bun 64KiB lexer observation was 0.3974s before and 0.1601s after, about
2.48 times faster. The corresponding complete loader observations were
1.8037s and 1.9442s. These single-process, unpaired diagnostics do not establish
a whole-loader speed gain, explain peak memory at the full compiler size, or
measure native cost. Node also passed, but the two engines and their memory
observations are not interchangeable benchmarks.

After those gates, the five wrappers/helpers were integrated into the maintained
lexer. The [integration audit](lexer-suffix-integration.json) confirms five changed
bodies, five appended helpers, and 8,404 unchanged original declarations. All
8,409 original declarations retain their global order. Every declaration body
matches the checked experimental source. All 112 current protected entries and
the main entry are unchanged; 111 protected entries also remain exact against
Phase152, with the already-authorized `p111_native_request` integration being
the sole earlier difference.

The final maintained assembly is
`selfhost/build/phase170/source-final/compiler.bend`, SHA256
`434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`,
3,150,535 bytes. The initial canonical source, checked experiment and old recipe
are preserved. Recipe changes append only five declaration-order rows and five
inventory rows. Fresh final-source B1/B2/B3 acquisition, complete-loader behavior,
and native cost/qualification remain separate integration gates. No speed gain
or release promotion is inferred from the source integration.
