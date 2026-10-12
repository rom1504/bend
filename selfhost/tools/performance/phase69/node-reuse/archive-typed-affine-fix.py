#!/usr/bin/env python3
"""Archive root's failed09 -> successful10 affine annotation correction."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent


def pin(p):
    p = Path(p).resolve()
    return dict(path=str(p), sha256=hashlib.sha256(p.read_bytes()).hexdigest(), bytes=p.stat().st_size)


def main():
    before = ROOT / 'selfhost/build/phase69/typed-build09/snapshot/src/back/native/flat.bend'
    after = ROOT / 'selfhost/build/phase69/typed-build10/snapshot/src/back/native/flat.bend'
    source = before.read_text()
    start = source.index('def nf_expand_kinds(')
    at = source.index('case Con{shape, rest}', start)
    old, new = 'case Con{shape, rest}', 'case Con{+shape, rest}'
    assert source[:at] + new + source[at+len(old):] == after.read_text()
    failed = ROOT / 'selfhost/build/phase69/typed-build09/build.json'
    passed = ROOT / 'selfhost/build/phase69/typed-build10/build.json'
    assert json.loads(failed.read_text())['complete'] is False
    assert json.loads(passed.read_text())['complete'] is True
    error = ROOT / 'selfhost/build/phase69/typed-build09/bootstrap/stderr'
    assert 'shape (consumed more than once)' in error.read_text()
    result = dict(kind='phase69-typed-affine-fix-derivation-v1', producer=pin(__file__),
                  failedSource=pin(before), successfulSource=pin(after),
                  failedBuild=pin(failed), successfulBuild=pin(passed), originalFailure=pin(error),
                  originalCandidate=pin(HERE/'typed-worker-candidate-v2/plan.json'),
                  edits=[dict(offsetInParent=at,lineInParent=source.count('\n',0,at)+1,before=old,after=new)],
                  exactWholeFileReplay=True, targetsExecutedByArchiver=False,
                  explanation='Mark shape shareable because the guard reads tg(shape) and its selected branch reads ix(shape). Root applied this single affine annotation after build09 failed. The prepared v2 candidate and failed build remain preserved; successful10 is the execution evidence.')
    out = HERE / 'typed-affine-fix-v1.derivation.json'
    assert not out.exists()
    out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(pin(out)))


if __name__ == '__main__':
    main()
