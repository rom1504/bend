#!/usr/bin/env python3
"""Falsify reference substitutions without executing any compiler or program."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import tempfile

spec = importlib.util.spec_from_file_location('p134_plan', Path(__file__).with_name('plan.py'))
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--reference', type=Path, required=True)
    a = ap.parse_args(); P.reference(a.reference); original = P.read(a.reference)
    mutations = [
        ('wrong parent', lambda x: x.update(measuredN2=x['qualifiedFallbackN3'])),
        ('wrong carrier', lambda x: x.update(carrierReceipt=x['inputs'][0])),
        ('wrong corpus', lambda x: x['cases'].reverse()),
        ('wrong request product', lambda x: x['cases'][0].update(expectedQbe=x['cases'][1]['expectedQbe'])),
        ('wrong wrapper product', lambda x: x['wrappers'][0].update(expectedQbe=x['wrappers'][1]['expectedQbe'])),
    ]
    results = []
    with tempfile.TemporaryDirectory(prefix='p134-metadata-') as directory:
        for name, mutate in mutations:
            changed = copy.deepcopy(original); mutate(changed)
            path = Path(directory) / 'reference.json'; path.write_text(json.dumps(changed))
            try: P.reference(path)
            except ValueError as error: results.append(dict(name=name, rejected=True, reason=str(error)))
            else: raise ValueError('Incorrectly accepted ' + name)
    print(json.dumps(dict(complete=True, targetsRun=False, negativeControls=results)))


if __name__ == '__main__': main()
