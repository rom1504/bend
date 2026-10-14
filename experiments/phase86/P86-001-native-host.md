# P86-001: native execution of the compiler

Status: feasibility demonstrated; default migration rejected for now.
[Design](../../design/phase86/native-compiler-host.md).

Question: does native hosting remove the first-use cost found in Phase85 without
reimplementing compiler algorithms or losing prepared Base reuse?

Control: current manifest/pinned upstream; same experimental Bend entry emitted
as JS and C, explicit preparation/request clocks, complete output comparison.
Prototype restrictions and failed acquisitions remain evidence. A host migration
requires broader CLI/diagnostic/foreign/cache qualification than this pilot.

Small, Functions65, Numeric, Lexer and Unicode produce exact ordinary-B2 C.
However, Map reaches a native reference-counting fail-stop, Lexer takes about
five times the sibling-JS first-request time, and native Base preparation adds
about three seconds per process. Earlier small-input wins do not establish a
general host win. The planned broad timing campaign stopped at these boundaries;
a four-source repeated-call diagnostic is explicitly a successful subset.

Results and retained failures: [Phase86](../../implementation/phase86/README.md).
