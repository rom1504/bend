# Phase150 parser acquisition profile

The original lexer candidate adds **21.972s diagnostic wall / 22.013s process CPU** while compiling the same two parser sources. Seven stages account for **21.430s (97.5%)** of that wall increase. The cost is concentrated in frontend and intermediate-term processing; this supports the prepared first-character-factoring experiment before promotion.

The ordinary acquisition penalty reproduced with reversed order: **+20.159s** in native01 and **+20.660s** in native02. Those build totals overlap emission and QBE machine construction. This diagnostic pair measures compiler emission alone, so it localizes the penalty without estimating instrumentation overhead or isolated QBE cost. See the [capture](../../selfhost/build/phase150/parser-acquisition-profile01/capture/report.json), [reference stages](../../selfhost/build/phase150/parser-acquisition-profile01/reference-stages.json), [candidate stages](../../selfhost/build/phase150/parser-acquisition-profile01/candidate-stages.json), and [pinned results](parser-acquisition-profile-results.json).

| Stage | Reference wall s | Candidate wall s | Δ wall s | Δ process CPU s | Samples ref/cand |
| --- | ---: | ---: | ---: | ---: | ---: |
| parse/load | 3.321 | 8.244 | +4.923 | +4.923 | 101/256 |
| checking/publication | 1.709 | 6.349 | +4.640 | +4.640 | 52/196 |
| annotation/reach | 0.689 | 4.270 | +3.581 | +3.581 | 19/132 |
| layout check | 0.356 | 1.614 | +1.258 | +1.258 | 9/48 |
| erasure/finalization | 0.716 | 3.586 | +2.870 | +2.870 | 21/110 |
| static preparation | 0.695 | 1.721 | +1.026 | +1.026 | 20/52 |
| raw generic/private lowering | 6.618 | 9.750 | +3.132 | +3.132 | 205/302 |
| Initial optimizer | 7.780 | 7.554 | −0.226 | −0.226 | 241/234 |
| First independent verifier | 3.221 | 3.062 | −0.159 | −0.159 | 99/94 |
| Registry preparation | 3.295 | 3.395 | +0.100 | +0.100 | 101/104 |
| Render/output through observer exit | 8.653 | 8.744 | +0.091 | +0.132 | 257/261 |

Complete compiler processes take 42.775→64.747s wall and 42.707→64.720s CPU. Peak RSS rises 225,836→367,656KiB. The required nonoverlapping stage deltas sum to 21.958s wall; startup/exit outside the markers explains the small difference from process wall. The optional nested verification interval is excluded.

Both exact whole-SSA oracles and empty stderr pass. Whole captures contain 1,324/2,011 samples, zero loss/overruns, intact handlers, complete thread lifecycle and 99.31%/99.53% sampled-thread CPU coverage. **Every individual stage has fewer than 500 samples and `quantitativeProfileAdmitted=false`.** Valid stage attribution and diagnostic clocks do not authorize precise owner percentages. One 32ms pair also supplies no aliasing control or confidence interval.

The candidate parse/load observations show `f_pattern_sub` (27), `f_pattern_subs` (15), context materialization, freshening and error scans. Checking and annotation show `lookup` (25/20) and `subst_node` (14/12); erasure shows `lookup` (22), `nc_erase` (14), and `norm_max_book` (10). Lowering shows `nc_uses_term` (27), `p112m_fresh_terms` (11), and layout substitution. These are descriptive sample counts. Physical leaves repeatedly include `term_drop`, `span_fade`, constructor/argument transport and borrowed string comparisons, consistent with repeated tree traversal and ownership work. Active owners do not recover a logical call stack.

The frozen compiler provides a concrete mechanism to test:

- [Character decoding](../../selfhost/build/phase147/integrated-source03/compiler.bend#L13630) builds `Chr` containing a U32 literal. [Pattern processing](../../selfhost/build/phase147/integrated-source03/compiler.bend#L11477) expands literals; [word expansion](../../selfhost/build/phase147/integrated-source03/compiler.bend#L5998) builds 32 `WCon` bit constructors.
- [Match flattening](../../selfhost/build/phase147/integrated-source03/compiler.bend#L13003) recursively constructs hit/miss trees. [Row rewriting](../../selfhost/build/phase147/integrated-source03/compiler.bend#L13172) invokes [recursive pattern substitution](../../selfhost/build/phase147/integrated-source03/compiler.bend#L13225).
- The resulting terms undergo [context materialization](../../selfhost/build/phase147/integrated-source03/compiler.bend#L13880), [freshening](../../selfhost/build/phase147/integrated-source03/compiler.bend#L14008), [error scanning](../../selfhost/build/phase147/integrated-source03/compiler.bend#L14793), checking/normalization/erasure, and [lowering use scans](../../selfhost/build/phase147/integrated-source03/compiler.bend#L31706).

This supports amplified intermediate-tree work despite source growth of only 2.67% and final QBE growth of 0.69%. It does **not** prove that the two flat matrices alone cause the penalty: no per-input-definition timing or intermediate-node count was collected.

The first falsifier now supplies partial support: the [grouped lexer](../../selfhost/build/phase150/variants01/grouped.bend), changing only `p150l_other` and `p150l_symbol`, takes **24.186s** to acquire versus **30.766s** for the original probe, a 6.580s reduction (21.4%; one acquisition each). See the [original report](../../selfhost/build/phase150/lexer-native01/report.json) and [grouped report](../../selfhost/build/phase150/lexer-grouped-native01/report.json). The coordinator reports 15 complete graph JSON oracles pass; native controls were still in progress at this update. This is a small-probe result, not a grouped complete-parser result. Equal generated SSA is not expected across changed source.

The broader scalar character-test variant strengthens this result: keeping direct String unpacking and fused metadata while replacing literal Char-pattern dispatch takes **8.599s** to acquire, versus 30.766s original and 24.186s grouped (72.0% / 64.4% less; one build per proxy variant). See the [scalar acquisition](../../selfhost/build/phase150/lexer-scalar-native01/report.json). It passes 315 exact token-pair controls, 10 independent lexical oracles, exact equality of all 850,068 compiler tokens, Base/Hashmap token transfers, and 15 complete graph fixture comparisons. Paired lexer times average **4.2375→0.957s**, a 4.43× speedup. These results support avoiding expanded literal-pattern trees, without assigning a measured cost to each internal pass of the scalar variant.

The completed scalar parser observation removes the original acquisition tradeoff: **45.591s** versus reference mean **46.525s**, with original literal-pattern mean **66.934s**. Only one scalar acquisition was run, so the small difference below reference is not a claimed build speedup. Complete-source parse times are reference 30.680/30.390s versus scalar 27.145/28.049s: **9.62% less parsing**, with mean process time **31.4973→28.5524s** (9.35% less). All parser result hashes agree; checksum agreement remains separate from the exact token and graph-fixture evidence. See the [scalar build](../../selfhost/build/phase150/parser-scalar-native01/report.json) and [paired requests](../../selfhost/build/phase150/parser-scalar-timing01.json).

The phase outcome is a **validated scalar C3 candidate**, retained without whole-compiler promotion. The complete-parse 2× gate is not met. No whole-compiler speed measurement or broad compiler qualification follows. The [maintained-source census](literal-pattern-audit.md) identifies 17 ordinary fixed-result U32 functions with 77 numeric-leading cases after excluding control/proof helpers; those are possible follow-ups, not measured hot costs. Start with a small nondependent table such as `p88_roles`, preserving exact outputs and measuring acquisition plus resulting runtime before extending the frontend.

A general frontend opportunity is to retain compact literal patterns longer, but this remains a hypothesis. Dependent matches need the same constructor refinement, branch substitutions, coverage, first-match priority and typing refusals; scalar tests are not universally interchangeable with constructor evidence. Affine quantities, ownership, fresh IDs, spans and error precedence must also survive. Any future compact representation needs explicit eligibility and independent semantic/proof-interface validation. The present evidence attributes no penalty to QBE construction and supports no weakening of verification. No new target runs or production edits were performed for this analysis.

The preferred module is now [lexer-candidate.bend](../../selfhost/tests/phase150/lexer-candidate.bend), scalar SHA256 `c5b1e71ff4f0d42c69b8c764fb83c42fa755b3f9a38d9d3611f3fff92981ed85`. [Exact variant snapshots](../../selfhost/build/phase150/variants01/selection.json) preserve literal, grouped and scalar bytes; the original literal version also remains at Git `6e88473`. Historical assembled-source paths remain valid. Production source is unchanged.
