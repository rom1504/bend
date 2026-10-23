#!/usr/bin/env python3
"""Freeze user-supplied workloads and independent output oracles; execute nothing."""
import argparse
import json
from pathlib import Path

from run import pin, save


def freeze(recipe, recipe_path):
    cwd = Path(recipe['cwd']).resolve()
    def path(value):
        p = Path(value)
        return p.resolve() if p.is_absolute() else (cwd/p).resolve()
    result = dict(schema='bend-native-profile-workloads-v1', cwd=str(cwd),
                  scope=recipe.get('scope'), inputs=[pin(recipe_path)], workloads=[])
    for key in ('sampler', 'unwindTable'):
        if recipe.get(key):
            result[key] = pin(path(recipe[key]))
    result['inputs'].extend(pin(path(p)) for p in recipe.get('inputs', []))
    seen = set()
    for workload in recipe['workloads']:
        if workload['name'] in seen:
            raise ValueError('Duplicate workload name')
        seen.add(workload['name'])
        row = dict(name=workload['name'], timeoutSeconds=workload.get('timeoutSeconds', 30), variants=[])
        variants = set()
        for variant in workload['variants']:
            if variant['name'] in variants:
                raise ValueError('Duplicate variant name')
            variants.add(variant['name'])
            command = list(variant['command']); command[0] = str(path(command[0]))
            expected = dict(exitCode=variant.get('exitCode', 0))
            for channel in ('stdout', 'stderr'):
                oracle = variant[channel]
                if isinstance(oracle, str):
                    expected[channel] = dict(kind='exact', **pin(path(oracle)))
                elif oracle.get('kind') == 'prefix-integer-line' and channel == 'stdout':
                    # Prefix is supplied independently, never learned from a target run.
                    expected[channel] = dict(oracle)
                    if 'evidence' in oracle:
                        expected[channel]['evidence'] = pin(path(oracle['evidence']))
                else:
                    raise ValueError('Expected oracle path or explicit stdout elapsed-line contract')
            row['variants'].append(dict(name=variant['name'], command=command,
                binary=pin(command[0]), expected=expected,
                dispatchInstrumentation=bool(variant.get('dispatchInstrumentation', False)),
                inputs=[pin(path(p)) for p in variant.get('inputs', [])]))
        if not row['variants']:
            raise ValueError('Workload has no variants')
        result['workloads'].append(row)
    if not result['workloads']:
        raise ValueError('Recipe has no workloads')
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--recipe', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    if a.out.exists():
        raise ValueError('Fresh manifest path required')
    manifest = freeze(json.loads(a.recipe.read_text()), a.recipe)
    save(a.out, manifest)
    print(json.dumps(dict(manifest=pin(a.out), workloads=len(manifest['workloads']), targetsRun=False)))


if __name__ == '__main__':
    main()
