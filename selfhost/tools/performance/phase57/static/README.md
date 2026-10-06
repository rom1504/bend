# Saved compiler-image inventory

`code-shapes.json.gz` is the complete lossless inventory. The uncompressed copy
is ignored because it duplicates the same 8.1 MB of data. Restore it before
running the profile joiner:

```sh
gzip -dk selfhost/tools/performance/phase57/static/code-shapes.json.gz
```

`summary.json` and `representative-bodies.md` are the compact readable views.
`code-shapes.mjs` only parses saved image bytes; it does not execute compiler code.
See the [findings](../../../../../implementation/phase57/code-shapes.md).
