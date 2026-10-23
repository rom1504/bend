# P126-006: allocator-call elimination is not allocation elimination

Status: rejected from the selected compiler.

A checked closed tree permutation reuses two uniquely owned input shells,
moves each field once, and constructs one outer result. All raw/distinct/layout
guards run before either take; failure leaves the original computation untouched.

Dynamic counters show5630/5630 fast-path successes and11260 fewer allocation and
take calls. Node allocator-call traffic falls37.92%. Yet the raw helper regresses
5.47% geometrically across three tree cases; replacing its outer generic
constructor with the existing fixed-arity constructor still regresses3.35%.

The baseline already recycles the same shells through its local freelist. Thus
the counters establish removed bookkeeping, not less fresh allocation. The new
helper adds checks and a call frame and changes physical cell placement. Cache
effects remain unmeasured. RFC1 support was built but not timed; raw success was
already100%, so broader ownership admission did not explain this deficit.

Do not generalize allocator-call counts into a runtime win. The next decisive
experiment would separate exact memory placement from call/guard cost. No
production complexity from this experiment is retained.

Evidence and source/machine pins: `implementation/phase126/tree-reshape.md`.
