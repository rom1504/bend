# Pinned JavaScript effect sources

These 37 `.js` files are copied byte-for-byte from `bend2/effs/` at
[commit `018751270e800bc222a93dad7f257083ee53a5f7`](https://github.com/rom1504/bend/tree/018751270e800bc222a93dad7f257083ee53a5f7/bend2/effs).
The authors and Apache-2.0 license of that upstream repository apply; its
unchanged license is included as `LICENSE`. `manifest.json` binds every source
path, byte count, and SHA256. No effect implementation is adapted here.

The direct driver maps only the 37 listed imports beside its selected Base file
under `effs/`, after verifying that Base content has the exact pinned SHA256 in
`manifest.json`. A custom `BEND_BASE`, user effect paths, and unlisted filenames
keep their ordinary resolution; missing original files fail explicitly. The shared
Bend foreign scanner receives the original import path and performs the pinned
CID/FID namespace substitutions; acquisition receipts record the actual vendored
files read. Release inventories retain this entire directory.

This copy removes the installed release's dependency on an upstream checkout.
It does not change the pinned effects' platform requirements: some syscall,
socket, audio, and window paths still require their upstream host facilities.
