# Corrected Phase121 diagnostic sources

Version one remains unchanged in `../diagnostic/`. Its first compiler emission
rejected a live use of an unfilled law: helpers had been inserted after `bench`.
This version inserts completed helper definitions before `bench`, preserving the
same single-expression substitution and byte-identical Phase93 wrapper suffix.
It uses the original helper files and pins both the parent and rejected version.
No compiler or native executable was run while preparing these sources.

The six measurement variants and their semantic limits are described in
`../diagnostic/README.md`. `manifest.json` records all exact file identities.

Two additional standalone programs retain complete values for finite independent
checks:

- `list-controls.bend`: counts 0, 1, 2, 17 and 257, crossed with seeds 0, 1 and
  4294967295. Each case prints count, seed, original result, map/fold result and
  fully fused result. Its independent expected stdout has 75 lines.
- `map-controls.bend`: sizes 0, 1, 2, 17 and 129, crossed with the same seeds.
  Each prints size, seed, original result and tree-fold result. Its independent
  expected stdout has 60 lines.

`prepare.py` calculates expected outputs using an imperative arithmetic model
for lists and an ordinary Python dictionary for Maps. The Map model sorts keys
lexicographically: Base's `Map.bit` uses a presence bit followed by 32 MSB-first
character bits, and `Map.to_list` lists the lo subtree before the hi subtree.
The models first reproduce the unchanged frozen expectations for list128/512 and
map32/128. Model execution is preparation of independent expected data, not a
compiler run or performance result. The exact generated stdout must still be
checked by the root's ordinary guarded compiler/native workflow.

The controls preserve all result values rather than aggregating comparisons into
a single Boolean or checksum. They cover empty structures, branch boundaries,
larger recursion and overflowing seed arithmetic; they are finite tests, not a
proof of arbitrary source fusion.
