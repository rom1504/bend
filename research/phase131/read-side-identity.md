# Read-side identity: preserve one complete lookup computation

The fresh Phase131 profile moves priority from insertion to lookup. Lexer
active contexts include `index_find` 5.77% and `index_bucket` 7.92%; Map includes
3.78% and 2.92%, respectively. The surrounding `p111v_get` context is another
3.62%/0.81%, partly covering synchronous hash-reader work. These are diagnostic
owner fractions, not disjoint physical costs that can be freely added to other
profile categories. The insertion experiment remains useful, but cannot by
itself remove the much larger read-side cost.

## The hash loop is already borrowed; the tree loop is not closed

Static inspection of the qualified Phase130 QBE and ELF shows:

| Selected computation | QBE lines | Machine instructions | Concrete observation |
| --- | ---: | ---: | --- |
| Private `index_hash` reader | 101 | 71 | Already emitted as `$p118borrow.read.index_hash` |
| `index_bucket` direct worker | 352 | 327 | Existing direct worker; 21 sink and 5 constructor callsites across all paths |
| `index_find` scheduler segment | 431 | 426 | Five jump, seven constructor and 17 sink callsites across all paths |
| `index_find_leaf` scheduler segment | 153 | 112 | Cross-helper return to `index_find` |
| `index_find_absent` scheduler segment | 100 | 95 | Dispatch through another helper |

These are static counts, including uncommon paths, **not** calls per lookup.
The reproducible input pins, extracted QBE and disassembly are in
[`identity/read-inspection/report.json`](../../selfhost/tools/performance/phase131/identity/read-inspection/report.json),
produced by `identity/inspect-read.py` without executing the target program.

The source-level cycle is:

```text
index_find
  KDef legacy case -> index_find_absent
    non-absent -> index_find_leaf
      internal node -> index_find
```

The legacy helpers consume/destructure records and then pass their reconstructed
value onward. Consequently, the main lookup cannot simply remain a local
self-tail loop, even though the Patricia algorithm itself is such a loop.
This is a stronger immediate opportunity than another name catalogue.

## Bounded candidate

`identity/read-loop-v01.bend` unfolds only those dispatch decisions into
`index_find`. It keeps the exact order of absence, zero-mask, hash and child
selection checks. It still calls the original collision-bucket lookup and
returns the original full KDef payload. All recursive tree edges now return
directly to the same function.

No hashes, names, type IDs, ownership contracts, effects, final verifier checks,
runtime imports or global representations change. Unlike the insertion
experiment, the rewrite needs no additional canonical-tree invariant. A finite
malformed legacy/concrete node follows exactly the original helper decisions,
including short child lists and zero-mask `KIndexNode` bucket behavior.

The expected removed work is helper-boundary reconstruction and generic
scheduler transport. Successful source checking alone does not demonstrate it:
inspect the emitted direct worker/local loop and measure native execution.

`read-controls-v01.bend` contains the exact selected original/helper definitions
with names changed only for differential comparison. `read-check.mjs` compares
11,088 generated canonical/mixed-legacy lookups against both that clone and the
already checked Phase130 fixture API. It also compares 840 deliberately malformed
finite lookup inputs. Whole KDef equality covers payloads and duplicate ordering.
The checked API passed this screen: 336 generated trees, 11,088 full-payload
lookups and 840 malformed queries (`read-loop-finite01`). The CPU6 guard took
2.56 seconds and peaked at 191 MB process-tree RSS.

The same lane then compared complete lexer/closures/Map emissions from both
the qualified Phase130 API and candidate. All six outputs exactly matched the
frozen independently qualified native QBE oracles (`read-loop-request-check01`).
The guard took 43.74 seconds and peaked at 714 MB. Single-round hosted timings
were mixed and are not evidence of a native speedup. The native proxy and
machine-code checks below subsequently established the bounded benefit;
full native compiler request speed remains a separate measurement.

## Small native discriminator

`identity/read-proxy-cases.json` freezes two ordinary Bend programs. Both use
the selected compiler's actual KDef/index representation and 256 actual compiler
declaration names. One uses the original lookup, the other the closed loop.
The same qualified compiler should compile both.

The timed loop holds an already built immutable index while repeatedly querying
all names. Construction lies outside the `IO.now` window in both variants;
ordinary controls still perform and validate construction. The independent
checksum and millisecond parser are the already frozen
`identity/timing-oracle.py`. This tests actual representation, lookup, ownership
and transport costs without acquiring a full compiler image.

If it wins, use the candidate compiler API to require byte-identical whole
lexer/closure/Map QBE. Only then pay for native compiler acquisition and complete
request timings. If emitted lookup still uses generic dispatch or runtime does
not improve, preserve that negative result rather than generalizing the change.

## Why not simply borrow the returned KDef?

`index_find` returns an owned descendant of its held input tree. Existing
borrowed observers prove a scalar, nonescaping result; returning a descendant
requires retaining that exact result before cleaning up the held root. A borrowed
word cannot safely be passed through the ordinary owning result ABI without
that proof and transition.

There are further layout barriers: KDef has nine fields, while current observer
admission allows eight, and Patricia nodes have two recursive children rather
than the previously supported single-child spine. The runtime's borrowed-field
helper itself accepts exact CID arity, but layout analysis and projected
verification deliberately impose the narrower supported contract. Relaxing a
number alone is not a complete implementation.

The separate shallow-view experiment is valuable for scalar queries, but its
current KTerm/packet work should not be conflated with a safe owned-result tree
reader. Closing the source computation first is cheaper, simpler and does not
need that new ownership interface.

## Reusable lesson to test

A compiler can know how to optimize all of a lookup's individual pieces yet
lose its local loop because trivial compatibility helpers cross recursive
boundaries. The immediate remedy is a small implementation consolidation.
If this transfers, a later general optimizer rule could flatten such bounded,
pure dispatch helpers within a recursive component while preserving stack-safe
control flow. That broader transformation is a hypothesis, not part of this
prototype or an excuse to add another pass now.

## Measured native result and actual machine change

`selfhost/build/phase131/read-lookup01/timing/report.json` contains five
alternating pairs from ordinary programs built by the same qualified Phase130
native compiler. Median timed read work fell from **283 ms to 214 ms**, a
**24.38% reduction**. Independent ordinary and timed checksums passed. This is
an extracted compiler computation, not a whole-compiler speed claim.

The static inspector `identity/inspect-native-proxies.py` preserves exact QBE
and disassembly in `identity/read-native-inspection/report.json`. Across the
whole lookup/helper family, the original has 13 functions, 1,060 QBE lines,
1,003 machine instructions and eight generic-jump callsites. The candidate has
four functions, 1,594 QBE lines, 1,018 machine instructions and zero such
callsites. The direct worker has local backedges, without native self-recursion.
Thus local control flow removed scheduler work while whole-family machine
size grew only 1.5%; comparing just the new large worker with the original
small entry segment would misrepresent the size tradeoff.

`lookup-loop-v01.bend` applies the same source consolidation to the catalogue
wrapper (`lookup -> lookup_cached -> lookup_named -> lookup`). Its additional
2,656 full-payload controls preserve first-match behavior, authoritative cache
misses, duplicate names, collision buckets and malformed cache children.

The composed FAST source is
`selfhost/build/phase131/combined-fast-source02/compiler.bend`, SHA256
`7f7952989ca1dd4b9c5246ee7f2fdbdee6c9b0e1a603f2bfb2244d76a75d22fd`.
It combines one-pass insertion v02, closed index lookup, closed catalogue
lookup and the separately tested usage summaries. The `combined-fast-identity02`,
`combined-fast-read02`, `combined-fast-lookup02` and `combined-fast-usage02`
receipts pass. `combined-fast-request02/report.json` additionally preserves six
byte-identical lexer/closures/Map emissions and 16 actual Base-body usage
comparisons. None of these hosted gates replaces native qualification.

## A newly visible allocation boundary: constant sentinel construction

The selected `missing()` calls `atom("Absent")` twice. `atom` calls `kt`, which
constructs an immutable KTerm. Static preparation sees those calls before
ordinary inlining exposes their closed constructor trees, so the eventual
native code allocates two constant KTerm nodes and a KDef node for each sentinel.

`identity/missing-static-v01.bend` writes precisely that same closed tree in
the source. The existing static-data pass and independent verifier then suffice;
no new cache, allocation ABI, optimization pass or ownership rule is required.
The bounded checked-API emission `missing-static-emit01` confirms:

| Code region | Original QBE lines | Exposed constant | Constructor callsites before/after |
|---|---:|---:|---:|
| `missing` worker | 153 | 7 | 3 / 0 |
| Closed `index_find` worker | 1,563 | 681 | 32 / 14 |
| `index_bucket` worker | 352 | 205 | 5 / 2 |
| Whole proxy | 1,228,019 bytes | 1,087,633 bytes | 118 / 71 |

The original emission exactly matches the earlier native proxy's QBE hash.
`identity/missing-inspection/report.json` pins the inspection and verified
outputs. These are static counts, not measured dynamic allocation or runtime
gains. The native discriminator is
`identity/missing-mixed-manifest-v02.json`: alternate a real present name with a
guaranteed absent spelling, while building names and the index outside the
timer. This avoids using the existing all-successful read timing loop to judge
a miss-path optimization. Its independent arithmetic oracle lives in
`identity/missing-timing-oracle.py`.

If the native discriminator pays off, this suggests a broader source-level
opportunity before new optimizer machinery. A subsequent lexical inventory
found 425 actual bare literal `atom` calls, including 351 `"Absent"` calls;
four calls are in protected verifier declarations. Raw substring counts
included longer helper names and were too high. Exposing closed immutable construction earlier may remove
work that the current backend already knows how to eliminate. That extension
received separate bounded checking; see [the immutable-constants assessment](immutable-constants.md). It is not part of the earlier combined FAST source.
