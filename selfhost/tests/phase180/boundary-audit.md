The bounded candidate misses the 5% gate. Root's closing B/C/C/B observation is
12.2465 → 12.154 seconds (0.76% less). Root also reports `app` shrinking from
33 to 13 machine instructions, `ks` still constructing two `Con` cells, and
`p177s_loop` growing from 1,122 to 1,300 instructions. This note adds source
evidence only: it does not attribute measured time or allocations to these
boundaries, and no additional target ran for this audit.

The candidate's `app` and compact `ki_pair` branch produce `KApply` directly
(`application-core.bend:14`, `:31`). Its `kid`, substitution loop and
`env_subst_term` also have direct compact branches. However, `ks(KApply)` still
returns `[function, argument]` (`application-accessors.bend:80`). Three concrete
consumer boundaries retain the old list contract:

1. **Checking conversion: `compare` → `norm_exact_head` / `norm_exact_lists`.**
   `check_fits` calls `compare` on inferred and expected types
   (`../../src/check/kernel.bend:872`). `compare` first calls `norm_exact`
   (`../../src/core/normalize.bend:467`). For an App encountered there,
   `norm_exact_head` obtains each child count through `terms_len(ks(...))`
   (`:610`); if the heads agree, `norm_exact_lists` requests children again and
   joins them onto traversal lists (`:599`). Compact application types therefore
   still satisfy comparison through materialized child lists. A migration of
   this owner would have to retire both the App child-count list and the App
   list traversal, preserving malformed generic Apps and comparison behavior.
   Changing `kid` alone cannot remove either call.

2. **Selection before annotation: `reach_book` → `kr_refs`.**
   The actual request passes checked context through
   `annotate_selected(context, reach_book(...), stops)`
   (`../../src/host/native-plan.bend:189`). `kr_dependencies` visits declaration
   types and bodies; `kr_refs` immediately delegates `ks(t)` to `kr_refs_list`
   (`../../src/core/reach.bend:139`, `:151`). It therefore reconstructs compact
   App children just to enumerate references. Retiring that contract would mean
   visiting the two fields directly while preserving reference order and
   duplicate handling. The annotation App path itself already uses `kid` and
   `app` (`../../src/check/annotate.bend:388`, `:414`); it should not be described
   as universally converting Apps back to generic nodes. Annotation wrappers
   still use their own two-child lists (`:216`). After annotation, request
   preparation also runs `norm_max_book` (`../../src/back/common/constructor-facts.bend:185`),
   whose `norm_max_walk` uses `norm_join(ks(h), rest)`
   (`../../src/core/normalize.bend:565`), so bypassing reference enumeration alone
   would not eliminate all later materialization.

3. **Live application erasure: `nc_erase_app` → `nc_erase_list` → `k_rebuild`.**
   Request closure visits call `nc_definition_plain`, which sends ordinary
   bodies to `nc_erase` (`../../src/core/query-ownership.bend:56`;
   `../../src/back/native/book.bend:110`). For a retained App,
   `nc_erase_app` supplies `ks(t)` to `nc_erase_list`, then passes the rebuilt
   child list to `k_rebuild` (`../../src/back/native/erase.bend:77`, `:84`).
   Thus compact input is unpacked to a list and mapped to another list before
   compact output is reconstructed. Retiring this boundary requires direct
   function/argument erasure, retaining the erased-argument branch and erasure's
   deliberate metadata reset. The closure owner subsequently calls `nc_refs`
   on that body (`../../src/core/query-ownership.bend:60`); `nc_refs_go` again
   appends `ks(h)` to a worklist (`../../src/back/native/book.bend:63`). Fixing
   reconstruction alone would leave that consuming walk intact.

These are bounded explanations of work the representation change leaves in
place, not evidence that removing it would meet the gate. A future experiment
would need to retire an identified owner's old child-list contract and include
its downstream observation in the measured computation. This audit does not
recommend broadening Phase180, adding a universal traversal abstraction, or
reviving Phase178's rejected erased-body/reference product. Stop at the existing
rejection; retain the candidate and its exact evidence.
