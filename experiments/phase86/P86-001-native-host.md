# P86-001: native execution of the compiler

Status: planned. [Design](../../design/phase86/native-compiler-host.md).

Question: does native hosting remove the first-use cost found in Phase85 without
reimplementing compiler algorithms or losing prepared Base reuse?

Control: current manifest/pinned upstream; same experimental Bend entry emitted
as JS and C, explicit preparation/request clocks, complete output comparison.
Prototype restrictions and failed acquisitions remain evidence. A host migration
requires broader CLI/diagnostic/foreign/cache qualification than this pilot.

Results will be recorded in [Phase86](../../implementation/phase86/README.md).
