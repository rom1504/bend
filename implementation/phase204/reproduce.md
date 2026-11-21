# Reproduce Phase204

Run from the repository root on the native Linux/x86-64 host. The Phase203 source, native image, same linked runtime and Phase198 prepared Base are required. [Producer and runtime acquisition](../phase203/reproduce.md)

The repository supervisor pins CPU 3, preserves the 5 GiB reserve, and rejects output directory reuse. Choose fresh names for repetitions. The large generated sources and binaries remain in the local build store. The compressed receipts in this directory retain identities and individual timings.

```sh
P=research/phase204
J=research/phase201/cold/job.py
D=selfhost/build/phase201
B=selfhost/build/phase204
python3 -B "$P/prepare.py" "$B/repro-copy-live" copy live
python3 -B "$J" p204reproctrl 120 1024 python3 -B "$P/control.py" OUT "$B/repro-copy-live/compiler.bend"
python3 -B "$J" p204reprostrings 120 768 python3 -B "$P/strings.py" OUT
python3 -B "$J" p204reprocensus 110 1024 python3 -B "$P/census.py" OUT
python3 -B "$P/prepare.py" "$B/repro-cont" continuation
python3 -B "$J" p204reprocontract 40 768 python3 -B "$P/contract.py" OUT "$B/repro-cont/compiler.bend" "$D/p204reprocensus/census.json"
```

The initial full-source check of the copy/liveness candidate caught an affine reuse error at its two allocator callers. The final version makes those two uses explicit. The checked differential uses the same changed function bodies. To reproduce the algebraic gate, run `lean research/phase204/Liveness.lean` with Lean 4.32.0.

For the complete continuation experiment follow the commands in [native.sh](../../research/phase204/native.sh) with the fresh trial source and fresh job names. The Phase203 producer builds the new compiler. The timed native successor compiles this exact same source, with the same Base and linked runtime. Compare the two receipts with `research/phase202/cold/compare.py`. The command checks object size and SHA-256, linked ELF SHA-256, input source, runtime, and equality of producer and successor. The verifier oracle requires its entire independent object and stdout 768. The portfolio gate requires each ordinary program's independent object, output, iteration count and time-field contract.

The machine census uses the original Phase203 linked image and the retained Phase202 textual listing. These are two different snapshots. The ELF reader compares a known complete function body and resolves its one PC-relative relocation. The assembly reader hashes full public function definitions with only their own identity normalized.

```sh
python3 -B research/phase204/footprint.py selfhost/build/phase201/p203rankimage01/program.gz
python3 -B research/phase204/families.py selfhost/build/phase201/p203asm01
```
