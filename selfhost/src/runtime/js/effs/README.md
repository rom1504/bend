# Pinned JavaScript effect sources

These 36 `.js` files are copied byte-for-byte from `bend2/effs/` at
[commit `9a4223d577ba56a0cb53d1fd952d2b481c38930f`](https://github.com/bendlang/bend/tree/9a4223d577ba56a0cb53d1fd952d2b481c38930f/bend2/effs).
The authors and Apache-2.0 license of that upstream repository apply; its
unchanged license is included as `LICENSE`. `manifest.json` binds every source
path, byte count, and SHA256. No effect implementation is adapted here.

The direct driver maps only the 36 listed imports beside its selected Base file
under `effs/`, after verifying that Base content has the exact pinned SHA256 in
`manifest.json`. A custom `BEND_BASE`, user effect paths, and unlisted filenames
keep their ordinary resolution; missing original files fail explicitly. The shared
Bend foreign scanner receives the original import path; compiler emission
resolves constructor CID and qualified definition CID/FID identities. Acquisition
receipts record the actual vendored files read. Release inventories retain this
entire directory.

This copy lets a packaged direct JS provider operate without an upstream checkout.
It does not establish that an installed release selects these new provider bytes.
It does not change the pinned effects' platform requirements: some syscall,
socket, audio, and window paths still require their upstream host facilities.

The pinned Base defines `Poll` and `try_` operations for channels, TCP, and UDP.
The blocking and timed variants share their registered JavaScript providers;
`tcp_poll.js` and `udp_poll.js` belong to the previous upstream version and are
not in this inventory. Provider bytes and the IO runtime must use the same pin.
