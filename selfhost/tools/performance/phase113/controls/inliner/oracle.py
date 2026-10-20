#!/usr/bin/env python3
"""Independent mathematical/literal oracle; imports no compiler."""
import argparse
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent


def loop(count, value):
    for _ in range(count):
        value = ((value + 17) % (2**32)) ^ ((value * 8) % (2**32))
    return value


def expectations():
    text = "λabc🙂"
    return {
        "hot-helper": "\n".join(str(loop(n, x)) for n, x in
            [(0, 2**32-1), (1, 2**32-1), (31, 7), (100001, 123)]) + "\n",
        "owned-helper": text + text + "\n" + text + "\n" + text[::-1] + "\n",
    }


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--write", action="store_true")
    args = p.parse_args()
    for name, stdout in expectations().items():
        path = HERE / (name + ".expected.json")
        row = dict(status=0, stdout=stdout, stderr="")
        if args.write:
            if path.exists():
                raise ValueError("Refusing to replace frozen oracle")
            path.write_text(json.dumps(row, ensure_ascii=False, indent=2) + "\n")
        elif json.loads(path.read_text()) != row:
            raise ValueError("Oracle mismatch: " + name)
    print("Independent source expectations agree.")


if __name__ == "__main__":
    main()
