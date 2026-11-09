# Phase183 — maintained assembly target

In progress. [Design](../../design/phase183/README.md). The installed release
remains Phase182 until the new target passes independent qualification and
promotion. Upstream remains2.0.40 (`9a4223d`).

The maintained `x86` profile assembles1,416,804 bytes/4,281 declarations,
SHA256 `49409f730473d87b03e378ffbcfb999ffcf083a68baa707f2de65e3585a52455`.
[Independent upstream checking](evidence/source-check01.json) accepts it with
zero holes in5.275s. This is source acceptance, not a kernel proof or backend
qualification. The five earlier source profiles remain byte-identical.

The existing driver/profile, runtimeABI and benchmark/profiler integration is
being qualified through ordinary maintained tools. No target performance claim
or installed assembly selection is made at this checkpoint.

To preserve the5GiB reserve, eight explicit immutable Phase182 generated-product
pairs were compared byte-for-byte and hardlinked. All paths, contents and modes
remain available; installed images, runtime objects, receipts and sources were
untouched. The [journal](evidence/equal-products.json) records584,200,192 bytes of
observed filesystem recovery. Future builds must use fresh paths rather than
mutating these linked products in place.
