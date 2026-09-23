# Final release documentation checks

`link-audit.py` checks inline local Markdown file/directory links in documents
changed since the consolidated release commit `d5a7bd8`, current untracked
Markdown, and the named user-facing entry points. The JSON records the exact
source hashes and every target. It does not check URL availability, anchors,
HTML links or language/compiler correctness. `links-01.json` is the earlier
checkpoint; `links-final.json` is the final document snapshot.

From the repository root, reproduce into a new report path:

```sh
python3 implementation/phase5/release-doc-evidence/link-audit.py /tmp/bend-links-NEW.json
```

[Independent review](../../phase6/final-release-doc-review.md) separately covers
artifact boundaries, measured versus proposed gains, current versus historical
backend claims, and the failed H graph gate versus successful checked core output.
The [source recount](../code-size.md) has its own explicit file boundary. These
are documentation/static checks; they do not rerun compiler or timing gates.
