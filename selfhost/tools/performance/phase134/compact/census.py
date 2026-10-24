"""Metadata-only ceiling for map-free local-name token shortening; no targets."""
from collections import Counter
from pathlib import Path
import hashlib, json, re

ROOT = Path(__file__).resolve().parents[5]
SOURCE = ROOT / 'selfhost/build/phase130/p131-final-self01/program.ssa'
EXPECTED = 'f3ff63b04b58e5a5b92be781d0d1cba8cc574a37765cbf66d817c3d38f4b576e'
rules = [b'p112f_', b'p114t_', b'p113i_', b'p113p_', b'local_',
         b'capture_', b'move_', b'result_', b'match_', b'next_']
counts = Counter()
pattern = re.compile(rb'%v_([A-Za-z_.$][A-Za-z0-9_.$]*)')
sha = hashlib.sha256()
size = 0
with SOURCE.open('rb') as stream:
    for line in stream:
        # Frozen Phase132 lexical census independently established both zero.
        # Refuse a different lexical scope instead of matching inside strings.
        assert b'"' not in line and b'#' not in line
        sha.update(line)
        size += len(line)
        counts.update(pattern.findall(line))
assert sha.hexdigest() == EXPECTED
rows = [dict(atom=atom.decode(), occurrences=sum(name.count(atom)*n for name,n in counts.items()),
             originalBytes=len(atom), hypotheticalBytes=2) for atom in rules]
for row in rows:
    row['optimisticBytesRemoved'] = row['occurrences']*(row['originalBytes']-row['hypotheticalBytes'])
saved = sum(row['optimisticBytesRemoved'] for row in rows)
result = dict(complete=True, targetsRun=False, compilerChanges=False,
    source=dict(file=str(SOURCE), bytes=size, sha256=EXPECTED),
    method=dict(file=str(Path(__file__).resolve()), sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()),
    localPayloadOccurrences=sum(counts.values()), distinctLocalPayloads=len(counts),
    localPayloadBytes=sum(len(name)*n for name,n in counts.items()), rules=rows,
    optimisticBytesRemoved=saved, optimisticWholeTextReduction=saved/size,
    scope='Optimistic spelling ceiling only. Does not pay escape-marker, reserved-name or '
          'Bend scan/reconstruction costs. No encoding implementation, collision proof, speedup '
          'or eligibility claim. Dense per-function-ID Phase132 bound is a different algorithm.')
print(json.dumps(result, indent=2))
