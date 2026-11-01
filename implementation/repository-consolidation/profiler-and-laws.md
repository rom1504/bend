# Profiler and law tooling consolidation

This lane migrated maintained tooling and exact fixtures without running a
compiler, generated program, profiler target or Lean. Root owns those execution
gates and final integration. The [migration map](../../selfhost/tools/laws/migration.json)
records exact origins, changes, supported commands and operational dependencies.

The generic profiler no longer imports a Phase68 script or reads Phase111/113
emitter source defaults. Four ELF functions were copied exactly; owner contract
sources are explicit pins with unverified producer provenance retained. Frozen
ABI control C and expected JSON bytes remain untouched. The Phase144 concat
extension is now `runtime.py --concat-v1` plus `concat_v1.py`, preserving its seven
hook/counter definitions and source-audited positive-branch limitation. Existing
`stages_v1` and runtime support remain unchanged.

The qualified direct-QBE runtime and both headers now live under
`selfhost/src/runtime/qbe/`, byte-identical to the serial-RFC source that produced
the current 119,096-byte object. Its only quoted dependencies are the two copied
headers; effect providers are already embedded. The single-mutator
`--threads 1 --gpu off` policy and historical ABI symbols remain. No current
runtime build needs to read a phase implementation. Object reproduction/ABI
execution are separate root gates, not inferred from relocation.

Seventy unique law/reference/oracle/challenge fixtures were copied exactly.
Current proof preparation extracts real requested declarations and verifies the
frozen contract boundary. The checker uses explicit operational assets,
nonopaque-law validation, independent BendTT checking and a known false kernel
control. Source checking alone does not count as an independent proof. Model
ownership theorems still do not establish native ownership safety.

The unchanged finite oracle covers 226 cases in 16 families, with 32 native
representatives. Two independently frozen later witnesses are optional and
separately labeled, giving 228/34. The worker verifies actual driver-resolved
API/runtime/Base identities and compares complete values. Compilation/admission
failure is excluded from semantic mutation detection. Source extraction now
accounts UTF8 offsets in one pass; a complete supplemented preparation took
0.53s in the observed offline command. This is tooling preparation time, not a
compiler performance measurement.

Offline validation passed 100 profiler tests and 7 law migration tests, including
wrong source binding, retired-helper refusal, Unicode byte offsets, exact fixture
hashes, semantic-rejection classification, additive counters and owner pins.
The saved [offline receipt](../../selfhost/build/consolidation/profiler-law-offline02/report.json)
also authenticates the four copied ELF functions and exact concat literals. Two
data-preparation failures remain preserved: absent Node in shell PATH, corrected
with an explicit versioned installed executable; and an audit variable-name
comparison (`hooks` versus `HOOKS`), corrected without changing hook values.

Current 96c source binds `representation`, `held-simple`, `tag`, and `permission`
packages offline. `scalars` refuses because `p98_term_scalar_finish` was retired;
its frozen historical proof remains available, but a new current-source bridge
is required. No old helper or positive receipt is substituted. Historical
aggregate challenge/audit campaigns remain restoration workflows, not fresh
current-source CI; their unique bad/good recipes and witnesses are preserved.

Root-run plans are under
`selfhost/build/consolidation/profiler-law-rootplan02`: a 39-case/6-native smoke,
the full optional 228/34 package, a reversible concat runtime/ABI control plan,
and a small independent C arithmetic sampler control. `assets-laws.json` uses
the checked upstream-produced B1 API, copied kernel modules and explicit existing
Lean4.34 installation. Finite execution through that API is not genuine B2
lineage. The sampling control validates profiler plumbing, not Bend execution
speed; sample quality gates still apply. These are prepared commands until root
records execution receipts.

Root subsequently independently checked all six law bodies in the actual-source
tag package, including the kernel negative control
([receipt](../../selfhost/build/consolidation/law-tag01/report.json)). The
maintained QBE runtime rebuilt byte-identically to its qualified object
([receipt](../../selfhost/build/consolidation/runtime01/report.json)). These
are separate formal-source and machine-construction results.

The first finite smoke refused preflight because the driver had legitimately
changed since its asset freeze; no compiler target ran. The original manifest
and snapshots remain untouched. `assets-laws-finite.json` and
`law-finite-source02/manifest.json` bind the updated driver, and the new frozen
worker explicitly sets `BEND_TYPED_BASE_CACHE=off` before loading it. Thus a
finite job cannot silently read or write the shared Base-cache directory.

The maintained `selfhost/tests/consolidation/profiler-smoke.py` now runs event
controls and real native-compiler profiling inside one fresh guarded output
root. It snapshots inputs, creates the diagnostic plan there, checks the frozen
ABI fixture, and profiles the actual N2 compiler compiling the maintained lexer.
Its fresh clean QBE output is a stability reference, not independent conformance.
The emitted lexer itself is not timed. Its owner table must not be attached to
the sampled compiler ELF; ordinary ELF attribution and existing quality gates
remain in force. Live execution of this successor is owned by root.

The root-run [profiler smoke](../../selfhost/build/consolidation/profiler-smoke01/report.json)
completed in about 12 seconds. Counter-off/on ABI outputs and all existing
per-FID counts passed, including the seven new zero columns. The clean and
sampled native compiler requests produced identical 577,601-byte QBE stdout and
empty stderr. This establishes pipeline/output stability, not independent source
conformance or generated-program speed.

The sampled capture is **not usable for cost attribution**: 608 samples arrived,
but the 250 µs request incurred 9,072 timer overruns and delivered only 6.28% of
the expected clock periods. Main-thread CPU coverage was 99.51%, and there were
no buffer drops; those facts do not excuse timer loss. Quality gates correctly
kept `profilesUsable=false`. No hotspot ranking or absolute cost claim is drawn
from that capture. A future attribution run needs a less aggressive interval
and enough CPU duration to retain the normal minimum-sample gate.

Finite JS attempt02 then reached real checking and exposed an observer mismatch:
current `N_WordKind` adds `N_Imm64`, so the original exhaustive serializer was
incomplete. The diagnostic was already stored in the execution report; the
successor also exposes it in the worker summary/error. The original fixture
remains untouched, while `serialize-current.bend` adds only the distinct `3`
wire tag. Its checked profile refuses unknown constructor sets. The
`law-finite-method03/bridge.json` receipt verifies all 39 cases, six native case
IDs, extracted production bytes and expected native bytes are unchanged.
Eight offline law controls pass after this repair. No production compiler edit,
weakened expected value or semantic-failure credit was involved; root owns the
fresh attempt03 execution.
