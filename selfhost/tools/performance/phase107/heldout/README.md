# Frozen scalar source gate

The first run passed all six native builds and 196 exact-output checks. The
[report](../../../../build/phase107/heldout01/report.json) retains complete stdout,
stderr, commands, QBE products, executable pins and per-process clocks. The
[external guard](../../../../build/phase107/heldout01-guard/process.json) completed
in 4.331787s with status 0; the harness recorded 4.245778s. These campaign clocks
are correctness-gate costs, not a performance comparison.

Commit `8b3fba0` froze the three sources, [independent oracle](oracle.py),
[98 input/expected-output records](expected.json), [method](controls.py) and
[manifest](manifest.json) before any compiler check. No source, expectation,
method or optimizer was adapted after that freeze. A refusal would fail the gate;
the method permits neither exclusions nor policy search.

| Source | Contract and independent oracle | Inputs | Raw + fast outputs |
| --- | --- | ---: | ---: |
| [GCD](gcd.bend) | Subtraction GCD of the low 10 bits; Python `math.gcd` | 18 | 36 |
| [Triangular](triangular.bend) | Non-tail sum through low-10-bit `n`, plus wrapping U32 seed; closed formula | 56 | 112 |
| [Saturating](saturating.bend) | Saturating U32 addition and piecewise helpers; integer minimum and branches | 24 | 48 |

Inputs include zero, equal/reversed operands, recursion-bound transitions,
unsigned high bits, overflow and branch boundaries. Each source is checked and
compiled through the fixed `native-source04` image with prepared Base, once with
`raw` and once with `fast`, using QBE whole-object mode and the unchanged common
runner ABI. Every execution must return 0, print exactly the expected decimal
value plus one LF, and produce empty stderr.

For a separately authorized replay, choose a fresh output directory and run this
inside the campaign's serial CPU3 guard with a 30s outer deadline:

```sh
python3 -B selfhost/tools/performance/phase107/heldout/controls.py \
  --out selfhost/build/phase107/heldout02 --max-seconds 25
```

The manifest authenticates 23 inputs, including source/image/acquisition,
Base/carrier, driver/helper, Python, QBE, binutils, runner and all fixture/oracle
files. They are verified before and after execution. This is new final held-out
qualification following the earlier policy investigation; it does not make those
earlier policy-search cases held out. See the
[scope and result](../../../../../implementation/phase107/heldout-source-gate.md).
