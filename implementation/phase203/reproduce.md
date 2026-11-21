# Reproducing the preparation and emission measurements

Use the qualified Linux x86-64 host with the same compiler source, producer, prepared Base, runtime and linker that Phase202 used. The Phase202 source digest begins with `42dbbd2c` and its self-reproducing producer digest begins with `6d1b9098`. [Phase202 acquisition](../phase202/reproduce.md)

The commands below use the Phase201 disk, time, CPU and memory supervisor. Run one job at a time, on CPU 3, with the 5 GiB disk reserve. The supervisor refuses to overwrite an existing output directory. Change the job names for a repeat. Large binaries and listings stay in the local build store.

```bash
D=selfhost/build/phase201
J=research/phase201/cold/job.py
P=research/phase203
python3 -B "$J" p203reproasm 480 1536 python3 -B "$P/assembly.py" OUT
python3 -B "$J" p203reprobuild 180 1536 python3 -B "$P/instrument.py" OUT "$D/p203reproasm"
python3 -B "$J" p203reproverify 110 1536 python3 -B "$P/run.py" --build "$D/p203reprobuild" --out OUT stock marks counts counts marks stock
python3 -B "$J" p203reprocounts 480 1536 python3 -B "$P/run.py" --build "$D/p203reprobuild" --out OUT --full counts
python3 -B "$J" p203repromarks 480 1536 python3 -B "$P/run.py" --build "$D/p203reprobuild" --out OUT --full marks
python3 -B "$P/summarize.py" "$D/p203repromarks/results.json" "$D/p203reprocounts/results.json"
python3 -B "$P/overlap.py" "$D/p203reproasm"
```

The `stock`, `marks` and `counts` executables come from the same ordinary GNU assembly listing. Each request checks the expected entire direct object against its independent Phase202 receipt and links it. The verifier executable must also print `768`. The probes use the first function entry at each named boundary, including emitted adapters for that source name. Read the timestamp-only run for stage timing and the counted run for work quantities. The hooks include a first-entry guard and preserve registers and flags. The counter labels distinguish public entries, private workers, direct call sites and tail-loop visits. One operation can hit several labels. In particular, every hash loop includes a terminal visit. Source planning, native preparation and object emission use the same process.

The ranking trial uses ordinary direct-object images for the speed comparison.

```bash
S=selfhost/build/phase203/reprosource
I=$D/p202acquire01/program.gz
R=$D/runtime01/runtime.o
python3 -B "$P/candidate.py" "$S"
python3 -B "$J" p203reproctrl 100 1536 python3 -B "$P/control.py" OUT --source "$S"
python3 -B "$J" p203reproimage 460 1536 python3 -B research/phase201/cold/replay.py --out OUT --full --source "$S/compiler.bend" --product-runtime "$R" --save-image "image:$I"
C=$D/p203reproimage/program.gz
python3 -B "$J" p203reproab 90 1536 python3 -B research/phase201/cold/replay.py --out OUT --reference "$D/p202self01smoke/results.json" "image:$I" "image:$C" "image:$C" "image:$I"
python3 -B "$J" p203reproself 460 1536 python3 -B research/phase201/cold/replay.py --out OUT --full --source "$S/compiler.bend" --reference "$D/p203reproimage/results.json" --product-runtime "$R" "image:$C"
python3 -B research/phase202/cold/compare.py "$D/p203reproimage/results.json" "$D/p203reproself/results.json"
```
 Stage its source using `candidate.py` and pass the directory to the control harness. The control harness runs the full upstream source checker and the sliced hosted API differential. For acquisition, compile this trial source with the Phase202 image through Phase201's `replay.py --full --save-image --source ... --product-runtime ...`. To time a true self-build, invoke that new image on the same trial source and pass the acquisition's `results.json` as `--reference`. Phase202's `compare.py` additionally verifies unchanged object and linked ELF digests and equality of the producer and successor. No prepared compiler-source object is reused.
