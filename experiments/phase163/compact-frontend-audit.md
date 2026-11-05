# Independent compact-App frontend review

Read-only review of `selfhost/tests/phase163/compact-app.bend`,
`compact-frontend.bend`, the raw structural controls, maintained prefix loader
and checker entry, and the retained six hosted observations. No compiler,
benchmark or generated target was executed by this reviewer. No blocking defect
was found in the bounded frontend comparison; the limits below remain material.

## Observation completeness and injectivity

`p163f_term` retains tag, name, ID, quantity, source interval, children and removed
names. It additionally retains physical Lambda/literal identity, Lambda quantity
presence and literal kind/number/text. Every field of all three KDef variants is
serialized, including index hashes/masks, buckets/children, types, values,
constructor books, native/unsafe flags and declaration order. DResult includes
the full returned book, error string and every diagnostic field: expected and
observed expressions, observed-presence flag, context, definition, span, note and
trail. Parse output includes its full FResult book, error and imports.

The encoding appears unambiguous on these finite valid-string graphs: variants
have distinct tags, numeric fields terminate explicitly, Boolean fields occupy
one character, strings are length-delimited and each list has an explicit end.
Lengths count Bend characters, not UTF-8 bytes; a future decoder must respect
that convention. Delimiter characters inside strings are not terminators.

The one deliberate quotient maps physical `KApp` variant3 to generic variant0,
with semantic fields `App`, empty name, ID0, empty removed names, stored quantity,
all children and exact origins. `KChildren` has disjoint zero/one/two/at-least-three
forms, so its list projection loses no semantic child sequence. This is semantic
App equivalence, not equality of physical representations or allocation graphs.

One independence limitation remains: the full observer uses the candidate's
`tg/nm/ix/qt/ks/...` accessors. A coupled producer/accessor mistake could therefore
mask a malformed internal value. The separate finite controls use raw
constructor matching and compare all fields independently, which helps detect
this failure mode but is not a universal representation proof. The full observer
also does not test heap sharing/reference identity or future consumers that do
not obey the public term-observation contract.

## Loader, prefix and checking boundaries

The workload copies the maintained `p86_plan` path through its DResult boundary:
Base preparation; located source/header; required Base import; ready-prefix
completion; source completion; graph trace; and the same checker dispatch.
The `suffix >= 256` condition still selects `p143cb_program`; smaller suffixes
use `check_program_diagnostic_world`. The screen stops before proof reporting,
ownership eligibility, annotation and native lowering, as advertised.

The physical files transporting inputs do not alter origins: both variants use
the same in-memory `/phase163/Base.bend` and `/phase163/Main.bend` identities and
the maintained source-interval calculations. Hosted preparation creates a seed
inside each exact API image. No old-image seed or public three-variant cache
carrier is passed into the compact image. The native workload likewise prepares
its own Base state.

Parse observation intentionally omits `FPrefixLoad.prefix/suffix/eligible` and
`FLoadTrace.done/sources`. Consequently exact FResult equality establishes the
observed parser product, but does not establish identical cache eligibility,
selected work or internal source-trace representation. Full DResult equality
similarly does not prove every internal checker state/algorithm path identical.
Any explanation attributing timing solely to App allocation must acknowledge
that these internal route facts were not included in this observation.

The old public typed-driver/cache ABI and backend constructor-fact consumers are
not qualified by this screen. Finite frontend equivalence is not a new BendTT
proof, whole compiler conformance, emitted-program equivalence or self-bootstrap.

## Timing interpretation

The hosted pilot prepares Base separately, then times the selected frontend
operation **including complete canonical serialization**. It saves outputs after
that timed call. These numbers are not exclusive parser/checker times.

The native transport records separate read, Base preparation, parse/load, check,
and observation/write spans. The result value is computed before the next clock;
serialization and file output begin after the check clock. Observation includes
diagnostic serialization as well as streamed definition serialization. Process
time still includes all observation, output and teardown.

Each stage's start timestamp precedes printing the preceding stage's timing
marker. Thus the next span includes that small stderr-print overhead. These are
wall-clock boundaries, not exclusive CPU attribution or allocation counts.
Short workloads should not be overinterpreted at millisecond granularity.

## Retained hosted success receipts

Receipt: `selfhost/build/phase163/frontend-pilot01/report.json`, SHA256
`7da3d6d7ef5ffe72d98d0d0097ca8a697c2ad506219d6bf7a635115d1cae4e55`.
The receipt itself was hashed during this audit; output pins below are the
existing receipt pins. Both roles' output tails were inspected in the earlier
review: every parse output has empty error `E0:` and every check output has empty
error plus an empty diagnostic. They are substantial graphs, not matching
failures or empty outputs.

Within `selfhost/build/phase163/frontend-pilot01/`, each row names both
`<stem>-baseline.txt` and `<stem>-compact.txt`; their lengths and hashes agree:

| Stem | Bytes per role | SHA256, both roles |
| --- | ---: | --- |
| `0-parse` | 975,288 | `1fca24382bbcaa15ec46a8ed0063e84eab2cecd07f6ab5a8f19b094c6c337ce0` |
| `0-check` | 725,554 | `45218aca8f6ee38674edecbcc27894993f4b9f85e2eb4babb6d7976d798b331e` |
| `1-parse` | 1,002,336 | `dde1af64d1cf1a49bc5cdde3d3a05a51aa4771369d36a596befd50c2e85656e5` |
| `1-check` | 754,445 | `f2abb69e86a881cc9797a1fb454b17f388ccdc4faac320c89d0252666c1d5c72` |
| `2-parse` | 849,471 | `358987f3c8bfc9920a37dd915f0d3353d86c0afce47989a0c97a2a01aa9a826f` |
| `2-check` | 672,237 | `4d489e21f3b1042c61a3e34c14798e4a24d7d3b71401a83ac64d5e5247b229ef` |

Inputs, relative to repository root:

| Index | Source | Bytes | SHA256 |
| --- | --- | ---: | --- |
| 0 | `selfhost/build/phase163/reverse-source01/compiler.bend` | 2,829 | `9120efd01328dab9fa833fa4783a060b43f4bf0d44c6bb3550588b0193fa6c68` |
| 1 | `selfhost/build/phase163/lookup-source01/compiler.bend` | 9,323 | `1548b9aee25b6e2ba52a83bc8d73f8a3418daff1d89a3847ae4fef18f803da6d` |
| 2 | `selfhost/tests/consolidation/native-broad/lexer.bend` | 7,257 | `f1d8e7e7e68f5c79053fadc35ba2f6e95f0115a40a5e6ce792e34d9f1faafdae` |

Common Base is `selfhost/.bootstrap/upstream-phase66/bend2/base.bend`,75,064 bytes,
SHA256 `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`.
The checked baseline API is `frontend-baseline-api03/api.mjs`, SHA256
`fbc95b01444676b78b6b5d65f91e0a914d8bb0a1c1cb8d1d633a2a6ab13323ed`;
the checked compact API is `frontend-compact-api02/api.mjs`, SHA256
`75a2bf654fe5448c5d743f8640bf305622b1770edde9b56ebe8f84df5b0bde30`.
Both are under `selfhost/build/phase163/`; their acquisition receipts and method
pins are retained in the pilot receipt.

The pilot harness asserts exact equality but does not itself assert the expected
success/failure verdict of every fixture. The six inspected cases succeed.
Future negative cases must assert their expected verdict independently so that
matching refusal cannot be mislabeled successful checking. No additional run or
code change was requested by this review.
