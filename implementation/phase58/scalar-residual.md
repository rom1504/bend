# Scalar provenance through residual Word patterns

Status: the checked scalar01 build passed strict checks in 60.3 seconds, and the
private baseline/candidate fixture acquisition passed in 25.3 seconds. The focused
three-image controls passed at the default Node stack in 11.26 seconds. Source and
controls are independently reviewed. Performance measurements remain pending;
these qualification times are not generated-program speed measurements.
The root applies the patch after the independent field/lookup changes, rather
than overwriting their constructor file with this experiment's parent snapshot.

The [Phase57 analysis](../phase57/implementation-comparison.md#7-sk_char-is-canonical-key-escaping-with-a-separate-numeric-lowering-cost)
found that numeric matching already uses scalar equality/mask tests. Residual
bindings still construct Word suffixes and rebuild full Words in the default
arm. The proposed rule applies to any checked native U32 row with a proved
reconstruction; it does not recognize compiler functions or benchmark names.

The patch attaches private metadata to residual bit/suffix binders: the held
scalar origin and exact bit position. A U32 constructor can consume that fact
only if its checked Word expression covers exactly all 32 positions with literal
Bool heads or same-origin, same-position fragments. The result is mask/or scalar
arithmetic. Explicit prefix replacements are reproduced even for the final
unconditional row, rather than assuming that row's positive mask test ran.
Depth 32 is explicit, so no JavaScript shift-by-32 wrap can enter the result.

Ordinary residual uses—including captured uses—refuse the complete row change.
The compiler then regenerates its original body and bindings. This matters when
a callback receives and mutates a Word suffix: scalar provenance must not bypass
that mutation. The same refusal preserves escaping Word aliases and moved or
mixed-origin fragments. Successful rows eliminate all residual objects, while
the original scalar is still evaluated and held once at the matcher boundary.

F32 residual rows retain their old lowering, and existing whole native inverse
views remain first. The focused controls require unchanged F32 function bodies,
NaN classification, signed-zero preservation and cross-image bit observations;
they do not introduce a new NaN payload or arbitrary boxed-host-value contract.

[Source overlay and commands](../../selfhost/tools/performance/phase58/scalar/README.md)
include the before/after hash receipt, patch, independent source fixture and
three-image controller. Cases cover default reconstruction, changed low bits,
a bit 31 suffix, moved bits, mixed origins, ordinary aliases, callback mutation,
throwing callbacks, partial application, ignored fields and F32 fallback.
Positive syntax assertions are paired with a separate untimed counter derivative.
The existing 34-case numeric suite remains required for the selected candidate.

The compiler may render a refused row twice (one proof attempt and its old
body), so compiler throughput needs its own measurement. Removed generated Word
syntax is not proof of V8 allocation elimination or a quantified speedup.

The actual acquired module has the intended syntax change: `residual` shrinks
from 1,681 to 747 bytes, with eight `u32_to_word` and four `word_to_u32` call sites
replaced by four scalar reconstructions. `prefix` shrinks 422→195 bytes and `high`
1,588→211 bytes, with both conversion helpers absent from those functions. All
seven refusal/F32 functions checked here are byte-identical. These are static
source counts, not allocation measurements. Inputs are the baseline/candidate
`scalar-residual.mjs` modules and complete manifest under
`selfhost/build/phase58/scalar-fixtures01`.


The completed `scalar-controls02/report.json` records **1,728 counted observations
per role** for checked-lookup01, checked-scalar01 and pinned TypeScript: **5,184
across the three roles**, plus the shared checksum. Each role passed the same
independent arithmetic, alias, mutation, throw, partial-application and F32
oracles. The 275 U32 inputs cover 0–259 plus boundary values through 2^32−1;
36 mixed-origin pairs and the targeted host callback observations also passed.
All ten F32 cases retained matching observed bits across all three images,
including negative zero, infinities, subnormal and NaN inputs. This does not
broaden the existing NaN payload contract.

The candidate's separate diagnostic derivative recorded exactly three scalar
entries for three positive calls. All value observations above used the original
modules. The seven refusal/F32 function bodies matched the baseline exactly;
the three positive functions contained eight static scalar reconstruction sites
and no Word conversion calls. The 34-case numeric suite and broader performance
gates remain separate selected-candidate requirements.

The original TypeScript acquisition 01 sandbox `git` spawn refusal is retained;
independent acquisition 02 passed without a compiler or oracle change. The actual
private paired acquisition used the preserved producer SHA `a428473a…`, and
controller v2 reverified its full attempt/copy/input bindings. Controller v1 and
the later hardened paired-producer successor remain separate artifacts.

Exact frozen identities (raw paths are relative to `selfhost/build/phase58`):

| Artifact | SHA-256 |
| --- | --- |
| Isolated scalar patch | `0f9f08dba5b4e3ecfbc6733c6a18062a097bab9bcc0d56a3dc80de2082582787` |
| Focused source | `a3b71274e3542e05144f27b22d783fb9ce4fa9b7107a1bc8e013e9e9eb6d9f01` |
| Catalog | `0ee0a934f43cbaf39c87ce2c115e7f3f3bcada7c56fc1d0bc2da15ff6eac9eec` |
| Consumed controller v2 | `a3395faa3b99b4f41bc96c511494a3ea5e7fa5e900eda9ae35f8ab47877890b4` |
| `checked-scalar01/attempt.json` | `e2ab8f0d29811bef2989d296289fd1b8cec08359121a07e29c919f1db9856869` |
| `scalar-fixtures01/manifest.json` | `52a2e08729cd8fdf97b9c2bd151963861113ec6841566dbae55f967737e9467f` |
| `scalar-typescript02/manifest.json` | `d5fd0f897281a72baae2575619ae81c83424fe8d54e546c39865a8b83106478e` |
| `scalar-controls02/report.json` | `d5a5f42ac772008a8e7dcb45935314a62ca02966b732dc2854d4144be3faae9b` |
| Baseline emitted module | `d609b3800aa798cba24f73c5e39a085f580d1a08e8d347ee2c93945711f04959` |
| Candidate emitted module | `6f1cfb1e9a61eba7f3a5482ee86a47ef9688f8df2811bc67bd8b7088ecef5d24` |
| Pinned TypeScript emitted module | `4abfaccaffe088ac48b549c9fc46d892a855d58e7ee5aed4cc710774881fbd73` |
