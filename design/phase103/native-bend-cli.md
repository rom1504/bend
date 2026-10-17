# Phase103: a public CLI implemented in Bend

Contract and test plan; actual results belong in the implementation report.
The starting compiler is promoted Phase102 candidate04, source
`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`.
Its [promotion report](../../implementation/phase102/default-promotion.md)
supersedes the older candidate03 status still in the experiment frontier.

The deliverable is a native executable invoked directly as
`bend-native input.bend -o output.c`, without Python, Node or Bun in an ordinary
request. Argument parsing, request selection, compiler calls and diagnostics
belong in Bend. Small C primitives may implement OS operations unavailable in
the admitted effect set; they must not implement parsing, checking or emission.
The existing C runtime and a C toolchain for building emitted programs remain.

## Existing boundary

[`launch.py`](../../selfhost/tools/native/launch.py) authenticates selection,
source, image, Base, runtime parts, effects and cache; bounds the process; checks
complete output; and publishes without replacement. The existing Bend entry
already reads inputs, prepares Base, invokes `p86_compile`, prints diagnostics
and writes C. Its `p86_cli` takes private absolute asset paths, while
`p86_write_file` opens with `"w"`; exposing those directly would lose the current
public interface and output protection.

Keep the Phase102 compiler algorithms and optimization policy unchanged. This
work replaces the host entry and package transport, not the parser or backend.
Keep the old Python entry, native images and receipts available during rollout.

## Public contract

* Accept exactly one input and one `-o PATH`/`--output PATH`; allow either option
  order and `--` for a positional name beginning with `-`. Reject missing values,
  duplicate options, extra inputs and unknown flags. Do not interpret shell text.
* `--help` and `--version` succeed without compiling or creating files. Help
  describes C emission and the supported import/effect boundary. Version binds
  this CLI build to the compiler profile and stage, not an unrelated upstream
  version string. No arguments or malformed usage return status 2.
* A successful compile returns 0, emits complete C at the requested path, and
  leaves stdout empty. Compilation, asset and filesystem failures return 1,
  with a useful stderr message. Preserve compiler diagnostics. Benchmark timing
  and receipt locations need not appear in the ordinary user interface.
* Resolve user paths relative to the caller's working directory, never by
  changing the process directory to locate assets. Handle spaces and Unicode.
  Read the source completely once, retaining the existing 16 MiB input bound;
  report short reads, invalid input and unsupported imports without publishing.
* Refuse an existing destination, including a directory or dangling symlink.
  Preserve existing bytes and modes. Source/output aliases therefore refuse too.
  For the first version, a missing output parent may report an explicit error;
  recursive directory creation is not required for a successful minimal CLI.
* Publish only after compilation and all writes succeed: create an exclusive
  temporary file in the destination directory, write and close it successfully,
  then perform an atomic no-replace publication. An existence check followed by
  ordinary rename is insufficient. Clean temporary files on handled failure;
  abrupt termination may leave an identifiable temporary file, never partial C
  at the requested destination. Do not claim power-loss durability without fsync.
* Preserve the selected CPU-only compiler behavior. One compiler worker is the
  supported default; user program parallelism is a separate capability.

## Package and asset identity

Use one executable with either embedded immutable assets or a small adjacent
asset directory. Discover adjacent assets from the executable location, with
an explicit policy for symlink/PATH invocation; never search the current
directory for trusted Base or effect providers. Package movement must work
without the old checkout. Test it with the original assets inaccessible.

Bind exactly the consumed Base, five canonical runtime parts and nine effect
providers to this build. For external assets, keep expected byte counts and
digests in the executable or another authenticated root; comparing an editable
manifest to equally editable files is not authentication. Validate the bytes
actually consumed, preferably read once, and refuse missing or modified assets.
Do not hash the entire historical qualification closure on every request.
An embedded asset set needs no repeated disk verification of those same bytes.
Retain the build/package inventory for reproducibility, without making the
ordinary compiler parse admission history or introduce a large new schema.

Prepared Base is the relocation trap: the existing capsule and launcher bind
the original absolute Base path and carrier identity. Rewriting paths alone
does not establish cache validity. The smallest relocatable first package may
prepare Base live and state that cost honestly. If the prepared carrier is kept,
establish an immutable logical Base identity and check its source-origin/cache
obligations explicitly; compare live/cache behavior after package movement.
Never silently downgrade a failed authenticated cache check to a live request.

Private filesystem/path primitives must retain the provider-identity boundary.
Adding a CLI capability must not bless arbitrary user foreign providers as safe
for observer optimization. Keep process execution out of the minimal launcher:
the compiler can call its own Bend routines in process, and C compilation remains
a separate command. B1/B2 selection can use separate packaged executables rather
than retaining a Python-like subprocess dispatcher or JSON selection parser.

## Supervision and release scope

The public executable does not require the Python guard, CPU-3 affinity, a
repository log directory, or a Python interpreter. Benchmark/CI callers may
still run it under the existing external deadline/RSS/process-tree supervisor,
which retains raw evidence. Do not advertise inherited `--seconds`, `--calls`,
`--stage` or `--selection` options unless implemented; those belong to the old
experimental request interface. Resource enforcement is distinct from compiler
correctness and atomic output publication.

## Focused validation sequence

Reuse existing source checking, fixture emission and process capture. Root owns
all target execution. Add a small CLI case list, not a new admission framework.

| Loop | Required observations |
| --- | --- |
| Source and parser | Check the changed Bend entry and narrow FFI. Exercise help/version, valid option orders, `--`, missing/duplicate/unknown arguments and exact exit/stderr behavior. |
| Small native CLI | Compile one ordinary fixture and one existing file-IO fixture; compare complete C and compiler diagnostics with candidate04 for the same source. Exercise one parse/type rejection and one unsupported import. |
| Filesystem | Relative paths from another cwd; spaces/Unicode; existing file, directory and dangling symlink; missing input/parent; injected write failure; competing publishers to one destination. Failed requests preserve destination bytes and do not publish partial C. |
| Package | Copy to a new directory, run through the documented direct/PATH/symlink forms, hide the original asset directory, and test one missing/corrupt required asset. If caching is retained, compare live and cached complete output after relocation. |
| Final image | Freeze the entry/assets/FFI, produce the intended B1 or B2 package, and replay the focused public cases against that exact executable. A newly claimed genuine B2 requires its actual self-emission chain; an upstream-built prototype must remain labeled B1. |

Before broad image work, compare the compiler/backend source closure with
candidate04 and explain each changed dependency. If changes remain at the host
boundary, exact fixture C plus relevant IO/ownership controls justify reusing
the prior backend evidence with explicit scope. Do not rerun optimization
benchmarks, all 45 runtime programs, or full self-compilation after every CLI
edit. Broaden only for a changed compiler dependency, runtime representation,
provider policy, or an observed mismatch. One final image chain can be justified
by shipping a new self-hosted executable, independently of optimization claims.

Release only after the actual standalone package succeeds without language-host
interpreters on PATH. Record its source/image/package identities, tested platform,
asset policy and focused results. Update public usage then; preserve candidate04
and the Python benchmark tools. This is a usability milestone, not a new compiler
speed result or a proof of all compiler/runtime behavior.

## Resolved implementation choices

Keep the prepared carrier and its original logical Base identity. Read the exact
Base, carrier, runtime parts and effect bytes beside the executable; embed their
digests in generated Bend declarations. This preserves the existing cache and
effect provenance without checking an old physical checkout at runtime.

Use three OS effects (`NativeHost.read`, `NativeHost.path`,
`NativeHost.publish`). Read returns the same bytes it hashes; publication holds
the created inode through atomic no-replace linking. All CLI and compilation
decisions stay in Bend. A small image-only C startup adapter forwards arguments
past the generic runtime option parser and selects one CPU worker/GPU off. The
generated-program runtime and emitted user C are unchanged.

The existing compiler rejects new foreign providers and would disable observers
and constructor packing for a new host effect. Therefore build a temporary
bridge, with explicit permissions for only the three checked operations and
their exact pinned C source. This bridge also needs the constructor-packing
exception; an observer-only change is insufficient. Its C routines consume
strings and allocate fresh results, never mutate or expose identity of immutable
Bend roots. Preserve the final compiler's original backend predicates and
provider allowlist. Do not install the bridge or expose its wider authority as
a user option.

Pinned upstream builds this bridge B1, then bridge B1 emits public CLI B2, which
Clang builds with the startup adapter. This establishes native Bend production,
not public-CLI self-reproduction: the narrow public provider policy still refuses
the CLI's own OS source. Rebuilding its host entry deliberately uses the pinned
bridge. Keep that limitation explicit instead of widening ordinary requests.

Keep SHA-256 and POSIX/Linux byte operations in C, with no OpenSSL dependency.
Retain Python supervision only for development and independent benchmark jobs.
The public package requires no host-language interpreter. This phase does not
port the separate JavaScript driver, build automation or proof tooling.
