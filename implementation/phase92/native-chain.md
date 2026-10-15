# Same-source native chain

The upstream-C native B1 is now built from the exact frozen native source used
by native07. This replaces the previous apples-to-oranges comparison with an
older native source. No compiler source or production runtime changed.

## Identities and bootstrap meaning

- Bend source: `d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097`,
  1,759,353 bytes; the original native-entry source path is used for both
  self-compilation requests.
- Upstream: `059266225b77c8ca256ac6b25ee5c21449bab151`; actual source load,
  validation, zero holes and C emission were rerun. Source derivation replay,
  inverse recovery, all19 derivation inputs and67 upstream inputs were verified.
- Upstream-produced C: `d9c6fe2d0030e648eeeb6ada9c06cd054480eefae6e53e97d54caf866a37365d`,
  17,764,676 bytes.
- New native B1: `6bb07e94e2f8ef383a9b8a476441ea751bb2c22e92c776ae66d779a6d6b72b22`,
  10,019,552 bytes.
- Existing own-C native B2/native07:
  `d7c7a47917884b14fd3ef37471d9f2a8660d7c4ab9bcc93a249c7cb6d0e37d3e`,
  16,913,416 bytes.
- B1's newly emitted full self C exactly matches native07's unpatched build
  input: `dae071f0fae7aec4ae8036ccebe4954690a249e32f59a87ac485b2fa428016bf`,
  38,614,882 bytes. Native07 was reused, not rebuilt under a new filename.

This establishes a content link from the current upstream-C B1 to the existing
B2 product. It does not rewrite the historical bootstrap: native07 was originally
built after the JS/native06 diagnostic-seed route documented in Phase90. Full C
identity supports reusing that existing build and saves another roughly five
minutes of Clang work. It is not a claim of fresh ELF bit-reproducibility or a
correctness proof.

## Build costs and fairness

Fresh upstream acquisition took60.635s overall: load1.271s, check1.479s and
C emission55.350s. It peaked at1,756,098,560 process-tree RSS bytes under a3GiB
ceiling. The2GiB Node heap used for this acquisition is separate from the native
compiler performance comparison.

Fresh native B1 Clang build took194.587s, peaking at4,291,608,576 bytes under
6GiB RSS/16GiB available-memory limits. Clang22.1.4, O2, include path, link flags,
CPU2,3 affinity and timing-report flag exactly match native07's build command;
only C-input and executable-output paths differ. Native07's historical build
was308.201s/4,172,177,408 bytes; those are separate builds, not a repeated build
benchmark.

Each image's executable runtime/providers obey its backend ABI. They cannot be
interchanged as raw C. Compilation requests nevertheless receive exactly the
same Base, prepared carrier, output-runtime parts and nine effect providers.
Upstream IO.args supplies the executable head; native07 needs its explicit
sentinel. The shared native entry sees the same payload arguments.

Self-emission observations and ratios are collected in `summary.json` after both
bounded requests complete. The small-source screen is reported separately in
[compilation-screen.md](compilation-screen.md).
