# Phase144 report claim audit

Read-only audit of the untracked Phase144 notes and methods during final
consolidation. No target runs or performance evidence changes. Historical
source-only sections remain useful chronology; the final report should link
the later outcome instead of presenting them as the latest status.

Material points for the coordinating report:

1. `upstream-c-build-cost.md` still recommends an O1 attempt. That attempt now
   exists and was stopped at the RSS limit after 103.464 seconds, in addition to
   O2's 104.302 seconds. Record both negative acquisitions and stop this lane;
   no current same-source C speed ratio exists.
2. `compact-and-parallel.md:249` calls 315 seconds the current denominator;
   `parser.md:259` and `emission.md:217` use related historical whole-build
   examples. Keep them explicitly historical/illustrative. The current matched
   source01 request is 266.862 seconds, its separate serial-runtime observation
   249.679 seconds, and final03 Q3's 250.296 seconds compiles a different source.
   None can be silently substituted for the others.
3. `shipping-source-census.md` ends at unchecked profile01; the source-profile
   workflow subsequently checked profile02 and exercised native ordinary/session/
   batch requests. Its line-based savings remain unmeasured modeling, not a
   same-source compiler speedup. `source-profile/README.md` also says the
   integrated frontend has not been stage-profiled; the new source01 capture now
   supplies that partition. Do not use the historical 117-second frontend as
   though it is the remaining integrated cost (94.833 seconds).
4. The compact verifier's 11.06% and repaired product prototype's 7.51% are
   **slice results**, not compiler gains. Their reports already qualify this
   correctly. Likewise the append workload's RLE improvement comes from a
   transport-capability change, and the List128 apparent regression uses an
   unchanged executable. Preserve those distinctions in any short summary.
5. Final03 proves Q2=Q3, not Q1=Q2. Its native-request `runtime` pin is explicitly
   future-build context; actual serial-runtime linkage is proved by its N1/N2
   build receipts. The source01 profiler did not sample that final serial image.
   No source01 stage fraction can be called an exclusive final03 clean cost.

Other negative findings were already responsibly scoped: range-pass repetition
is not automatically redundant, generated-code size is not execution speed,
compact-name text ceilings are not time savings, and broad current hot workers
do not all suffer the prototype's product-admission failure. No untracked note
reviewed establishes 50-second execution, upstream parity or a quota reduction.
