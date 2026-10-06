# Closed Phase58 evidence

The archive contains 30,169 files from the closed Phase58 campaign,
1,303,364,859 uncompressed bytes, including failed and held experiments. The
archive producer reopened it and verified every member hash. `archive.json`
remains unchanged; `transport.json` lists the three exact ordered parts.

Reconstruct in a separate location, never over the closed original:

```sh
cat raw-campaign.tar.gz.part-000 raw-campaign.tar.gz.part-001 raw-campaign.tar.gz.part-002 > /tmp/phase58-replay.tar.gz
sha256sum /tmp/phase58-replay.tar.gz
# f8328b53c8d11d5a177c9bb034cff8d719ee25df1bbc8d0ef453fcd84e643144
mkdir -p /tmp/phase58-replay
tar -xzf /tmp/phase58-replay.tar.gz -C /tmp/phase58-replay
```

The publication index independently verifies concatenated transport bytes.
Original absolute paths identify the measured run; restore in a separate matching
checkout with pinned inputs for replay. Archive verification executes no targets.
The local unsplit transport copy is retained outside the repository under /tmp.
