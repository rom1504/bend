# Actual 10,000-round machine shapes

Offline inspection of the exact three `lookup-products02` binaries is recorded
in `code-shapes.json`, produced by `code-shapes.py` using `nm -S` and targeted
`objdump --disassemble=SYMBOL`. No compiler or target executed. Four clean runs
reported by the root give QBE 0.54148s, mature C 0.35772s and Bendc C 0.15649s:
3.46× and 2.29× Bendc respectively, and QBE 1.51× mature C. These are this
complete tiny-book lookup/consumer fixture, not whole-compiler ratios.

| Actual machine body | QBE bytes / instructions | Mature C bytes / instructions | Bendc C bytes / instructions |
| --- | ---: | ---: | ---: |
| Ordinary lookup | 760 / 206 | 1,376 / 340 | 730 / 161 |
| Ordinary index_find | 1,628 / 409 | 4,221 / 968 | 1,223 / 261 |
| Equality reader | 902 / 220 borrowed reader | 2,263 / 572 scheduled entry; equality also inline in owning wrapper | 172 / 52 |
| Hash reader | 274 / 71 borrowed reader | 674 / 165 scheduled entry | 66 / 20 |
| Full-result p163r_scan | 10,154 / 2,271 | 21,356 / 4,660 | 14,919 / 3,447 |

The split QBE borrowed reader does not include its guard/owned fallback; the
table does not add incomparable function sizes into a total execution cost.
QBE equality/hash are already loops without scheduled transitions internally.
Their borrowed readers have 2,088/2,048-byte explicit stack subtractions and
representation/RFC checks, plus cold fallback calls; Bendc's readers have no
stack subtraction and only a failure call site. No allocation is removed by
simply declaring those QBE readers to be native again.

The largest concrete contrast is around the shared full-result consumer. QBE's
`p163r_scan` contains 91 constructor-helper call sites (44 ctor1 + 47 ctor2),
19 take/destructure call sites, and 15 separate scalar-mix calls. It subtracts
2,632 stack bytes. Those are real out-of-line runtime boundaries in the machine
body. Mature C inlines allocation fast paths but retains ownership machinery:
its scanner has 73 heap-allocation-miss, 68 RFC-wrap, 36 heap-hand, 18 span-fade
and two term-drop call sites; frame subtraction is 120 bytes. Bendc's scanner
inlines its small allocation fast paths, with 71 GC-refill slow-path call sites
and one failure site, and subtracts 72 bytes. Static sites are not dynamic calls:
for example a refill is not executed for every allocation.

Lookup itself also preserves different lifetime costs. QBE's 760-byte worker
calls keep four times and sink eleven times at distinct static sites, alongside
two take2 sites and its direct query calls. Mature C's lookup has six term-drop
sites and three RFC-wrap slow-path sites. Bendc uses tracing GC and has neither
of those explicit ownership operations in its lookup worker. These observations
are consistent with the root's profiles: QBE ctor/take helpers about46.7% plus
scanner13.6%; mature-C scanner43.9% plus drop/RFC/span39.0%; Bendc scanner61.6%
plus GC around15%. Those physical percentages overlap semantic responsibilities
and cannot be subtracted across different binaries.

The results show ordinary constant-factor work around a real computation, not a
100× missing primitive. They also expose the fixture limitation: the same digest
consumer materializes many work-list cells and can dominate. Names are constants,
books are tiny, and the same physical representations are reused; this is not a
random-name or deep-index distribution. A counterfactual replacing actual lookup
results with the independently specified complete expected records, retaining
the same changing IDs and full consumer, is economical. Compare its full result
and elapsed time, but do not treat the timing difference as an exact subtraction:
reachability, inlining, allocation and lifetime can change with the producer.
