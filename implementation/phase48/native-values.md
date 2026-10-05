# Direct typed String.append: checked independent outcome

Status: **independent checked-source semantic suite PASS** for `checked-native01`,
against selected Phase47 `checked-array06`. Actual Unicode activation and the
fresh three-point screen also pass. This is not an installed-release or universal
String-native speed claim. This owner recomputed saved data and ran no targets.

The [design](../../design/phase48/native-values.md) and
[native leaf emitter](../../selfhost/src/back/js/ir/native-values.bend) recognize
only canonical JWNative String.append with exactly two already-proved String
values. Existing proof supplies exact native identity, quantities, arity and
String input/result types. Emission replaces residual
`callOwned(get(G,"String.append"),[left,right])` with `left+right`; other native
leaves retain their previous fallback. Operand order, original public ABI,
host/source admission and generic fallback stay in place. String allocation
remains.

## Exact image and evidence

- Candidate API: `ea62fafd65cd04b173015e09e786fbeede7b4485fa79a842a57a5f5a1eaa1eeb`.
- Baseline API: `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`.
- Shared runtime: `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
- Shared Base: `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.
- Node: v24.18.0; executable SHA-256 `41a74efb34cbde5c7632cdac0cf8bd1a14d0b8d73dc1e82755014d9a9ce70f5c`.
- Controller: SHA-256 `5b38104857958369f597ddc866ea2ee1732d27567695c25338290128c239ffe3`.
- Independent source: SHA-256 `1f502b3037f98f72437f729baefed38a568dca9322ea87e5909e903ca07cf505`.

The [raw report](../../selfhost/build/phase48/native-controls01/report.json) is
complete/pass. [Compact evidence](evidence/native-values.json) binds its digest,
exact attempt manifests and compiler/source/catalog/module identities. Receipts
require checked successful emission, exact independent source, the same catalog,
and the selected array06 baseline. The controller checks actual catalog and Node
hashes, then rehashes original inputs and separately counted modules at completion.

## Ordinary activation and complete values

The renamed source surrounds a middle String with an alpha/emoji left String and
decimal-seed/accent right String. Its independent oracle is
`"α🙂".repeat(n) + (String(seed) + "é").repeat(n)`. All seven ordinary public calls
match that complete String. Separate diagnostic comma-expression instrumentation
counts executed native leaves; clean compiled modules remain performance inputs.

| Turns | Seed | UTF-16 code units | Observed private concat executions |
| ---: | ---: | ---: | ---: |
| 0 | 0 | 0 | 1 |
| 1 | 0 | 5 | 3 |
| 2 | 17 | 12 | 5 |
| 3 | 4294967295 | 42 | 7 |
| 16 | 123 | 112 | 33 |
| 64 | 17 | 384 | 129 |
| 4096 | 7 | 20480 | 8193 |

Baseline counters are zero. The candidate executes one suffix concat plus two
per turn in this source, including 4,096 turns. Counts describe this qualified
route; they are not compiler eligibility rules or thresholds. Actual positive
ordinary execution proves the emitted leaf is live. Proof state is null after
every call.

**1,372 complete-value rows** cover 14×14 inputs across append, reversed append,
fork, both Bool branches, a pair and a custom record. Inputs include empty/ASCII,
accents, combining marks, alpha/emoji/CJK, NULs, lone high/low surrogates and mixed
malformed UTF-16. Scalar strings match independent concatenation oracles and
baseline values. Pair/record checks include every field and public constructor
representation. Read-only recomputation independently matched all saved rows,
using UTF-16 code-unit concatenation and JSON normalization of paired surrogates.

## Mutation and public boundary controls

All **18 boundaries** match baseline outcomes and ordered event traces:

- Native G binding/code replacement and binding/code getters; env, bound and
  arity changes; own code.call getter.
- Global String replacement, String.prototype method/getter changes, and an
  Object forcing marker with nested reentry.
- Original native-code error and an error after restoring the dependency and
  reentering the ordinary root.
- Completed partial application, raw/forged code entry, and public coercing inputs
  with left/right demand order.

Mutation/host/raw/coercion cases have zero private concat executions. Restored
dependency reentry executes five concats in the nested call; the outer call
refuses before the mutated code callback. Completed partial application matches
the original public path (observed zero counters). Native errors retain sentinel
messages/event order, and proof state is null after each boundary. This separates
valid nested admission from an outer mutation bypass.

## Actual corpus activation and fresh timing

The checked native image emits 14 private concat sites in Unicode. Ordinary
Unicode16/64 execute **178/706** of them, respectively, and match the full
independent strings (192/832 UTF-16 code units). Morning emits and executes zero
private concats and retains its complete 29-code-unit oracle. All three restore
proof state to null. The [corpus probe](../../selfhost/build/phase48/native-corpus-controls01/report.json)
uses reviewed controller SHA-256
`a237b95dfdc14f41f0a4e0ce031f26c2bbba324368d5a5c92a3063050870f751`;
marker commas preserve exact expression inversion and are AST checked. Its
receipt joins checked source/catalog/API/runtime/Base and exact distinct cases.

Clean modules, separately from counted modules, were measured in three rotated
fresh rounds per role/point: 27 samples, 21.42 seconds, no budget overrun. CPU 3,
Node v24.18.0, 1024 MiB heap, 2048 MiB RSS limit and 4096 MiB available-memory
floor; three warmup calls plus 350 ms, 40 ms calibration and 150 ms target.

| Point | Baseline μs (range) | Candidate μs (range) | TS μs | Gain | Candidate / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| coverage-unicode-text-16 | 91.2131 (90.6573–92.6043) | 75.0995 (74.8611–75.3358) | 22.1936 | 1.215× | 3.384× |
| coverage-unicode-text-64 | 239.5709 (238.9542–242.8460) | 157.5801 (155.7608–159.0477) | 86.6961 | 1.520× | 1.818× |
| test-morning-program | 236.6312 (234.5009–237.5092) | 231.9803 (231.1714–233.2290) | 3.3435 | 1.020× | 69.382× |

Half-sample drift percentages, in recorded fresh-round order:

| Point | Baseline | Candidate | TS |
| --- | --- | --- | --- |
| coverage-unicode-text-16 | -0.14, 0.25, -1.08 | -3.33, -3.58, 3.44 | -5.70, -3.28, -0.98 |
| coverage-unicode-text-64 | -5.19, -4.86, -4.76 | -1.74, -0.27, -1.32 | 2.55, 2.05, 3.25 |
| test-morning-program | -36.72, -33.50, -9.45 | -35.32, -35.78, -36.20 | -10.97, -10.56, 3.43 |

Unicode gains 1.215× and 1.520× with executed concat removal. Morning is a
neutral mechanism control: its 1.020× median difference cannot be attributed
to private concatenation. Its large negative drift also cautions against
interpreting this small change as a stable gain. Three fresh samples establish
a useful screen, not significance, universal parity, or a complete release.

[Raw timing](../../selfhost/build/phase48/native-screen01/report.json) and
[hash-bound screen summary](evidence/native-screen.json) retain all samples,
ranges, drift, output checks, protocol and image inputs. All 27 complete first
results equal their catalog oracles; summary medians/ranges were independently
recomputed. Raw reports and counted modules were not changed.

## Decision and remaining work

This narrow native leaf is semantically qualified on independent fixtures and
shows actual gains on both maintained Unicode points. Keep it for integrated
Phase48 qualification; final release admission still requires the combined
image's independent semantic suites, compiler/output costs and broad corpus
tradeoff. Other native leaves cannot inherit this result. Entry-guard allocation
removal is separately deferred and unsupported host-footprint narrowing is
rejected; neither contributes a claimed combined gain.
