# Phase153 — find consequential cold-build headroom

Starting HEAD: `0a16bb7`; qualified Phase152 N2 and its exact source/products.
Question: which removable work has a credible path to at least 20–30% less
complete cold compilation time, without buying that saving with slower output?
This is investigation, not another production promotion campaign.

1. Reuse the existing object and generic profiler; rebuild only diagnostic
   support. One small output gate, then one current full-source sampled emission
   with an existing complete QBE oracle. No compiler self-build or broad runtime
   campaign. Old stage profiles inform hypotheses but are not current timings.
2. Independently audit frontend and backend source against the largest costs.
   Separate disjoint stages, overlapping leaf attribution and causal estimates.
   Require a specific category of work to disappear and account for new costs.
3. Choose the cheapest decisive ceiling test if the refreshed evidence identifies
   one. Do not implement another small optimization just to report a gain.
4. Rank structural opportunities by whole-build ceiling, plausible realization,
   uncertainty and implementation/testing cost. Preserve negative evidence.

Budget: one bounded target lane on CPU3; roughly 10 minutes of target execution
before a decision. Two bounded read-only source audits run independently. Use
existing guarded profiler/build tools, 2 GiB RSS and 5 GiB free-disk reserve.
One diagnostic full request is information gathering, not qualification. Keep
production source, runtime selection, semantics and installed images unchanged.
