# Renderer: emitted code and worker measurements

The complete-image renderer retains actual parallel work in both emitted
programs. The production measurement validates every output byte and shows
2.028× native and 2.228× upstream speedup with four workers versus one. The
identical-image single-tile control does not gain from extra workers. These
measurements do not identify which generated-code differences explain the
native program's higher elapsed time.

The separate
[additional-controls01](../../selfhost/build/phase100/additional-controls01/report.json)
receipt also passes all eight renderer CLI executions: zero dimension,
dimension above the bound, missing iterations and help, each on native B2 and
upstream. These enforce exact complete stdout, empty stderr and the documented
zero exit status. They are correctness controls, not image timing samples.

The inspected products are pinned by
[image-acquire01](../../selfhost/build/phase100/image-acquire01/report.json):
native B1 and B2 produce identical C, with B2 C SHA256
`8554b9a345109e852d18f9bd568be84a8fc3d88da2a3518e9b5c36c31c13497e`;
upstream C is
`a7d3afce6c4b8f0e8d635a1370d4d6fd6ccf3413569793b43148c332bdc00891`.
Both executables use the same pinned Clang, `-std=c11 -O3`, pthread and math
libraries. Native C is 555,516 bytes and its ELF 240,800 bytes; upstream C is
177,590 bytes and its ELF 77,280 bytes. These are static sizes, not executed
instruction or allocation counts.

In [native C](../../selfhost/build/phase100/image-acquire01/image-render/b2.1.c),
the direct `mr_rows` branch around line 5525 creates two child task nodes and a
join node with dependency count two. The children compute disjoint consecutive
row ranges; the join concatenates the returned strings in row order. In
[upstream C](../../selfhost/build/phase100/image-acquire01/image-render/upstream.1.c),
`FID_MR_ROWS` around line 3601 creates the equivalent two child tasks and
`FID_MR_ROWS_J105` join. This is executable scheduler code, not just retained
parallel syntax in the source. A cutoff at least the image height takes the
single-leaf path and provides a control without independent row branches.

Both CPU backends compile the escape iteration into a direct scalar loop:
native `NF_FID_109_114_95_101_115_99_97_112_101_` starts around line 3147 and
repeats with `goto nf_again`; upstream `spin_14` starts around line 1578.
The native worker includes many intermediate error checks and generic term
operations in emitted C, while the upstream worker is considerably shorter.
Clang can eliminate or combine source operations, so their appearance alone
does not establish runtime cost. The large-table `wl_target` accessor discussed
in Phase99 is inactive here: native `FID_ENTER` is 512, below its 4096 threshold.

Both programs retain linked String traversal and reconstruction for append,
including continuation storage and constructor allocation. Formatting happens
inside row work, but joining strings and the final single `IO.print` remain
part of the application. The print handler materializes a C string and writes
the complete image after the join. Consequently the measured application
includes arithmetic, formatting, allocation, scheduling and output; it is not
an isolated arithmetic kernel.

[image-survey01](../../selfhost/build/phase100/image-survey01/report.json)
is complete with 72/72 successful executions: three images, two backends,
1/2/4 workers, four rounds each. Every full PPM matches the independent Python
oracle. For the largest image, 384×256 pixels, 512 iterations and tile eight,
the child-process elapsed medians are:

| Workers | Native B2 seconds | Upstream seconds |
| --- | ---: | ---: |
| 1 | 0.139926 | 0.100030 |
| 2 | 0.084540 | 0.064075 |
| 4 | 0.071180 | 0.050454 |

One-to-four-worker speedups are 1.966× and 1.983× respectively. The four native
four-worker samples range from 0.068258 to 0.073322 seconds; upstream ranges
from 0.049263 to 0.054301. These are four observed samples, not confidence
intervals. CPU affinity is CPU 3, CPUs 2–3, and CPUs 0–3 respectively on the
recorded Xeon E3-1245 V2 host. The clock includes process startup and complete
835,816-byte stdout capture, but excludes compilation, Python oracle generation
and the outer guard. Median child peak RSS at one/four workers is
46.64/47.70 MiB native and 37.83/45.41 MiB upstream.

[image-production01](../../selfhost/build/phase100/image-production01/report.json)
extends this to 512×384 pixels and 1024 iterations. All 48 executions pass:
two tile configurations, two backends, three worker counts and four rounds.
Both tile configurations produce the same 1,671,816-byte image, SHA256
`d28ec05f6dba63d5a8f8ccc46c453d448790f3e2c243a335302e90a5253b461d`.
The compiler products, timing scope and affinity scheme are unchanged.

| Workers | Native tile 8 seconds | Upstream tile 8 seconds | Native single tile seconds | Upstream single tile seconds |
| --- | ---: | ---: | ---: | ---: |
| 1 | 0.348373 | 0.257574 | 0.309892 | 0.193972 |
| 2 | 0.216298 | 0.152777 | 0.310040 | 0.193921 |
| 4 | 0.171763 | 0.115601 | 0.309686 | 0.198427 |

For tile eight, the four-worker native sample range is 0.162951–0.174942
seconds; upstream is 0.112213–0.118401. Native median child peak RSS is
79.38/79.42 MiB at one/four workers, upstream 65.20/78.35 MiB. With one tile,
both use approximately 47.3–47.4 MiB median child peak RSS and receive no
consistent elapsed-time benefit from extra workers. At one worker the tiled
version is slower than the single leaf in both backends, while at four workers
it is faster. This isolates an application-level cost/benefit of partitioning
the same image; it does not separate task management from String construction
and joining costs.

Possible scaling limits are unequal pixel iteration work despite equal row
counts, tile and scheduler overhead, repeated String traversal/allocation,
and the final output dependency. These are hypotheses, not measured causal
attributions. The similar observed scaling also does not prove identical
bottlenecks. The smaller images and sub-0.1-second first-survey samples are too
short for strong conclusions from small differences. The longer production
samples and single-leaf control support useful parallel execution, while four
rounds on this host still provide neither a confidence interval nor a forecast
for other workloads or machines.
