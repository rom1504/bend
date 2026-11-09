# P185-001: Compose existing verified native optimizations in x86

Status: testing; no promotion.

Observation: direct x86 private emission ignored the array-certified context and bypassed structured late expansions already used by QBE. Local fold has402 machine instructions versus54 in QBE; the scalar mit worker has1432 versus100, with1014 moves. These are source-grounded static findings, not dynamic savings estimates.

Hypotheses, independently captured: A) reuse exact array versioning and guarded fallback; B) reuse tag/register/constructor/borrowed structured templates; C) select immediates and compact memory operands; D) remove only proven stable whole-word copies without crossing setup/backedge semantics.

Expected mechanism: eliminate calls and representation conversions, then avoid unnecessary register/spill transfers. Existing checked plans supply legality; target instructions and profitability remain separate. Preserve every slow path, simultaneous loop arguments and bounded native stack.

Evidence: phase185 array-source01/api01/emit01/programs01; late-source01/api01/emit01; machine-source01; exact retained Phase183 x86 and Phase184 QBE/C native45 products. First screen is five existing cases, four runtime-eligible, against all three baselines. It is not a whole-suite claim.

Gates: unchanged direct verifier; raw machine/ABI and immediate edge controls; exact complete-output native45 oracle; adaptive rotated native runtime; unrelated list/map/tree/ray cases before full45. Current qualified images remain intact.
