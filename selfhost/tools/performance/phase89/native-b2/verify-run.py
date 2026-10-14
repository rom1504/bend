#!/usr/bin/env python3
"""Offline assertion of a finished guarded program run; never launches a target.

MANIFEST GUARD_DIR decoder
MANIFEST GUARD_DIR argv --convention retained|upstream --program EXACT_ARGV0 --case-index N
MANIFEST GUARD_DIR file --id CASE_ID
"""
import argparse
import hashlib
import json
from pathlib import Path


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('manifest', type=Path)
    p.add_argument('guard', type=Path)
    p.add_argument('kind', choices=['argv', 'decoder', 'file'])
    p.add_argument('--convention', choices=['retained', 'upstream'])
    p.add_argument('--program')
    p.add_argument('--case-index', type=int, default=0)
    p.add_argument('--id')
    a = p.parse_args()
    m = json.loads(a.manifest.read_text())
    r = json.loads((a.guard / 'process.json').read_text())
    stdout = (a.guard / 'stdout.log').read_text()
    stderr = (a.guard / 'stderr.log').read_text()
    # Guard.complete means exit0. Expected refusals must be actual program exits,
    # not a timeout/RSS stop that happens to have produced a prefix of stderr.
    assert 'stoppedFor' not in r, r
    if a.kind == 'decoder':
        expected = m['decoderExpected']
    elif a.kind == 'argv':
        assert a.convention in ['retained', 'upstream']
        xs = m['argvCases'][a.case_index]
        if a.convention == 'upstream':
            assert a.program
            xs = [a.program] + xs
        expected = dict(exitCode=0, stderr='', stdout=''.join(
            f'arg[{i}]={v}\n' for i, v in enumerate(xs))+'END\n')
    else:
        case = next(c for c in m['fileCases'] if c['id'] == a.id)
        expected = case['expect']
        output = Path(case['output'])
        if expected.get('outputAbsent'):
            assert not output.exists(), output
        else:
            assert hashlib.sha256(output.read_bytes()).hexdigest() == expected['outputSha256']
    assert r['returncode'] == expected['exitCode'], r
    assert stdout == expected['stdout'], repr(stdout)
    if 'stderr' in expected:
        assert stderr == expected['stderr'], repr(stderr)
    else:
        assert expected['stderrContains'] in stderr, repr(stderr)
    print(json.dumps(dict(complete=True, kind=a.kind, case=a.id or a.case_index,
                         expectedExit=expected['exitCode'], guard=str(a.guard.resolve()))))


if __name__ == '__main__':
    main()
