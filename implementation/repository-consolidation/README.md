# Repository consolidation

This campaign replaces historical source composition with one maintained Bend
compiler and one maintained research toolchain. Publication and final-check status
are recorded below; this report is being completed as the closing gates finish.

The authoritative recipe is [`selfhost/src/compiler.json`](../../selfhost/src/compiler.json).
Its206 modules contain7,402 named declarations in8,085 declaration blocks.
The assembled source is3,010,912bytes and64,958physical lines. JS, C and direct
QBE share this tree; thin entry profiles select the public interface. The source
residual audit found no obsolete compiler declaration copies outside the recipe.
Runtime providers, independent test fixtures and entry adapters have distinct roles.

## What changed

- Preserved the latest qualified QBE implementation as maintained modules,
  including its accepted optimizations and112 protected verifier/proof declarations.
- Replaced phase-script composition with explicit assembly, asset, request,
  native construction, bootstrap, qualification and transactional release tools.
- Consolidated compiler/program benchmarks, native and V8 profiling, generated-code
  analysis, finite laws, independent kernel checking and experimental sessions.
- Moved historical methods, generated compiler copies and archive bodies out of
  HEAD, with exact Git identities and bounded recovery tools. Scientific reports,
  independent fixtures and the original Git history remain.
- Replaced obsolete development commands and prepared current-manifest launchers.
  Compiler algorithms remain in Bend; host tools authenticate inputs, transport
  files, supervise execution and collect measurements.

The initial modular extraction exactly reproduced qualified source
`96c40c9dd273e2fae5fabfe68093aa7fb8f25f075e2317bed06ff46d4feaab80`.
One integration change raises the direct-JS definition budget from4096 to4352:
all current API functions require4109 non-absent source definitions. The current
source is `00940ed508e7d1456dd19bee01b0d2e16ac227fdf13ac306e805a1e4c982fb5e`.
Semantic admission rules and other resource bounds are unchanged. Boundary tests
cover4096/4100/4352/4353, with literal output equality below the old limit.

## Correctness and generated-code continuity

These gates establish different properties; none is a whole-compiler theorem.

| Gate | Observed result |
| --- | --- |
| Independent source checking | Current complete source accepted by pinned upstream; checked B1 acquired |
| Current QBE source equivalence | Complete117,232,528-byte QBE equals the qualified compiler product |
| QBE runtime reconstruction | Maintained runtime rebuild equals qualified runtime object byte for byte |
| QBE ordinary controls | Focused19 pass; unchanged image retains earlier qualified45-program evidence |
| JS self-hosting | Actual B2 and B3 pass; B3 freshly checks the complete source; complete images equal |
| C-emitting native producer | Built from canonical source profile;45 independent ordinary program outputs pass |
| Public C CLI | New canonical-source package built; public behavior, relocation, corruption and publication controls pass |
| Laws |39 finite JS cases and6 native cases pass; separate tag theorem and negative control accepted/rejected by independent kernel as expected |
| General profiler | Output/ABI/control gates pass; one real CPU capture correctly fails sampling-quality admission |
| Sessions | Initial8 semantic requests and cold/no-op/edit object controls pass; current-source closing gate recorded separately |

Closing broad JS/public-C, operational release and fresh-checkout results will be
recorded in the final evidence summary. A generated product becoming smaller or
a compiler executing its own source is not by itself a speedup or a correctness proof.

## Performance boundaries

This is a cleanup, not a new optimization result. The complete QBE equality and
unchanged qualified native image/runtime preserve executable code for that path.
The same-source QBE emission took238.15seconds including request supervision;
this is not a new full source-to-executable time or an upstream comparison.

Actual JS B2 acquisition took298.85seconds; B3 took247.7seconds including a fresh
self-check. Their work differs, so these are acquisition costs, not a speed ratio.
The public CLI producer took169.9seconds to build, emitted C in134.6seconds, and
Clang constructed the final package in419.9seconds. Its peak process-tree RSS was
2.83GB. This one-time integration cost should not be included in program runtime.

The maintained benchmark smoke compares two actual programs against upstream C
and exercises program timing and compiler-request timing. The stored cold request
smoke compares C emission with QBE emission; it is explicitly not same-target
parity. No new45-program geometric score is claimed. Final product comparisons
and construction settings are recorded separately from these timings.

## Useful failures and limitations

1. Retaining all current API functionality exceeded the old JS resource bound.
   Three rejected/limited acquisition attempts preceded the explicit capacity fix.
   The large synthetic4352-export control also overflowed upstream-generated JS
   after successful planner admission. The revised test keeps admission boundaries
   separate from old-limit output-equality checks; the real B2/B3 builds pass.
2. Adding public CLI foreign declarations disabled QBE static-data preparation
   globally and greatly expanded generated code. The guarded attempt stopped at
   its RSS ceiling. The public CLI therefore uses the existing narrow build-only
   producer bridge and C construction. The installed compiler retains ordinary
   admission rules. No QBE optimizer change was hidden in cleanup.
3. A finite-law observer omitted the newer `N_Imm64` constructor. Its authenticated
   successor adds that observer case; production extracts, cases and expected
   outputs remain unchanged.
4. A profiler capture delivered608 samples with9,072 timer overruns. Its6.28%
   period coverage fails the quality gate despite high main-thread CPU attribution.
   It supports no hotspot or cost conclusion.
5. Prepared Base carriers bind their original logical source path. Moving that
   path requires a fresh qualified carrier; live mode remains available. A copied
   file with equal bytes is not automatically a valid relocated cache.
6. Experimental session/object reuse is preserved with explicit gates and mode
   boundaries. It is not advertised as a newly qualified parallel/native batch
   compiler or as a new incremental speedup.

The failed C smoke initially lacked a Clang header path; another failed negative
control used an overly narrow diagnostic predicate. Corrected gates passed while
preserving the original failures. Resource guards stopped oversized attempts;
there was no system OOM or disk-reserve breach.

## Historical retention and current use

The first applied retirement removed56,800 exact historical files and retired826
additional index entries while preserving their working bytes. The planned
logical total is5,500,736,880bytes. Final native/development retirement follows
qualified release selection. The recovery baseline is
`2a4f9f8383cbc66fadaedd9b4b27f83b93a13511`; the compressed index records original
Git blobs and ordered split-archive parts. Git history has not been rewritten.

Existing unrelated research edits and untracked work remain untouched. The
maintained source is not duplicated into new experiment folders. Future changes
belong in the module tree; experiments should record the relevant commit and
small reproducibility receipts.

Start with [the maintained workflow](../../docs/self_hosted/workflow.md),
[benchmark tools](../../selfhost/tools/bench/README.md),
[profiler](../../selfhost/tools/profiler/README.md),
[laws](../../selfhost/tools/laws/README.md),
[release protocol](../../selfhost/tools/build/RELEASE.md) and
[historical recovery](../../selfhost/tools/history/README.md).
The next optimization objective remains **complete cold compilation**.
