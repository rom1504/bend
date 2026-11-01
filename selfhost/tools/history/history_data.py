"""JSON and deterministic gzip JSON for recovery metadata, never code capsules."""
import gzip
import io
import json
from pathlib import Path


def read_json(path):
    path = Path(path)
    opener = gzip.open if path.suffix == '.gz' else open
    with opener(path, 'rt', encoding='utf-8') as stream:
        return json.load(stream)


def write_json(path, value):
    path = Path(path)
    if path.suffix == '.gz':
        with path.open('wb') as raw:
            with gzip.GzipFile(filename='', fileobj=raw, mode='wb', mtime=0) as compressed:
                with io.TextIOWrapper(compressed, encoding='utf-8') as text:
                    json.dump(value, text, separators=(',', ':'))
                    text.write('\n')
    else:
        path.write_text(json.dumps(value, indent=2)+'\n')
