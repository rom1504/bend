# Phase51 source accounting

The maintained Bend source graph adds two proof-comment lines. Code-line,
definition, law, type and module counts are unchanged. The JavaScript runtime
adds one IO helper and one private capability identity: six physical lines,
304 bytes including explanatory comments. The generated runtime bundle contains
the same six-line increase; it is not an independent implementation.

| Metric | RNFA04 | Phase51 |
| --- | ---: | ---: |
| Physical Bend lines | 23,660 | 23,662 |
| Nonblank/non-comment Bend lines | 19,489 | 19,489 |
| Definitions | 2,673 | 2,673 |
| Laws | 629 | 629 |
| Types | 87 | 87 |
| Manifest-listed Bend modules | 92 | 92 |
| Bend source bytes | 1,047,729 | 1,047,916 |
| Runtime core lines | 377 | 383 |
| Runtime bundle bytes | 57,196 | 57,500 |
| Checked API bytes | 1,628,716 | 1,628,734 |

Counts reuse the frozen Phase47 counting function and each checked attempt's
manifest-listed modules. Code lines exclude blank lines and lines beginning
with `#` after whitespace. Runtime, tests, experiment tooling and generated API
are counted separately. These measures do not quantify semantic complexity.

The new proof obligation is local: preserve an interval containing only inert
scalar checks between fresh String validation and `localGuard`. The discarded
four-helper and exact-call split variants add no maintained concepts. All 24
benchmark libraries change their runtime prefix; 13 also change contextual-entry
arguments at 28 sites. All other generated body bytes are identical to RNFA04.

This phase measures generated-program speed. It does not establish a change in
compiler throughput; the historical Phase48 compiler-request measurements remain
historical. The one checked build took 53.48s including its focused gate, which
is a development-loop observation rather than a paired compiler benchmark.
