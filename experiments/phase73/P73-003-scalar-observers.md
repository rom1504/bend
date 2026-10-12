# P73-003: shared scalar traversals

Tape's fixed input cycle performs1033 wrapper allocations and1033 decrements
versus upstream1/1. The root-preserving observer already handles `total`, but
ordinary scalar consumers still increment/decrement shared children while walking.
A saved-C `hash` borrowed-body diagnostic plus one root release reduced921→528ms
(upstream296), all nine rotated intervals/oracles passed.

Extend the existing bounded typed observer analysis to a scalar result with
omitted roots. Reuse its tail-recursion, field-layout, effects, demand and fuel
proofs. The owning adapter evaluates the borrowed result, then the existing owned
lowering drops the original roots. Redirect both private and public calls through
the original ordinary worker, only when every root has a shared RFC count>1.
Unique inputs keep normal owned lowering. Do not introduce C recursion.
