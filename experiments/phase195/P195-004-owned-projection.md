# P195-004 — retained-root readers returning owned projections

Current Map.bit already uses the borrowed scalar worker; reconstructing its
prefix was a false hypothesis based on a cold worker. Actual Map.seek may still
reconstruct nodes while returning unchanged owners plus Maybe<storedkey>, a
result outside the existing scalar observer contract.

First test a checked application-IR ceiling with bounded reconstruction and a
borrowed Again worker, independent lifetime oracles and shared/raw roots. Borrowed
raw-child keep is unsound unless the parent word is updated; only already-RFC or
trivial projection values may use the new publication path, otherwise preserve
exact reconstruction fallback. This is not yet a general compiler transform.
