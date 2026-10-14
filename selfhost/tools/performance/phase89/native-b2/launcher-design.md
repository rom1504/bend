# Minimal maintained native89 launcher

Proposal only. No new image or prepared-cache consumer is admitted by this file.
The full nine-effect image build, its eight live/cache gates, and its own broad
45-point exact-C gate must finish before sealing admission.

Reuse `phase88/native.py` in a private `importlib` module instance. Replace only
that instance's `authenticate` global with a Phase89 admission function, update
its descriptive docstring, then call its existing `main`. Its CLI, source-size
limit, serial guard, per-request logs, output refusal, repeated-output equality,
before/after authentication, atomic publication and error handling remain the
reviewed implementation. No historical module or global installed image changes.
The wrapper identity and admission-module identity belong in the authentication
result because the reused launcher's `method` field identifies its own file.

The new admission function would:

1. Verify a sealed manifest against a digest fixed in the new wrapper, containing
   exact native B1 binary/source/C identities, checked acquisition/build receipts,
   the nine-effect asset identities, successful gate receipt and broad receipt.
2. Use existing `native_support.authenticate(image, None)` for the checked frozen
   source/C/image/build chain. Require the exact admitted image/source/C tuple
   and the new source SHA256 `4584cf08…`, not an arbitrary checked build.
3. Verify every admitted effect name, path, byte count and hash independently;
   the scalar authentication helper intentionally covers only three providers.
   Verify Base, runtime parts and template against the admitted identities.
4. Verify the sealed eight-gate and broad receipts against their manifest hashes
   and exact producer tuple. The former must contain four live and four cached
   successful exact-C cases; the latter must cover the expected 45 point IDs,
   successful grouped emissions, unchanged inputs and the same producer image.
5. For `--live`, return the admitted authentication with `cache:None`. Otherwise
   require the existing exact prepared-cache receipt and use its already checked
   carrier/API/Base/ABI/path/stamp binding. Initially this can reuse the existing
   Phase88 admitted cache authentication, accepting its preserved baseline-image
   dependency rather than copying the cache protocol. Return the same structured
   cache binding after the new consumer's independent qualification.
6. Include all qualification and method identities in the authentication result,
   so the reused launcher's final authentication comparison catches changes.

The manifest refers to frozen acquisition source and output bytes. It must not
require today's 145 inherited mutable production-source paths to continue
matching historical inputs. Their original acquisition identities remain in the
archived evidence. Current `run-b1.py` retains all those checks for its single
frozen attempt; this proposal does not weaken that method.

`broad-exact.py` currently accepts only compare-owned/compare-chunks live receipts.
Its exact-image binding correctly prevents using a chunks-image broad result as
qualification of the nine-effect image. A small evidence-input adapter for the
new eight-gate schema is required before the nine-effect broad run. It must not
relax exact image identity, independent oracle bindings or the 45-point set.

Expected implementation is a short wrapper plus one focused authentication
module and a sealed data manifest; no second copy of process supervision or
publication logic. No claim of native B2, full-language conformance, user-program
runtime gains or universal module support follows from this admission.
