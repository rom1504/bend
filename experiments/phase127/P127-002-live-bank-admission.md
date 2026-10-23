# P127-002: recover a lost whole-program transport capability

Status: causal compiler-runtime result demonstrated. No installed change or new
repaired-source N1/N2 qualification is claimed.

Hypothesis: the new verified Nat.divmod product import was omitted from the
independent live-bank whitelist. Cold formatting workers therefore disable
register-bank reuse globally, introducing clearing/copying into hot compiler
and ordinary-program paths. Repairing that one admission should remove those
operations without changing generated instructions or program semantics.

Static evidence: [audit](../../implementation/phase127/live-bank-audit.md) and
[45-program descriptors](../../implementation/phase127/live-bank-evidence.json).
Phase126 loses flag4 in44/45 products, including tree/morning; native compiler
capabilities change5→1. RLE already lacks the flag because of a separate
concat-helper omission and is intentionally outside this first repair.

Implementation: [reproduction and commands](../../selfhost/tools/performance/phase127/live-bank/README.md).
The patch extends only `p118z_runtime`; it does not edit descriptor bits,
weaken the main verifier or change runtime code. Source32/runtime hashes and
inverse byte reconstruction constrain the overlay. Twenty additional finite
controls cover legal admission and malformed/unknown-import refusals, alongside
the unchanged29 existing predicates. The prepared source has SHA256
`f4eb3c6b8aca8cdfc72c8eb308db83af50c6bee888a93b69415a77aa5101318d`.

Falsifiers: the verified helper can access/alias the state register bank;
another independent refusal prevents admission; emitted QBE changes beyond
the capability field; independent program outputs differ; or controlled
runtime counters/timing fail to show a useful reduction in transport work.
Record each separately. Fewer requested clears are not themselves a speedup.

The initial cheapest test is checked finite predicates followed by one small
same-source QBE comparison and independent ordinary execution. If successful,
the repaired producer can emit unchanged source32 to isolate compiler-runtime
effects while preserving compiler instructions. Building the repaired source
itself is a different adoption experiment and requires its own qualification.

The root executed the checked API and all49 predicates. Tree and Map outputs
differ only by restoration of flag4; RLE is byte-identical with no flag change,
as predicted by its separate admission blocker. The same-source full compiler
emission differs in exactly one QBE capability field across99,526,466 bytes.
The aligned machine build has byte-identical10,103,457-byte `.text`; its only
allocated-data change, aside from linker build ID, is capability byte1→5.

Three-round contemporaneous clean requests take0.88631×Phase126 time
geometrically: lexer−10.77%, closures−12.78%, Map−10.53%. Remaining ratio to the
fresh Phase125 baseline is1.08335×, dominated by Map's1.19559× ratio.
The single full-source comparison is493.996→444.823s, or−9.95%. It is a scale
check, not a repeated confidence interval or a new upstream benchmark.

All15 other measured runtime event channels match exactly per FID. Requested
clearing falls from614,487,605/236,753,496/954,732,702 words to zero for
lexer/closures/Map. The refreshed5,502 diagnostic samples observe no libc fill.
The capability also governs runtime bank transport paths not individually
counted by those hooks; do not assign the entire speedup solely to `memset`.

Evidence: `live-bank-full-comparison01.json`, `machine-identity02.json`,
`live-bank-paired01/report.json`, `live-bank-event-comparison01.json`,
`full-clean02/report.json` under `selfhost/build/phase127/`, with final compact
evidence and report in `implementation/phase127/`.

The14-minute hosted acquisition was necessary once for the checked causal image;
subsequent profiler runtime links reuse its unchanged generated object. The
source inside that image still has Phase126's policy, so its own output remains
the original Phase126 QBE. Adopting the source repair is a separate experiment.
