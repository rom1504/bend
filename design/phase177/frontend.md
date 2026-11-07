# Phase177: remove frontend traversal work

Parent: `c98764b`; maintained Phase175 source SHA256 `a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04`.

The objective is lower complete frontend latency, currently 56.219s on the frozen compiler input, without changing checked values, diagnostics or emitted program semantics. A 2x frontend gain is an ambition, not an estimate. The previous phase proved that one tail-recursive owner can enter the native direct region where mutually recursive frame helpers could not; its actual parser gain was only 2.86%.

## Experiments and decisions

1. Flatten the complete ID-freshening traversal into one owner, preserving simultaneous-let scope, global/local renaming, overflow and malformed public values.
2. Flatten substitution and beta rebuilding into one owner. Preserve opaque variables, eager application canonicalization, quantities, source spans and aliases. This may remove intermediate App construction as well as scheduler transitions; an absence-of-variable shortcut is unsound.
3. Reuse the indexed reachability set through final filtering rather than materializing names and rebuilding another set. Public traversal output remains unchanged. Repeated-parent suppression requires additional proof and is not assumed legal for arbitrary books.
4. Inspect publication/filter costs against the already selected compact checker; reject ideas that repeat previous deferral experiments.

These are independent bounded candidates, not commitments to a combined rewrite. Bounded agents own source overlays and semantic audits; one coordinator owns compiler acquisition and measurement. All algorithms remain Bend. Host scripts only transport pinned source, compare complete values and record resources.

## Gates and efficient execution

- Independently check extracted baseline/candidate Bend sources; compare full values on boundary controls and real frontend inputs. Hashes are supplementary observations, not equivalence proofs.
- Inspect native admission, and measure small real compiler inputs. Reject clear regressions immediately. Never infer a whole-request saving from profiler sample counts.
- Use the existing software batch runner for independent small comparisons on separate physical cores. Measure survivors alone with balanced order. Native image acquisition stays in one resource-controlled lane.
- Only survivors receive a full frozen-source frontend comparison. Combine candidates only after their individual effect is known; check interactions.
- Integrate a useful survivor into maintained source only after exact output/diagnostic gates. Then run a bounded frozen cold build and appropriate backend/ownership/conformance gates; reserve full N1/N2 acquisition for a materially improved integrated compiler. Keep the installed qualified compiler until independent qualification justifies publication.

Measure whole process and frontend separately; include acquisition, validation and failed attempts. Retain rejected candidates and uncertainty. Record source growth, native QBE size, emitted-program identity where promised, and any source-checking limitations. Every target uses the disk/RSS/time guard and closed retention receipt; no uncontrolled parallel build campaign.
