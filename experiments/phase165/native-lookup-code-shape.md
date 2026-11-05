# Portable checker lookup: generated-C audit

The combined v4 transplant passed ordinary checked C emission in `lookup04`.
This audit compares its generated C with `original02`, without running either
program. The reproducible inventory is `native-lookup-code-shape-v2.json`, made by
`tools/audit-native-lookup.py`. It masks C strings/comments, extracts ordinary,
specialized and `BEND_UINL` function bodies, and records F/U/W symbol references.

| Static property | Original | Portable checker |
| --- | ---: | ---: |
| Generated C bytes | 4,628,175 | 4,682,697 |
| Checker F/U/W bodies | 1,079 | 1,199 |
| Private portable F/U/W bodies | 0 | 120 |
| Checker native `String.eq` references | 36 | 0 |
| Checker native `Map.bit` references | 1 | 0 |
| Checker native `Map.has` references | 4 | 0 |
| Checker native `Map.get` / `String.cmp` references | 0 / 0 | 0 / 0 |

The original `F_Chk_dMap_dfind_dgo` at C line 19,467 references native String.eq
and Map.bit. Its portable counterpart at line 19,588 references
`U_Chk_dp165portable_dString_dcmp`, native Nat.divmod, and
`U_Chk_dp165portable_dMap_dbit_dgo`. Similarly, `F_Chk_dStr_dhas` changes from
native String.eq at original line 21,160 to portable String.cmp at candidate line
21,409. The small String.eq wrapper has been inlined; its absence as a standalone
private body does not mean the old intrinsic survived.

Following all F/U/W references from the 120 private bodies reaches exactly those
120 bodies plus native Nat/U32 primitives. No selected Map/String native is a
defined reachable function or an external terminal. Native Map/String calls in
other compiler modules are intentionally retained.

The six native memo symbols retain identical static reference counts in checker
bodies: new 2, has 1, get 1, set 1, same 2, link 2. The source treatment also
preserves the original memo names, bodies and native table. These observations
support the intended independent lookup treatment; they do not establish equal
dynamic memo hit rates.

## Independent Map-only arm

`native-map-code-shape.json` applies the same static audit to `map04/program.c`
(4,675,210 bytes; SHA256
`0b30273e3b97e53d2a29936fe963fe5cfdbbbf2ce25fdda1ec9902cb19252a29`).
Its 111 private F/U/W bodies replace the selected Map intrinsics while retaining
the independent native String policy:

| Checker static references | Original | Map-only |
| --- | ---: | ---: |
| Native `Map.bit` | 1 | 0 |
| Native `Map.has` | 4 | 0 |
| Native `Map.get` | 0 | 0 |
| Native `String.eq` | 36 | 36 |
| Native `String.cmp` | 0 | 4 |

The new String.cmp references occur in the portable Map operations, where they
replace comparisons previously performed inside native Map routines. Following
the private call graph reaches no native Map.bit/get/has; native String.cmp is an
allowed external terminal. At candidate line 19,578, `Map.find.go` calls native
String.eq, native Nat.divmod and portable Map.bit.go. `Str.has` at line 21,313
still calls native String.eq. All six native memo reference counts remain equal
to the original arm. These are treatment checks, rather than performance results.

The first inventory, `native-lookup-code-shape.json`, omitted `BEND_UINL` bodies
and is incomplete. Use v2 for counts and reachability. These are static code
properties, including wrapper references, rather than instruction counts,
dynamic calls, semantic equivalence or speed measurements. Complete checker
output gates and balanced timing remain separate requirements.

Reproduction with a fresh output file:

```sh
python3 -B experiments/phase165/tools/audit-native-lookup.py \
  --baseline selfhost/build/phase165/original02/program.c \
  --candidate selfhost/build/phase165/lookup04/program.c \
  --out /tmp/phase165-native-lookup-audit-fresh.json
```
