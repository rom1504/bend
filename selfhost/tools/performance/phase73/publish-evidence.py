#!/usr/bin/env python3
"""Split the already verified archive into 32MiB pieces, preserving every byte."""
from pathlib import Path
import hashlib, json

HERE = Path(__file__).resolve().parent
OUT = HERE / 'evidence01'
archive = OUT / 'evidence.zip'
verified = json.loads((OUT / 'verification.json').read_text())
assert verified['complete'] and verified['inputsUnchanged']
parts, joined, size = [], hashlib.sha256(), 0
with archive.open('rb') as stream:
    while data := stream.read(32 * 1024 * 1024):
        dest = OUT / f'evidence.zip.part-{len(parts) + 1:03d}'
        with dest.open('xb') as output:
            output.write(data)
        observed = dest.read_bytes()
        assert observed == data
        parts.append(dict(file=dest.name, bytes=len(data),
                          sha256=hashlib.sha256(observed).hexdigest()))
        joined.update(observed)
        size += len(observed)
assert size == verified['archiveBytes']
assert joined.hexdigest() == verified['archiveSha256']
result = dict(complete=True, archiveBytes=size,
              archiveSha256=joined.hexdigest(), parts=parts,
              methodSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              scope='Concatenate parts in listed order to restore the exact verified ZIP. '
                    'This publication method runs after sealing and is tracked separately.')
dest = OUT / 'publication.json'
with dest.open('x') as output:
    output.write(json.dumps(result, indent=2) + '\n')
# All bytes remain durably represented by the verified pieces and original raw.
archive.unlink()
print(json.dumps(dict(parts=len(parts), bytes=size, sha256=joined.hexdigest())))
