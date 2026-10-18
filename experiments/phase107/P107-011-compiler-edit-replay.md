# P107-011: extracted compiler-helper edit replay

Status: declined at the requested source-only preflight. No replay harness,
compiler request, build, or timing was performed for this hypothesis.

Hypothesis: exact per-function object reuse could reduce complete iteration cost
for three sequential, independently checkable edits to extracted compiler helper
bodies. The proposed native source04/raw-units comparison would check every source
version normally and compare fresh-cache construction with reuse, retaining full
boundary outputs and expected misses for only the edited function.

The explicit stop condition was absence of three independently editable compiler
helpers in the existing
[compiler_classify.bend](../../selfhost/tools/performance/phase107/cases/compiler_classify.bend)
group. That condition holds:

| Definition | Provenance | Eligible compiler helper |
| --- | --- | --- |
| `f_ascii_ident_code` | Exact body from `selfhost/src/front/lexer.bend:308` | Yes |
| `f_ascii_space_code` | Exact body from `selfhost/src/front/lexer.bend:312` | Yes |
| `flag` | Fixture Bool-to-U32 output adapter | No |
| `bench`, `main` | Fixture invocation/output composition | No |

Both compiler-helper bodies were compared byte-for-byte to the current lexer and
match. Counting an adapter edit as the third compiler edit would change the
requested experiment. Multiple threshold changes within one helper would also
fail the requirement for three independently editable helpers. Nearby lexer
predicates use Char inputs and are outside this already captured scalar fixture.

Read-only provenance pins for the decision:

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| Fixture `cases/compiler_classify.bend` | 606 | `8658162a8b3a8819df3b0840db3610b0959fc24b4a35e891c6f66419500504d1` |
| Compiler `selfhost/src/front/lexer.bend` | 13265 | `aa9d726b6b284deba84dbccc77a01a8143dd89dab70cf487e1ddc8d589380440` |
| Existing checked-capture receipt | 2457 | `92f3fb9ecbc8c8eb06a01a0811fe8ab28e4eea787823a2007f5e0a9cdb97c309` |

The [existing capture receipt](../../selfhost/build/phase107/source-graphs01/compiler_classify/report.json)
binds the exact fixture, producer methods and checked graph. It does not supply
an extracted third helper. No historical fixture, method, source image, or receipt
was changed.

This seed makes no claim of autonomous research acceleration or whole-compiler
edit reuse. Reopening it requires a separately scoped fixture with three admitted
compiler helpers and a frozen extraction/edit/oracle plan before target execution.
