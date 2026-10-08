# Flat worker v3: source rebase only

Frozen candidate and baseline source copies incorporate the root-applied demand-template lookup change. The worker implementation and integration delta are identical to v2: the patch SHA-256 remains `78bfbf12d1a45e6ea79337319e762bc0c4436e5c6eea3c9e3e59f4f516459759` because all template substitutions lie outside its changed context. `flat-v3.json` records the updated exact before/after source hashes.

Data-only checks: all six beforehashes match production at freezing; `git apply --check` passes; the candidate receives exactly the same template substitutions as the baseline; `flat.bend` is byte-identical to v2. The prior eta adapter and prefix affine fix remain intact. No compiler, C compiler, or target execution was performed by this lane.

The product-result follow-on owner may use `candidate/` as a stable isolated baseline. The root alone applies and qualifies this proposal. See ../README.md, ../check-workers.py, and the pre-registered P68-005 experiment for mechanism, gate, and limitations.
