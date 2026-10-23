# P127-002: recover a lost whole-program transport capability

Status: experimental overlay prepared; checked execution and causal timing
remain root-owned. No default change or native qualification is claimed here.

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

At preparation time only source composition/inverse reconstruction and host
Python/JavaScript syntax checks have run. No target or finite predicate was
executed by the implementing agent.
