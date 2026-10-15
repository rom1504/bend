# Phase97 proof usefulness pilot

The [ownership package](ownership/README.md) proves a small semantic-preservation
obligation: a temporary retain/read/release sequence can be replaced by a read
in an explicit sequential immutable-cell model, under arbitrary surrounding
operations. Complete equality preserves read traces, final roots and explicit
dead-root faults.

The package contains **four public laws and three supporting lemmas**. All seven
safe proof bodies passed source checking, elaboration, and independent BendTT
checking: 26 elaborated definitions, none opaque. Evidence:
[ownership-proof02/report.json](../../build/phase97/ownership-proof02/report.json).
All three semantic helper mutants passed standalone source checks, then the
unchanged preservation laws rejected them:
[ownership-negatives01/report.json](../../build/phase97/ownership-negatives01/report.json).

The [implementation analysis](../../../implementation/phase97/semantic-pilot.md)
explains why this is relevant to runtime ownership, what it does establish,
and the exact missing production bridge. It remains a model proof. The separate
[runtime boundary control](../../build/phase97/ownership-boundary01/report.json)
compiled a missing-child-retain mutation in generated C, then observed a runtime
failure while the proof sources remained unchanged. No claim of native runtime
correctness follows from this package.
