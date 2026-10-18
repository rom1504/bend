# Optional native full45 gate

`manifest.json` freezes the exact 45-case Phase105 catalogue and its complete
expected output bytes. `prepare.py` authenticated every source and stdout record
against the prior Phase92 successful program execution, including empty stderr
and exit zero. The Phase108 qualification plan, Phase105 corpus, Phase92 inputs,
and Phase111 native assets all bind the same Base and cache carrier. Every source
imports only `Base`; the runner uses its original absolute source path.

These are reused regression outputs observed before Phase111, independent of the
Phase111 candidate. They are not new handwritten oracles, fresh held-out cases,
or 45 independent language features. The catalogue has 45 finite wrappers from
23 distinct historical source hashes. Historical generated C is neither loaded
nor translated by this gate.

The adapter authenticates and imports unchanged `../native-run.py`, changes only
its corpus-directory binding, and delegates to its existing transport, builder,
observation checks, and reports. The manifest pins both methods. The original
focused manifest, runner, sources and oracles remain unchanged.

Run under root's serial CPU3 process-tree guard. After the existing six-case
broader gate passes, execute only the other 39:

```sh
python3 -B selfhost/tools/performance/phase111/coverage/full45/native-run.py \
  --partition remaining39 \
  --image /absolute/path/to/acquired/program \
  --runtime selfhost/build/phase111/runtime-source03/runtime.o \
  --out selfhost/build/phase111/native-remaining39-FRESH --mode cache
```

`--partition representatives6` selects the same six as the original runner's
`--suite broad`. `--partition all45` selects the whole catalogue. Without a
partition, the delegated runner defaults to all 45; its `--names NAME ...` also
works. Do not combine a partition with `--suite` or `--names`. Optional reference
mapping and `--keep-going` retain the original runner's behavior.

For a combined 45-case claim, require successful six- and 39-case receipts using
the same image hash, runtime object, mode, Base and carrier, then count each
canonical source once. The six-case receipt may prefix names with `broad:`;
the frozen source paths and hashes establish their identity. The manifest's
partitions are disjoint and cover exactly 45 source paths.

Each case compiles and executes once, with no benchmark repetition. Defaults are
120 seconds per native request and 10 seconds per QBE, assembler, linker or
generated-program command. `--seconds` and `--build-seconds` can override these
explicit limits. The native supervisor adds transport timeout slack; root's
outer guard bounds the overall campaign. A timeout fails qualification, and the
default stops at the first failure.

The longest historical Phase92 program guard wall was 43.53 ms (`raytrace`);
the other cases were around 23 ms including roughly 20 ms guard polling. These
measurements establish prior finite executions, not an expected Phase111 runtime
or a speed comparison. Compilation by the new generic native image may be much
slower. Source preparation executed no compiler or generated target.
