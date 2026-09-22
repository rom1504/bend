# Constructor and datatype rejection reasons

The isolated P5-007 candidate preserves every captured authoritative checker
string and matches pinned TypeScript exactly on all 16 focused cases: twelve
rejections and four positive controls. Six local diagnostic differences resolve.
On six selected upstream cases, two exact diagnostics resolve and four remain.
Acceptance, phase and checked flags are unchanged; no timing claim is made.

The three shared changes distinguish an undeclared constructor during inference,
add the datatype `<>` hint to constructor-shaped terms naming an actual datatype,
and distinguish an unknown datatype from an existing family with the wrong
parameter count. `infer_adt` delegates only its existing failure metadata to a
diagnostic helper, retaining the original error code and success path.

| Upstream case | Result |
| --- | --- |
| `check/ctr_of_datatype.bend` | Exact diagnostic now matches, including the datatype hint and source location. |
| `io/channel_send_recv.bend` | Exact message-only unknown-datatype diagnostic now matches. |
| `check/nat_literal_import.bend` | Correct constructor reason; independent missing location remains. |
| `check/tuple_import_required.bend` | Correct constructor reason; independent missing location remains. |
| `import/list_sugar.bend` | Correct constructor reason; independent missing location remains. |
| `check/forward_data_table.bend` | Unchanged: constructor-field declaration replay loses structured detail earlier. Deferred. |

The control set includes known constructor inference, wrong goals and field
counts, declared-family arity, absent/filled/unfilled family names, competing
earlier errors, and accepted neighbors. The audit compares raw text without
normalization. A separate probe wraps only the normal host's authoritative
checker exports and captures their returned strings; all sixteen before/after
strings agree exactly. It does not implement a second checker.

The baseline is the first integrated Phase 5 checked API `a17d909d…`, not an old
Phase 4 API. Both source snapshots use the genuine maintained bootstrap.
The initial fixture attempt used invalid empty `<>` syntax in four cases.
Both compilers rejected those fixtures during parsing; that attempt and its
exact source are preserved. Corrected fixtures use nonempty unknown-family
arguments and a bare zero-parameter family. No compiler conclusion relies on
the invalid attempt.

Independent static review by lexer_analysis found no blocker in the narrow
reason-only patch. The reviewer confirmed that declared-family arity details
remain unchanged and the additional family lookup is rejection-only; no extra
reviewer test run is claimed.

Evidence: [verified archive](constructor-diagnostics-evidence/README.md), including
the exact patch, checked candidate, both paired reports, authoritative strings,
the failed fixture-author attempt, and `audit.json`. Promotion/integrated broad
counts are recorded separately by the root report; the focused evidence alone
does not claim whole-language conformance or a full self-reproduction gate.
