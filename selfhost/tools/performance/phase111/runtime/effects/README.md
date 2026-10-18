# Cached provider source

`prepare.py` is a data-only preparer; it invokes no compiler or executable. Its
default `selected-base` profile follows `selfhost/tools/native/selection.json`,
verifies the selected admission and all nine `assets.effects` pins, and adds
`selfhost/src/host/native-os.c`. The selected provider root is
`selfhost/build/phase90/runtime-accessor-transport02/effs`, not the newer root
`bend2/effs` tree. `prepared01` is the initial generated source snapshot.

```sh
python3 selfhost/tools/performance/phase111/runtime/effects/prepare.py \
  --out selfhost/build/phase111/effects-source01
```

The ten C files provide 15 registrations: `IO.args`, `IO.print`, `IO.print_err`,
`IO.now`, `File.open`, `File.read`, `File.read_bytes`, `File.read_at`, `File.size`,
`File.write`, `File.write_bytes`, `File.close`, and the three NativeHost effects.
`--profile compiler` selects args/print/print_err plus NativeHost: four files,
six effects. The catalogue also records all 29 upstream Base C files and their
admission-verified hashes, exact `CID(name)` dependencies, registration functions
and constructor annotations. Those upstream files are documentation inputs,
not replacements for the compatible selected providers.

Include `providers.inc.c` once at the retained runtime's `// Requests` insertion
point, after `Env`, `IoWork`, `io_eff_rows`, `io_eff`, and the other `io_*` helpers.
After installing and validating the program descriptor, call:

```c
static void p111_effects_bind(
  uint32_t (*lookup)(void *context, const char *semantic_name), void *context);
```

`lookup` returns the descriptor's exact semantic constructor ID, or `UINT32_MAX`
for absence. It must distinguish constructor identity/provenance before binding;
the provider layer does not authenticate a source declaration merely from a
spelling. Binding is once per process, before CLI/effect evaluation. Rebinding,
out-of-range IDs, aliased semantic names, duplicate installed rows, and an active
provider lacking a direct value-constructor dependency fail through `err_fail`.
The core also binds helper IDs such as SCon/SNil/Con/Nil/Tuple/Done/Fail before
these providers run and validates that every descriptor-requested effect has a
registered implementation. An absent effect leaves its row unregistered.

The generated source preserves provider bodies and their readiness arguments.
It replaces CID references with descriptor-filled slots, removes startup
constructor annotations, and guards the original registrations. Selected
`#ifdef CID_*` branches compile into the cache; runtime registration chooses
which rows are present. No program ID is baked into the object, and no
`.init_array` function reads an uninstalled descriptor. Direct dependency checks
are conservative per source file, including shared helpers.

Arbitrary custom foreign C remains a separate, explicit provider capability.
Do not silently accept its effect name or substitute an unrelated Base provider.
The broad upstream catalogue contains channel helper redeclarations and modern
helper dependencies absent from the retained runtime; its GUI/audio sources also
carry platform library requirements. This preparation preserves the selected
native effect surface and does not claim all upstream providers are qualified.
Neither the catalogue nor generated source constitutes a C/runtime proof;
coordinator-run compilation, descriptor mutation and effect tests remain needed.
