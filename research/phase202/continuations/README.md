# Pop-and-apply continuation selection

The selector recognizes seven complete typed statements after the ordinary public planner and local-name hygiene check. They allocate the 2,048-byte scratch region, pop one saved value, read slot zero, read the first incoming register, copy the saved local to a distinct generated local, apply the incoming function to that saved argument, and return the reply. The three generated locals must be distinct numeric `v_` names. The template uses ordinary typed instructions, function directives, the current local loop label and the direct runtime-call relocation. The generic selector handles all other rows.

The frozen direct compiler object contains 7,174 instances sharing the same 118-byte text and relocation target. The representative `$p111.k.3195` calls `p111_rt_apply` via an `R_X86_64_PLT32` relocation at offset 99 with addend −4. A retained older complete QBE compiler IR independently supplies 7,610 exact alpha-renamings of the corresponding statement sequence, including the intermediate copy. These counts are from different compiler snapshots. [Evidence and first complete IR body](evidence.json).

The candidate-only screen checks a focused Bend API, tests an admitted instance and three near misses, encodes the selected sequence, and compares all 118 bytes, the relocation kind, offset, addend, target and function symbol against the frozen direct object. A second mode includes the generic selector to compare complete ELF and assembly and time selector calls under the hosted engine. CPU3 remains owned by the coordinator.

```sh
python3 -B research/phase201/cold/job.py p202cont02 30 10 \
  python3 -B research/phase202/continuations/quick.py --out OUT
python3 -B research/phase201/cold/job.py p202contpaired01 40 12 \
  python3 -B research/phase202/continuations/quick.py --paired --out OUT
```

`prepare.py --out FRESH/compiler.bend` overlays Phase201 `source02`; `--source` accepts a composed input containing the original segment hook. `standalone.py --out FRESH` stages optional native paired fixtures with 127 admitted continuations, one swapped-argument refusal, and increasing function/local IDs. `screen.py --fixture FRESH --out OUT` uses the existing guarded Phase201 native oracle/timing procedure. This heavier pair remains subject to the inherited 35-second per-image compilation limit. The selector gate alone does not measure cold self-build transfer.
