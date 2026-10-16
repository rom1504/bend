import Base

# Deterministic Mandelbrot PPM renderer. Q12 coordinates use signed U32
# two's-complement words. All products stay within signed 32-bit range;
# the Python oracle instead uses ordinary signed, unbounded integers.

def mr_asr12_choose(word: U32, positive: Bool) -> U32:
  match positive:
    case True{}:
      U32.shrn(word, 12n)
    case False{}:
      U32.or(U32.shrn(word, 12n), 4293918720)

def mr_asr12(+word: U32) -> U32:
  mr_asr12_choose(word, U32.is_zero(U32.shrn(word, 31n)))

# Count completed updates; test the current z before each update.
# Carry the derived square/predicate values so matches scrutinize parameters.
def mr_escape(left: Nat, +cr: U32, +ci: U32, +zr: U32, +zi: U32,
              count: U32, r2: U32, i2: U32, escaped: Bool) -> U32:
  match left escaped:
    case 0n other:
      count
    case 1n+p True{}:
      count
    case 1n+p False{}:
      +nr = U32.add(U32.sub(r2, i2), cr)
      +ni = U32.add(mr_asr12(U32.mul(2, U32.mul(zr, zi))), ci)
      +nr2 = U32.shrn(U32.mul(nr, nr), 12n)
      +ni2 = U32.shrn(U32.mul(ni, ni), 12n)
      mr_escape(p, cr, ci, nr, ni, U32.inc(count), nr2, ni2, U32.is_gt(U32.add(nr2, ni2), 16384))

def mr_colour_choose(+count: U32, interior: Bool) -> String:
  match interior:
    case True{}:
      "\n0 0 0"
    case False{}:
      "\n" ++ U32.show(U32.mod(U32.mul(count, 9), 256)) ++ " "
        ++ U32.show(U32.mod(U32.mul(count, 7), 256)) ++ " "
        ++ U32.show(U32.mod(U32.mul(count, 13), 256))

def mr_colour(+count: U32, limit: Nat) -> String:
  mr_colour_choose(count, U32.is_eq(count, U32.from_nat(limit)))

# Pixel centers sample [-2,1) x [-1.5,1.5); arbitrary rectangular sizes.
def mr_pixels(left: Nat, +x: U32, +width: U32, +ci: U32,
              +iterations: Nat) -> String:
  match left:
    case 0n:
      ""
    case 1n+p:
      cr = U32.sub(U32.div(U32.mul(U32.inc(U32.mul(x, 2)), 12288),
        U32.mul(width, 2)), 8192)
      colour = mr_colour(mr_escape(iterations, cr, ci, 0, 0, 0, 0, 0, False{}), iterations)
      colour ++ mr_pixels(p, U32.inc(x), width, ci, iterations)

def mr_row(+y: U32, +width: U32, height: U32, iterations: Nat) -> String:
  ci = U32.sub(U32.div(U32.mul(U32.inc(U32.mul(y, 2)), 12288),
    U32.mul(height, 2)), 6144)
  mr_pixels(U32.to_nat(width), 0, width, ci, iterations)

def mr_tile(left: Nat, +y: U32, +width: U32, +height: U32,
            +iterations: Nat) -> String:
  match left:
    case 0n:
      ""
    case 1n+p:
      mr_row(y, width, height, iterations)
        ++ mr_tile(p, U32.inc(y), width, height, iterations)

# Balanced row blocks: the multi-binding is Bend's explicit fork/join form.
# Effects happen only after joining the complete ordered image. A depth of
# ten covers the maximum 1024 rows, even when --tile is one.
def mr_rows(+depth: Nat, +y: U32, +count: U32, +width: U32, +height: U32,
            +iterations: Nat, +cutoff: U32, small: Bool) -> String:
  match depth small:
    case 0n other:
      mr_tile(U32.to_nat(count), y, width, height, iterations)
    case 1n+p True{}:
      mr_tile(U32.to_nat(count), y, width, height, iterations)
    case 1n+p False{}:
      +half = U32.div(count, 2)
      +right = U32.sub(count, half)
      a b = mr_rows(p, y, half, width, height, iterations, cutoff, U32.is_le(half, cutoff)) mr_rows(p, U32.add(y, half), right, width, height, iterations, cutoff, U32.is_le(right, cutoff))
      a ++ b

def mr_render(+width: U32, +height: U32, iterations: Nat, +cutoff: U32) -> IO(Unit):
  pixels = mr_rows!(10n, 0, height, width, height, iterations, cutoff, U32.is_le(height, cutoff))
  IO.print("P3\n" ++ U32.show(width) ++ " " ++ U32.show(height) ++ "\n255" ++ pixels)

def mr_usage() -> String:
  "Usage: image-render --size WIDTH HEIGHT --iterations COUNT [--tile ROWS]\n"
    ++ "Writes a complete P3 PPM image to stdout.\n"
    ++ "WIDTH/HEIGHT: 1..1024; COUNT: 1..4096; ROWS: 1..1024.\n"
    ++ "Defaults: 256 256, 128 iterations, 4 rows per tile.\n"
    ++ "Native runtime: --threads N --gpu off -- <application options>"

def mr_fail() -> IO(Unit):
  IO.print("image-render: invalid arguments\n" ++ mr_usage())

def mr_positive_bound(value: Nat, valid: Bool) -> Maybe<&2, Nat>:
  match valid:
    case False{}:
      None{}
    case True{}:
      Some{value}

def mr_positive_read(parsed: Maybe<&2, Nat>, cap: Nat) -> Maybe<&2, Nat>:
  match parsed:
    case None{}:
      None{}
    case Some{+value}:
      mr_positive_bound(value, Bool.and(Nat.is_ge(value, 1n), Nat.is_le(value, cap)))

def mr_positive(text: String, cap: Nat) -> Maybe<&2, Nat>:
  mr_positive_read(Nat.read(text), cap)

def mr_parsed_values(width: Maybe<&2, Nat>, height: Maybe<&2, Nat>,
                     iterations: Maybe<&2, Nat>, tile: Maybe<&2, Nat>) -> IO(Unit):
  match width height iterations tile:
    case Some{w} Some{h} Some{n} Some{t}:
      mr_render(U32.from_nat(w), U32.from_nat(h), n, U32.from_nat(t))
    case a b c d:
      mr_fail()

def mr_values(width: String, height: String, iterations: String, tile: String) -> IO(Unit):
  mr_parsed_values(mr_positive(width, 1024n), mr_positive(height, 1024n),
    mr_positive(iterations, 4096n), mr_positive(tile, 1024n))

def mr_checked_values(width: String, height: String, iterations: String, tile: String,
                      valid: Bool) -> IO(Unit):
  match valid:
    case True{}:
      mr_values(width, height, iterations, tile)
    case False{}:
      mr_fail()

def mr_options(args: List<String>) -> IO(Unit):
  match args:
    case [w, h, flag, n]:
      mr_checked_values(w, h, n, "4", String.eq(flag, "--iterations"))
    case [w, h, flag, n, tile_flag, tile]:
      mr_checked_values(w, h, n, tile,
        Bool.and(String.eq(flag, "--iterations"), String.eq(tile_flag, "--tile")))
    case other:
      mr_fail()

def mr_flags_choose(size: Bool, help: Bool, args: List<String>) -> IO(Unit):
  match size help:
    case True{} other:
      mr_options(args)
    case False{} True{}:
      match args:
        case []:
          IO.print(mr_usage())
        case other:
          mr_fail()
    case False{} False{}:
      mr_fail()

def mr_flags(+flag: String, args: List<String>) -> IO(Unit):
  mr_flags_choose(String.eq(flag, "--size"), String.eq(flag, "--help"), args)

# Current upstream IO.args includes a program name; retained native IO.args
# omits it. Accept one initial non-option name, then require marked options.
def mr_after_program(args: List<String>) -> IO(Unit):
  match args:
    case []:
      mr_render(256, 256, 128n, 4)
    case flag <> rest:
      mr_flags(flag, rest)

def mr_cli_first(flag: String, rest: List<String>, option: Bool) -> IO(Unit):
  match option:
    case True{}:
      mr_flags(flag, rest)
    case False{}:
      mr_after_program(rest)

def mr_cli(args: List<String>) -> IO(Unit):
  match args:
    case []:
      mr_render(256, 256, 128n, 4)
    case Con{+flag, rest}:
      mr_cli_first(flag, rest, String.starts_with(flag, "--"))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    mr_cli(args)
