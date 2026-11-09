#!/usr/bin/env python3
"""Deduplicate two generated text products of one completed Phase186 chain.

Default is read-only preflight. --apply requires a fresh retention output.
QBE: n1/program.ssa and q3/program.ssa share n2/program.ssa.
x86: n1/program.s and s3/program.s share n2/program.s.
No executable, object, source, installed image or receipt is replaced.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
# Phase185 authentication policy adapted only to Phase186 paths; the original
# mutation engine remains unchanged and is pinned below.
PARENT_METHOD = dict(file=str(ROOT/'selfhost/tests/phase185/deduplicate-chain.py'),
                     bytes=7989, sha256='106ce6b99f8e8859d0189ed022896d7d03e40df409707e7f7c4f62afa19e195b')
ENGINE_SHA256 = 'ec2f447a483a7a28ad851ceae42f10d3310580f92a90e45d4ab65f3378fb3311'
spec = importlib.util.spec_from_file_location('phase185_immutable', ROOT/'selfhost/tests/phase185/deduplicate-immutable.py')
D = importlib.util.module_from_spec(spec); spec.loader.exec_module(D)
A = D.A


def preflight(chain):
    chain = chain.absolute()
    A.need(chain.resolve() == chain and chain.parent == ROOT/'selfhost/build/phase186',
           'Explicit direct Phase186 chain directory required')
    inputs = {}

    def authenticate(pin):
        A.need(set(pin) == {'file', 'bytes', 'sha256'}, 'Exact file identity required')
        previous = inputs.get(pin['file'])
        A.need(previous is None or previous == pin, 'Conflicting authenticated input')
        if previous is None:
            A.authenticate(pin)
            inputs[pin['file']] = pin
        return Path(pin['file'])

    def report(pin, expected):
        A.need(pin['file'] == str(expected), 'Generation report outside explicit chain')
        return json.loads(authenticate(pin).read_text())

    authenticate(PARENT_METHOD)
    A.need(A.pin(D.__file__)['sha256'] == ENGINE_SHA256, 'Frozen immutable engine changed')
    for path in (__file__, D.__file__, A.__file__): authenticate(A.pin(path))
    receipt = report(A.pin(chain/'report.json'), chain/'report.json')
    A.need(receipt.get('kind') == 'bend-native-bootstrap-chain' and receipt.get('version') == 1
           and receipt.get('complete') is True and receipt.get('changedInputs') == []
           and receipt.get('producerHost') == 'native', 'Completed unchanged native chain required')
    target = receipt.get('target')
    A.need(target in {'qbe', 'x86'}, 'Explicit QBE or x86 bootstrap target required')
    emitted, final, fixed = (('program.ssa', 'Q3', 'qbeFixedPoint') if target == 'qbe'
                             else ('program.s', 'S3', 'assemblyFixedPoint'))
    A.need(receipt.get(fixed) is True and receipt.get('machineIdentity', {}).get(emitted) is True,
           'Both generation identity and emission fixed point required')
    generations = receipt.get('generations', [])
    A.need([g.get('stage') for g in generations] == ['N1', 'N2', final]
           and all(g.get('complete') is True for g in generations), 'Exactly three complete generations required')
    A.need(isinstance(receipt.get('inputs'), list) and receipt['inputs'], 'Pinned chain inputs required')
    for pin in receipt['inputs']: authenticate(pin)
    for key in ('source', 'producer'): authenticate(receipt[key])

    protected = []
    selector = A.pin(ROOT/'selfhost/manifests/current.json')
    installed = json.loads(authenticate(selector).read_text())
    A.need(set(installed.get('components', {})) == {'qbe', 'js', 'nativeCli', 'x86'}
           and installed.get('gateStatus', {}).get('qualified') is True, 'Qualified installed selector required')
    protected.append(authenticate(selector))
    for row in installed['files'].values(): protected.append(authenticate(D.bound(row)))
    products = {}
    for generation in generations:
        stage = generation['stage']
        directory = chain/stage.lower()
        details = report(generation['report'], directory/'report.json')
        native_build = stage in {'N1', 'N2'}
        A.need(details.get('kind') == ('bend-native-build' if native_build else 'bend-build-request')
               and details.get('version') == 1 and details.get('complete') is True
               and details.get('changedInputs') == [] and details.get('target') == target
               and details.get('host') == 'native', 'Generation receipt is incomplete, changed or mismatched')
        A.need(isinstance(details.get('inputs'), list) and details['inputs'], 'Pinned generation inputs required')
        for pin in details['inputs']: authenticate(pin)
        if native_build:
            A.need(details.get('retainIR') is True, 'Retained native generation text required')
            product = details['retainedIR' if target == 'qbe' else 'assembly']
            binary = details['binary']
            A.need(binary['file'] == str(directory/'program'), 'Unexpected native image path')
            protected.append(authenticate(binary))
        else:
            A.need(details.get('byteExact') is True, 'Exact final emission required')
            product = details['product']
        A.need(product['file'] == str(directory/emitted), 'Product outside explicit generation text path')
        authenticate(product)
        products[stage] = product

    protected_inodes = {(path.stat().st_dev, path.stat().st_ino) for path in protected}
    canonical = Path(products['N2']['file'])
    cm = A.metadata(canonical)  # All three initial inodes must be exclusive.
    A.need(not cm['mode'] & 0o111, 'Generated text must not be executable')
    pairs = []
    for stage in ('N1', final):
        duplicate = Path(products[stage]['file'])
        dm = A.metadata(duplicate)
        A.need(cm['device'] == dm['device'] and cm['inode'] != dm['inode']
               and all(cm[key] == dm[key] for key in ('mode', 'uid', 'gid')), 'File identity or metadata mismatch')
        A.need((cm['device'], cm['inode']) not in protected_inodes
               and (dm['device'], dm['inode']) not in protected_inodes, 'Protected image inode must remain independent')
        A.need(all(products['N2'][key] == products[stage][key] for key in ('bytes', 'sha256'))
               and D.same_bytes(canonical, duplicate), 'Generated products differ')
        A.need(A.metadata(canonical) == cm and A.metadata(duplicate) == dm, 'Products changed during preflight')
        def relative(pin):
            return dict(pin, file=str(Path(pin['file']).relative_to(ROOT)))
        pairs.append(dict(group=target+'-complete-chain-text', canonical=relative(products['N2']),
                          duplicate=relative(products[stage]), canonicalMetadata=cm, duplicateMetadata=dm))
    A.need(pairs[0]['duplicateMetadata']['inode'] != pairs[1]['duplicateMetadata']['inode'], 'Repeated recipient inode')
    plan = dict(kind='phase186-complete-chain-text-pairs', version=1, complete=True,
                chain=str(chain), target=target, pairs=pairs,
                allocatedRecipientBytes=sum(row['duplicateMetadata']['allocatedBytes'] for row in pairs),
                scope='Exactly two completed same-chain generated text recipients. Every path and byte remains; ELF, object, source, installed selections and receipts stay independent. Future builds must use fresh paths.')
    for pin in inputs.values(): A.authenticate(pin)
    return plan, list(inputs.values())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--chain', type=Path, required=True)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--out', type=Path)
    args = parser.parse_args()
    if args.apply and args.out is None: parser.error('--apply requires --out')
    if args.out is not None:
        out = args.out.absolute()
        A.need(out.resolve() == out and out.parent == ROOT/'selfhost/build-retention/phase186',
               'Fresh direct Phase186 retention output required')
    with A.exclusive():
        plan, inputs = preflight(args.chain)
        result = D.apply(args.out, plan, inputs) if args.apply else dict(
            complete=True, planOnly=True, chain=plan['chain'], target=plan['target'],
            pairs=len(plan['pairs']), allocatedRecipientBytes=plan['allocatedRecipientBytes'],
            inputs=inputs, plan=plan)
    print(json.dumps(result, indent=2))
    return 0 if result['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
