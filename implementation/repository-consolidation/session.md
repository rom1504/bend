# Preserved experimental sessions and object reuse

The maintained compiler retains the experimental incremental/session path, with
one interface under `selfhost/tools/build/session/`. It is not a second compiler.
The source audit found all 609 accepted session declaration names in the shared
source and retained nine later body refinements. The only additional Bend module,
`selfhost/src/session/object-frames.bend`, adds three pure declarations exposing
existing `P134Cursor` machine-unit boundaries; it overrides no declaration.

The host retains two distinct protocols: P140/2 transports counted opaque byte
pieces; P135/1 groups compiler-produced QBE at Bend-provided boundaries. Object
keys include exact unit bytes, producer, target runtime, toolchain, flags,
adapter methods and policy. Source identity is recorded per request but excluded
from unit keys so an unchanged unit can survive a real source edit. The known
generated-symbol globalization is mechanically audited against original ELF
allocated bytes, relocations and symbol metadata.

## Executed qualification

The initial checked session API uses parent source
`96c40c9dd273e2fae5fabfe68093aa7fb8f25f075e2317bed06ff46d4feaab80`
plus the adapter, producing source
`5fedc4036b4c434dc48eb60c37f190e045f05c47c18b7e4df4390a833ebbad48`.
Its B1 API is
`ff2d6f8389c6a759cc15bd249f3cdeff41ae27014a291f68666a44551df6ac88`.
These are execution receipts, not inferred capabilities from source presence.

| Gate | Observed result |
|---|---|
| Checked acquisition | Passed; eight explicit session API exports |
| Semantic requests | 8/8 passed; each compared with an independent empty session in the same mode |
| Positive requests | Cold A, no-op A, edit B, revert A, recovery B, recovery A all exact |
| Refusal/recovery | Parse and type errors refused without changing prior compiler cache; later requests succeeded |
| Render reuse | No-op: 956 hits, zero misses; real edit: 952 hits, four misses |
| Object reuse | Cold: three builds; no-op: three hits; edit: two hits and one build |
| Independent program outputs | Cold/no-op/edit printed `3`, `3`, `5` |
| Object identity controls | Eight key dimensions separated; deliberately corrupted private-cache object refused |
| P140/2 byte controls | 34 passed, including changed source acceptance and producer/runtime/policy rejection |
| P135/1 unit controls | 12 passed, including 200KB data and every-byte chunking |

Primary evidence is under `selfhost/build/consolidation/`:
`session-api01`, `session-semantic01`, `session-semantic-controls01`,
`session-objects01`, `session-transport-controls01`, and
`session-protocol-controls01.json`. Compact pinned results are recorded in
`session-evidence.json` alongside this document. The machine-stage observations
are one tiny correctness fixture; they are not a benchmark or an incremental
speedup claim.

The later maintained source is
`00940ed508e7d1456dd19bee01b0d2e16ac227fdf13ac306e805a1e4c982fb5e`;
with the same adapter it becomes
`8a0410f6bb7ff24c23f9f374407ef36f7d92a37edb263e44dfe7c9e272dcaac0`.
The original receipts remain unchanged. The separate serial current-source gate
`session-current01` passed all five steps in 28.4 seconds: checked API acquisition,
fixture preparation, eight semantic requests, semantic assertions and object
controls. It repeated all eight same-mode cold comparisons, both error-recovery
cases, outputs `3`, `3`, `5`, the three-object no-op reuse, the one-object rebuild
on edit and the corrupt-object refusal. Its independently acquired API was byte
identical to the initial API (`ff2d6f83…`); the new source and execution receipts
remain distinct. `session-current-plan01.json` / `session-current-job01.py`
record the exact serial commands. This elapsed time measures the finite gate,
not compiler or incremental-build performance.

## Offline relocation result

`session-portability01/report.json` passes. The filtered tree contains 207
maintained source modules and explicit session/build helpers, without `.git`,
historical performance methods or a copied experiment tree. Nine relocated
commands assembled the current source byte-exactly, appended the adapter,
verified seven explicit asset pins, prepared fixtures, imported both CLIs and
passed all 34+12 protocol controls. A Python file-access audit refused access to
the original repository for those commands: zero such accesses occurred. The
initial explicit staging copies necessarily read their named original inputs.
No compiler, QBE, linker or generated program ran in this audit.

The prepared Base carrier binds the absolute logical Base path as well as bytes
and source spans. The audit intentionally relocates Base and confirms cached
preparation refuses that stale path binding. Rewriting its stamp would not
establish validity. This is an explicit portability boundary: a fresh workspace
needs a newly generated and qualified prepared carrier for its Base path, or an
explicitly retained external Base binding. Ordinary live preparation is a
separate path; this session interface currently admits cached preparation only.

## Final fresh-worktree audit plan

1. After consolidation is committed, create a fresh checkout from that exact
   commit. Copy no `selfhost/build`, performance phase directory, node modules or
   untracked helper. Confirm all selected methods are tracked.
2. Assemble maintained QBE, hosted and native-C entry profiles with `source.py`.
   Compare source hashes against the declared commit's source receipts, keeping
   the additive session adapter separate. Acquire explicitly named external
   tools/assets; external pins are allowed, implicit historical lookup is not.
3. Obtain a fresh prepared Base carrier/binding for the new absolute Base path,
   or declare retention of the original external binding. First demonstrate
   stale-path rejection; do not rewrite old evidence into a new qualification.
4. Under one bounded outer resource guard, acquire a checked session API from
   that checkout and run the existing eight-request semantic gate, its eight
   mode-matched cold comparisons, and the three object/program controls.
   Preserve the original IDs and record new source, image and tool identities.
5. Run the offline transport/refusal controls and inspect active imports for
   historical method paths. Record runtime/producer/policy mismatches and
   corrupted-object refusal. Native batch, native error recovery and broad
   self-hosting remain separate qualifications; do not count unsupported lanes
   as passes.

The selected capability remains experimental. These finite tests preserve
useful functionality and its admission rules; they do not prove arbitrary edit
invalidation, full compiler correctness, native session recovery, a self-hosting
fixed point or a generally stable separate-compilation ABI.
