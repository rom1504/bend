#!/usr/bin/env python3
"""Resume an interrupted exact-dedup proposal with append-only progress receipts.

Only already-reviewed proposal pairs are admitted. No path or unique bytes are
deleted. The previous applier must have stopped; its report is preserved.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import time
import uuid

ROOT = Path(__file__).resolve().parents[4]
METHOD = ROOT / 'selfhost/tools/performance/phase112/apply-dedup.py'
spec = importlib.util.spec_from_file_location('exact_dedup112', METHOD)
D = importlib.util.module_from_spec(spec)
spec.loader.exec_module(D)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--proposal', type=Path, required=True)
    ap.add_argument('--previous-report', type=Path, required=True)
    ap.add_argument('--previous-stopped-exit-code', type=int,
                    help='Coordinator-attested termination status if interrupt prevented the prior final save')
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    proposal = json.loads(a.proposal.read_text())
    previous = json.loads(a.previous_report.read_text())
    if not proposal.get('complete') or proposal.get('mutationsPerformed'):
        raise ValueError('Read-only completed proposal required')
    if not previous.get('finished') and a.previous_stopped_exit_code not in (130, -2):
        raise ValueError('Previous applier has no stopped/completed receipt')
    if previous.get('kind') != 'phase112-exact-generated-artifact-hardlink-dedup' or previous.get('methodSha256') != D.digest(METHOD):
        raise ValueError('Unexpected previous applier identity')
    if previous['proposal']['sha256'] != D.digest(a.proposal):
        raise ValueError('Previous applier used a different proposal')
    out = a.out.absolute()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase131') or out != out.resolve():
        raise ValueError('Fresh non-symlink Phase131 output required')
    paths = [r['file'] for g in proposal['groups'] for r in [g['keep'], *g['duplicates']]]
    if len(paths) != len(set(paths)):
        raise ValueError('Duplicate proposal paths')
    inputs = [dict(file=str(p.resolve()), sha256=D.digest(p))
              for p in [a.proposal, a.previous_report, METHOD, Path(__file__)]]
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    report = dict(kind='phase131-journaled-exact-artifact-dedup', complete=False,
                  started=time.time(), inputs=inputs, preflightComplete=False,
                  priorTermination=dict(receiptFinished=previous.get('finished'),
                                        coordinatorAttestedExitCode=a.previous_stopped_exit_code,
                                        scope='External owned-session cancellation; previous receipt preserved. Actual paths independently reconciled before resume.'),
                  alreadySharedPaths=0, remainingPaths=0, replacements=0,
                  recoveredAllocatedBytes=0, priorRecoveredAllocatedBytes=previous.get('recoveredAllocatedBytes', 0),
                  policy='Exact reviewed pairs only; original Phase112 checks retained. '
                  'Append-only pending/complete records replace repeated whole-history rewrites. '
                  'Paths, bytes, permissions, owners and xattrs preserved. No unique content deletion.')

    def save():
        temporary = out / 'report.json.tmp'
        temporary.write_text(json.dumps(report, indent=2) + '\n')
        temporary.replace(out / 'report.json')

    def pin(row):
        p = D.checked_path(row)
        before = D.identity(p)
        sha = D.digest(p)
        if before != D.identity(p) or sha != row['sha256']:
            raise ValueError('Artifact changed: ' + str(p))
        return p, dict(before, sha256=sha)

    save()
    try:
        remaining = []
        already_shared = []
        # Every proposed pair is preflighted before any replacement. Completed
        # destinations must share the authenticated keeper inode, not merely hash.
        for group in proposal['groups']:
            keep, ks = D.verify(group['keep'])
            if group['sha256'] != group['keep']['sha256']:
                raise ValueError('Keeper/group hash mismatch')
            attrs = D.attributes(keep)
            for original in group['duplicates']:
                path, now = pin(original)
                if (now['device'], now['mode'], now['uid'], now['gid'], now['bytes']) != (
                        ks['device'], ks['mode'], ks['uid'], ks['gid'], ks['bytes']):
                    raise ValueError('Metadata mismatch: ' + str(path))
                if D.attributes(path) != attrs or group['sha256'] != original['sha256']:
                    raise ValueError('Group or extended attributes differ')
                if now['inode'] == ks['inode']:
                    already_shared.append(dict(file=original['file'], keeper=group['keep']['file'],
                                               original=original, current=now))
                    continue
                if now['hardlinks'] != 1:
                    raise ValueError('Remaining destination is not independently reclaimable')
                for key in ['device', 'inode', 'bytes', 'mode', 'uid', 'gid', 'mtimeNs']:
                    if now[key] != original[key]:
                        raise ValueError('Unfinished destination identity changed: ' + str(path))
                remaining.append(dict(keep=group['keep'], original=now, sha256=group['sha256']))
        # Fresh explicit remaining proposal is preserved before mutation.
        fresh_groups = {}
        for row in remaining:
            key = row['keep']['file']
            fresh_groups.setdefault(key, dict(keep=row['keep'], sha256=row['sha256'], duplicates=[]))['duplicates'].append(row['original'])
        (out / 'remaining-proposal.json').write_text(json.dumps(dict(
            complete=True, mutationsPerformed=False, groups=list(fresh_groups.values())), indent=2) + '\n')
        (out / 'already-shared.json').write_text(json.dumps(already_shared, indent=2) + '\n')
        report.update(preflightComplete=True, alreadySharedPaths=len(already_shared), remainingPaths=len(remaining),
                      observedAlreadySharedAllocatedBytes=sum(r['original']['allocatedBytes'] for r in already_shared))
        save()
        with (out / 'replacements.jsonl').open('x') as journal:
            def record(value):
                journal.write(json.dumps(value, separators=(',', ':')) + '\n')
                journal.flush()

            for index, row in enumerate(remaining):
                keep, unused = D.verify(row['keep'])
                path, before = D.verify(row['original'])
                source = D.identity(keep)
                if source['inode'] != row['keep']['inode'] or before['hardlinks'] != 1:
                    raise ValueError('Source or destination identity changed')
                if D.attributes(keep) != D.attributes(path):
                    raise ValueError('Extended attributes changed')
                temporary = path.with_name(path.name + '.p131-link-' + uuid.uuid4().hex)
                event = dict(index=index, source=source, original=before, sha256=row['sha256'],
                             temporary=str(temporary.relative_to(ROOT)), status='pending')
                record(event)
                linked_created = False
                try:
                    os.link(keep, temporary, follow_symlinks=False)
                    linked_created = True
                    linked = D.identity(temporary)
                    if linked['inode'] != source['inode'] or D.digest(temporary) != row['sha256']:
                        raise ValueError('Temporary hardlink mismatch')
                    if D.identity(path) != before:
                        raise ValueError('Destination changed before atomic replacement')
                    os.replace(temporary, path)
                    after = D.identity(path)
                    if after['inode'] != source['inode'] or D.digest(path) != row['sha256']:
                        raise ValueError('Replacement verification failed')
                    record(dict(index=index, status='complete', after=after, sha256=row['sha256']))
                    report['replacements'] += 1
                    report['recoveredAllocatedBytes'] += before['allocatedBytes']
                    if report['replacements'] % 64 == 0:
                        os.fsync(journal.fileno())
                        save()
                finally:
                    # Only this attempt's extra hardlink is removable. All
                    # original artifact paths are retained, including failures.
                    if linked_created and temporary.exists():
                        temporary.unlink()
            os.fsync(journal.fileno())
        for row in inputs:
            if D.digest(Path(row['file'])) != row['sha256']:
                raise ValueError('Input changed during application: ' + row['file'])
        report.update(complete=True, finished=time.time())
        save()
        print(json.dumps({k:report[k] for k in ['complete', 'alreadySharedPaths', 'replacements', 'recoveredAllocatedBytes']}))
    except BaseException as error:
        report.update(error=repr(error), finished=time.time())
        save()
        raise


if __name__ == '__main__':
    main()
