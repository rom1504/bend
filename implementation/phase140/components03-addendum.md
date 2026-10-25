# Component checkpoint through native API15

This checkpoint preserves completed component checks, source-check failures and the hosted integrated screen. It does not include the second native acquisition or qualify a compiler for installation.

The [checked API15 receipt](../../selfhost/build/phase111/p140-native-api15/report.json) binds source15, SHA `9d6ac8d5ae357fddb00dca1025d610921ea43b113e793cd9c144f2e6b2946902`. All **167** checks in [native-finite04](../../selfhost/build/phase140/native-finite04/report.json) pass: framing6, native runner20, checker cut7, batch14, exact comparison40, metadata16, late observer32, constructor catalogue4, global dependency7, erasure5 and static prefix16.

The late controls include the two dependencies found by independent review: an unrelated alias changing the scalar catalogue, and hidden erased-fact references, including their removal over successive revisions. Static controls compare complete original and cached prepared products, not only hit counts. The [late](../../research/phase140/late-cache-audit.md), [static-prefix](../../research/phase140/static-prefix-audit.md) and [promotion](../../research/phase140/promotion-audit.md) source audits are also snapshotted. Source checking and finite differential tests are not formal correctness proofs.

## Hosted integrated screen

[session-screen03](../../selfhost/build/phase140/session-screen03/report.json) includes frontend, backend, registry, rendering, complete byte materialization, hashing and file writing. These are ordered observations in one hosted process; they are neither native timings nor a calibrated overhead estimate. Seed acquisition is separate.

| Actual edit | Original fresh B | Candidate cold B | Candidate warm B | Fresh/warm | Cold overhead |
| --- | ---: | ---: | ---: | ---: | ---: |
| Lexer shift13→12 |2.654s|3.186s|1.396s|1.90×|+20.0%|
| Map multiplier31→29 |3.760s|4.600s|1.403s|2.68×|+22.3%|

All cold, warm and no-op B products equal independent fresh B byte-for-byte. Complete frontend plans match, and A matches its frozen reference. The warm results show useful work removal. The cold observations exceed the planned5% guardrail; they must remain visible and require an explicit native tradeoff assessment. This screen alone cannot establish a cold non-regression pass. Do not multiply these ratios by isolated component improvements or by an earlier native edit result.

## Durable evidence and bounded cost

[components03/index.json](evidence/components03/index.json) maps **1,553** byte-exact members to their original paths. The **7,086,074** raw bytes compress to **1,293,268** bytes in [metadata.tar.gz](evidence/components03/metadata.tar.gz), with a verified extraction-free round trip. The snapshot includes native source/API01–15 identities, failed API04–12 diagnostics, finite04, screen03, versioned methods/modules and the three independent audits. Large compiler sources, APIs, generated QBE and binaries remain explicitly excluded payloads with recorded identities.

Seven historical working-path identity mismatches remain intentional: all seven resolve to exact earlier module/method snapshots in this archive. No missing historical payload is presented as a current reproduction input.

The [cost ledger](evidence/components03/costs.json) contains **72** completed guarded attempts, including **29** failed attempts, totaling **746.69s**. Maximum sampled process-tree RSS is **2,300,661,760 bytes**. Relative to the union of `components02` and `native-preflight01`, this adds **18** unique guarded attempts and **251.10s**, including10 failed attempts. The new archive is cumulative: **do not add its746.69s to those earlier ledgers**. Nested API seconds are not counted again.

These costs are charged guarded execution intervals, not elapsed research wall time or model quota. They exclude native image acquisition, full compiler edits and machine qualification from other receipt roots; this is a component checkpoint, not a final campaign-cost report.
