# Reproducing the cold direct-x86 comparison

Run from the repository root on the qualified Linux/x86-64 host. The native producer, prepared Base carrier, compiler runtime and source snapshot are the retained Phase198/201 inputs identified in the Phase201 report. Phase201's prepare.py recreates its compiler source from the pinned Phase198 source if required. The acquisition input and replay helpers check their identities. Choose fresh output names for each run. The conservative disk supervisor observes other activity on the same filesystem, so the campaigns use a 2 GiB transient allowance and retain the 5 GiB reserve.

Recreate the research compiler source. A second independent composition must have the same SHA-256 as the first, `42dbbd2c900b9f51c79c337e4226a219b2bc83aaed06692d601bb9e17e373aa8`.

```sh
python3 -B research/phase202/cold/compose.py \
  --out selfhost/build/phase202/reproduce01 opcodes template sized
bash research/phase202/cold/campaign.sh check p202reprocheck selfhost/build/phase202/reproduce01
bash research/phase202/cold/campaign.sh acquire p202reproacq selfhost/build/phase202/reproduce01
bash research/phase202/cold/campaign.sh self p202reproself selfhost/build/phase202/reproduce01 p202reproacq
python3 -B research/phase201/cold/job.py p202repro45 160 2048 \
  python3 -B research/phase201/cold/transfer.py --out OUT \
  --image selfhost/build/phase201/p202reproacq/program.gz
```

Each build reads source, runs the compiler on one pinned CPU and links the fresh object. The timer starts immediately before invoking the native compiler and stops when linking completes. Reading the compressed producer into memory, artifact hashing, checking and qualification are outside this interval. Project-cold here means the build reuses no prior object or checked state for the compiler source. Its CLI uses the same prepared standard-library Base carrier as the historical benchmark. The operating system page cache is uncontrolled.

For the fast gates, the source and scripts live in [opcodes](../../research/phase202/opcodes/), [continuations](../../research/phase202/continuations/) and [elf](../../research/phase202/elf/). The compressed campaign receipts contain the exact commands, producer and source identities, resource usage, failed attempts and output digests. The original Phase198 N3 timing uses different compiler source. The new acquisition and self-reproduction pair uses identical source and target runtime.

The full physical profile uses the qualified sampler at a 20 ms CPU interval. Its symbolizer verifies the exact executing native image. Destruction, field extraction and other runtime functions can serve many compiler stages. The leaf counts assign CPU time to named operations. Stage ownership of those shared operations requires caller attribution.
