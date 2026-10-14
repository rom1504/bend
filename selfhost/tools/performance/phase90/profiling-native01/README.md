# Exact native90 profile preparation

This is a fresh derivative of the Phase89 bounded-capture runner for native
image `c621447d…`, compiled from the checked combined source `74b390d3…`.
The old native89 sampler library embeds different addresses and is unsuitable.
Offline `make-table.py` generated 55 validated CFI rows from this exact new ELF
in `selfhost/build/phase90/ownership-native01-table/`. No compiler was run during
preparation. The completed eight-gate admission and all 137 recorded gate inputs
were independently authenticated offline.

`commands.json` contains exact argument arrays for root's serial execution:

1. `samplerBuild`: compile the unchanged Phase88 sampler against the new header,
   under a 30 s CPU3 guard. `sampler-build-inputs.json` pins its source, exact
   table/header and Clang. No compiler image rebuild occurs.
2. `capture`: first run normal Map COUNT5 with a 60 s watchdog, requiring five
   exact complete C outputs and the original completed-profile analyzer. Next
   stop Map COUNT5 after 3 s and require the unchanged strict partial analyzer.
   Only after both pass, capture 180 s of the unchanged full frozen source.

The runner also accepts `--seconds 120`; self sampling is 16,000 µs, so either
duration fits the unchanged 25,000-entry per-thread buffer. Controls use the
previous 4,000 µs period. Each outer guard allows another 30 s for shutdown.
`--check-only` verifies bindings without executing a target. The matching
completed failed self report is mandatory before any self capture is enabled;
the new unsampled attempt hit its 240 s deadline without producing C.

Use the existing `phase90/watchdog01.so`, pinned by its exact digest. No watchdog,
sampler, analyzer, runtime or compiler algorithm changed. `run.patch` and
`derivation.json` preserve the narrow runner changes. Strict zero-loss checks
are unchanged; any sample loss or altered input retains a failed report and raw
evidence. Intentional exit77 is never a passed compilation. If the self request
unexpectedly finishes first, this stopped-control method rejects its expected
exit condition and preserves the output for separate qualification.

Accepted stopped profiles additionally run the existing offline `windows.py`.
Its windows describe physical samples over monotonic elapsed time, not compiler
stages. Musttail-eliminated callers remain unavailable. Do not edit any bound
source, method or asset while capture is running.
