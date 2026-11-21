# Bounded unfolding over a known String

The source stager specializes a structurally recursive worker only when a call supplies a literal String, directly or through a nullary literal definition. The matched formal may occur at any position. Its empty case has no recursive call; its cons case has exactly one, with the known tail as that formal’s successor. The full body of every selected case supplies the residual operation, including its other operands and recursive state changes. There is no stored source equation, program name or checksum used by the transformation. The frontend operates on the parsed source subset. It does not run inside the installed Bend compiler.

An application may unfold at most 64 Unicode codepoints and 10,000 expression evaluations. Up to 1,024 intermediate values can be introduced. Calls with an unknown input String stay on their original implementation. Unknown state remains an argument to the generated function at the call site, evaluated once. In the admitted first-order subset, known constructor matches and U32 arithmetic simplify early. Other calls remain as ordered Bend let bindings. A dead computation is removed only for a syntactically total operation or for a nonrecursive chain of such operations. An opaque possibly nonterminating call must remain, even when the chosen branch ignores its value. Every retained binding is annotated with its result type for native source checking.

For the original catalog lexer, each generated line previously traversed 39 template characters. The residual helper has 12 PRNG calls, four identifier calls, three number calls, five operator calls and 27 literal character conses. The dynamic token strings and the original lexer remain. For a default 256-line batch this eliminates 9,984 template steps and 6,912 discarded literal-position salt updates. The three lexer variants differ in their original harness point and expected result. [Exact source sites](fixtures.json).

The separately authored packet header starts with an unknown rolling word and traverses a fixed 18-codepoint header, including a non-ASCII codepoint and adjacent delimiters. Its String is the first formal, as required by this compiler’s structural termination check; recursion is in tail position. A delimiter XORs the rolling word and a payload codepoint multiplies and adds. The same stager emits 32 U32 updates without a packet-specific compiler rule. The packet reference calculation traverses the literal independently in Python. [Original packet](packet.bend) and [residual packet](packet-staged.bend).

The source-only controls exercise the 64-character bound, empty and Unicode strings, dynamic fallback, non-decreasing and repeated tail recursion, lexical shadowing, an unsupported import, and preservation of unused opaque calls. [Source control receipts](source-controls.json).

## Native screen

The frozen parent image is the Phase204 N1 `9cb68bf2…`, linked programs use the same original Phase199 live-plus-scan runtime `1c819e63…`, and the independent C products come from the original catalog evidence. The three default points are `8/0`, `6/17`, and `10/123`. Alternate lexer points use `0/4294967295`, `3/7`, and `4/123`. Packet inputs include the length-zero identity, a Unicode header, a seed at U32 maximum and the default 512-packet point. Each sample validates complete stdout, repetition successes, stderr and exit status. Three rounds rotate all lexer roles; four rounds alternate the two packet roles. The object census records text size, function bodies and relocated calls at the traced owners. [Frozen plan](plan.json), [source smoke](smoke-argv.json), and [timed run](argv-v3.json).

The first native run rejected a residual binding without a type annotation. After adding explicit annotations, the original lexer’s staged product passed the native smoke and alternate oracles. The packet smoke exposed the checked frontend’s structural decrease requirement on the first formal; moving its decreasing String formal first preserved the packet algorithm and oracle. Both earlier attempts are retained. [First refusal](attempt01.json.gz) and [packet termination refusal](attempt02.json.gz).

## Native results

Each ratio uses median per-invocation elapsed time and a freshly built unchanged source in that screen. The independent C reference applies to the three original catalog points.

| Workload | Spine only / original | Full staging / original | Full staging / C |
| --- | ---: | ---: | ---: |
| Lexer 8/0 | 0.78829 | 0.67460 | 1.87055 |
| Lexer 6/17 | 0.77807 | 0.69076 | 1.86957 |
| Lexer 10/123 | 0.78140 | 0.69074 | 1.85243 |
| Packet 512/17 | 0.27561 | 0.14819 | — |

The spine-only source passes all original dynamic arguments, including the initial counter, and retains each of the 39 `salt` and `gen.at` calls. It selects no helper branches. Its native object contains 39 relocated calls to `gen.at` and 27 to `salt`. Inlining or other compiler decisions can discharge a static source call. With full staging both sets of relocated calls disappear, and ordinary lexer text shrinks from 74,796 to 70,832 bytes. The ordinary lexer builds have 249 and 217 functions, respectively. [Full machine census](p205unfold03-summary.json) and [spine-only census](p205unfoldab01-summary.json).

At the fixed three-row catalog repetition counts, full staging measured 1.12716 s, its unchanged lexer measured 1.64445 s, and C measured 0.60461 s. The separate spine-only screen measured 1.27816 s, its unchanged lexer 1.63351 s, and C 0.60768 s. Applying within-session ratios to the historical Phase200 frozen weights projects savings of 0.60155 s for full staging and 0.41835 s for spine unfolding. That projection holds the other 42 workloads fixed. Their current runtimes and the whole-compiler activation rate were not measured here. Three samples per lexer role and four per packet role limit precision on the difference between treatments.

Both guarded runs completed. Every role reproduced its expected complete program output at the catalog point and every alternative. The final independent packet exercises the checker’s accepted decreasing-argument order. The measurement archives include fresh objects’ identities, link inputs, stage and compiler identities, runtime, pilots, complete timed observations, guard and retention receipts. [Full measurements](p205unfold03-receipts.json.gz), [spine-only measurements](p205unfoldab01-receipts.json.gz), and [ablation command](argv-spine.json).
