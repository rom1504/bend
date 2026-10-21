# Fixed-profit region screen

The checked `profit02.bend` candidate removes both intended arithmetic calls
from each nearest worker. Each has exactly two copied sites; all four scalar
selector calls remain. The original Bend planner reports copy cost 295 per
arithmetic leaf, so these two copies consume 590 of the unchanged 1024-node
budget. Eligibility, four-site cap, stack bound and integer ABI are unchanged.

Root completed 27 correct observations across three rounds:

| Case | Safe03 median | Profit-region median | Candidate / parent |
|---|---:|---:|---:|
| active ray | 1692 ms | 1324 ms | 0.7825 |
| raytrace | 1884 ms | 1848 ms | 0.9809 |
| numeric recurrence | 417 ms | 416 ms | 0.9976 |

The filter improves the intended admission pattern. This remains a small
numeric screen, not parity or broad-suite evidence. The earlier CtorId-only
screen used separate paired runs, so its 1363 ms active-ray median is not a
matched comparison with this candidate's 1324 ms.

Against that earlier emitted product, active-ray QBE shrinks from 2,034,048 to
2,009,959 bytes. `$product.nearest` shrinks from 2927 to 2538 QBE lines and from
596 to 586 machine instructions; static stack references fall from 134 to 107.
The tail worker also loses both arithmetic calls, but its machine body grows
from 559 to 603 instructions and stack references rise from 139 to 167. There
is no uniform register-pressure improvement. Static total calls increase because
copied arithmetic brings helper/failure calls into each body and the selectors
remain out of line. These counts are not executed-path frequencies.

The failed first profit source used unavailable `U32.dec`; root's versioned
`profit02.bend` uses the pinned subtraction primitive. That source repair does
not change the selection criterion. Root reports all 23 finite selection
controls passed. No threshold search or further policy variant is proposed.

`results06.json` pins the checked source/API, planner costs, emitted code, root
screen and read-only `region-machine06` disassembly. No compiler or target was
run by this author.
