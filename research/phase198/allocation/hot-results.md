# Retaining existing spill producers improved edit distance in both layouts

The unchanged emitted edit-distance row still held three private spilled values in the GPRs that produced them for 6, 16 and 19 instructions. Removing their unique stores and reading those GPRs directly reduced median paired elapsed time by 8.96% under project assembly flags and 8.24% under default layout. The two layouts favored the candidate in four and three of four pairs. Mandelbrot did not benefit. The denominator is two of 45 native catalog programs, one successful family, two independent assembly layouts of each program, and one timing session. [Static analysis and compiler object hashes](hot-freeze.json) · [Frozen predictions](hot-predictions.md).

| Program | Placement | Project candidate / baseline, favorable pairs | Default candidate / baseline, favorable pairs |
|---|---|---:|---:|
| Edit distance | Original producer retention | 0.91036, 4/4 | 0.91758, 3/4 |
| Edit distance | Producer retention plus free physical homes | 0.93264, 2/4 | 0.87303, 4/4 |
| Mandelbrot | Original producer retention | 1.00715, 0/4 | 1.00240, 2/4 |
| Mandelbrot | Producer retention plus free physical homes | 1.00000, 1/4 | 1.00001, 2/4 |

The free-home arm passed the runtime threshold only in edit distance's default layout. Relative to producer retention alone its ratios were 1.00253 project and 0.95454 default. Mandelbrot's corresponding ratios were 0.98819 and 0.99764. Several raw samples show substantial variation. In edit distance the final baseline pairs lasted 234/239 ms compared with 183/181 ms in the first pairs. These data support advancement of the original-producer policy to independent replication and a checked compiler implementation. They do not establish the claimed effect for a maintained compiler, the orbit image or additional workloads.

The edit row executes 262,144 positive iterations per ordinary invocation. The original-producer policy removes six of twelve frame operands and four of 58 instructions per iteration. The extended policy removes eight frame operands with the same instruction count. Mandelbrot retains all mit/hchunk instructions while moving four/six frame operands, respectively, to registers, and its physical timing remains neutral.

The guarded run took 12.65 seconds. At the four selected source inputs per program all six assembled siblings and the current direct object matched mature Bend C, totaling 56 observed native outputs and eight oracle executions. Every timed sample also checked its result and counts. The retained receipt includes each executable/object digest, calibration, paired sample, command and closed guard. [Compressed receipt and guard](hot-session.json.gz) · [Screen](hot-screen.py) · [Physical projection](hot-placement.py).
