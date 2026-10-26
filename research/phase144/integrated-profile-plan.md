# Fresh stage profile for the integrated Phase144 N1

This plan measures the **new** integrated compiler on the unchanged Phase142
input. It does not rerun the old engine or use the reduced native-profile source.
Preparation is metadata only; the coordinator executes all jobs serially on CPU3.

| Artifact | Exact identity |
| --- | --- |
| Executing compiler source | `integrated-source01/compiler.bend`, SHA256 `992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b` |
| Acquired N1 | `phase134/p144-integrated-n1-01/program`, SHA256 `516bf6d3ffeb1d86b2a26a173530ec758b9fe372aad22c38f61417450180aa50` |
| Retained object | SHA256 `f08bda546c00a7671634d66eb19ac4778b132701fe49589c66da3030218f3269` |
| Compiler's own QBE/map input |117,055,961 bytes, SHA256 `4b913b26a9f007aa9296cb99be189f636d9ff32b49a6150c634219859764394a` |
| Request input | Unchanged Phase142 source `15f5cada…7dac1` |
| Expected request output |115,909,112-byte frozen QBE, SHA256 `1dca2d0ea568b2e28db87066ed10dbef01a385f4e38dd4d18c99e1074d128643` |

The exact source is independently checked. Qualified Phase143 N2 produced the
N1 through the retained-IR pipe builder. This experiment does not relabel N1 as
fully native-qualified or change the installed compiler.

The fresh clean pair is304.534s for Phase143 N2 and266.862s for integrated N1 on
that identical request. Both complete products match. The new profile is intended
to locate which work disappeared and which stage costs remain; its diagnostic
clocks are not a replacement for this clean comparison.

Prepared job list: `selfhost/build/phase144/integrated-stages01/jobs.json`.

1. Build only the small marker runtime and relink the new retained object.
2. Seal actual runtime/image products into the fresh manifest.
3. Run the existing exact-QBE Lexer oracle with8ms sampling.
4. Validate the native generic sidecar, source/object binding, required order,
   multiplicity and captured ordinals. Stop if this gate fails.
5. Run the frozen full Phase142 request with32ms sampling.
6. Produce the generic offline stage/owner report.

The already-qualified generic ordinal sampler is reused after checking its
source and unwind-header bytes against the newly prepared sampler. The derived
`runtime/plan-reuse.json` retains the original three-job generic plan and proves
this reuse explicitly. No compiler/QBE/assembler rebuild is needed for profiling.
Resource guards retain3GiB tree RSS,16GiB available memory,256MiB file cap and a
600-second full target deadline.

Three source boundaries changed with the optimization. Required markers now use
`p144o_prepare_annotated`, `p144o_lower_request` and `p144o_prepared`; the first two
replace pure forwarding wrappers and the third replaces the old static-prepared
continuation. Semantic interval labels remain comparable. The spec records the
exact mapping, and the new owner map supplies actual FIDs/symbols. Old numeric IDs
are never copied. `p126bp_complete` remains explicitly optional and is only given
a separate nested interval if exactly one actual invocation is observed.

The previous full stage profile used the earlier stage-hook packaging; the new
capture uses the separately small-gated generic implementation. Stage deltas are
descriptive across these diagnostic images, not an exact causal decomposition of
the12.37% clean gain. Large changes supported by source and hot-owner evidence
can guide the next experiment without another full parent rebuild/profile.
