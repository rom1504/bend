# P111-001: full generic segments directly to QBE

Decision: implemented, full native qualification in progress. Correctness:
19native focused cases pass on runtime03, five byte-identical cases and ten
runtime boundaries pass on runtime04. Performance: full machine build10.26s;
small runtime-only screen improves15–18%in single observations. Native
self-emission now reproduces all50,664,292QBEbytes and builds its successor. Production: unchanged.

[Design](../../design/phase111/direct-qbe-selfhost.md).

Hypothesis: retaining semantic operations before C text and targeting the
existing portable one-pointer segment ABI removes cproc from full native Bend
compilation without replacing the runtime or duplicating the checked frontend.

Controls: selected Phase102 native compiler and Phase108 full C/cproc/QBE route;
independent fixture outputs and negative checks. Preserve exact source/tool/
runtime identities, resource guards, failures and output artifacts.

First gate: closures, non-tail continuation and IO through actual checked source.
Decisive gate: full compiler emits QBE, its directly built successor emits itself
again, with semantic and product consistency checks. No full build before the
small gate. Kernel results do not establish full self-hosting or upstream parity.

[Report and retained failures](../../implementation/phase111/README.md).

The complete generic direct-QBE compiler is built and executes real source
requests without generated C/cproc. A1,100-second native self-request failed
by deadline. The bounded-register runtime retry preserves identical Bend and
QBE input and has advanced from lowering to IR verification in separate
qualitative continuation samples. These pauses make its wall clock instrumented.
Full output comparison and successor construction succeed in the runtime04
retry (944.82s native emission;10.26s machine build). Successor corpus
qualification follows. Raw executables differ in linker metadata; a separate
loaded-image comparison preserves that distinction.
