"""Retain the local-fold worker byte-for-byte and select another success oracle."""
import argparse
from hashlib import sha256
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = ROOT/'selfhost/tools/bench/catalogs/native45/fixtures/local-fold.bend'


def main(out):
    src = BASE.read_bytes()
    assert sha256(src).hexdigest() == '2252256562cc415348f3aa53c960b318f87c4a8b5fd118a0a2f115d446723125'
    rows = json.loads((HERE/'oracles.json').read_text())['original']
    old = ('U32.is_eq(value, '+str(rows[0]['carry'])+')').encode()
    new = ('U32.is_eq(value, '+str(rows[1]['carry'])+')').encode()
    assert src.count(old) == 1
    variant = src.replace(old,new)
    assert variant.split(b'def p93.loop')[0] == src.split(b'def p93.loop')[0]
    out.write_bytes(variant)
    print(sha256(variant).hexdigest(),out)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('out',type=Path)
    main(parser.parse_args().out)
