# Remove quadratic report-name membership

Source-only experimental overlay at `0d12402`. No targets run and no maintained
source changed. This is a separate experiment from checked field-quantity reuse.

`driver/report.bend` calls `dr_own_names(book,[])` before producing the proof
dependency report. For each non-native definition, the original recursively
growing `seen` list is queried with `has_name`. An all-distinct sequence of N own
names performs N(N−1)/2 name comparisons. The result must retain first-occurrence
source order; it is not a sorted set and must not include native definitions.

The overlay changes only `dr_own_names`, adding two helpers. The existing
`p142j_members/member/mark` supplies collision-safe membership. Initial `seen` is
converted once; subsequent names are tested using their existing hash. Native
rows are skipped before hashing and are **never marked**, so a later ordinary
definition with the same name still appears in its original position.

Inductive invariant: at every list suffix the index contains exactly the names
in the original `seen` list. A native head leaves both unchanged. A member head
leaves both unchanged. A previously absent non-native head is prepended to the
output while its name is added to both membership representations. Hence the
ordered result agrees, including empty names, duplicate initial names, and hash
collisions. This argument depends on the existing collision-safe set operations;
it is not a new BendTT proof.

Files under `selfhost/tests/phase175/`:

- `semantic-report-names.bend`: three definitions, one original replacement.
- `semantic-report-prelude.bend`: forward declaration for the recursive helper.
- `semantic-report-controls.bend`: 15 complete cases containing input book,
  initial names, literal expected list, cloned original result and candidate
  result. `p175rn_cases` exports those complete values; `p175rn_controls` returns
  pass/fail labels. Controls cover native/ordinary order, duplicates, initially
  seen names, empty names, Unicode, and the costarring/liquid hash collision.

Acquire the overlay by replacing only `dr_own_names`; export both control roots.
Compare complete report verdict and bad-name results on the actual compiler
source before using a full image. Keep checking/unsafe-dependency traversal
unchanged. The final full-request oracle is byte-identical QBE with independent
source/output gates; no generated-program runtime gain is expected.

The retained Phase171 candidate's complete report interval is **2.576791s**.
This is the maximum stage envelope, not a gain forecast. Root identified older
Phase144 report sampling dominated by this routine; that is evidence to test
the algorithm, not a current CPU attribution. Index construction, allocation
and teardown are charged; small books may see little benefit or regress.

## Raw Unicode boundary audit

Source and actual generated-code inspection falsify the suspected lone-surrogate
exception mismatch. `has_name` calls **`p88_string_eq`**, not Base `String.eq`.
The former consumes string heads and compares them with `Char.is_eq`; it does
not reconstruct a `Char`. `index_hash` consumes the same string heads through
`Char.to_u32`. Both are total on ordinary JavaScript strings, including isolated
UTF-16 surrogate units: JavaScript `codePointAt` returns their numeric value,
and slicing consumes one unit. Full scalar pairs consume two units in both.

Read-only evidence in the acquired
`selfhost/build/phase175/report-api01/api.mjs`:

- `Char.to_u32` at514 returns `c.codePointAt(0)` directly.
- `Char.is_eq` at1078 compares the two `codePointAt(0)` results directly.
- `index_hash` at1281 uses only head/tail slicing, `Char.to_u32`, XOR and multiply.
- `p88_string_eq_go` at1693 uses the same head/tail slicing and `Char.is_eq`.
- `index_bucket` at3109 compares collision-bucket names through `p88_string_eq`.

The installed `selfhost/dist/typed-api.mjs` independently has the same relevant
shapes at543,547,783 and1375. Neither path calls the scalar-validating
`char_new`. Base `String.eq` may reach `Char.cmp`, which *does* reconstruct
characters and may validate them, but it is not this membership operation.

Thus string equality implies an identical hashing code-point sequence even for
an isolated surrogate. Hash collisions retain exact equality checking. No new
Unicode guard or original fallback is justified for this concern; an eager
validation guard could itself introduce an exception the old function avoided.

`dr_own_names` is not a maintained public export, but `driver_report_data` is
exported by `selfhost/tools/build/hosted-exports.json`, so it is incorrect to
dismiss the raw-book boundary as categorically inaccessible. The conclusion
above covers JavaScript **strings**, including malformed Unicode; it does not
claim preservation for arbitrary non-string JavaScript objects impersonating
Bend String values, ambient prototype mutation, or invalid native heap objects.
No runtime probe or compiler execution was performed in this audit.
