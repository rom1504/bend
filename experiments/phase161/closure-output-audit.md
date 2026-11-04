# Phase161 closure QBE difference audit

The output difference is **not restricted to diagnostic text or source
positions**. Constructor identities, local names, specialization names and
dispatcher references change. The bounded comparison strongly supports mostly
identity renumbering with nearly all executable structure retained, but it does
not establish semantic equivalence or qualify a replacement compiler image.

The fixed compiler emitted these two products:

| Input scope | QBE bytes | SHA256 |
|---|---:|---|
|Full maintained compiler, Phase152 N3 oracle|118,227,421|`1032c6a6495ca86bb26ad2bcd7ae639ed49dc987765dfe567dce7ac6224bf7bb`|
|Checked closure, Phase161 `closure01/child/program.ssa`|118,188,267|`c1a93beb26acb1de6a69c4f84f0cf57b8bd7fc7f54d4730ba1e277a6b9532dea`|

The closure is 39,154 bytes smaller, about 0.0331%. The audit streamed both
files, hashed top-level function/data blocks and inspected differing blocks
individually. It did not use whole-file difflib, execute either product, or
invoke a compiler/build tool. Reproduction and all computed counts are in
[the offline tool](tools/qbe-block-audit.py) and
[the 31 KB report](closure-output-audit.json).

## Executable structure and identities

- Both products contain **73,926 functions**. Of 73,925 common symbols,
  **64,005 complete blocks are byte-identical** and 9,920 differ.
- Of the differing common blocks, 2,780 match after replacing numeric
  immediates by placeholders. With consistent alpha-renaming of local variables
  and block labels as well, **9,915 of 9,920** match. This retains instruction
  spelling/order and global symbol references, while intentionally discarding
  local spelling and numerical values. It is a structural diagnostic, not a
  valid equivalence transformation: numerical values include ordinary values,
  constructor IDs, dispatcher IDs and packed runtime constants.
- The five remaining common-symbol differences are all in the
  `p134v_list~7` through `p134v_list~11` specialization family: public wrappers
  `~7`/`~11`, and private `p114r` workers `~8`/`~9`/`~10`. Four have different
  line counts. One private symbol is removed (`p114r_$direct.p134v_list~11`)
  and one is added (`p114r_$direct.p134v_list~7`). Same-spelling comparison
  therefore cannot identify every specialization's semantic counterpart.
- The dispatcher still has **56,649 entries**. Ten positions change names:
  factory/direct pairs for five `p134v_list` specializations. Its arity, flags
  and result-width tables are byte-identical. This is an identity-graph change
  even though it is consistent with reassigning specialization names.

Concrete examples distinguish the classes. `descend` uses local
`%v_v_9435` versus `%v_v_8391` with the same constant and instructions. A
`descend_field` constructor call changes CID174 to CID172. The factory
`p134v_list~10` changes its closure target from FID46086 to FID35348.
The public `p134v_list~11` changes from a 557-byte private-worker adapter to a
3,502-byte scheduled body, while `~7` changes in the opposite direction.
Those last examples require matching specialization meaning and references,
not ignoring textual differences.

## Data changes

There are 715 versus 606 data blocks. The 109 removed blocks are constructor
name records; no data block is added. Among common data blocks, 436 differ:
430 surviving constructor-name positions plus these six tables:

`p111_cid_names`, `p111_cid_arity`, `p111_cid_hot`, `p111_segments`,
`p111_static_image`, and `p111_program`.

The constructor catalogue shrinks **695 → 586**, with no new constructor names.
All 586 surviving names have exactly the same arity and hot flag when compared
by name; **430 receive different numeric CIDs**. Removed names include
`FProvenance`, `FPSourceSet` and multiple `JD*` records; the full list is retained
in JSON. These are metadata for actual runtime representation, not just debug
strings: the emitted calls and tag tests contain the corresponding identities.

The program descriptor changes only its constructor count, 695 → 586. Segment
count56,649, main FID56,643, register width26, result width1, static-image
word count47,762, capability field and eight effects remain the same. Effect
names, show tables, FID tables and all other common data blocks are byte-exact.
The static image itself differs; this audit has not proved that every packed
word is exactly the corresponding CID relocation under the name mapping.

## What the experiment can support

The source closure does not remove a substantial body of emitted functions:
the function and dispatcher counts are unchanged, and nearly all common bodies
retain their instruction structure under the diagnostic renamings above.
This is useful evidence for separating source/front-end inventory cost from
the backend's nearly unchanged emitted-work inventory. It is not a timing
attribution, nor does equal function count imply equal compiler work.

Do not describe the closure product as byte-equivalent, diagnostics-only
different, or a qualified equivalent executable. Establishing the stronger
claim would require a consistent constructor/FID/specialization mapping through
all code and static data, or independent generated-program execution and
ordinary qualification appropriate to the intended claim. Neither was requested
or performed here. Source checking remains a distinct gate.

Reproduce the bounded offline audit from the repository root:

```sh
python3 -B experiments/phase161/tools/qbe-block-audit.py \
  --full selfhost/build/phase152/native-n3/program.ssa \
  --closure selfhost/build/phase161/closure01/child/program.ssa \
  --out /tmp/phase161-closure-output-audit.json
```

The tool pins both complete inputs and its own source, rejects duplicate symbols
and constructor names, bounds individual lines/blocks to32 MiB, and rehashes each
block it rereads. It retains compact summaries and the five remaining structural
cases rather than storing either complete QBE file. Its parser accepts this
emitter's top-level block format; it is not a general QBE parser or verifier.
