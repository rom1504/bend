# Independent final-definition selection audit

The indexed reverse scan preserves output order and last-definition wins for valid immutable books. Filtering the original `done` list preserves arbitrary untouched duplicate entries and their order. Internal marker kinds distinguish a missing lookup from an empty-name entry. User names and kinds cannot inject markers into the internal index; direct index operations avoid `BookCache` special lookup behavior. Existing parent tests cover threshold boundaries, reserved names, arbitrary initial entries and a full 32-bit hash collision.

An actual Bend-emitted component exposed a public raw-JavaScript boundary difference. With 256 distinct filler definitions followed by `a\ud800x` and `a\ud800y`, the legacy algorithm compares the names and rejects the invalid Unicode scalar. The indexed algorithm assigns different hashes and never performs that comparison, so it succeeds. The same divergence occurs between one malformed name in the book and another in `done`. A single malformed suffix is **not** a counterexample: hashing projects SCon and extracts Char.to_u32 without validating scalar range. Identical malformed names fail in both variants. Valid non-BMP names, empty names, reserved marker names and BookCache entries match.

This does not describe names produced by a successful source parse, but it prevents claiming unchanged public helper behavior on all raw JS string inputs. The narrow repair is a non-throwing name-validity scan of both book and done before selecting the large fast path; any surrogate codepoint selects the unchanged legacy algorithm on the original inputs. The fallback preserves the legacy demand and failure order, including malformed names that are never compared. The guard adds linear work and should be included in the next measured candidate.

The six-case [actual H audit](evidence/book-final-audit-result.json.gz) and [build identities](evidence/book-final-audit-build.json) retain both success values and exact failures. The [component source](evidence/book-final-audit-component.bend.gz) uses the earlier threshold of 64; the parent is evaluating a threshold of 256. These witnesses use 258 entries and therefore exercise either threshold. No production source was edited by this audit.

Replay with `selfhost/tools/performance/phase4/book-final-audit-prepare.mjs SOURCE_ROOT NEW_OUTPUT`, compile the resulting component through the frozen checked B1 typed-driver in library mode using the frozen runtime, then run `book-final-audit-test.mjs COMPONENT.mjs NEW_REPORT.json`. The preparer copies the original book_without implementation from the supplied kernel source. The audit accepts a component generated from a repaired candidate and records whether each comparison agrees; it deliberately retains divergences instead of aborting before recording them.

The repaired overlay scans names only on the large (256+ entries) branch and falls back on the original inputs whenever either list contains a malformed name. Its newly emitted H component passes **23 exact legacy/fast outcome comparisons and eight name-validity checks**, including both previously divergent witnesses and boundaries 255/256/257. See the [guarded result](evidence/book-final-audit4-result.json.gz) and [guarded build record](evidence/book-final-audit4-build.json). This remains an isolated source overlay awaiting the parent's full checked build and workload measurement.

A separate actual-H component experiment measured the guard cost on synthetic unique names `definition-N` (three alternating repetitions; exact outputs checked outside the clock):

| Entries | Legacy | Unguarded index | Guarded index |
| --- | ---: | ---: | ---: |
| 256 | 48.2 ms | 59.1 ms | 63.2 ms |
| 1024 | 739.0 ms | 194.6 ms | 208.6 ms |

The guard adds linear work. This H component regresses at 256 entries despite the parent's B1 experiment improving there, so the cutoff cannot be chosen from B1 alone. At 1024 entries the guarded component still substantially outperforms legacy. These are helper timings, not compiler throughput; actual Base and parsed compiler-book measurements follow separately. [Full component timing](evidence/book-final-audit4-timing.json).
