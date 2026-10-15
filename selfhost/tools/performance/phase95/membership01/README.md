# Exact membership short-circuit experiment

Hypothesis: native `nb_contains` eagerly evaluates both Boolean OR arguments,
so a head hit still scans the entire list. Existing `has_name` selects on the
comparison result before recurring. Reuse it by changing only the body of
`nb_contains`; retain signatures, equality, name order and all callers.

`prepare.py --out FRESH_DIRECTORY` authenticates D04, extracts its five exact
membership/equality definitions, instantiates identical baseline/candidate
harnesses, and writes source hashes plus two unapplied one-definition patches.
It runs no compiler, executable, or benchmark. Canonical patch uses the existing
canonical `has_name`/`String.eq`; D04 uses its existing consuming comparator.

Micro arguments are `reps size mode`. Modes 0/1/2/3 select head/middle/miss/tail.
Rows contain descending dynamic `module:worker~N` strings, generated outside the
clock. Start with sizes 8, 128, 1024 and modes 0, 1, 2. Both roles receive the same
size and mode. Calibrate repetitions independently per role, normalize elapsed
time per repetition, and compare a doubled repetition control before interpreting
very large early-hit ratios. No extra sink or unrelated traversal is timed.

Exactly three stdout lines: untimed checksum (97 for hit, 53 for miss), timed
accumulated checksum modulo 2^32, elapsed milliseconds. Thus expected line 2 is
`(reps * line1) % 4294967296`. As in Phase94, the timed interval includes printing
the accumulated checksum. Runtime arguments and consumed U32 output prevent a
literal fixed-result benchmark. The same list/key are shared across iterations;
their final release is included once. The candidate still pays that final list
release, even when its membership scan stops at the first element.

`controls.bend` has independent literal expectations for empty lists/strings,
head/middle/tail/miss, duplicates, prefixes, Unicode and non-normalization. Its
shared list is queried repeatedly and finally consumed into an exact printable
sequence. Compare full stdout to `controls.expected.txt`. These finite controls
do not establish arbitrary-input equivalence. No targets have been run by this
preparation task; root owns acquisition, execution and reporting.

The intended universal law is simple: for every finite list and key, the eager
recursive OR fold equals the short-circuit scan. A generic safe version can use
the Phase94 closed predicate template plus explicit state, with an eager fold
as frozen reference and a constructor/Bool proof by list induction. There is no
need to prove string equality itself if both sides call the identical predicate.
The canonical `has_name` pair has a forward call and mutual recursion
(`has_name` -> `has_name_next` -> `has_name`), which is outside the safe structural
recursive pattern. Its body uses no obviously unsafe data operation, but that
does not prove the annotation removable. The safe variant must either restructure
the recursion around a structural helper or use the language's accepted local
continuation pattern; do not claim the current `@unsafe` pair kernel verified.
Defer that proof work until attribution and measurements justify this change.
