# Qualified FAST checkpoint

This is the separately qualified Phase131 FAST research compiler. It preserves
the earlier algorithm candidate while the later combined code-generation
candidate is evaluated. It does not change the installed compiler or select
FAST as the final Phase131 result.

The exact source is stored in `compiler-source01.bend.gz`. `source.json` records
its restored hash and deterministic compression settings. Decompression was
checked against all 2,628,217 original source bytes. `candidate.json` identifies
the checked API, native N1/N2 images, runtime, carrier, and qualification.

Qualified Phase130 N1 compiled this source to FAST N1, which compiled the same
source to FAST N2. Both emissions contain exactly the same 104,618,546 QBE bytes.
Focused19 passed on each native image (16 positive programs and three expected
refusals); ordinary45 passed on N2. This is finite regression qualification and
a raw-QBE fixed point, not an ELF fixed point or a complete compiler proof.

The preserved timing block measured FAST **N1**, Phase130 N1, and pinned
TypeScript on three requests over three rounds. Its geometric compiler-request
ratio was **0.939× Phase130** and **1.704× TypeScript**. Those are compiler timings,
not the speed of generated programs. The raw timing receipt still records that
FAST was experimental when measured; qualification completed afterward. There
is no N2 timing claim here.

The source bridge covers five actual safe declarations and seven law names.
It does not prove the generic term traversal, merge implementation, caller
integration, or compiler translation. The archive contains the exact
qualification, admission, source/API binding, semantic, source-bridge, and
timing receipts. Native binaries, full QBE products, toolchains, and other raw
dependencies remain separately pinned by those receipts.

`receipt.json` records the archive producer and copied-file hashes. Packaging
ran only data checks and compression; it executed no compiler or program.
