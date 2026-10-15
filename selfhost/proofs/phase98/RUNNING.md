# Checking a real compiler edit against the laws

Use the compiler source that the ordinary assembly path actually produced for
the proposed edit. The ongoing-source preparer extracts that file's helper
bodies and checks them against the frozen contracts; it never substitutes an old
candidate implementation. Historical candidate preparers remain available for
reproduction, but rerunning one does not validate a later production edit.

From the repository root, choose a fresh output directory and the relevant
package. This example checks the tag comparison contract:

```sh
python3 -B selfhost/proofs/phase98/prepare-current.py \
  --candidate selfhost/build/phase98/permission-tag-source02/compiler.bend \
  --kind tag \
  --out selfhost/build/phase98/current-tag-proof-source01

python3 -B selfhost/tools/laws/phase98/check.py \
  --source selfhost/build/phase98/current-tag-proof-source01/tag.bend \
  --out selfhost/build/phase98/current-tag-proof-check01
```

For a later edit, replace that concrete example path with the newly assembled
effective native compiler source. Merely editing a canonical module and then
passing an unchanged historical compiler file does not check the edit. This
tool does not perform or certify the canonical-module-to-native assembly step;
retain the ordinary assembly/source-replay receipt for that boundary.

The first command only prepares data. Inspect `manifest.json`: its `candidate`
hash must identify the compiler being reviewed, and `candidateDefinitions`
contains each original and extracted declaration. The second command is a
target run and belongs to the campaign's serial controller. Its default checks
the source, emits safe BendTT, runs the independent pinned kernel and rejects a
separate deliberately false kernel statement. A source-only diagnosis can use
`--source-only`; that result is not independent mathematical acceptance.

| `--kind` | Entry | Frozen public contract |
| --- | --- | --- |
| `held-simple` | `held-simple.bend` | Actual public string comparison equals the original D04 comparator for arbitrary strings. |
| `tag` | `tag.bend` | Actual fused tag comparison equals original comparison of actual `tg(term)` with the key. Includes the held comparison laws. |
| `scalars` | `scalars.bend` | Actual retained-root `ix` and `qt` equal their original complete U32 results for every actual `KTerm`. |
| `permission` | `laws.bend` | Actual foreign-admission helper implements the exact closed whitelist and both explicit input guards. The source02 package independently passed in `permission-proof-check01`. |

`KTerm` and `tg` must still match the frozen reference boundary for packages that
use them. A representation change needs a reviewed specification update. Missing
or ambiguous selected helpers fail preparation. New dependencies are not
silently imported from an earlier candidate: a missing dependency must be added
explicitly to the extraction before checking. In particular, the permission
package includes the actual held comparison finish helper when present.

Original projection references share the candidate's exact datatype, with only
their declaration names reversibly changed. Leading `@unsafe` annotations on
the selected total observers are removed in extraction so that the checker must
validate their bodies as safe. Proof/reference bodies stay frozen. These are
explicit source transformations, recorded in the manifest, rather than a claim
that an unsafe whole compiler was proved safe.

For the first permission candidate, bind the helper to the replayed actual
classifier receipt as well:

```sh
python3 -B selfhost/proofs/phase98/permission/prepare.py \
  --receipt selfhost/build/phase98/observer-permission-source02/changes.json \
  --out selfhost/build/phase98/permission-proof-source01
```

That extra bridge authenticates exact helper bytes, their use by the actual
classifier and every source edit. It does not prove the unsafe classifier's
traversal or that its `trusted` and `filled` arguments were computed correctly.

To also prove equality to the existing actual `nb_contains` expression, use the
membership preparer on the same current compiler. Its entry imports all seven
permission laws and adds the two bridge laws, so a separate permission check is
unnecessary when this package is selected:

```sh
python3 -B selfhost/proofs/phase98/permission/prepare-bridge.py \
  --candidate selfhost/build/phase98/permission-tag-source02/compiler.bend \
  --out selfhost/build/phase98/current-membership-proof-source01

python3 -B selfhost/tools/laws/phase98/check.py \
  --source selfhost/build/phase98/current-membership-proof-source01/bridge.bend \
  --out selfhost/build/phase98/current-membership-proof-check01
```

## Fast check budget and failure handling

For a local change, select its one relevant package and run the default
independent check once. Accepted Phase98 packages occupied roughly 1.7–2.7 s
across their guarded targets; this is an observation about these small packages,
not an authoring estimate or a promise for a future proof. A practical initial
scheduling allowance is 30 s per package, retaining the existing 60 s per-target
guard, 2 GiB tree RSS limit, 4 GiB available-memory floor and CPU 3 assignment.
Do not run packages concurrently with compiler acquisition or timing. Larger
contracts need a new measured allowance rather than silently increasing limits.

Classify a failed run from its raw diagnostics. Resource stops, syntax errors,
missing dependencies and an actual expected/observed proof mismatch are distinct.
For a deliberate semantic negative, first admit the changed helper alone, then
apply unchanged laws. An equivalent implementation may need support-proof
maintenance: the accepted codepoint refactor did, while retaining its public
statements and reference. Preserve the old attempt, make a fresh repair, and
retain the independent counterexample for a genuinely wrong variant.

The fast tier proves safe Bend value contracts. Before promoting an optimization,
also retain actual source replay, finite complete-value/alias controls, generated
C inspection for the intended ownership mechanism, and the relevant compiler
correctness and performance screen. None follows merely from a law passing.

## Catalog and historical evidence

[`catalog04.json`](catalog04.json) records accepted source closures and groups
laws by exact names, statement hashes and body hashes. Its baseline is Phase96
plus the Phase97 ownership model: 35 public contracts and 10 supports. Phase98
currently adds 15 distinct public contracts and 38 supports, for 50 public and
48 support names combined. Its 13 accepted closures contain 109 checked law
instances but only 53 distinct Phase98 named statements. These are not counts
of repeated check runs. Tag
v3/v4/v5 reuse the same statement and proof; the carrier contract is historical
after its helper's removal. Finite controls, unaccepted literal drafts and the
unproved production bridge of the Phase97 model are not folded into this count.
The final combined source has thirteen distinct accepted law names: eight public
contracts and five supports across its tag, permission and membership closures.

The ongoing-source extractor's first data-only preparation failed because the
unrelated `subst_node` law and its proof definition legitimately share a name.
It produced no output. The method
is retained as `prepare-current-v1.py`; the repaired parser requires uniqueness
for every selected helper while allowing unrelated law/body pairs. This is a
preparation failure, not a semantic proof rejection. Fresh tag and scalar data
preparations succeeded; those preparations themselves run no targets.

The membership bridge's initial data preparer appended a declaration to a file
already pinned by its inner extraction manifest. This stale-pin problem was
noticed offline before any target. `permission/prepare-bridge-v1.py` and
`permission-bridge-data01` retain that attempt. The successor keeps the original
extraction in an unchanged subdirectory and writes the bridge closure separately;
`permission-bridge-data02` is its successful data-only preparation.
