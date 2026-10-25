# Derived erased-reference reuse

`products-v03.bend` is derived from the frozen indexed-visited `products-v02`.
It preserves that version's visited index, exact ordered done/fact lists, queue
schedule and erasure cache admission. Only P140OEEntry gains a fourth field:
`refs:List<String>` equal to the original `nc_refs(body)` result.

A miss computes the original body and arity, then computes its references once.
The same refs are appended to the todo queue and retained with that body. A hit
reuses that actual list under the unchanged name/clean-owner gate. `nc_refs` is
pure and consults only its body, so this introduces no context dependence or
new invalidation predicate. Reference order and duplicates are retained; there
is no set conversion. Publication still follows the full session's successful
output-close boundary. Previous versions' cache constructors are not wire
formats and cannot be imported into this fixed-producer in-process cache.

The new entry retains one derived list per erased owner. It avoids rescanning
cached body trees and reconstructing those lists, but still schedules references
through the original ordered traversal. Native gain and live-memory overhead
are unmeasured. Validate against original nr_walk for cold/warm/edited closure
and compare full raw/final QBE on the existing real request screen. The
coordinating owner agent is supplying those original-walk controls; no target
was run while preparing this module.
