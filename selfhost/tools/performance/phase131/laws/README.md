# Phase131 usage-summary laws

See [the report](../../../../../research/phase131/laws.md) and
[evidence.json](evidence.json). Fifty-seven distinct laws were independently checked. The first twenty
are recorded in evidence.json; the eight later first-order equivalence and
transport laws are recorded in [first-order-evidence.json](first-order-evidence.json).
The admitted merge domain is two maps with the same key sequence. Full generic
KTerm traversal and disjoint-key merge correctness are still unproved.

## Replay

Run from the repository root. Every output directory must be fresh. The guard
serializes CPU4 work, caps each target at 60s/2GiB, and requires at least 16GiB
available memory. Coordinate this lane with other compiler measurements.

```sh
python3 -B selfhost/tools/performance/phase131/laws/check.py \
  --source selfhost/tools/performance/phase131/laws/aligned-lookup-laws.bend \
  --out selfhost/build/phase131/laws-aligned-lookup-replay01
```

The other independently accepted entrypoints are `add-only.bend`,
`low-only.bend`, `high-only.bend`, `absent-laws.bend`, `lookup-laws.bend`,
`compare-laws.bend` and `aligned-merge-laws.bend`. The last two are already in
the aligned-lookup dependency closure. `laws.bend` is the retained combined
attempt that exceeded the kernel deadline; `lookup-production.bend` is the
retained parser-rejected local-match attempt. Do not treat a glob of all Bend
files as a positive test suite.

The source connection to the acquired candidate can be rechecked without
executing Bend:

```sh
python3 -B selfhost/tools/performance/phase131/laws/source-bridge.py \
  --candidate selfhost/build/phase131/usage-source02/compiler.bend \
  --out selfhost/build/phase131/laws-bridge-replay01
python3 -B selfhost/tools/performance/phase131/laws/prepare-safe-summary.py \
  --out selfhost/build/phase131/laws-safe-summary-replay01
```

The second command constructs a smaller safe algorithm candidate from exact
proved declarations, preserving every other analyzer declaration. It does not
check the full compiler, qualify native code, select the candidate or measure
performance.

The negative controls first independently accept the law-free mutant, then
require semantic rejection with the unchanged laws:

```sh
python3 -B selfhost/tools/performance/phase131/laws/mutation.py \
  --accepted selfhost/build/phase131/laws-add01 \
  --out selfhost/build/phase131/laws-mutation-replay01
python3 -B selfhost/tools/performance/phase131/laws/merge-mutation.py \
  --accepted selfhost/build/phase131/laws-aligned-lookup01 \
  --out selfhost/build/phase131/laws-merge-mutation-replay01
```

No toolchain download/build is performed. The pinned existing frontend,
elaborator and independent kernel must still authenticate against the retained
Phase94 receipt. The runner intentionally refuses changed or missing inputs.

## First-order alternative

The initial safe source was 2.564× slower on the parent's native proxy. The
first-order source removes callbacks and repeated current-head reconstruction.
Its all-input equivalence to the earlier safe algorithms and the transported
aligned-map contract can be replayed with:

```sh
python3 -B selfhost/tools/performance/phase131/laws/check.py \
  --source selfhost/tools/performance/phase131/laws/first-order-summary-laws.bend \
  --out selfhost/build/phase131/laws-first-order-summary-replay01
```

The closure includes 18 laws. It does not prove native speed, production
selection, generic KTerm traversal or the full differing-key map specification.
The first-order proof-source declarations must be authenticated again in any
actual acquired compiler candidate.

## Bounded-map consolidation

The fourteen later laws and actual native proxy/eleven-declaration source
bridge are recorded in [consolidation-evidence.json](consolidation-evidence.json).
`bounded-lookup-laws.bend` proves universal lookup count validity under an
explicit 0/1/many input domain; `empty-merge-laws.bend` proves the maximum lookup
base case for an empty right map in all three modes. Replay either through
`check.py` into a fresh output directory. Full differing-key merge correctness
and KTerm traversal remain unproved.

Authenticate the exact first-order algorithms in an acquired source with:

```sh
python3 -B selfhost/tools/performance/phase131/laws/first-order-source-bridge.py \
  --source selfhost/build/phase131/usage-first-order-proxy01/main.bend \
  --out selfhost/build/phase131/laws-first-order-bridge-replay01
```

This checks eleven declarations against pinned accepted proof snapshots; it
performs no target execution and does not replace native qualification.

## Borrowed String identity experiment

`string-reflexivity-laws.bend` proves exact current `p88_string_eq` reflexivity
and the stronger `p88_string_eq_go(x,x,same)=same` invariant. It uses actual
Word/U32/Char equality, not an assumed comparator. See
[string-evidence.json](string-evidence.json). A native constant-True identity
shortcut requires incoming same=True and retained typed/liveness/ownership
contracts; this is not a Float equality rule.

Replay through `check.py` with a fresh Phase131 output, and authenticate an
actual compiler source through `string-source-bridge.py --source ... --out ...`.
The original proof receipt is `laws-string-reflexivity01`; no native shortcut
or performance gain is established by that receipt.

## Universal merge count-range preservation

`merge-range-laws.bend` proves the actual first-order merge preserves the
0/1/many range for arbitrary differing key domains, including unsorted and
duplicate keys. `merge-range-evidence.json` records the ten new laws and the
24-law accepted dependency closure. The theorem inspects both fields of the
actual output list; it does not prove sortedness, uniqueness, `low <= high`,
full lookup semantics or generic KTerm traversal.

```sh
python3 -B selfhost/tools/performance/phase131/laws/check.py \
  --source selfhost/tools/performance/phase131/laws/merge-range-laws.bend \
  --out selfhost/build/phase131/laws-merge-range-replay01
```

These proofs refer to the unchanged production algorithm bodies. They do not
modify or replace any frozen native qualification or admission receipt.

## Exact bucket scalar fusion

`bucket-fusion-laws.bend` proves `dx(index_bucket(xs,key)) = p131sc_bucket(xs,key)`
for every List<KDef> and key, including empty-key IndexNode matches. It uses
actual concrete producer/helper bodies. `bucket-evidence.json` records the
two accepted laws and source bridge. Replay via `check.py` into a fresh output.

`bucket-source-bridge.py --source <compiler.bend> --candidate <frozen-v03.bend>
--out <fresh-directory>` authenticates the precise extraction and actual
candidate. No full-tree or runtime ownership/performance claim is made.
