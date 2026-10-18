# Live samples: interpretation and source correction

The historical
[`native-self01-diagnostic/ptrace01/report.json`](../../selfhost/build/phase111/native-self01-diagnostic/ptrace01/report.json)
and its method copy remain unchanged. Its 24 first-frame observations include
13 in `p111_set_regs` and four in `WL_BEND_CLO_APPLY`. The register-copy hits are
94, 103 or 117 bytes past the recorded symbol, not large-offset shared-library
misattributions. Offline ELF program-header inspection confirms that all 17 PCs
lie in the pinned, non-PIE image's executable load range. This is a useful reason
to inspect register transport and closure application.

These counts are qualitative clues, not estimates that register transport uses
13/24 of CPU time. The sampler pauses a single thread with ptrace, uses 24 fixed
intervals, and performs other metadata/readback work during the surrounding run.
It can sample only a short stage of compilation, and it changes wall-clock
behavior. Deeper frame-pointer chains are heuristic: optimized functions may
not provide a complete usable chain, and return addresses identify call sites,
not CPU time spent in callers. The run is not an unperturbed timing control.

The original sampler assigned the nearest lower `nm` symbol to every address,
including addresses outside the image. Such a shared-library address could be
misnamed as the last executable symbol with a large offset. Its old report did
not retain `/proc/PID/maps`, so it must not be treated as validated attribution
of every historical frame.

The source correction in
[`sample-running.py`](../../selfhost/tools/performance/phase111/sample-running.py)
captures `maps.txt`, pins its bytes, and records the exact image's `r-xp` ranges.
Only PCs within those ranges receive a nearest-symbol label; outside-image PCs,
unrecognized in-image symbols and failed/out-of-range stack reads are explicit
unknowns. This remains a pinned Linux x86-64 diagnostic for the existing non-PIE
image, not a portable unwinder or a statistical CPU profiler. No new sampling
run was executed by this reviewer.

The separate [`relink.py`](../../selfhost/tools/performance/phase111/relink.py)
experiment authenticates a complete earlier QBE build and reuses its exact
object while changing the pinned cached runtime object. It creates a fresh
binary, rechecks inputs and records link-only status. This supports a narrow
runtime experiment without repeating QBE translation. It does not itself prove
the new runtime ABI or logical behavior equivalent; runtime source review and
unchanged semantic observations remain separate gates.

The optional [`sample-continuations.py`](../../selfhost/tools/performance/phase111/sample-continuations.py)
is a separate source-prepared diagnostic for the exact `full-native03/program`
SHA `284797e08ea6c754e6f0a8508e3f2d3bc18b18722ba27616229fee7403897872`.
It obtains the indirect dispatcher return address from `objdump` and checks it
against the reviewed image-specific layout: state starts eight bytes above
that return slot and occupies 2088 bytes. It scans at most 64 KiB of the mapped
native stack, requires one state with matching heap/allocator globals and
valid sequential state/descriptor metadata, then follows at most 64 logical
frames. Each frame skips one FID word plus `arity - incoming` captured words;
the captured words are never recorded. Runtime FIDs, invalid frames, unreadable
memory, pending transitions and ambiguous states stop recovery explicitly.

The raw segment symbol and FID remain available. Generated names have the exact
`$p111.k.<decimal>` form from `p111_name`; their owner label is inferred from the
preceding ordinary definition or direct entry in the descriptor's segment
order, as emitted by `p111_compile_step` and `p111_entry_join`. This is a stage
label, not proof of a dynamic caller. A stop during frame push/pop or a
continuation prelude can expose a transient stack even after these checks.
The tool records maps, method, image/source identities and pause durations;
it records no terms, captures or raw memory dumps. It uses only ptrace attach,
GETREGS and detach, with `/proc/PID/mem` opened read-only. Preparation was checked
with Python AST parsing; no live sampling was executed by this reviewer.
