"""Authenticate complete original control diagnostics from retained guarded captures."""
from pathlib import Path
import re
from support import SUCCESS_DIAGNOSTIC, read, strip_clocks


def control_diagnostic(row, bindings):
    assert row['passed'] and row['exactC'] and row['guardReturncode'] == 0
    raw = {Path(item['file']).name:bindings.bind(item) for item in row['receipts']}
    assert {'process.json', 'stdout.log', 'stderr.log'} <= raw.keys()
    process = read(raw['process.json']['file']); assert process == row['process']
    assert process['complete'] and process['returncode'] == 0
    assert not process.get('stoppedFor') and not process.get('interrupted')
    stdout = Path(raw['stdout.log']['file']).read_text()
    stderr = Path(raw['stderr.log']['file']).read_text()
    assert stdout == row['stdout'] == '' and stderr == row['stderr']
    assert row['source']['file'] in process['command']
    assert len(re.findall(r'^request=1 request_ms=\d+ consumed_chars=\d+$', stderr, re.M)) == 1
    diagnostic = strip_clocks(stderr)
    unsafe = re.fullmatch(r'SOME PROOFS FAIL\nError: (\d+) defs rely on unsafe or foreign code:\n((?:- [^\n]+\n)+)\n', diagnostic)
    assert diagnostic == SUCCESS_DIAGNOSTIC or (unsafe and int(unsafe[1]) == len(unsafe[2].splitlines()))
    return diagnostic
