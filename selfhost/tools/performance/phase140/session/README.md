# Early incremental request experiment

This is an experimental, fixed-producer, fixed-Base, process-local compiler
session. The qualified Phase137 compiler and ordinary entry remain available.
No serialized semantic cache or externally supplied successful-check Boolean is
accepted. Compiler decisions are implemented in checked Bend. Host scripts only
package source, supervise processes, authenticate artifacts and transport bytes.

`modules-v01.json` lists the first integrated pure implementation; use
`modules-native-v01.json` (or its checked successor) for the native adapter. The
native composition overrides only `p111_native_args`, preserving its ordinary
six-argument branch exactly. See the individual component READMEs for active
module versions, conservative invalidation and retained failed attempts.

The pipeline retains parser state at a certified source boundary, an actual
checker world before an unchanged prefix, dependency-aware annotation/erasure
and raw owner products, successful body-verifier judgments, optimizer products,
registry plans and typed renderer inputs. Changed or unknown inputs fall back.
The original final verifier remains in place. The session publishes the combined
state only after successful output-file closure. Machine construction and
independent evaluation are separate gates.

The parser hint is an edit offset in UTF16 source units. It is a performance
hint, not evidence of equality. The compiler validates the actual source prefix,
lookahead, ordered declarations, complete checker state and dependencies. A
named owner selects the actual source-event checkpoint inside Bend. Both A and B
use A's logical path; the supervisor separately pins their actual source bytes.

The framed native output contains new chunks or references to ordinals in the
previous successful output. Protocol2 counts exact runtime UTF8 bytes, so
protocol-looking strings in payloads are unambiguous. The strict transport
checks producer/runtime/policy/session identity and pins prior payloads. Only
complete native exit plus complete transport may establish a successful product.

Current small-program integration evidence is described in
[screen-README.md](screen-README.md). The frozen full-compiler edit suite is
created by `../edits/freeze-v01.py`. Those three policy edits are late definitions:
results must not be generalized to early edits, added binders, changed headers,
literal relocation or arbitrary project/module changes.

Report original fresh B, same-candidate cold B, warm B and acquisition separately.
Do not compare warm B with an unrelated A revision. Exact complete QBE plus fixed
machine construction permits reuse of generated-program evidence; changed
products need independent checks. This experiment is not a compiler-correctness
proof, a persistent incremental build service or native self-hosting qualification.
