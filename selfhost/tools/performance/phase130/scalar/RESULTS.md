# Scalar query ceilings: rejected for integration

The unchanged Phase128 compiler emitted and executed both variants. Five paired
runs with retained shared-prefix64 inputs produced these medians:

| Variant | Baseline | Candidate | Candidate/baseline |
|---|---:|---:|---:|
| Cmp result,16,384 repetitions |133ms|149ms|1.1203|
| U32 result,65,536 repetitions |525ms|640ms|1.2190|

Both pass the frozen six-line ordinary output. Neither is integrated. The
69-line supplemental semantic fixtures were prepared but not executed, because
the performance discriminator already rejected these candidates.

The first runner mislabeled IO.now units; raw integer output and process wall
time establish milliseconds. Corrected medians above preserve the original
ratios. Future runs use scalar-run-v2.py.

Static inspection shows Cmp was admitted to a borrowed reader. The rewritten
loop and scalar adapter change per-character work and sharing fallback costs;
the source rewrite is not a clean ceiling for composing the existing String.cmp
reader with an immediate projection. Both original and Cmp candidate readers
still use generic U32.cmp. Direct-U32 source did not demonstrate a gain either.
A targeted existing-reader projection or authenticated compare template remains
an unproved hypothesis, not a reason to add another optimization now.

See v05-inspection/ for exact generated SSA and machine inspection. No compiler
source transformation was made by this experiment.
