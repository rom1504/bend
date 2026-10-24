"""Prepare bounded QBE-only String-reader hypothesis probes, never production code.

The input remains a checked ordinary compiler-derived index proxy. The private
reader must match the final N2 reader byte for byte. Diagnostic counters are
single-thread-only and the clean ceiling implements the proved String diagonal
law under the existing typed, immutable, ancestor-held reader premise.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
READER = '$p118borrow.read.p88_string_eq_go'
TARGETS = {READER, '$direct.p88_string_eq', '$direct.p98_tag_eq',
           '$p118borrow.read.p98_tag_eq', '$direct.String.order',
           '$p118borrow.read.String.order', '$direct.String.eq',
           '$p118borrow.read.String.eq'}

def pin(path):
    path = path.resolve()
    return dict(file=str(path), bytes=path.stat().st_size,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest())

def decode(symbol):
    if 'FID_' not in symbol:
        return symbol
    return ''.join(chr(int(x)) for x in symbol.split('FID_', 1)[1].split('_') if x)

def functions(path):
    current = None
    with path.open() as source:
        for line in source:
            if line.startswith(('function ', 'export function ')):
                assert current is None
                symbol = re.search(r'\$(\w+)\(', line)[1]
                current = (symbol, decode(symbol), [line])
            elif current:
                current[2].append(line)
                if line.strip() == '}':
                    yield current[0], current[1], ''.join(current[2])
                    current = None

def inspect(path):
    readers = []
    callers = {x: Counter() for x in TARGETS}
    for symbol, name, body in functions(path):
        if name == READER:
            readers.append(body)
        for target in re.findall(r'\bcall \$(\w+)\(', body):
            decoded = decode(target)
            if decoded in callers:
                callers[decoded][name] += 1
    assert len(readers) == 1
    return readers[0], {k: dict(v) for k, v in callers.items()}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--compiler', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase131')
    source = args.source.resolve(); compiler = args.compiler.resolve()
    reader, proxy_calls = inspect(source)
    native_reader, compiler_calls = inspect(compiler)
    assert reader == native_reader, 'Proxy must contain the exact final N2 reader'
    assert reader.count('\n@p113_loop\n') == 1
    assert '%p131_identity_' not in reader
    header = '@p113_loop\n'
    compare = ('  %p131_identity_equal =w ceql %v_v_4294967295, %v_v_4294967294\n'
               '  %p131_identity_pending =w ceql %v_v_4294967293, 1\n'
               '  %p131_identity_hit =w and %p131_identity_equal, %p131_identity_pending\n')
    counters = ('  %p131_identity_iters_old =l loadl $p131_identity_iters\n'
                '  %p131_identity_iters_new =l add %p131_identity_iters_old, 1\n'
                '  storel %p131_identity_iters_new, $p131_identity_iters\n' + compare +
                '  %p131_identity_hit_long =l extuw %p131_identity_hit\n'
                '  %p131_identity_hits_old =l loadl $p131_identity_hits\n'
                '  %p131_identity_hits_new =l add %p131_identity_hits_old, %p131_identity_hit_long\n'
                '  storel %p131_identity_hits_new, $p131_identity_hits\n')
    # Match a whole label line, never a predecessor jump target.
    diagnostic_reader = reader.replace('\n' + header, '\n' + header + counters)
    diagnostic_reader = diagnostic_reader.replace('@entry\n', '@entry\n'
        '  %p131_identity_calls_old =l loadl $p131_identity_calls\n'
        '  %p131_identity_calls_new =l add %p131_identity_calls_old, 1\n'
        '  storel %p131_identity_calls_new, $p131_identity_calls\n', 1)
    ceiling_reader = reader.replace('\n' + header, '\n' + header + compare +
        '  jnz %p131_identity_hit, @p131_identity_return, @p131_identity_continue\n'
        '@p131_identity_return\n  ret 1\n@p131_identity_continue\n')
    original = source.read_text()
    assert original.count(reader) == 1
    diagnostic = original.replace(reader, diagnostic_reader)
    main_body = [body for symbol, _, body in functions(source) if symbol == 'main']
    assert len(main_body) == 1 and main_body[0].count('\nret %result\n') == 1
    printer = ('  %p131_identity_calls =l loadl $p131_identity_calls\n'
               '  %p131_identity_iters =l loadl $p131_identity_iters\n'
               '  %p131_identity_hits =l loadl $p131_identity_hits\n'
               '  %p131_identity_printed =w call $printf(l $p131_identity_format, ..., '
               'l %p131_identity_calls, l %p131_identity_iters, l %p131_identity_hits)\n')
    diagnostic = diagnostic.replace(main_body[0], main_body[0].replace('\nret %result\n', '\n' + printer + 'ret %result\n'))
    diagnostic += ('\ndata $p131_identity_calls = align 8 { l 0 }\n'
                   'data $p131_identity_iters = align 8 { l 0 }\n'
                   'data $p131_identity_hits = align 8 { l 0 }\n'
                   'data $p131_identity_format = { b "p131-identity %lu %lu %lu", b 10, b 0 }\n')
    out.mkdir()
    (out / 'diagnostic.ssa').write_text(diagnostic)
    (out / 'ceiling.ssa').write_text(original.replace(reader, ceiling_reader))
    (out / 'reader.ssa').write_text(reader)
    report = dict(complete=True, targetsRun=False, productionChange=False,
        independentVerifierAppliedToPatches=False,
        inputs=[pin(Path(__file__)), pin(source), pin(compiler)],
        exactN2ReaderMatch=True, reader=pin(out / 'reader.ssa'),
        diagnostic=pin(out / 'diagnostic.ssa'), ceiling=pin(out / 'ceiling.ssa'),
        proxyDirectCallers=proxy_calls, compilerDirectCallers=compiler_calls,
        scope='Hypothesis probe only. Call graph omits generic scheduler edges. '
              'Counters require one thread/GPU off; never benchmark their timings. '
              'The ceiling assumes valid immutable typed Strings held by an outer owner; '
              'malformed raw Terms are outside the source theorem. Outer adapters and fallbacks unchanged.')
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, output=str(out), exactN2ReaderMatch=True)))

if __name__ == '__main__':
    main()
