# Two-case early compiler-cost screen

Root runs `bash selfhost/tools/performance/phase42/facts/compiler-cost-screen-v01/root-run.sh`. No jobs were executed during preparation. New output directories are never overwritten.

The unchanged Phase37 planner and Phase35 runner independently acquire baseline checked41 and candidate checked13 ordinary library output, verify both attempts/runtime/cache identities, and reuse the already pinned TS ordinary output. Each18 timed fresh processes (two cases × three roles × three rotated rounds) must reproduce its own role-specific output exactly. No runtime-equality premise is introduced. Tree bitonic and list512 match the Phase41 cost cases.

The Phase41 process medians predict about105–115seconds for the runner, plus30–45seconds for acquisition/bindings. Shortening below90seconds would require changing the measurement contract or dropping a balanced round. Keep unchanged boundaries and report actual elapsed time.

Compare request medians and ranges first, then host-import, preflight and process/RSS. A difference is the combined checked13 implementation delta; it does not isolate request-cache causality. Large regression triggers investigation before final image selection. The final selected-image four-case cost gate remains required; this is an early two-case screen only.
