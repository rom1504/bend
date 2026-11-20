# Reproducing the compiler and timing experiments

Run from the branch root. Use the pinned Phase182 upstream checkout, Phase194 toolchain assets, qualified Phase195 native45 manifest and mature C references listed in the evidence. The timed executables use the ordinary native45 inputs and result/count protocol. Record new runs under fresh output names. The experiment guard pins CPU 3 and keeps a 5 GiB disk reserve.

## Produce an opt-in full compiler

The staging tool builds the ordinary maintained x86 source profile in a fresh directory and writes a unified diff against its original modules. Without an API input it only needs the checkout at the pinned baseline and the experiment sources.

```sh
python3 -B research/phase197/validation/stage-compiler.py \
  --minimum --decrement research/phase197/decrement/select-v2.bend \
  --out selfhost/build/phase197/replay-source
git apply --check selfhost/build/phase197/replay-source/compiler.patch
```

Omitting either selection builds the other alone. The generated `compiler.bend` is the complete x86 source input for the ordinary build workflow. With `--api PATH`, the staging tool additionally compares every candidate declaration with the measured checked API. The full-source experiment checks the exact assembled source using the pinned upstream checker. [Maintained build workflow](../../docs/self_hosted/workflow.md)

## Reproduce the timing

The evidence archive includes the exact argument vectors, method hashes, benchmark inputs, executable identities, calibration pilots, individual timing observations, failure reports and guard receipts. It contains metadata, not compiler images. The materialized Phase195 timing helper is the tracked `selfhost/tests/phase185/runtime-loop.py` with its pilot retry limit increased from 8 to 20. Its required SHA-256 is `e325f78026e84b99a445b2a4a7c4fc841df51b6899dd4574c7edfa7dd2d4c89b`.

1. Assemble the baseline x86 source and prepare the hosted baseline API. Use the baseline source, API-source and acquisition argument records in order. The qualified N1 product manifest supplies baseline executables; the baseline rebuild recipe records how to regenerate them.
2. Prepare each compiler API from the same baseline source and acquire it. Use the minimum V1 and decrement/combined V2 recipes. The V1 decrement checker failure has its own receipt.
3. Run the minimum, combined minimum and combined decrement control harnesses. Prepare the shared emission plan before executing the combined controls/emission argument batch. The prepared input identity covers 4,081 shared declarations. Build each candidate's six direct objects and check each ordinary output with its independent catalog oracle.
4. Run the machine-product comparison, merge the four roles, and run the two timing sessions sequentially. The summary script reads both raw reports. The C-reference session uses a separate three-role manifest. The extra-input gate checks new points against C. The additional source, input and C-reference commands are listed together in the archive.
5. The two discovery directories each provide a separate replay path including generation, models, output checks and assembler-layout siblings. The absorbing-state follow-up has its own frozen inputs and measurements.

[Implementation sources and fixtures](../../research/phase197) · [Ray discovery](../../research/phase197/discovery-a/RESULTS.md) · [BST and tree discovery](../../research/phase197/discovery-b/README.md)
