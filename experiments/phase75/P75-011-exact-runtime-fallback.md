# P75-011: retain generic layout until omission passes runtime gates

Candidate09 removes about40% C and saves compilation time, but causes repeatable
~5% runtime regressions in tree and Array.map. Alignment64 recovers tree; hot,
outline alignment and bank7 do not recover Array.map, and forced32-byte block
alignment hurts tree. A macro-wide alignment failed to compile because it also
aligned a function-pointer typedef. Keep all failures as evidence.

Test restoring generic lowering while retaining request, erasure, arity, trust
and context sharing. Require complete C identity with the installed Phase73
compiler across twelve families before calling runtime preserved. Planning
before lowering remains; its body-omission permission is withheld. Measure the
remaining compilation gain rather than accepting the runtime tradeoff.
