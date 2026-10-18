# Phase108 — the full Bend compiler works through QBE

The full compiler now runs as a QBE-built native executable. It successfully
compiled its own source and produced **exactly the same 30,396,376-byte C output**
as the trusted parent under the matched runtime policy. Self-emission needed no
bootstrap metadata bridge. That output built a successor compiler through QBE
in **56.08 s**; the successor passed all nine frozen controls in **11.68 s**.

[Design](../../design/phase108/full-native-qbe.md) ·
[Usage](../../docs/self_hosted/QBE_COMPILER.md) ·
[Commands](../../selfhost/tools/performance/phase108/README.md) ·
[Machine-readable metrics](metrics.json).

The [sealed evidence manifest](evidence/manifest.json) binds full generated C,
compiler executables, controls, commands and failed attempts. The usable snapshot
is selected by [image.json](../../selfhost/tools/performance/phase108/image.json).

## What is now implemented

The compatibility path is **Bend → existing Bend C lowering → cproc → QBE →
GNU assembler/linker**. Parsing, checking, erasure and compiler optimization and
emission decisions remain in Bend. It reuses the mature backend's ownership,
closures, arrays, static image, primitive and IO implementation.

This is distinct from Phase107's direct **Bend → typed Nx → QBE** scalar backend.
We did not extend Nx to the entire language. Reusing the C boundary made the full
compiler executable without rebuilding thousands of semantic lowering decisions.
The initial trusted native seed was previously built with Clang; no Clang or Bun
runs in this phase's QBE image builds, self-compilation or ordinary request path.
GCC preprocessing/linking and a small GCC-built atomic/CLZ object remain dependencies.

The CPU runtime now has an explicit segment trampoline with ordinary calling
conventions. v1 retained a wide register signature; v2 passes one state pointer;
v3 additionally expands five pure scalar accessors because cproc/QBE does not
inline C helpers. The state carries continuation-stack position, registers,
result count and execution mode. Segment transitions do not grow the C stack.
Ownership, reference counting and synchronization decisions remain unchanged.

Bend's table emitter gained 10 lines: one helper and four register-state metadata
macros. The old producer needs a temporary exact four-macro bridge for its first
image; the updated Bend source emits these itself. Runtime variants are compact,
hash-checked edit recipes against the existing selected runtime. Three 85 KiB
copies were removed after exact materialization checks. Experiment orchestration
and qualification code is separate from the compiler implementation.

Two small pinned toolchain changes were necessary: cproc now emits ELF initializer
records for the admitted constructor annotation; QBE's alignment storage supports
128-byte alignment. A GCC support object implements real atomic operations and
CLZ. It does not replace atomics with ordinary accesses.

## Measured results and limits

| Measurement | Result | Denominator |
| --- | ---: | --- |
| First full QBE image machine build | 45.62 s | Existing generated C, v1 portable runtime; no frontend emission included |
| Pointer ABI plus accessor image build | 60.42 s | Same compiler program, v3 runtime; build peak about 3.05 GiB |
| Full compiler self-emission | 338.89 s | Native QBE v3, prepared Base, complete 30.4 MB output |
| Self-emitted successor machine build | 56.08 s | Complete C produced by the QBE compiler, then built through cproc/QBE |
| Trusted parent emission | 144.39 s | Selected Clang-built native B2; same compiler source, v1 runtime before exact template rebinding |
| Full self-output identity | Exact SHA-256 `24b697abc934fe6c006b7f6e1964cb2bd6249a2eb3b249dac4f30f5a5252fe48` | All 30,396,376 bytes, including runtime, tables and compiler functions |
| Six-source request ratio, v1 | 4.18× | QBE image / selected Clang-built native B2 |
| Six-source request ratio, v2 | 4.02× | Same six whole requests |
| Six-source request ratio, v3 | 3.22× | Same six whole requests |
| Successor qualification request screen | 3.34× | Separate single round, same six requests and identical executable text to Q0 |

The six-source figures are single-round geometric means, suitable for identifying
this large regression, not percent-level statistical claims. They compare native
compiler images, **not upstream TypeScript and not generated-program runtime**.
Full self-emission is about 2.35× the retained parent emission, with the explicit
runtime-text difference above. No new upstream B1/B2 parity metric is asserted.
We have not yet measured a controlled matched Clang machine-build pair, so the
absolute QBE build times are not presented as a measured Clang speedup factor.

The installed production compiler remains unchanged. The QBE compatibility path
is useful and self-hosting, but its current runtime regression prevents default
promotion on performance grounds.

Packaging is scoped to the experimental Linux x86-64 image and its authenticated
runtime/toolchain assets. GCC preprocessing/linking and system libraries remain
host dependencies. This does not establish a standalone cross-platform release,
replace the installed production CLI, or qualify device execution.

## Correctness evidence

- A 100,000-step recursive scalar test passes through both portable GCC and QBE
  builds with independent expected result 705082704.
- Six frozen output controls cover the real `nt_reverse`, retained aliases,
  Unicode String reversal, captured functions, non-tail lists, arrays/IO and the
  actual lexer. Three invalid source/provider inputs reject without products.
- All six representative real compiler requests produce exact complete C and
  matching diagnostics in each v1/v2/v3 screen: lexer, ray geometry, closures,
  Unicode text, map churn and numeric recurrence.
- Full self-compilation produces exact complete C, and its built successor passes
  the nine frozen acceptance/rejection controls. This is a bootstrap consistency
  result, not a proof that the compiler correctly translates every Bend program.
- The successor passes all six whole-C comparisons. All six representative
  programs then build through QBE and match their previously retained outputs,
  including floating-point ray geometry.
- Five lexer requests in one successor process produce identical complete C.
  Live source Base and prepared Base produce identical C for numeric recurrence.
  The end-to-end packaged command builds the retained-alias reversal control in
  2.03 s from outside the repository directory; its executable output also passes.
- Toolchain controls check constructor execution before main, 128-byte alignment,
  two-thread 32/64-bit atomics, compare/exchange, CLZ and aggregate ABI. Six invalid
  constructor forms reject. Device/GPU execution and parallel scaling are not
  established by these CPU controls.

The array fixture initially used forbidden computed tuple destructuring. The
source was corrected before candidate execution, its independent expected output
was unchanged, and the old fixture/manifest plus failed attempt were retained.
Three initial hand-written scalar setup sources also failed parser/affinity gates;
the accepted fourth source and independent integer result are retained.

The first v2 build crossed the 3 GiB guard and was terminated cleanly. A 4 GiB retry
with a 16 GiB available-memory floor succeeded at 3.04 GiB. No machine OOM occurred.
Completed, reproducible object files were removed only after checking recorded
hashes to retain disk headroom; cleanup receipts preserve their identities.

The original full-self plan proposed two fresh Q0 emissions. We instead used one
full emission followed by a real Q1 build and its separate controls. Q0 and Q1
executable text is identical; complete binaries differ in non-text data. We make
no two-run full-self timing or unrestricted binary fixed-point claim. The 3.22×
and 3.34× request screens have identical machine code and are not evidence of a
generation-to-generation regression or improvement.

## What we learned

The fastest route to a full backend was preserving the existing semantic boundary
and replacing execution transport. Ownership/closure support did not need to be
reimplemented to answer whether a full QBE compiler could work. Direct Nx remains
valuable as the longer-term typed, composable backend, with this compatibility
path providing an executable reference.

Machine backend substitution changes more than code generation. cproc/QBE has no
C inliner: tiny tagged-word queries remain real calls, exposing a major difference
from Clang. The pointer-only ABI helped slightly; five exact accessor expansions
made a larger difference while preserving complete products. Runtime helper
inlining is the strongest next general opportunity. A reusable optimized runtime
object is another route, but requires an explicit ABI for program tables, layout
constants and scheduler state.

The first signal sample used 2 ms periods on a timer effectively delivering about
4 ms, recording 1,202 overruns with 1,204 samples. It is retained as a qualitative
lead, not a loss-free quantitative profile or a speedup estimate. Disassembly and
cproc/QBE source independently establish the missing-inlining mechanism. Clean
request clocks, not sampled clocks, underpin the table above.

## Detailed audits

[Lowering architecture](lowering-audit.md) · [Runtime boundary](runtime-audit.md) ·
[cproc/QBE toolchain](cproc-audit.md) · [Coverage boundaries](coverage-audit.md).

The experiments preserve actual native stages, successful/failed commands, output
hashes, declared limitations and separate promotion decisions. No PR comments were
posted, and no automatic research acceleration or whole-compiler proof is claimed.
