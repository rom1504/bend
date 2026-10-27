# Early native fixed-point qualification

Source/receipt review, 2026-10-27; no target execution by this reviewer. This
reviews a proposed qualification discriminator, not an already completed gate.

The proposed shortcut is valid **if the identity gate is strict**. Let `S` be
the exact candidate source and fixed request inputs, `P` the qualified parent,
and `M` the fixed machine build including the selected runtime:

```
Q1 = P(S);       N1 = M(Q1)
Q2 = N1(S);      N2 = M(Q2)
```

If the complete Q1/Q2 products and the complete N1/N2 executable files are
observed identical, N1 has already reproduced its own implementation on S.
Under the same deterministic request/runtime assumptions, N2 repeating the
request would repeat the same computation. A third full self-build would be a
repeatability observation, rather than a new bootstrap implementation. Its
omission should be explicit: **Q1=Q2 and N1=N2 observed; Q3 not executed.**
This is stronger at an earlier generation than the previous Q1-allowed-to-differ,
Q2=Q3 gate. It is not a proof of compiler correctness or determinism.

## Required boundaries

1. Rehash the qualified parent and complete candidate source, checked-API/source
   composition, Base text, carrier and stamp, imported sources if any, and the
   same ordinary compilation mode. N2's producer must be the actual N1 binary;
   comparing two builds both produced by the parent would establish no native
   self-reproduction.
2. Require successful complete emission, no compiler/QBE errors, matching full
   QBE size/content, and successful assembly/link. The current
   [`pipe/build-v02.py`](../../selfhost/tools/performance/phase134/pipe/build-v02.py)
   `--expected-qbe` gate checks full streamed length and SHA256. For literal
   byte-comparison wording, retain Q2 and compare complete Q1/Q2 files; otherwise
   accurately name the existing full-stream digest gate.
3. Require the same runtime object, QBE executable/target, assembler/link driver,
   flags and order. Compare complete machine objects and preferably complete
   final ELF files directly. Whole-file equality includes loader metadata and
   avoids introducing a new ELF normalization policy.
4. If complete ELF files differ, `.text`/`.rodata`, or even all allocated section
   contents alone, are insufficient for image equivalence. The loader follows
   program headers: PT_LOAD file/memory sizes, virtual addresses, flags and
   zero-fill; entry point; interpreter; dynamic relocation/initialization data;
   TLS and relevant execution policy must also match. The cheapest conservative
   fallback is the existing Q3 campaign, not a new general ELF equivalence tool.
5. Retain the independent source check, finite controls, fresh N2 focused19 and
   ordinary45 output/refusal suites. Identical stages can share identical bugs;
   bootstrap equality cannot replace independent semantic oracles. Revalidate
   input/output pins when sealing the receipt.

Dynamic loader/libraries, hardware, environment, file contents and request
arguments remain external execution assumptions even with identical ELF bytes.
The selected runtime contains executable-relative path and GPU helpers, so this
argument must not silently generalize to all launch modes. In this ordinary
`phase111` request, source, Base and carrier paths are explicit and GPU is off.
`p111_rt_main` removes executable argv[0] from Bend IO.args;
`p111_native_request` reads the three explicit files. The different N1/N2 binary
directories therefore do not themselves supply a different compiler input on
this route. Keep diagnostic instrumentation disabled as in the existing guard.

## Current inspected evidence

[`p146-context01-n1/report.json`](../../selfhost/build/phase134/p146-context01-n1/report.json)
records qualified final04 N2 producing source03 in 275.327356 seconds. Source03
is `96c40c9dd273e2fae5fabfe68093aa7fb8f25f075e2317bed06ff46d4feaab80`;
the retained Q1 is 117,232,528 bytes,
`dceae94a7659ad1ff58395ed34914971422ff9e5841668e910cd95e6b0914010`.
Its runtime is the unchanged serial object `2d078323…e493a3`, and N1's ELF is
`5070701ca8a403f0094531ecebe8e9fde4cce7301a6320f4fbec2ab29a034ff5`.
This receipt alone is acquisition evidence; the proposed N2 identity and fresh
semantic gates still need their own receipts. If any strict identity condition
fails, preserve that result and use the established qualification sequence.

## Subsequent outcome: strict shortcut not adopted

The completed
[`N2 receipt`](../../selfhost/build/phase134/p146-context01-n2/report.json)
records matching complete QBE stream length/digest and identical assembly and
machine-object hashes. Its final ELF SHA256 is
`367b639915c0bbc8906fc5827b002ca2c7fc07acc238034e54be994f8833d251`,
different from N1's `5070701c…034ff5`. Therefore the strict full-file gate above
does not pass. The coordinator chose a fresh Q3 request instead of a new ELF
normalization policy. No ELF equivalence or observed Q3 result follows from
these N1/N2 receipts alone.

N1 retained its full emitted IR; N2 did not. Their 275.327s versus 268.311s
pipeline wall times therefore also differ in output-retention work and are not
a clean compiler-speed comparison. The planned matched ordinary requests use
the same streaming/output policy and independent complete-byte reference.
