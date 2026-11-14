#!/usr/bin/env python3
"""Offline lexical source-name grouping of authenticated pooled physical leaves."""
import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/profiler'))
from compare import pin, Reader


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--comparison', type=Path, required=True)
    p.add_argument('--roles', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    reader = Reader()
    comparison = reader.read(pin(a.comparison))
    roles = reader.read(pin(a.roles))
    source_pin = roles['roles']['qbe_n1']['compilerSource']
    source = reader.verify(source_pin).read_bytes()
    source_map_path = Path(source_pin['file']).with_name('source-map.json')
    source_map = reader.read(pin(source_map_path))
    declarations = {r['name']: r for r in source_map}
    result = dict(complete=True, targetsRun=False, comparison=pin(a.comparison),
        source=source_pin, sourceMap=pin(source_map_path), roles={},
        scope='Physical leaf estimates grouped by decoded symbol spelling; no inclusive '
              'caller attribution or reconstructed source owner. Recognized direct/borrow '
              'wrapper prefixes are stripped only for lexical declaration-name lookup. '
              'Anonymous/generated names remain separate. Declared source spans are byte checked.')
    for role, value in comparison['workloads']['test-map-set-ops'].items():
        profile = value['profile']
        groups = defaultdict(lambda: dict(samples=0, fraction=0., estimatedCpuSeconds=0., symbols=[]))
        for leaf in profile['functions']:
            decoded = leaf['decoded']
            match = re.match(r'^p\w+_FID_\$(?:direct\.|p118borrow\.read\.|p128borrow\.owned\.)(.+)$', decoded)
            name = match.group(1) if match else None
            declaration = declarations.get(name)
            if declaration:
                physical = ROOT/'selfhost'/declaration['file']
                physical_data = physical.read_bytes()
                start, offset, count = (declaration[k] for k in ('sourceByte', 'generatedByte', 'bytes'))
                if physical_data[start:start+count] != source[offset:offset+count]:
                    raise ValueError('Source map span mismatch: '+name)
                reader.verify(pin(physical))
                group = 'source-name:'+name
            elif match:
                group = 'lowered-name:'+name
            elif '_FID_' in decoded:
                group = 'unassigned-generated'
            else:
                group = 'physical:'+decoded
            row = groups[group]
            row['samples'] += leaf['samples']
            row['fraction'] += leaf['periodWeightedFraction']
            if profile['estimateAvailable']:
                row['estimatedCpuSeconds'] += leaf['estimatedCleanCpuSeconds']
            else:
                row['estimatedCpuSeconds'] = None
            row['symbols'].append(decoded)
            if declaration:
                row['sourceLocation'] = {k:declaration[k] for k in ('file', 'sourceLine', 'name')}
        ranked = [dict(name=k, **v) for k,v in sorted(groups.items(), key=lambda kv:-kv[1]['fraction'])]
        result['roles'][role] = dict(clean=value['clean'], adequate=profile['adequate'],
            samples=profile['samples'], rejected=profile['rejectedCaptures'],
            estimateAvailable=profile['estimateAvailable'],
            unknownFraction=profile['unknownPeriodWeightedMicroseconds']/profile['periodWeightedMicroseconds'],
            samplingOverCleanWallRatio=value['sampledOverCleanWallRatio'],
            physicalLeaves=profile['functions'], lexicalGroups=ranked)
    result['evidence'] = list(reader.identities.values())
    with a.out.open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    for role, row in result['roles'].items():
        print(role)
        for group in row['lexicalGroups'][:18]:
            print(f"  {group['fraction']*100:.2f}% {group['estimatedCpuSeconds']:.4f}s {group['name']}")


if __name__ == '__main__':
    main()
