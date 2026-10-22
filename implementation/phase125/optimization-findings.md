# Phase125 optimization findings

The initial bounded analysis at `7d37d51` compared append variants and selected
source06 for integration. The variant observations below retain their original
scope. Subsequent broad/native qualification passed: the final44-point ratio is
1.89221× upstream and hosted→N1→N2 reproduces exact QBE. See the
[final report](README.md) and [native results](native-results.md). No recursive
research acceleration is established.

## Removed work is real; its value depends on the surrounding computation

The automatic append transformation recognizes checked structural append equations,
preserves producer→suffix→append evaluation order, and attaches the suffix to an
entirely unique dynamic left spine. Shared/static inputs retain the original
implementation. It eliminates reconstruction; it does **not** eliminate the
producer or its traversal/ownership probe.

Adjacent-repetition diagnostic counts establish these per-invocation differences:

| Workload | Constructor cells | Consuming takes | Allocator requests | Successful append / visited cells |
| --- | ---: | ---: | ---: | ---: |
| Original RLE | 32→26 | 42→36 | 54→45 | 3 / 6 |
| Independent map/append256 | 770→514 | 770→514 | 770→514 | 1 / 256 |

RLE's sized extend1 calls fall 12→6; transfer's fall 512→256. Allocator requests
include pool hits and reference-count allocations, not system malloc calls.
Counters include the whole process; the reported differences use adjacent
repetition counts and retain their original output checks. Instrumented clocks
are excluded. RLE counts use the source01 wrapper with the RFC1 runtime; transfer
counts use source04. They do not establish source06 counts. Exact evidence:
[RLE counts](../../selfhost/build/phase125/append-counts01/report.json),
[transfer counts](../../selfhost/build/phase125/transfer-counts01/report.json).

On the independent varying-value map/append256 input, three rotated clean rounds
give parent 265 ms, identity-only 251 ms and typed-append+identity source04 **165 ms**:
37.7% less than parent, 34.3% less than the identity-only composition. Every result
and validation count passes. This workload is deliberately outside the frozen
historical score; it demonstrates transfer and a useful reconstruction reduction,
not representative whole-language speed. See
[transfer screen](../../selfhost/build/phase125/transfer-screen01/report.json).

## Source ceiling and automatic optimization are different experiments

The changed-source RLE ceiling evaluates the recursive suffix before filling the
repeated prefix. It changes only this pure finite construction, retaining the
frozen wrapper/count/oracle. Its 1995 ms versus 2433 ms parent median is 0.8200×
(18.0% less), while upstream is 399 ms in that screen. It removes the same six
constructor/take pairs, but uses zero extend1 calls; automatic append retains
the original producer's six calls and adds a read-only ownership scan. These
differences are observed; their individual shares of the timing gap are not
isolated. Do not describe the 18% ceiling as an automatic compiler gain.
[Ceiling screen](../../selfhost/build/phase125/ceiling-screen01/report.json),
[ceiling counts](../../selfhost/build/phase125/ceiling-counts01/report.json).

The unchanged-source RLE variants show why allocation counts alone are insufficient:

| Variant | Candidate/parent median | Evidence |
| --- | ---: | --- |
| Raw-only probe | 1.0584× |[append-screen01](../../selfhost/build/phase125/append-screen01/report.json) |
| Admit exact RFC1 dynamic cells | 1.0029× |[unique-screen01](../../selfhost/build/phase125/unique-screen01/report.json) |
| Direct owning-result ABI | 1.0004× |[value-screen01](../../selfhost/build/phase125/value-screen01/report.json) |
| Typed append helper | 0.9825× |[typed-screen01](../../selfhost/build/phase125/typed-screen01/report.json) |
| Typed append plus identities, source04 | 0.9758× |[screen-combined04](../../selfhost/build/phase125/screen-combined04/report.json) |
| Identities alone, source05 | 0.9858× |[screen-identity05](../../selfhost/build/phase125/screen-identity05/report.json) |

Each row is its own paired screen, not a controlled subtraction across rows.
Raw-only rejection discards useful unique cells that publication has wrapped.
RFC1 repairs that admission limitation but remains approximately neutral on the
small RLE prefixes. Removing output-slot transport alone is also neutral.
Small differences between the last three rows are not strong component attribution.

The first source06 RLE screen reported median 1273 ms versus 1214 ms parent
(1.0486×), with candidate rounds 1149/1273/1297 ms. Its separate six-family screen
shows roughly 0.3–2.6% lower medians. Preserve both observations; neither alone
establishes the sized ABI's incremental benefit.
[RLE06](../../selfhost/build/phase125/screen-rle06/report.json),
[families06](../../selfhost/build/phase125/screen-families06/report.json).

The subsequent matched, same-run ablation uses four rounds at scale 8, with all
outputs passing. Medians are source04 **2396.5 ms**, Phase124 parent **2423.5 ms**,
upstream **398 ms**, and source06 **2285.5 ms**. Source06 is 0.95368× source04
(4.63% less) and 0.94306× parent (5.69% less). The earlier isolated regression was
not reproduced in this matched comparison. This supports selecting source06 for
broad/native qualification; it does not yet establish a corpus or compiler-speed
gain. [Matched ablation](../../selfhost/build/phase125/ablation06b/report.json).

## Semantic obligations retained

Append admission proves the actual zero/two-constructor owner, exact recursive
tail type, unchanged heads/suffix/base case, and source-name-independent equations.
Its typed helper may omit proved shape checks; an arbitrary U64 import is not
authority to do so. The complete ownership probe still checks dynamic storage,
RFC count exactly one with acquire semantics, and the resolved payload location:
a dynamic RFC wrapper can point to static data. No mutation occurs before the
entire spine passes. Wrappers/heads retain their credits; final suffix publication
uses the existing capability/hot-constructor policy. The contract is sequential.

The direct result ABI uses zero only as refusal for these proved nonzero PAK/CTR
results. Primitive identities preserve the complete U64 word for exact
`u32_to_nat`/`f32_bits`; they do not authorize numeric conversion rewrites.
The sized ABI projection runs after existing verification: constructor metadata
and buffer capacity are proved, while take's actual input shape remains dynamic
and keeps its original checks. See the existing
[typed-helper audit](../../selfhost/tools/performance/phase125/producer/typed-helper-audit.md),
[RFC1 review](../../selfhost/tools/performance/phase125/producer/rfc1-review.md) and
[verified-ABI audit](../../selfhost/tools/performance/phase125/verified-runtime/audit.md).

The 21-line ordinary alias/static/deep-list suite, 16-line String producer witness,
and finite equation/identity/ABI controls support these bounded contracts. They
are not whole-compiler proofs. The transfer fixture's initial missing affine
duplication annotation was correctly rejected and retained; its corrected version
is separately pinned. No gate was relaxed to acquire the positive result.

## Highest-value next composition experiment

Preserve a private producer's fresh-spine endpoint across the already-supported
local helper/resume boundary. Current destination construction already knows its
root and last cell; finishing it with Empty discards that information, and append
later scans to rediscover the endpoint and uniqueness. A bounded experiment could
carry that existing private construction capability until the suffix is ready,
then finish once in original evaluation order. It must not expose an incomplete
value, skip payload ownership, or extend a capability after escape/sharing.

Test one existing producer and the unrelated transfer before generalizing. Require
unchanged outputs/aliases, explicit-stack safety and demonstrated disappearance
of the extra scan/finalization. The source ceiling motivates this question but
does not quantify its attainable gain. Compiler `nt_append`/reverse compositions
are concrete later transfer candidates, with no established hotspot attribution.
Source06 broad/native qualification subsequently passed; see the
[final report](README.md) and [native results](native-results.md). No new broad
framework is justified by these results.

## Final integration outcome

Source06 passes405 original45 observations, improves the44-point ratio
1.92031→1.89221× upstream, and passes hosted→N1→N2 reproduction plus native
focused19/full45. Its final independent transfer is241→163ms. The earlier
variant-specific evidence above is retained without relabeling it as source06.
