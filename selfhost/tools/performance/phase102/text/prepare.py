#!/usr/bin/env python3
"""Offline canonical-append ablation; original linked String representation.

No compiler/build/program execution. The caller owns guarded target execution.
This is a saved-C mechanism experiment, not production intrinsic admission.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def transform(source, reuse=True):
    assert 'TAG_STR' not in source and 'p101_' not in source, 'Requires original String ABI'
    assert 'p102_linked_append' not in source, 'Refuse double transformation'
    marker = 'INLINE Term term_word(Env e, Term w) {'
    assert source.count(marker) == 1, 'Expected original runtime helper boundary'
    helper = Path(__file__).with_name('linked-append.c').read_text()
    source = source.replace(marker, helper + '\n' + marker)
    name = 'FID_' + ''.join(str(ord(c)) + '_' for c in '$direct.String.append')
    pattern = r'  WL_CASE\(' + name + r'\)\n  \{.*?\n  \}\}'
    replaced = []

    def worker(match):
        old = match[0]
        assert all(token in old for token in ('CID_SNIL', 'CID_SCON', 'ctr_take')), 'Unexpected append body'
        assert 'WL_CASE(' not in old[len('  WL_CASE('):], 'Worker boundary crossed'
        replaced.append(hashlib.sha256(old.encode()).hexdigest())
        return ('  WL_CASE(' + name + ')\n  {\n'
                '    Term p102_left = r0, p102_right = r1;\n'
                '    WL_OPEN\n'
                'r0 = p102_linked_append(e, p102_left, p102_right);\n'
                'WL_RETN(1);\n\n  }}')

    source, count = re.subn(pattern, worker, source, flags=re.S)
    assert count == 1, ('Canonical saturated append worker required', count)
    guard = ('#if defined(__METAL_VERSION__) || defined(__CUDACC_RTC__) || BEND_CUDA || BEND_METAL\n'
             '#error "P102 experimental host-only linked String append"\n#endif\n'
             '#define P102_APPEND_REUSE ' + ('1' if reuse else '0') + '\n')
    return guard + source, dict(appendEntry=count, helper=1, reuse=bool(reuse), originalWorkerSHA256=replaced[0])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--copy', action='store_true', help='Free/reallocate even exclusive input cells')
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    report = dict(complete=False, method=pin(__file__), helper=pin(Path(__file__).with_name('linked-append.c')),
                  source=pin(args.source), reuse=not args.copy,
                  scope='Original linked String ABI; saved-C canonical append intervention, no release claim')
    for item in (report['method'], report['helper']):
        (args.out / ('snapshot-' + Path(item['file']).name)).write_bytes(Path(item['file']).read_bytes())
    try:
        code, counts = transform(args.source.read_text(), reuse=not args.copy)
        candidate = args.out / 'candidate.c'
        candidate.write_text(code)
        report.update(complete=True, candidate=pin(candidate), rewrites=counts)
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        (args.out / 'preparation.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
