# Compact private constructor spines

BST insertion in the Phase199 native45 fixture uses its private
`List<&2,BFrame>` path affinely during descent and ascent. Each selected interior node adds `BF{pivot,sibling,flag}`
inside a list cell. Ascent matches the frame and flag to rebuild the tree.
The incumbent absorbing countdown already recognizes an unchanged leaf.
An independent replay of the actual 64/17 key sequence counts 365 genuine
interior visits, 119 left and 246 right. At 32/0 the count is 496, all right.

## Measured alternatives

Both alternatives retain the public benchmark, input generation, digest and
clock. They were upstream checked with zero holes and emitted by qualified
Phase199 N1, then linked against the same live/scan runtime as the published
incumbent. The explicit trail uses two nonempty constructors, each holding
the unrelated sibling, pivot and tail. Descent and ascent remain tail
recursive. The direct recursive alternative rebuilds the tree on the
machine call stack and can require stack proportional to the visited depth.

| Candidate on BST64 | First balanced session | Second balanced session |
|---|---:|---:|
| Explicit compact trail | 0.78754 | 0.79504 |
| Direct recursion | 1.38851 | 1.40008 |

Each number is the median candidate/stock elapsed ratio for three matched
rows, rotated through the three possible first roles. The second session
reverses the order. The compact trail won all six rows. Each role, stock and
the mature C product agreed with an independently computed value on eight
inputs. For the seven noncatalog inputs the public fixed-digest warmup and
success counts used zero, and the independently compared full computed
digest still printed. The calibrated canonical timing validated every
repetition. The measured comparison is for generated product execution.
There is no compiler bootstrap or broader promotion claim.

## Automatic transformation

`private_spine.py` is an experimental restricted source-to-source pass. It
discovers a single-constructor product with exactly one Bool field, then finds
laws using a list of that product at the Data kind. Fresh private clones replace each
immediate frame/list construction or matching pattern with one tagged frame
containing all other fields and the previous tail. The pass preserves field
order, tail position and the target branch. Original public helpers and
their representations remain available to all other callers. It redirects
only entries whose state starts with a literal empty private path and whose
final consumer returns a representation-independent result. It follows the declared argument and result types through nested calls and
pairs to prove every private path argument comes from a fresh empty literal.
Its entry grammar accepts standalone call expressions; its pure-operation
vocabulary is explicit.

For any original spine, the representation relation maps the empty list to
the new empty constructor and maps a cons cell to the constructor selected
by its head's Bool, carrying the remaining payload and recursively related
tail. Each accepted push and consuming match preserves that relation for
either tag. Each cloned pure helper applies only those representation
changes to the original body. The recursive steps and fuel arithmetic
are preserved. Mandatory upstream type checking independently checks that
the fresh representation cannot escape into an original monomorphic
interface. Unrecognized constructors, consumers, nonliteral flags, list
operations or boundaries refuse the rewrite. The current pass runs outside
the maintained native compiler. Integrating it requires a checked-book
analysis with resolved constructor and binder identities, quantities and a
fallback for arbitrary input syntax. Its text parser is an experimental
admission implementation for the source subset.

The independent transcript fixture has no tree. It advances a scalar LCG,
records adjacent words with a parity tag in the middle field, and folds
its history backward with different mixing operators. Its oracle reconstructs
the transcript using Python integer arithmetic. The BST shape fixture prints
both the original and resulting entire trees for 44 combinations of shared
root, fuel and key, including duplicate routing, exhausted fuel on leaf and
interior, and U32 edges.

## Reproduction

Run all native products through the project guard on the scheduled CPU3
lane. Use fresh output directory names and preserve the 5120 MiB reserve.
From the repository root, the first two commands prepare and run the
explicit alternatives. The third runs the automatic pass through native
emission, persistent-shape and unrelated-transfer controls.

```sh
python3 -B research/phase200/tree/prepare.py --out selfhost/build/phase200/tree-source01
python3 -B research/phase200/measure/job.py tree-screen01 20 2 python3 -B research/phase200/tree/screen.py --source selfhost/build/phase200/tree-source01/report.json --out selfhost/build/phase200/tree-screen01
python3 -B research/phase200/measure/job.py tree-auto02 23 2 python3 -B research/phase200/tree/automatic.py --out selfhost/build/phase200/tree-auto02
```

Machine-specific input hashes, both control session orders and raw timings
are in [the first screen](evidence/first-screen.json). The source pins and
independent counts are in [the prepared inputs](evidence/first-source.json).

Static relocations confirm that each branch of the incumbent product descent
has a three-field frame constructor plus a two-field list constructor. Both
two-field constructor sites disappear in the compact descent, while the two
three-field sites remain. The product descent shrinks from 716 to 584
bytes, and the direct ascent from 915 to 556 bytes. These are static
machine sites. [Disassembly-derived counts](evidence/machine-sites.json)

The restricted pass admits the two BST production inputs among 45 native
fixtures and the original BST test among 1,860 tests. The 17 published
runtime source files have no admissions. The selfhosted frontend offers a
separate future case in `selfhost/src/front/fresh_work.bend`. Its seven
continuation constructors are pushed into an ordinary list, then destructured
after a pop. Applying this representation there would require supporting
an existing sum type and proving the separate head-dispatch call is
private. [Corpus census](evidence/census.json)

The first automatic emission failed upstream source checking because its
cloned helper bodies were appended after the first caller. The generator
now inserts them before the redirected calls, preserving original
dependency order. [First refusal](evidence/auto-first-refusal.json)

## Automatic native result

The corrected generator transformed the original BST64 source and produced
a checked native executable. Across forward and reverse balanced orders its
elapsed ratios against the ordinary Phase199 incumbent were **0.77617** and
**0.74909**, corresponding to 22.38% and 25.09% less time. All four candidate
rows were below every incumbent row; each observation ran 8,192 validated
invocations. Eight input digests also matched the independent reference.
[Source, executable hashes and raw timings](evidence/automatic.json)

A separate generated native executable matched all 44 exact pairs of original
and updated trees. The independent scalar transcript and its stock source
each compiled with zero holes and produced the same eight oracle values.
Seven rejected source mutations and the two positive admissions are in the
same receipt. The guarded four-product run used 12.0 seconds. The unrelated
transcript establishes semantic transfer; its runtime was not measured.
[Persistent output](evidence/persistent-shapes.txt) ·
[Transcript output](evidence/transcript.txt) ·
[Guard receipt](evidence/automatic-guard.json)
