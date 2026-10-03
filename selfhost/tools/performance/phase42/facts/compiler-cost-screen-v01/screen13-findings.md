# Checked13 compiler-cost early screen

All18 fresh jobs passed exact independent output checks. Root reported164.57seconds including acquisition/planning; the retained runner report records131.659seconds. The [hashed findings](screen13-findings.json) retain all request/process/RSS samples and role-specific output sizes.

| Case | Baseline request median [range], ms | Checked13 request median [range], ms | Change | TS median [range], ms |
| --- | ---: | ---: | ---: | ---: |
| tree-bitonic | 2492.636 [2406.631–2529.562] | 2242.556 [2204.143–2405.577] | -10.03% | 363.337 [320.778–372.381] |
| coverage-list-pipeline-512 | 2000.799 [1982.974–2073.069] | 2241.447 [2234.737–2248.862] | +12.03% | 429.545 [427.347–430.560] |

Tree request cost falls10.03%; list cost rises12.03%. The list sample ranges do not overlap in this screen, so this is a concrete early regression flag. Three samples do not establish a general variance model or significance result. Median process cost is6961.069→6792.641ms for tree (−2.42%) and6448.959→6753.480ms for list (+4.72%). Median tree RSS rises539156480→543633408bytes; list rises543854592→545865728bytes. Host import remains roughly3.7–3.8ms for Bend; request differences are not explained by host import.

This compares all checked13 changes against checked41 with each role's own runtime/API/Base/cache/driver. It cannot attribute tree improvement to plan caching or list regression to fusion alone. Output sizes differ: tree109624→127215bytes, list142134→140319bytes; exact checks compare each role to independently acquired output, never require cross-role runtime equality. Final four-case cost on the next selected hybrid image remains required.

## Static list-cost inspection

The current fusion hook has one external source call: tree.bend j_flat_root_scope invokes j_fusion_root_body once, and that invokes j_fusion_root_prefix once. Its pipeline recognizer resolves four helpers, checks exact container specialization, scans producer/filter/map/fold structure and scalar expressions, then emits their expressions again. Filter unlet normalization has bounded8subst steps. These are new analyses and may contribute to cost, but no duplicate same-root j_fusion fact walk was found statically that justifies a new cache patch.

Other candidate costs remain confounded: exact List/Sigma same-type checks add bounded parameter-aware work, flat-root proof still performs its own complete j_pure_graph, and request fact preparation eagerly computes selected component/direct plans even if fusion later supersedes a path. Existing component/direct fact payloads encode those specific logical planners; substituting them for flat-root graph proof would need exact admission/fuel/refusal evidence and is not an obvious unchanged-proof reuse. No source change is proposed from this screen. A focused compiler CPU profile or proof/fusion-call counts could isolate the list increase if it persists on the actual selected image; ordinary runtime headroom and compiler request cost must be reported separately.
