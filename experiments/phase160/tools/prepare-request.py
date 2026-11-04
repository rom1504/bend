#!/usr/bin/env python3
"""Data preparation only: exact Phase156 copy and narrow lambda-layout edit."""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / 'selfhost/build/phase156/request-prepare01/compiler.bend'
EXPECTED = '6020f680fd96e59b5a629e3ba898aacfc7f85895e9b2b22f3f1426084f656ce3'


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def scan(text):
    """Identify real arrows, protecting strings, characters and line comments.

    This is a delimiter/layout audit, not a replacement Bend parser. The
    independently executed upstream structural gate is still required.
    """
    i, stack, arrows, payload = 0, [], [], []
    while i < len(text):
        c = text[i]
        if c.isspace():
            i += 1
        elif c == '#':
            end = text.find('\n', i)
            i = len(text) if end < 0 else end
        elif c in ['"', "'"]:
            begin, quote = i, c
            i += 1
            while i < len(text):
                if text[i] == '\\':
                    i += 2
                elif text[i] == quote:
                    i += 1
                    break
                else:
                    i += 1
            else:
                raise ValueError('Unclosed literal')
            payload.append(text[begin:i])
        else:
            if text.startswith('=>', i):
                match = re.match(r'=>\n[ \t]+', text[i:])
                if match:
                    assert '(' in stack, 'Lambda arrow is not in parentheses'
                    end = i + len(match[0])
                    following = text[end:text.find('\n', end)]
                    assert not re.match(r'(?:do|match|return)\b|[+!\w]+\s*(?:=|:)[^=]', following), 'Possible statement body'
                    arrows.append(dict(offset=i, end=end, line=text.count('\n', 0, i)+1,
                                       before=match[0], after='=> ', nextLine=following))
            if c in '([{':
                stack.append(c)
            elif c in ')]}':
                assert stack and stack.pop() == {')':'(', ']':'[', '}':'{'}[c], 'Delimiter mismatch'
            payload.append(c)
            i += 1
    assert not stack, 'Unclosed delimiter'
    return arrows, ''.join(payload)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    original = SOURCE.read_bytes()
    assert hashlib.sha256(original).hexdigest() == EXPECTED, 'Frozen source changed'
    text = original.decode('utf8')
    changes, tokens = scan(text)
    assert len(changes) == 768, 'Unexpected normalization sites'
    changed = text
    for change in reversed(changes):
        changed = changed[:change['offset']] + change['after'] + changed[change['end']:]
    after, tokens_after = scan(changed)
    assert not after and tokens == tokens_after, 'Non-layout lexical payload changed'
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    (out/'original.bend').write_bytes(original)
    (out/'compiler.bend').write_text(changed)
    files = [SOURCE, Path(__file__), ROOT/'experiments/phase160/tools/compare-parser.mjs',
             ROOT/'selfhost/.bootstrap/upstream-phase66/bend2/bend.ts',
             ROOT/'selfhost/.bootstrap/upstream-phase66/bend2/base.bend',
             ROOT/'selfhost/build/phase156/request-prepare01/checked-api/report.json',
             ROOT/'selfhost/build/phase156/request-prepare01/native/report.json',
             ROOT/'selfhost/build/phase157/seed01/bendc',
             ROOT/'selfhost/build/phase157/vendor/rt/bendrt.h']
    report = dict(kind='phase160-lambda-layout-preparation', complete=True, targetsRun=False,
                  source=pin(SOURCE), original=pin(out/'original.bend'), normalized=pin(out/'compiler.bend'),
                  inputs=[pin(p) for p in files], changes=changes,
                  nonLayoutPayloadSha256=hashlib.sha256(tokens.encode()).hexdigest(),
                  gate='Pending independent upstream loaded-book structural equality, excluding only term source spans. This lexical audit is not that gate.')
    (out/'manifest.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k:report[k] for k in ['complete','targetsRun','original','normalized']}))


if __name__ == '__main__':
    main()
