# Call fragments within the existing QBE stream

The renderer now accumulates fragments for calls, memory accesses, sets, binary operations and offsets until the existing whole-function flatten. Three existing definitions were replaced; no alternate production emitter or new declaration was added. Names, specialized selection, QBE policy, runtime ABI and the number of writes remain unchanged. Component timing and 18 complete selected-function comparisons passed; the full-compiler QBE gate remains separate.

The maintained output path already streams one complete function at a time through `p134e_next` and `p134w_plan`. The compatibility collector is not on the ordinary native request path. `p144e_body_tail` already flattens chunks directly into the footer; repeating the earlier body/footer fusion would add nothing.

The remaining boundary is in [p111q_args](../../selfhost/src/back/qbe/emit.bend) and the `N111Call` arm of [p112a_original_stmt](../../selfhost/src/back/qbe/tail-workers.bend): argument chunks become one argument string, then one call-line string, then part of the final function string. [render-call.bend](../../selfhost/tests/phase147/render-call.bend) instead stores prefix, argument fragments and suffix in the same reversed chunk list. Counter, terminal flag and error remain unchanged.

The source audit inspected every maintained file referencing `P111QCode`. No consumer interprets one chunk as one line, indexes a chunk, or counts chunks. Consumers prepend, carry or discard the list; `p111q_body_text`, `p144e_body_tail` and the control-only `p126i_control_text` flatten it with `nt_text_finish`. Existing chunks already contain multiple lines and empty strings. The exact source pins and census are in [rendering-opportunity.json](rendering-opportunity.json).

The retained complete compiler QBE is 117,232,528 bytes, SHA-256 `dceae94a7659ad1ff58395ed34914971422ff9e5841668e910cd95e6b0914010`.

| Static census | Count / size | Interpretation |
|---|---:|---|
| Functions | 71,854 / 111,995,641 bytes | Most output belongs to function bodies |
| Call lines | 243,175 / 19,957,715 bytes | 17.0% of output; includes other emitter paths |
| Data declarations | 702 / 5,178,878 bytes | 4.42% of output |
| Static image | 47,757 words / 688,421 bytes | 0.587% of output |
| Largest data declaration | `p111_segments`, 3,467,773 bytes | 55,111 relocations |

These byte shares do not measure execution time. Delaying `p112s_image_items` could reduce a transient list, but the static image is a small part of output and this does not establish a useful time saving. Current `File.write` converts the complete String to a host UTF-8 buffer once. `File.write_bytes` still consumes a linked byte list; it is not a packed-buffer shortcut. Splitting writes by fragment would add IO overhead and is excluded.

The first checked experiment passed 10 independent controls and complete-text comparisons on three retained complete Lexer segments. Controls cover empty and mixed-width arguments, symbols, missing-ID markers, prior chunks, Unicode, maximum counter/error/terminal state, complete return, fallthrough and statements after termination. The fixture segments contain 3, 3 and 4 calls and no branches. Their original captured statement trees are retained; only the ID map is reduced to exactly the referenced bindings. Both arms use the original scalar renderer, so this is not yet a comparison of the complete selected emitter. The earlier capture is explicitly historical; a broader transfer should use current Phase147 captures.

Root-owned first-kernel build commands are retained in `selfhost/build/phase147/render-native-plan03/jobs.json`. The first two unexecuted plans preserve source-review failures in the new IO harness: `U32.read` needed explicit `Maybe` matching, and `File` needed linear transfer through a direct match. The corrected workload changes only the Boolean selected by `main` between arms. It creates a fresh complete function string inside each iteration and consumes it with one `File.write`. Five superseded harness files now reside in the exact [method capsule](../../implementation/phase147/evidence/method-history/README.md); original build sources and reports remain unchanged.

The paired runner compares full native stdout byte-for-byte with the checked hosted baseline, including the complete-text SHA-256, before and after timing. Timed writes go to `/dev/null`; cost includes rendering, String-to-host conversion, write completion and process setup. Counts are calibrated to at least 150 ms, followed by six alternating pairs per fixture. Calibration is retained separately; each observation starts a fresh process with filesystem caches warmed by prior calibration. All 12 complete-text checks passed in each comparison block.

The first call-only kernel's median candidate/baseline ratios were **0.904, 0.852 and 0.848** on the three historical Lexer bodies. The generalized kernel then used three complete current captures, with exactly the same fixture and IO bodies across original, call-only and general modes:

| Current complete body | Statements / calls | General / original | General / call-only |
|---|---:|---:|---:|
| Map `$p111.k.45469` | 21 / 9 | 0.634 | 0.770 |
| Lexer `$p111.k.30318` | 10 / 3 | 0.689 | 0.761 |
| Compiler `p111_empty` | 4 / 1 | 0.870 | 0.952 |

Each column comes from its own six-pair comparison, not a quotient of unrelated medians. These are renderer/write kernels. In particular, the small `p111_empty` body supplies current compiler input coverage, not a representative whole-compiler cost. No multiplication of these ratios with sampled stage shares is claimed. Exact report identities are recorded in [rendering-opportunity.json](rendering-opportunity.json).

The historical Phase144 final03 diagnostic attributed 49.962 seconds to render/output, with 17.651 seconds in registry work. Registry work also includes worker discovery and continuation fusion. Those historical times are not current clean timings or fully removable string costs.

## Current profile and bounded next design

The fresh `profile-full02-analysis/report.md` attributes **47.469 thread-CPU seconds (19.0% of staged CPU)** to render/output and teardown through the exit milestone, with 1,481 samples. Active lowered owners include `String.append` 242 samples (16.3%), `p144e_body_tail` 144 (9.7%), and `p111q_memory` 135 (9.1%). Physical leaves include `p125_rt_take2` 239, `p118_rt_extend1` 122, and `p118_destination_fill` 80. Owner and physical views overlap; these are diagnostic samples, not removable-time estimates or clean performance ratios.

The successful bounded extension uses memory-line fragments and the remaining simple scalar lines. These reuse the existing reversed chunk list; they introduce no IR type, runtime helper, per-fragment write, name change or optimizer rule.

| Existing producer | Bounded fragment replacement | Exact behavior to retain |
|---|---|---|
| `p111q_memory`, nonzero offset | Address destination, ` =l add `, base, separator, decimal offset, newline | Emit the address line before the access; use the existing temporary number and increment it exactly once |
| `p111q_memory`, store | `store`, type, space, value, separator, address, newline | Zero offset uses the original base directly; retain terminal/error and type spelling |
| `p111q_memory`, load | Destination, existing load spelling, address, newline | U32 stays ` =l loaduw `; other types keep the repeated original type spelling; do not evaluate the unused store value |
| `N111Set` / `N111Offset` | Existing local/value formatter results separated by fixed literals | No counter or state change |
| `N111Bin` | Local, result width, opcode, operands and punctuation | Comparison result remains `w`; unsupported opcode marker remains exact |

Use direct `Con` construction in reverse emission order, not a second list traversal or list append. Keep small formatter outputs as strings initially; splitting every character or adding a generic rope layer could replace copy cost with more allocation. The current call prototype deliberately leaves the argument type/value fragment concatenation intact.

The 18 added controls passed, covering load/store with zero/nonzero/max offset, U32/U64/pointer type, all value forms, maximum counter wrapping, prior fragments, prior error and terminal state. They compare flattened full text plus counter/terminal/error, never raw chunk shape; the original 10 call controls also passed.

Canonical integration replaces only `p111q_args`, `p111q_memory` and `p112a_original_stmt`. The sole nonrecursive `p111q_args` caller now consumes its reversed fragment list directly. `p112a_words`, `p111q_stmt`, specialized dispatch and branch/return/alloca behavior are retained. The exact before/after receipt is `selfhost/build/phase147/render-integration01/report.json`.

The integration gate checked independent narrow APIs from original source `00940ed5…` and combined source `15e24090…`, exposing the actual production `p111q_segment`. All **18 complete selected-function outputs matched exactly** using full original function/constructor ID tables, including a Map body with 2,037 statements / 76 branches and a compiler body with 284 / 15. Input trees and ID maps stayed unchanged. This closes the earlier straight-line experiment's nested-dispatch gap. The gate is `render-selected01/controls/report.json`; full compiler output equality and compiler timing are still required before a whole-compiler claim.
