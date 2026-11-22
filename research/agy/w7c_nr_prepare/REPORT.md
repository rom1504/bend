# Wave 7c — `nr_prepare_annotated` / `p144o_prepare_annotated` Optimization

## Profiling Findings (3.29 MB `wave7_unified/compiler.bend`, 8,533 reachable defs)
Measured via `research/agy/w7c_nr_prepare/profile_nr_prepare.mjs` on CPU 0 (`AGY_NODE_MAX_MB=8192`):
- `1. nc_context_index(annotated)`: `48.2 ms`
- `2. nc_context_defs(book, annIdx)`: `34.2 ms`
- `3. norm_max_book(merged)`: **`1,201.2 ms`** (8.0%)
- `4. book_cached(merged, bound)`: `26.4 ms`
- `5. p144o_build(source)`: `12.3 ms`
- `6. p144o_view(source, facts)`: `59.8 ms`
- `7. nr_walk(view, ["main"], [], [])`: **`13,491.5 ms`** (90.0%)
- `8. ns_attach_book(view, facts, 0, [])`: `17.9 ms`
- `9. nc_paths_of(source, names)`: `51.8 ms`
- `10. kr_filter(source, names)`: `47.4 ms`
- **SUM (1..10)**: `14,992.6 ms` (note: solo run; `22,961 ms` under prior contention)

Sub-step breakdown of `nr_walk` (`profile_nr_walk_detail.mjs` on `750 KB`, 165 reachable defs):
- `nc_definition_plain` (which calls `nc_erase`): **67%** of `nr_walk`
- `nc_refs`: **15%** of `nr_walk`
- `nd_arity_plain`: **14%** of `nr_walk`
- `p142j` seen / `lookup`: **4%** of `nr_walk`

## Root Causes & Fixes (`research/agy/w7c_nr_prepare/apply_w7c_nr_prepare.py`)
1. **O(C) linear scan in `p144o_owned_term` / `p144o_constructors`**:
   - Every `Ctr` and `Mat` encountered during `nc_erase` (inside `nr_walk`) called `nc_ctor_identity` -> `p144o_owned` -> `p144o_owned_term` -> `nb_contains(names, query)`, linearly scanning the entire owned-constructor linked list (50+ entries, scanning to the end on every non-owned user constructor!).
   - **Fix**: In `p144o_ctor_carrier`, attach a pre-built `p142j_members(names, missing())` hash trie as the 2nd child of `NativeCtorIndex` (preserving `index_first(children)` for `nc_find_ctor` and `KTerm{"P144Ownership", ...}` in `typ` for `p144o_payload` backward compatibility). In `p144o_owned_context` -> `w7c_p144o_owned_children`, answer ownership queries in **O(1)** via `p142j_member(owned_set, query, index_hash(query, 2166136261))`. Also upgrade `p144o_constructors` to build `p142j_members` once and dispatch via `w7c_p144o_constructors_set` / `w7c_p144o_specs_set`.
2. **Allocation-heavy `norm_max_book` (`1,201.2 ms`)**:
   - `norm_max_defs` / `norm_max_walk` allocated a temporary `Con` cell via `norm_join` / `norm_defs_join` for every child of every `KTerm` in all 8,939 defs.
   - **Fix**: Replace `norm_max_book` body with zero-allocation recursive `w7c_norm_max_defs` / `w7c_norm_max_term` / `w7c_norm_max_terms`.
3. **Redundant work in `p143nr_visit`**:
   - `nd_arity_plain(book, name)` re-looked up `d` and re-checked `nc_native_def(d)` / `nc_foreign(d)` even though `p143nr_visit` already has `d` and already verified `dk(d) == "Def" && !nc_native_def(d) && !nc_foreign(d)`.
   - `nt_append(String, nc_refs(body), todo)` allocated an intermediate list via `nt_append` + `nt_reverse` + `nt_append(KTerm, ks(h), rest)`.
   - **Fix**: Inline `U32.max(nd_leading(dv(d), 0), jd_live_arity(book, dt(d), jd_arity(book, d)))` directly, and replace `nt_append(String, nc_refs(body), todo)` with zero-queue recursive `w7c_refs_term(body, Nil{})` reversed directly onto `todo` (`nt_reverse(String, ..., todo)`), preserving exact DFS order.

## Verification
- Patch script: `research/agy/w7c_nr_prepare/apply_w7c_nr_prepare.py --src <in> --dst <out>`
- Clean apply on `selfhost/build/agy/wave7_unified/compiler.bend` + `locked_bun.sh --check-only`: **PASS**
- Temp dir `/tmp/agy_w7c_nr_prepare/` cleaned.
- `selfhost/build/agy/wave7_unified/` untouched.
