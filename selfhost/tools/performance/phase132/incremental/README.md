# Object-reuse prototype commands

Run under the root-owned serial CPU3 process-tree guard. The tool does not
silently select a CPU or start frontend compilation. All output/cache paths
must be fresh under `selfhost/build/phase132` unless explicitly reusing the
completed cache. See [scope and gates](../../../../../implementation/phase132/incremental.md).

```sh
python3 -B selfhost/tools/performance/phase132/incremental/objects.py prepare --source selfhost/build/phase130/p131-final-self01/program.ssa --runtime selfhost/build/phase128/runtime-borrow01/runtime.o --out selfhost/build/phase132/object-baseline01
python3 -B selfhost/tools/performance/phase132/incremental/objects.py build --plan selfhost/build/phase132/object-baseline01/plan.json --cache selfhost/build/phase132/object-cache01 --out selfhost/build/phase132/object-baseline-build01 --cold
```

After the independently acquired real edit is closed, substitute its actual
`program.ssa` path below; there is no generated or assumed edited output.

```sh
python3 -B selfhost/tools/performance/phase132/incremental/objects.py prepare --source ACTUAL_EDITED_PROGRAM_SSA --runtime selfhost/build/phase128/runtime-borrow01/runtime.o --out selfhost/build/phase132/object-changed01
python3 -B selfhost/tools/performance/phase132/incremental/objects.py build --plan selfhost/build/phase132/object-changed01/plan.json --cache selfhost/build/phase132/object-cache01 --out selfhost/build/phase132/object-changed-cached01
python3 -B selfhost/tools/performance/phase132/incremental/objects.py build --plan selfhost/build/phase132/object-changed01/plan.json --cache selfhost/build/phase132/object-cache-reference01 --out selfhost/build/phase132/object-changed-reference01 --cold
python3 -B selfhost/tools/performance/phase132/incremental/objects.py compare --cached selfhost/build/phase132/object-changed-cached01/report.json --fresh selfhost/build/phase132/object-changed-reference01/report.json --out selfhost/build/phase132/object-changed-comparison01
```

These commands do not replace complete-output qualification. The final compare
is a data-only ELF section comparison; runtime checks remain separate root-owned
gates. A failed or partial cache entry is refused, not overwritten or promoted.

Supplemental data-only gates retain the original consumed builder unchanged:

```sh
python3 -B selfhost/tools/performance/phase132/incremental/audits.py compare --cached selfhost/build/phase132/object-changed-cached01/report.json --reference selfhost/build/phase132/object-changed-reference01/report.json --out selfhost/build/phase132/object-elf-comparison01
python3 -B selfhost/tools/performance/phase132/incremental/audits.py census --baseline selfhost/build/phase132/object-baseline01/plan.json --changed selfhost/build/phase132/object-changed01/plan.json --out selfhost/build/phase132/object-change-census01
python3 -B selfhost/tools/performance/phase132/incremental/audits.py gates --baseline selfhost/build/phase132/object-baseline-build01/report.json --cached selfhost/build/phase132/object-changed-cached01/report.json --reference selfhost/build/phase132/object-changed-reference01/report.json --comparison selfhost/build/phase132/object-elf-comparison01/report.json --out selfhost/build/phase132/object-output-gates01
```

The last command prepares the 15 exact root-owned commands and authenticated
oracles; it does not execute them. Paths above identify the retained closed
experiment, so use fresh successor paths for a rerun. `churn.py` is a bounded
text/bit-pattern classifier, not a semantic pool decoder. `archive.py` seals the
selected closed receipts and logs into a fresh publication directory and verifies
every archived member; it never builds or runs a compiler/program.
