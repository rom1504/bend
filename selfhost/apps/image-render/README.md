# Image renderer

Render a complete, deterministic Mandelbrot image with the installed Bend native
compiler. The application takes its dimensions, iteration budget and row tile
size at runtime. Standard output is a plain PPM (`P3`) image that image viewers
and image conversion tools can read. No image package or foreign application
code is required: `main.bend` imports only `Base` and uses `IO.args` and `IO.print`.

From the repository root, emit and build the application:

```sh
python3 -B selfhost/native.py selfhost/apps/image-render/main.bend -o /tmp/image-render.c
/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang \
  -isystem /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang \
  -O2 /tmp/image-render.c -o /tmp/image-render -lm -pthread
/tmp/image-render --threads 4 --gpu off -- --size 512 512 --iterations 256 --tile 4 > /tmp/mandelbrot.ppm
```

The runtime's `--threads` selects CPU workers. Omitting it uses the runtime's
available-CPU default. Use `--gpu off` for this CPU application milestone. Put
application options after `--` so `--help` reaches the application:

```sh
/tmp/image-render --gpu off -- --help
/tmp/image-render --threads 1 --gpu off -- --size 19 13 --iterations 64 --tile 3
```

`--size WIDTH HEIGHT --iterations COUNT` is the required option order when
providing a size. `--tile ROWS` is optional and follows the iteration count.
Dimensions and tile sizes must be 1–1024; iterations must be 1–4096. With no
application options, the defaults are 256×256, 128 iterations and four rows per
tile. Decimal inputs may have leading zeros. One leading non-option token is
accepted as the executable name because the retained native and upstream
`IO.args` conventions differ; marked options then have identical meaning.

Invalid options print `image-render: invalid arguments` and usage text to stdout
and return normally. This limited CLI does not provide a nonzero error exit
status; verify that image output starts with `P3`, or use the validator below.
Help and errors are not images. Help prints exactly the following text, followed
by one final newline; errors prepend `image-render: invalid arguments` and a
newline to the same text. Both paths leave stderr empty and exit with status 0.

```text
Usage: image-render --size WIDTH HEIGHT --iterations COUNT [--tile ROWS]
Writes a complete P3 PPM image to stdout.
WIDTH/HEIGHT: 1..1024; COUNT: 1..4096; ROWS: 1..1024.
Defaults: 256 256, 128 iterations, 4 rows per tile.
Native runtime: --threads N --gpu off -- <application options>
```

## Pixels and parallel work

For pixel `(x,y)`, the signed fixed-point coordinates are
`floor((2*x+1)*12288/(2*width))-8192` and
`floor((2*y+1)*12288/(2*height))-6144`. The scale is 4096 (Q12), sampling pixel
centers of `[-2,1) × [-1.5,1.5)`. Non-square images stretch this fixed viewport;
choose equal dimensions to preserve its aspect ratio.

Start at `z = 0`. Before each update, escape when
`floor(zr*zr/4096) + floor(zi*zi/4096) > 16384`. Otherwise update the real part
using those two squared values and the imaginary part using
`floor(2*zr*zi/4096)`. The escape count is the number of completed updates,
capped at the iteration budget. Capped pixels are black. Other RGB values are
`(9*count % 256, 7*count % 256, 13*count % 256)`. This is a fixed-point rendering,
with explicitly specified rounding, rather than a floating-point approximation
whose last bits depend on the target.

Bend stores signed quantities in U32 two's-complement form and implements the
signed right shift explicitly. Before an update each component is bounded by
the escape test; afterward its magnitude is at most six fixed-point units.
Even the conservative bound `72 * 4096²` is below `2³¹`, so the relevant signed
products fit. The Python oracle uses signed unbounded integers and floor
division instead of emulating these U32 operations.

`mr_rows!` enters parallel evaluation. A balanced tree splits consecutive row
ranges; the explicit `a b = ... ...` binding forks its two children. A leaf
computes at most `--tile` rows sequentially. All work is pure, and left-to-right
joins preserve row and pixel order. A single `IO.print` writes the image after
the join. Workers and tile size must not affect any output byte.

Rendering, decimal formatting, String concatenation, allocation and complete
image output are all part of the application. Joining String tiles copies text;
this cost can limit scaling and is deliberately visible in the measurements.
No checksum substitutes for the image. One-tile fixtures provide a useful
control where extra workers have no independent row blocks to process.

## Independent oracle and validation

Only the Python standard library is required:

```sh
python3 -B selfhost/apps/image-render/oracle.py render --size 19 13 --iterations 64 -o /tmp/expected.ppm
python3 -B selfhost/apps/image-render/oracle.py validate /tmp/mandelbrot.ppm --size 512 512 --iterations 256
python3 -B selfhost/apps/image-render/oracle.py self-check
python3 -B selfhost/apps/image-render/oracle.py fixtures /tmp/image-render-cases --depth survey
```

Validation parses every channel, checks dimensions, maximum value, complete
pixel count and channel bounds, then compares every pixel against independent
arithmetic. By default it also requires the exact complete text, including its
final newline. `--pixels-only` permits equivalent PPM whitespace/comments while
still checking every pixel. The first wrong pixel is reported by coordinates
and channel. Existing changed fixture files are refused rather than overwritten.

The shared runner can import `cases(out_dir: Path, depth='smoke'|'survey')`.
Each row contains `id`, application `argv`, complete newline-exact `expected`
stdout and `input_files=[]`. Seven smoke image cases have `parallel=True` and
cover a single pixel, escape behavior, rectangles, odd row splits, fine tiles,
one tile and the default cutoff. Four additional smoke controls have
`parallel=False`: zero width, width above 1024, missing iterations, and help.
Their independent expected text specifies the complete stdout above, empty
stderr and exit status 0; the shared runner enforces all three. All eight
executions of these four controls on native B2 and upstream pass in
[additional-controls01](../../build/phase100/additional-controls01/report.json).

Survey adds 128×96/256-iteration, 256×192/384-iteration,
384×256/512-iteration and 512×384/1024-iteration images. The last size has both
tile-eight and tile-512 variants with identical expected pixels; the latter
produces one sequential leaf. The oracle computes each image once across tile
variants. Expected PPMs, CLI text and a metadata manifest are written to the
chosen output directory; the original seven smoke image fixtures remain in
`fixtures/`.

The completed [production measurement](../../build/phase100/image-production01/report.json)
passes all 48 executions against the complete 1,671,816-byte PPM oracle. With
512×384 pixels, 1024 iterations and tile eight, median elapsed seconds over four
rounds are:

| Workers | Native B2 | Upstream |
| --- | ---: | ---: |
| 1 | 0.348373 | 0.257574 |
| 2 | 0.216298 | 0.152777 |
| 4 | 0.171763 | 0.115601 |

The native program gains 2.028× from one to four workers; upstream gains
2.228×. The identical-image single-tile control stays around 0.310 seconds
native and 0.194–0.198 seconds upstream across these worker counts. These
measurements include process startup, rendering, formatting and complete stdout
capture, using the same Clang `-O3` build flags and the recorded CPU affinities.
They exclude compilation and oracle generation. They are local measurements,
not performance guarantees; see the
[code and scaling analysis](../../../implementation/phase100/renderer-analysis.md)
for observed sample ranges, memory and unmeasured possible limits.

The oracle's data-only self-check covers six analytic complex-plane points,
the exact single black pixel, tile independence and five malformed or corrupted
images. These checks do not establish native or parallel correctness. Compiler,
execution and worker-scaling results belong to the root-run Phase100 receipts.
