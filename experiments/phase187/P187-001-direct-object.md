# P187-001 — optional direct ELF output

Status: implemented; final qualification is recorded in the Phase187 report.

Hypothesis: the existing x86 selector can share a Bend instruction encoder and
ELF writer with its assembly route, removing the system assembler without
reimplementing source-language lowering or optimizer decisions. This first
experiment deliberately tests capability before claiming a speed benefit.

Prediction: no inherent generated-program runtime gain. Removing GNU as alone
had a Phase186 ceiling of roughly 8 s in a 290 s build. Retaining text selection
and adding a parser can erase that saving. Near branches and missing GNU-as
branch-boundary padding also mean machine layout and performance can change.

Method: source-check the new Bend implementation; test literal instruction
bytes and refusals, independently inspect ELF, link C observers, then compile
real Bend programs and the compiler itself. Preserve the current installed
selection. Use one guarded CPU3 lane, bounded memory/disk, exact source/image
identities and independent output oracles.

Negative evidence retained: early Bend parsing/affinity failures; initial
immediate-to-memory refusal caught by the independent machine fixture; original
8 MiB section policy was deliberately enlarged to 32 MiB before attempting the
full compiler. Alignment beyond fixed ELF guarantees is refused, not silently
rounded. GNU-stack state is tracked so later bytes cannot enter the wrong
section. All prototype files and failed receipts remain in the bounded Phase187
artifact roots; no failure is counted as a pass.

Result: see [implementation report](../../implementation/phase187/README.md)
and its exact receipts. This is an integrated finite-dialect assembler in Bend;
it does not yet eliminate assembly String construction. A typed selector and
streamed section writer are distinct follow-up work.
