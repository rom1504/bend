#!/usr/bin/env python3
"""Apply only the explicitly reviewed Phase193 sealed generated-assembly tranche."""
import argparse
import importlib.util
import json
import shutil
from pathlib import Path

R = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('close', R/'selfhost/tools/build-retention/close.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
A = C.A
OUT = R/'selfhost/build/phase193/retention-apply03'
PROPOSAL = R/'implementation/phase193/retention-plan03.json'
PROPOSAL_SHA = '0723e11351e9b445cba7222d0068b4e461f47cc28f28c91091743965e0cfea6e'


class Budget(C.Budget):
    def check(self, *, additional=0, force=False):
        A.need(shutil.disk_usage(R).free >= 5*1024**3 + additional,
               'Preserve5GiB reserve plus bounded scratch')
        super().check(additional=additional, force=force)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--approved-proposal-sha256', required=True)
    args = parser.parse_args()
    proposal_pin = A.pin(PROPOSAL)
    A.need(args.approved_proposal_sha256 == PROPOSAL_SHA == proposal_pin['sha256'],
           'Reviewed exact proposal identity required')
    proposal = json.loads(A.authenticate(proposal_pin).read_text())
    with A.exclusive():
        A.need(not OUT.exists(), 'Fresh output required')
        budget = Budget()
        budget.check(force=True)
        rows = [item for batch in proposal['roots'] for item in batch['files']]
        protected = [proposal_pin, *proposal['protectedSelectors'], *proposal['protectedSources'],
                     *proposal['methods'], *proposal['sourceEvidence'],
                     *[item['completionReceipt'] for item in rows],
                     *[r['lifecycle'] for r in proposal['roots']],
                     *[r['closure'] for r in proposal['roots']]]
        critical = [proposal_pin, *proposal['protectedSelectors'], *proposal['methods'], *proposal['sourceEvidence'],
                    *[r['lifecycle'] for r in proposal['roots']],
                    *[r['closure'] for r in proposal['roots']],
                    *[item['completionReceipt'] for item in rows]]
        for pin in protected:
            A.authenticate(pin)
        for item in rows:
            receipt = json.loads(Path(item['completionReceipt']['file']).read_text())
            A.need(all(receipt[k] == v for k, v in item['completedFlags'].items()),
                   'Completion flags changed')
            p = A.authenticate(item['file'])
            A.need(A.metadata(p) == item['metadata'], 'Selected identity/metadata changed')
        before = shutil.disk_usage(R).free
        lock_inode = A.LOCK.stat().st_ino
        A.write_new(OUT/'intent.json', dict(kind='phase193-generated-assembly-archive-prune-intent', complete=True,
            proposal=proposal_pin, method=A.pin(__file__), protectedPins=protected,
            freeBeforeBytes=before, lockInode=lock_inode, roots=proposal['roots']))
        result = dict(kind='phase193-generated-assembly-retention-result', complete=False, roots=[],
                      intent=A.pin(OUT/'intent.json'), freeBeforeBytes=before)
        try:
            for index, batch in enumerate(proposal['roots']):
                for pin in critical:
                    A.authenticate(pin)
                root = Path(batch['root'])
                chosen = batch['files']
                identities = list({pin['file']: pin for item in chosen for pin in
                                   [item['file'], item['completionReceipt']]}.values())
                inventory = []
                for identity in identities:
                    p = A.authenticate(identity)
                    inventory.append(dict(path=p, name=str(p.relative_to(root)),
                        signature=C.signature(p),
                        identity={k: identity[k] for k in ['bytes', 'sha256']}))
                capsule = OUT/f'root-{index:02d}'
                receipt = C.capsule(root, inventory, capsule, budget)
                policy = dict(allowedRoots=[str(root.relative_to(R))],
                    archiveRoots={str(receipt.relative_to(R)): str(root.relative_to(R))},
                    keepPrefixes=batch['keepPrefixes'])
                A.write_new(capsule/'policy.json', policy)
                verified = A.verify(argparse.Namespace(policy=capsule/'policy.json',
                    receipt=receipt, out=capsule/'verified'))
                planned = list(A.plan_files(verified))
                A.need({x['file']['file'] for x in planned} ==
                       {x['file']['file'] for x in chosen}, 'Only reviewed generated intermediates may be pruned')
                if index == 0:
                    item = planned[0]
                    budget.check(additional=item['file']['bytes'], force=True)
                    restored = A.restore(argparse.Namespace(plan=capsule/'verified/plan.json',
                        member=[item['member']], destination=OUT/'restore-witness',
                        out=OUT/'restore-witness-receipt'))
                    witness_path = OUT/'restore-witness'/item['relative']
                    witness = A.pin(witness_path)
                    A.need(restored['complete'] and restored['restored'] == 1 and
                           all(witness[k] == item['file'][k] for k in ['bytes', 'sha256']) and
                           A.metadata(witness_path)['mode'] == item['metadata']['mode'],
                           'Full assembly restore witness failed')
                    result['restoreWitness'] = dict(file=witness, source=item['file'],
                        receipt=A.pin(OUT/'restore-witness-receipt/report.json'))
                for pin in critical:
                    A.authenticate(pin)
                budget.check(force=True)
                applied = A.apply(argparse.Namespace(plan=capsule/'verified/plan.json',
                                                     out=capsule/'applied'))
                A.need(applied['complete'] and applied['removedFiles'] == len(chosen),
                       'Incomplete exact prune')
                archive_receipt = json.loads(receipt.read_text())
                result['roots'].append(dict(root=str(root), batch=batch['batch'],
                    removedFiles=len(chosen), allocatedBytes=verified['allocatedBytes'],
                    archiveBytes=archive_receipt['archive']['bytes'], archiveReceipt=A.pin(receipt),
                    plan=A.pin(capsule/'verified/plan.json'),
                    apply=A.pin(capsule/'applied/report.json')))
                budget.check(force=True)
                print(json.dumps(dict(batch=batch['batch'], removedFiles=len(chosen),
                                      freeBytes=shutil.disk_usage(R).free)), flush=True)
            for pin in protected:
                A.authenticate(pin)
            A.need(A.LOCK.stat().st_ino == lock_inode, 'Shared lock changed')
            result['complete'] = True
        finally:
            result.update(removedFiles=sum(x['removedFiles'] for x in result['roots']),
                selectedAllocatedBytes=sum(x['allocatedBytes'] for x in result['roots']),
                compressedArchiveBytes=sum(x['archiveBytes'] for x in result['roots']),
                freeAfterBytes=shutil.disk_usage(R).free, minimumFreeBytes=budget.minimum,
                lockInode=A.LOCK.stat().st_ino, noTargetJobs=True, scope=proposal['scope'],
                recovery='Byte-exact local archives with full assembly restoration witness; not an independent backup.')
            result['observedRecoveryBytes'] = result['freeAfterBytes'] - before
            A.write_new(OUT/'report.json', result)
        print(json.dumps({k: result[k] for k in ['complete', 'removedFiles',
            'selectedAllocatedBytes', 'compressedArchiveBytes', 'observedRecoveryBytes',
            'freeAfterBytes', 'minimumFreeBytes']}), flush=True)


if __name__ == '__main__':
    main()
