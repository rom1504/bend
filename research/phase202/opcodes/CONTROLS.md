# Independent decoder gate and mixed-case micro-screen

`oracle.py` defines98 accepted spellings using manually authored opcode-family
rules and ISA condition numbers. It does not extract tuples or decisions from
prepare.py or the Bend decoder. The preparation step separately requires exact
set equality between this oracle and all source spelling tests. It never calls
the candidate to compute expected outputs.

The frozen fixture02 contains794 inputs: every accepted spelling, every proper
prefix (which may itself be accepted), longer suffix, uppercase, spaces, NUL,
Unicode head/suffix,129-character invalid input, and explicit unsupported aliases.
`sqrtss` and `cvttss2siq` intentionally reject here: the outer encoder handles
them before calling this decoder. cmov aliases absent from the original table
must remain absent. Empty and embedded-NUL strings are actual constructor data.

Each decoded result is independently checked against all five expected fields
on every visit. Unknown maps to the explicit all-zero sentinel; no supported
row uses family0. A nonzero mismatch count fails the screen even if rolling
checksums collide. Both whole programs must output exactly:

```
0
3019561797
```

The benchmark performs32 traversals of the deterministic mixed list,25,408
decodes/role. This is not a production-frequency workload. Four balanced paired
fresh-process runs include list construction, field checks, checksum, printing
and startup; acquisition timings are separate. Samples below100ms are flagged,
not silently extrapolated. Actual image checking, generated hardware and outputs
remain untested until root runs the guarded command.

Ready fixture: `selfhost/build/phase202/opcodefixture02/report.json`, generated
from source02 SHAa68ba12c823fff623c58f31154ddca5de8d80cce9a207f3f14b04e95c20836d0.
fixture01 was superseded offline for IO syntax and a smaller exact four-declaration
slice; no target used it. No maintained source or prepare.py was edited.

Root-owned guarded command (substitute chosen exact image and receipt):

```
python3 -B research/phase202/opcodes/screen.py \
  --fixture selfhost/build/phase202/opcodefixture02 \
  --image IMAGE/program --image-receipt IMAGE/report.json --out FRESH
```

For a different repetition count, prepare a fresh fixture with standalone.py
`--source SOURCE --out FRESH_FIXTURE --rounds N`; the independent oracle computes
the exact expected checksum. The screen fails immediately on either build,
checking, output or oracle failure and preserves its partial report. Native
builds each have a25s internal bound; root should wrap the complete job in the
ordinary shared CPU3/resource guard. This only screens decoding; full ELF/object
identity remains the promotion gate for any compiler change.

Fixture02's first native build stopped at parsing in0.453s: a computed match
scrutinee is forbidden by this Bend syntax. No decoder control or timing ran.
Fixture03 is the replacement: three computed matches now pass their result to a
separate helper with a parameter scrutinee. Case set, oracle, repetitions and
expected output are unchanged. Use `--fixture selfhost/build/phase202/opcodefixture03`.
The concrete failed diagnostic remains in
`selfhost/build/phase201/p202opcode01/old/compiler.stderr`.

Fixture04 supersedes03 after the decoder generator independently fixed its own
computed Char.to_u32 match. The new x202o_dispatch helper is explicitly retained;
the candidate slice has5 declarations, the old slice4. Its receipt now pins all
four preparation/screen methods. Use `--fixture selfhost/build/phase202/opcodefixture04`.
The latest generator SHA256 is
d405318e8a0d3d1dff792abd49c014f34175ce542fd44f3178d8323dfa27a04e.

[Checked Bend decoder](decoder.bend) contains the exact replacement declarations from the integrated source. Its focused native test took 0.1973× the original median paired time on the mixed corpus. All four candidate observations were below 100 ms. The whole-build comparison is reported separately.
