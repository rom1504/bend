# Phase187 — Bend-written x86 machine-code and ELF output

The existing x86 backend now has an opt-in `--emit object` format. It writes
ELF64 relocatable objects in Bend and uses the existing authenticated linker
and runtime, without invoking an external assembler. Assembly remains the
default; the qualified installed selection is unchanged.

The native compiler successfully compiled its own 1,652,868-byte source through
this route. That build took 315.348s and produced a 46,233,520-byte object and a
39,142,352-byte executable. This is an actual native source-to-executable build,
not a host-language encoder or a fixture standing in for the compiler. It does
not establish a speedup or a complete native reproduction fixed point.

## What was built

Five Bend modules (1,211 lines at the initial freeze) separate typed machine
operands, encoding, finite text parsing, object construction and ELF writing.
The selector, register allocation, all current optimizations, semantic
admission and native-body verification are shared with assembly output.

The original emitter constructs assembly Strings during selection. In this
first implementation, one function's text is parsed into machine instructions
before encoding. The complete assembly program is not collected, but complete
object sections are currently held in memory. This distinction matters: the
implementation removes GNU as, not assembly formatting or parsing work.

The encoder supports the observed integer/SSE subset, REX/ModRM/SIB encodings,
full-width immediates, explicit relative branches and ELF relocations. The
object writer handles text, read-only data, data, ordered local/global symbols,
three AMD64 relocation kinds, and a nonexecuting-stack marker. Raw binary output
uses `File.write_bytes`. Python/JavaScript tooling only orchestrates and verifies
artifacts; compiler decisions and all byte emission are in Bend.

Objects are bounded at 32 MiB per main section; individual zero directives at 8 MiB.
Unsupported forms and unsupported alignment fail explicitly. The current branch
encodings/layout differ from GNU-as relaxation and its branch-boundary policy.

## Evidence and scope

- Full selected compiler independently accepted by the unchanged upstream
  checker, with zero holes. This is source checking, not a BendTT correctness
  theorem; existing unsafe assumptions remain explicit.
- 38 exact parser controls, 106 literal encoding/relocation/refusal controls,
  eight complete-assembler refusals and 27 separate ELF structural controls.
- 926 independent C observations against both direct and GNU-as objects,
  including the frozen 93 binary F32 cases and seven conversions.
- 27 additional C observations isolate ELF symbol/relocation behavior.
- Ten real native45 workloads initially passed both direct output and retained
  reference executions. Final 45-case results appear in the final measurements
  below.
- A QBE-built native image produced a compiler executable through direct object
  emission. Full native reproduction and installed promotion remain separate.
- The canonical QBE source is byte-identical to Phase186:
  `1e8a23ace83520a9d909cf20ce6168e5aa5a0f372d32991381dfc9bf0c544902`.

The focused fixture's text was 2.44% larger than GNU as. This is a fixture size
observation, not a whole-workload performance result. Retaining local labels as
ELF symbols and relocations also increases non-executable metadata.

## Reproduction and next step

See [usage and limits](../../docs/self_hosted/x86-objects.md),
[design](../../design/phase187/README.md) and
[control commands](../../selfhost/tests/phase187/control-plan.md).
The selected final source is `selfhost/build/phase187/source05/compiler.bend`;
its QBE-built native producer is `native-image05`, and the directly emitted
compiler is `native-self-object05`. Each has an exact build receipt.

The next architectural step is to have the shared selector produce typed
machine fragments directly, then render either assembly or bytes. That can
remove the parsing/formatting cost this version retains. Streaming sections
and resolving local branch fixups before ELF serialization should reduce memory,
metadata and construction cost. They need their own measured qualification;
this phase does not claim those benefits in advance.

## Final measurements

All 45 frozen benchmark points passed through **both** formats using the
object-built N2 compiler:90 builds and 90 independent complete-output checks.
Every assembly output is byte-identical to its Phase186 counterpart. This
preserves the actual selected optimizations, not just the expected values.

| Same source, same N1 producer, same prepared Base/runtime | Assembly + GNU as | Direct object |
|---|---:|---:|
| Complete compiler build |199.112s |315.348s |
| Compiler process |188.704s |314.147s |
| External assembler |8.327s |0s |
| Linker |0.237s |0.417s |
| Peak process-tree RSS |1,716,338,688 bytes |2,325,749,760 bytes |
| Object size |29,649,784 bytes |46,233,520 bytes |
| Executable size |25,025,168 bytes |39,142,352 bytes |
| Executable text reported by `size` |20,316,526 bytes |20,805,550 bytes |

These are single complete fresh requests with prepared Base (`mode=cache`), not
statistical cold-filesystem measurements. Object emission was **1.584× slower**.
Across 45 paired small-program builds by the same object-built N2 executable
(including the catalog variants that share source),
the geometric build-time ratio was **1.509×**; summed times were 169.062 s versus
108.580s. This is useful capability, **not yet a compilation-speed improvement**.

The short runtime screen used all 45 points, 44 timing-eligible cases, two
position-balanced rounds, independent per-role calibration to 200 ms, 180 measurement executions (176 timing-eligible)
and 270 pilots. It completed in 108.118 s. Object/assembly geometric
runtime was **0.994×**, and the equal-source ratio was 0.997×. Treat this as near
parity in a short screen, not evidence of a reliable 0.6% speedup. The largest
regression was morning at 1.056×; list-pipeline128 was 1.037×. Only one timed case
exceeded 1.05×. A longer campaign is needed before claiming layout improvements.

The main finding is that the expensive part was not merely invoking GNU as.
Keeping String formatting and then parsing it again adds work. ELF serialization
also retains local labels and relocations that GNU as resolves and removes:
most executable-file growth is symbol metadata, while text grew 2.41%. The new
implementation provides a reusable machine encoding/object boundary; it has not
yet provided the typed, text-free selector required for the original speed
hypothesis.

An extra cross-host diagnostic on complete local-fold assembly hit an upstream
JavaScript stack limit in the non-tail `x187_elf_bytes` predicate. This is
preserved as failed evidence, not counted as a pass. Small upstream-JS controls
passed, and the native path completed the full compiler and all 45 programs.
Tail-recursive byte validation and streamed buffers are concrete follow-ups;
the current host adapter explicitly supports object requests only from native
images. No full N1/N2 emitted-compiler fixed point is claimed.

[Structured evidence](evidence.json) records exact receipts, every paired build,
resource bounds, worst runtime changes and failed diagnostic. The implementation
commit is [`e8438ce`](https://github.com/rom1504/bend/commit/e8438ce); the design is
[`cb40735`](https://github.com/rom1504/bend/commit/cb40735). Work began 16:40 UTC;
implementation, full self-build, 45-case qualification and the runtime screen
finished within the requested hour. The existing installed compiler and default
assembly output remain unchanged.
