# Repository consolidation

Completed on 2026-11-01. The installed release now uses one maintained Bend
compiler source tree for JS, C and direct QBE, with maintained build, benchmark,
profiling, conformance and law tools. Historical compiler implementations no
longer supply current builds. The implementation and release were pushed in
`bbf81e8`; the closing evidence was collected against that exact commit.

The authoritative recipe is [`selfhost/src/compiler.json`](../../selfhost/src/compiler.json).
Its 206 modules contain 7,402 named declarations in 8,085 declaration blocks.
The assembled source is 3,010,912 bytes and 64,958 physical lines. Thin entry
profiles select the compiler interface; generated bootstrap images are artifacts
of this source, not separately maintained versions. The
[source audit](source-residual-audit.json) found no obsolete compiler declaration
copies outside the recipe under `selfhost/src`. Runtime providers, independent
fixtures and thin entry adapters remain distinct.

## What changed

- Preserved the latest qualified QBE implementation and accepted optimizations
  as maintained modules, including 112 protected verifier/proof declarations.
- Replaced historical phase composition with explicit source assembly, assets,
  requests, native construction, bootstrap, qualification and release tools.
- Consolidated compiler/program benchmarks, native and V8 profiling, generated-code
  analysis, finite laws, independent kernel checking and experimental sessions.
- Retired historical methods, generated compiler copies and archived payloads
  from HEAD, preserving exact Git identities and bounded recovery tools.
- Switched public launchers to the single
  [`current.json`](../../selfhost/manifests/current.json) release selector.
  Compiler algorithms remain in Bend; host tools provide transport, supervision,
  runtime support and measurement.

The initial extraction exactly reproduced qualified source
`96c40c9dd273e2fae5fabfe68093aa7fb8f25f075e2317bed06ff46d4feaab80`.
One production integration change raises `jd_definition_budget()` from 4096 to
4352: the complete current API needs 4109 non-absent source definitions. The
current source SHA256 is
`00940ed508e7d1456dd19bee01b0d2e16ac227fdf13ac306e805a1e4c982fb5e`.
Semantic admission rules and other bounds are unchanged. Boundary controls cover
4096/4100/4352/4353, including literal product equality below the old limit.
This cleanup reduces duplicate repository content, not the maintained compiler's
64,958-line implementation.

## Installed compiler and qualification

| Component | Selected artifact | Evidence |
| --- | --- | --- |
| JS | B2, `selfhost/dist/typed-api.mjs` | Actual B3 freshly checks the complete source and reproduces the B2 image exactly; 45 ordinary outputs and 7 public CLI controls pass |
| Public native C | N1, `selfhost/dist/native/bend` | Built from the canonical source through a thin public profile; 45 ordinary outputs plus public behavior, relocation, asset-corruption and publication controls pass |
| Direct QBE | Qualified N2, `selfhost/dist/qbe/bend` | Original qualified image and runtime retained; complete canonical-source QBE product is byte identical; 19 focused controls pass and prior 45-program qualification remains bound to the unchanged image |

The QBE image retains its **actual original compiled-source identity**. Its
explicit canonical equivalence bridge records full QBE equality; it is not
relabeled as a newly built image. Native images and toolchains are explicitly
acquired artifacts, so a fresh Git checkout needs their pinned assets. JS and
native C public launchers now read the same selector. The compatibility
`dist/release.json` points to it rather than defining a second release authority.

These gates establish different properties; none proves whole-compiler correctness:

| Additional gate | Result |
| --- | --- |
| Independent source checking | Current complete source accepted by pinned upstream; checked B1 acquired |
| Full QBE equivalence | All 117,232,528 emitted bytes equal the qualified product |
| Runtime reconstruction | Maintained QBE runtime build equals the qualified runtime object byte for byte |
| Complete component command | All 17 groups pass, including frontend, exact diagnostics, source provenance, specialization, JS runtime ABI and 52 host/harness controls |
| Laws | 39 finite JS and 6 native cases pass; separate tag theorem and negative control accepted/rejected by the independent kernel as expected |
| General profiler | Output, ABI and runtime controls pass; the real sample capture is correctly rejected for insufficient sampling quality |
| Experimental sessions | Current-source five-step gate passes, including 8 semantic cases, same-mode fresh products, two error recoveries, and cold/no-op/edit object reuse with corruption controls |
| Operational installation | Selector verification and actual default JS/native launchers pass seven controls |
| Fresh Git worktree | At `bbf81e8`, exact source assembly and installed release verification pass; JS, C and QBE each compile and run an independent program yielding `42` |
| Historical recovery | 20 safety controls pass; exact original blobs and split-archive identities remain recoverable |

The [fresh-worktree gate](fresh-worktree.json) uses explicitly pinned assets
(154,996,868 copied bytes), live preparation and declared external toolchain/Base
inputs. It runs without historical performance or implementation directories in
that checkout. It is a finite relocation/use gate, not another full native rebuild.
See [complete component results](components-final.json) and the
[authenticated evidence index](qualification-evidence.json). The latter describes
91 exact JSON receipts in a 302,668-byte archive; it contains no compiler copy or
new binary capsule.

## Performance continuity and measurement limits

This campaign establishes cleanup and integration, not a new optimization score.
The unchanged QBE image/runtime and identical full emitted QBE preserve executable
code on that route. The current public C image emits exactly the same C bytes as
the consolidation pilot for all 45 cases, with matching construction settings.
Complete ELF bytes differ because of construction metadata and paths. This is
product continuity against that pilot, not a new upstream runtime comparison.
Earlier checked-B1 controls also established nine exact JS/legacy-JS/C products
against their prior incumbents, with 18 executions; their scope is preserved
rather than silently attributed to final B2. Final B2 has its own broad, public,
fixed-point and live-mode controls.

Selected observed costs are:

| Operation | Observed elapsed time | Scope |
| --- | ---: | --- |
| Full current source to QBE | 238.15 s | Includes request supervision; excludes machine construction |
| JS B2 acquisition | 298.85 s | Actual self-emission |
| JS B3 acquisition | 247.7 s | Includes fresh self-check; work differs from B2 |
| Public C producer construction | 169.9 s | Build-only bridge |
| Public CLI C emission | 134.6 s | Compiler execution |
| Public CLI Clang construction | 419.9 s | One-time image acquisition; peak process-tree RSS 2.83 GB |
| Final JS 45-program gate | 389.3 s | Live-mode correctness campaign, not program-only runtime |
| Final public C 45-program gate | 101.9 s | Correctness campaign |
| Fresh-worktree gate | 15.42 s | Harness time; guarded setup and execution 19.4 s |

The maintained benchmark smoke exercises upstream comparison, program timing
and compiler-request timing on two programs. Its C/QBE cold-request comparison
uses different targets and is explicitly not same-target parity. No new
45-program geometric score, full cold-build speedup or upstream ratio is claimed.
The frozen benchmark definitions, oracles, time budgets and diagnostic tools
remain available for the next optimization campaign.

## Failures, corrections and boundaries

1. Three limited/rejected JS acquisitions preceded the explicit capacity change.
   The synthetic 4352-export rendering control also overflowed upstream-generated
   JS after planner admission. Boundary admission and old-limit product equality
   were then tested separately; the actual full B2/B3 acquisitions pass.
2. Public CLI foreign declarations disabled QBE static-data preparation globally,
   expanding generated code until the resource guard stopped the attempt. The
   public CLI uses a narrow build-only producer bridge followed by C/Clang
   construction. No optimizer change or relaxed final admission was hidden here.
3. The finite-law observer omitted `N_Imm64`. An authenticated successor handles
   it; production extracts, case identities and expected outputs are unchanged.
4. The real profiler capture delivered 608 samples with 9,072 timer overruns:
   6.28% period coverage despite 99.51% main-thread CPU attribution. Its failed
   quality gate supports no hotspot conclusion. The maintained profiler detects
   this limitation instead of presenting misleading percentages.
5. Some old test expectations no longer matched current source or pinned upstream:
   qualified-name spelling, three effect-result shapes and the exact five-input
   bootstrap provenance set. Expectations were corrected from those independent
   contracts; production behavior was unchanged. A live-mode diagnostic control
   also needed the existing public error prefix. Failed receipts are retained.
6. The first fresh-worktree setup had an empty Git index; no compiler ran there.
   Explicit index population fixed setup, and the second real worktree passes.
   Early C smoke/header and negative-predicate failures remain recorded too.
7. Prepared Base carriers bind their logical source path. Relocation needs a fresh
   qualified carrier or live mode; equal copied bytes alone do not validate a cache.
   Session/object reuse remains experimental, with its own controls and no new
   incremental, parallel or native-batch performance claim.

## Repository size, history and storage

The [Git-tree census](census.json) compares exact commits. Values are logical
tracked blob bytes, not filesystem allocation or `.git` storage:

| Metric | Before `2a4f9f8` | Consolidated `bbf81e8` | Reduction |
| --- | ---: | ---: | ---: |
| Tracked files | 85,978 | 28,849 | 66.45% |
| Tracked bytes | 7,085,942,778 | 1,525,558,374 | 78.47% |

The first retirement removed 56,800 clean working files and retired another 826
index entries while preserving their working bytes. The final tranche removed
84 additional historical files. Together, 57,710 original historical tracked
paths account for 5,572,216,825 logical bytes. Five temporary consolidation
helpers were also retired after integration and remain recoverable at `739cb09`.
Scientific reports, independent fixtures and useful provenance stay at HEAD;
retained JSON evidence is still substantial. The final reporting commit adds
small receipts and documentation after the census above.

The immutable recovery baseline is
`2a4f9f8383cbc66fadaedd9b4b27f83b93a13511`. The single compressed metadata index
records exact original Git blobs and ordered split-archive parts. It does not
contain another compiler implementation. Git history is unchanged, so this
checkout reduction does not imply a smaller full-history clone.

Unrelated research edits and untracked work were preserved. The 826 index-only
retirements intentionally leave local working material; they are not remaining
tracked versions of the maintained compiler. Future experiments should name the
compiler commit and retain small evidence, rather than copy its source tree.

All **54 guarded jobs are closed**: 28 retain current release/recovery inputs or
explicit useful sub-results; 26 archive their cold/failed artifacts, reopen and
verify the archive, then prune the eligible hot copies. See
[retention accounting](retention.json). No age-based phase deletion was used.
The shared lock, qualified rollback inputs and unrelated working data remain.

The [cost ledger](cost.json) records 3,810.16 s (63.50 minutes) of guarded work:
37 successful jobs and 17 failed attempts. Failures cost 1,100.10 s (18.34 minutes)
and are included in that total. Two attempts hit an RSS limit; there was no
system OOM or disk-reserve breach. These clocks exclude agent effort, Git/metadata
work and lightweight unguarded controls; they are not an estimate of total effort
or a compiler-performance measurement. Roughly 13.1 GiB was free at campaign close.

## Current workflow and next work

Start with [the maintained workflow](../../docs/self_hosted/workflow.md),
[benchmark tools](../../selfhost/tools/bench/README.md),
[profiler](../../selfhost/tools/profiler/README.md),
[laws](../../selfhost/tools/laws/README.md),
[release protocol](../../selfhost/tools/build/RELEASE.md) and
[historical recovery](../../selfhost/tools/history/README.md).
The [original cleanup plan](../../design/repository-consolidation/README.md)
remains the record of intended boundaries.

The next objective remains **complete cold compilation**. The main improvement
from this campaign is a single editable implementation and a qualified, usable
research workflow. It makes future experiments easier to attribute and reproduce;
it does not demonstrate faster cold builds by itself.
