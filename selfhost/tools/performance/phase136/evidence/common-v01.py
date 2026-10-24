"""Phase136 evidence inventory only; no compiler/profile semantics."""
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
PHASE = ROOT / 'selfhost/build/phase136'
TOOLS = ROOT / 'selfhost/tools/performance/phase136'


def pin(path):
    path = Path(path).resolve()
    digest, size = hashlib.sha256(), 0
    with path.open('rb') as stream:
        while chunk := stream.read(65536):
            digest.update(chunk)
            size += len(chunk)
    return dict(file=str(path), bytes=size, sha256=digest.hexdigest())


def roots():
    return [PHASE, *sorted((ROOT / 'selfhost/build/phase111').glob('p136*')),
            *sorted((ROOT / 'selfhost/build/phase134').glob('p136*')),
            *sorted((ROOT / 'selfhost/build/phase130').glob('p136*'))]


def verify(value):
    if pin(value['file']) != value:
        raise ValueError('Changed evidence: ' + value['file'])


def metadata(path):
    if path.name == 'api.mjs' or path.suffix in ('.ssa', '.s', '.o', '.so', '.xz'):
        return False
    if path.name in ('program', 'binary', 'image', 'a.fifo', 'b.fifo'):
        return False
    return path.suffix in ('.json', '.jsonl', '.txt', '.log', '.md', '.stdout',
                           '.stderr', '.py', '.mjs', '.c', '.h') or path.name in ('stdout', 'stderr')
