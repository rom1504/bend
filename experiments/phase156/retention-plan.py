#!/usr/bin/env python3
"""Plan or explicitly seal every Phase156 guard; keep all artifact roots hot.

plan --out selfhost/build-retention/phase156/closure-plan01.json
seal --plan .../closure-plan01.json --out implementation/phase156/retention.json
No target execution or pruning. Generate a fresh plan after all targets finish.
"""
import argparse
import hashlib
import json
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / 'selfhost/build/phase156'
RESERVE = 5 * 1024**3
CLOSE = ROOT / 'selfhost/tools/build-retention/close.py'


def require(ok, message):
    if not ok:
        raise SystemExit(message)


def pin(path):
    path = Path(path).absolute()
    require(path.resolve() == path and path.is_file(), 'regular unsymlinked file required: ' + str(path))
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(expected):
    require(pin(expected['file']) == expected, 'changed input: ' + expected['file'])


def discover():
    found = set()
    for path in BUILD.rglob('process.json'):
        value = json.loads(path.read_bytes())
        if value.get('kind') == 'build-retention-disk-guard-v1':
            require(path.with_name('retention.json').is_file(), 'guard missing lifecycle: ' + str(path))
            found.add(path.parent)
    for path in BUILD.rglob('retention.json'):
        value = json.loads(path.read_bytes())
        if value.get('kind') == 'build-retention-run-v1':
            require(path.parent in found, 'lifecycle missing guard process: ' + str(path))
    return sorted(found)


def classify(process, reports):
    if process.get('stoppedFor') in ('disk-admission', 'host-headroom') and process.get('returncode') is None:
        return 'rejected', 'Admission/headroom refusal; no successful target is inferred.'
    if not process.get('complete'):
        return 'failed', 'Guard did not complete successfully; retain diagnostics and partial outputs.'
    if any(r.get('passed') is False or r.get('checked') is False for r in reports):
        return 'rejected', 'Successful command reported a semantic/control rejection; later corrections do not rewrite this attempt.'
    if any(r.get('complete') is False for r in reports):
        return 'failed', 'Target report is incomplete despite a successful wrapper exit.'
    return 'completed', 'Guard and available target reports completed; this does not qualify a compiler.'


def make_plan():
    rows = []
    for guard in discover():
        state = json.loads((guard / 'retention.json').read_bytes())
        process = json.loads((guard / 'process.json').read_bytes())
        require(state['artifactRoots'] == process['artifactRoots'], 'guard roots disagree')
        roots = [Path(p) for p in state['artifactRoots']]
        require(all(p.is_relative_to(BUILD) and p.resolve() == p for p in roots), 'non-Phase156 output root')
        reports, report_pins = [], []
        for artifact in roots:
            report = artifact / 'report.json'
            if report.exists():
                reports.append(json.loads(report.read_bytes()))
                report_pins.append(pin(report))
        classification, reason = classify(process, reports)
        output = ROOT / 'selfhost/build-retention/phase156/closed' / str(guard.relative_to(BUILD)).replace('/', '--')
        command = [sys.executable, '-B', str(CLOSE), '--run', str(guard),
                   '--classification', classification, '--out', str(output)]
        for artifact in roots:
            command.extend(['--keep-root', str(artifact)])
        rows.append(dict(guard=str(guard.relative_to(ROOT)), state=state['state'],
                         process=pin(guard / 'process.json'), reports=report_pins,
                         classification=classification, reason=reason,
                         artifactRoots=list(map(str, roots)), command=command,
                         shell=shlex.join(command), closureDirectory=str(output)))
    return dict(kind='phase156-closure-plan', version=1, complete=True, method=pin(__file__),
                closeMethod=pin(CLOSE), rows=rows,
                readyToSeal=bool(rows) and all(r['state'] in ('finished', 'sealed') for r in rows),
                policy='Explicit --keep-root for every declared artifact root; no --prune, no qualified classification. '
                       'One subsequent deduplicated evidence capsule preserves exact bytes without duplicate root archives.',
                disk=dict(reserveBytes=RESERVE, closureAllowanceBytes=8 * 1024**2,
                          currentFreeBytes=shutil.disk_usage(ROOT).free))


def write(path, value, *, new=False):
    path = path.absolute()
    require(path.is_relative_to(ROOT) and path.resolve() == path, 'output must stay in repository')
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x' if new else 'w') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')


def seal(args):
    plan = json.loads(args.plan.read_bytes())
    require(plan['kind'] == 'phase156-closure-plan' and plan['readyToSeal'], 'finished-guard plan required')
    verify(plan['method']); verify(plan['closeMethod'])
    require([str(p.relative_to(ROOT)) for p in discover()] == [r['guard'] for r in plan['rows']],
            'guard inventory changed; generate a new plan')
    require(shutil.disk_usage(ROOT).free >= RESERVE + 8 * 1024**2, '5 GiB reserve plus closure allowance required')
    result = dict(kind='phase156-retention-summary', complete=False, allSealed=False, pruned=False,
                  plan=pin(args.plan), rows=[], mode='all artifact roots kept hot; final capsule archives once')
    write(args.out, result, new=True)
    try:
        for row in plan['rows']:
            verify(row['process'])
            for report in row['reports']:
                verify(report)
            lifecycle = ROOT / row['guard'] / 'retention.json'
            state = json.loads(lifecycle.read_bytes())
            if state['state'] != 'sealed':
                require(state['state'] == 'finished' and not state['closed'], 'guard still active')
                require(shutil.disk_usage(ROOT).free >= RESERVE + 1024**2, '5 GiB reserve reached')
                subprocess.run(row['command'], cwd=ROOT, check=True)
                state = json.loads(lifecycle.read_bytes())
            require(state['state'] == 'sealed' and state['closed'] and
                    state['classification'] == row['classification'], 'unexpected closure classification')
            verify(state['closure'])
            closure = json.loads(Path(state['closure']['file']).read_bytes())
            require(closure['complete'] and not closure['pruneRequested'] and
                    all(r['keptHot'] for r in closure['roots']), 'closure must retain every artifact root')
            result['rows'].append(dict(guard=row['guard'], classification=row['classification'], closure=state['closure']))
            write(args.out, result)
        require([str(p.relative_to(ROOT)) for p in discover()] == [r['guard'] for r in plan['rows']], 'new guard appeared')
        result.update(complete=True, allSealed=True, closedGuards=len(result['rows']))
    finally:
        write(args.out, result)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    plan = commands.add_parser('plan'); plan.add_argument('--out', type=Path, required=True)
    close = commands.add_parser('seal'); close.add_argument('--plan', type=Path, required=True)
    close.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if args.command == 'plan':
        result = make_plan(); write(args.out, result, new=True)
    else:
        result = seal(args)
    print(json.dumps({k:result[k] for k in ('kind', 'complete', 'readyToSeal', 'closedGuards', 'allSealed') if k in result}))


if __name__ == '__main__':
    main()
