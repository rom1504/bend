# Ordinary cold native self-build profile

`prepare.py prepare --out FRESH_PHASE143_DIRECTORY` is metadata only. It binds
the exact experimental Phase142 N1 source, acquired QBE, machine object and clean
runtime. It authenticates the existing Phase131 diagnostic runtime against the
unchanged Phase128 source/headers and reversible instrumentation recipe. It
extracts the current QBE dispatch-owner map and writes a **relink-only** plan.
It does not execute a compiler, QBE, linker or target. The candidate remains
explicitly unqualified and unselected.

Prepared instance: `selfhost/build/phase143/profile01/`. Its `jobs.json` records
the following ordered commands for the root's single CPU3 lane:

1. Execute `profiler/build-runtime.py` under the existing guard to link the
   retained current `program.o` with the authenticated diagnostic `runtime.o`.
2. Run `prepare.py seal --out ... --cold-report ...` after that link and the
   ordinary clean current-source self-build both succeed. Sealing checks the
   actual link command/product, exact source/image/Base/carrier request and full
   independent QBE identity. It writes the generic profiler manifest.
3. Run unchanged `profiler/run.py` in sample-only mode, one 32 ms period, under
   CPU3 / 4 GiB process-tree RSS / 16 GiB available floor / 256 MiB file limit.
   The target timeout is 900 seconds and the outer guard allows 960 seconds.
4. Run generic `attribute.py --summary-only` and `timeline.py` offline. Neither
   runs the target. The timeline uses approximate 30 CPU-second windows.

The ordinary command is the current image's `phase111` entry compiling the
**same Phase142 source** with the authenticated compact Base. Expected stdout is
the complete 115,909,112-byte QBE previously produced by qualified Phase137 N3;
stderr must be empty and exit status zero. The output is streamed to a file and
verified by the existing generic profiler. It is neither an incremental-session
request nor a new self-hosting qualification campaign.

With `dispatchInstrumentation=true` and `--modes sample`, the existing runner
sets `BEND_PROFILE_COUNTERS=0`. It enables physical PC sampling, the active
dispatch sidecar and bounded libc caller evidence. Reusing this runtime does
not require recompiling the compiler or regenerating runtime instrumentation.
Only the small diagnostic link is new.

Interpretation constraints:

- Check loss, sample/process CPU coverage, sidecar pairing, owner-map/image
  binding and unresolved shares before deriving quantitative fractions.
- Active owners include synchronous private helper work; they are not complete
  inclusive logical call stacks. Caller evidence is explicitly bounded.
- Counters are disabled: do not infer allocations, query frequency or original
  allocation sites from samples or static counts.
- The sampled process duration is diagnostic. The separately authenticated
  ordinary clean receipt remains the speed observation. A single observed
  diagnostic/clean ratio does not establish precise overhead.
- Approximate CPU windows cannot be aligned exactly to the JS/Bun observer's
  wall-clock stages. Use ordering and active semantic owners to form hypotheses,
  then collect an actual native boundary if a decision requires exact attribution.
- The independent final verifier remains enabled throughout.
