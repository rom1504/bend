#!/usr/bin/env python3
"""Source-only, fail-closed counters for checked Phase67 native C; no targets."""
import argparse
import hashlib
import json
import re
from pathlib import Path


def identity(path):
    path = Path(path).resolve(strict=True)
    content = path.read_bytes()
    return dict(path=str(path), sha256=hashlib.sha256(content).hexdigest(), bytes=len(content))


def once(source, old, new):
    assert source.count(old) == 1, 'Missing or ambiguous anchor: ' + old[:100]
    return source.replace(old, new, 1)


def instrument(source):
    """Counts entries/operations of the instrumented executable, never timings."""
    assert 'p68_' not in source
    names = ['heapAllocCalls', 'heapMissCalls', 'heapFreeCalls', 'termKeepCalls',
             'termDropCalls', 'rfcWrapCalls', 'rfcBumpCalls', 'rfcBumpUnits',
             'rfcDecrementOperations']
    starts = list(re.finditer(r'^  WL_CASE\(([^)]+)\)', source, re.M))
    assert starts
    mapping = [{'index': i, 'symbol': m.group(1),
                'sourceLine': source.count('\n', 0, m.start()) + 1}
               for i, m in enumerate(starts)]
    generic = [x['index'] for x in mapping if x['symbol'] in ('FID_CLO_APPLY', 'BEND_CLO_APPLY')]
    assert len(generic) == 1
    # Per-segment entries are frequencies, not a CPU-time profile. Inlined loops
    # may perform arbitrarily many iterations between two segment entries.
    for i in range(len(starts) - 1, -1, -1):
        begin = starts[i].start()
        end = starts[i + 1].start() if i + 1 < len(starts) else len(source)
        body = source[begin:end]
        body = once(body, '    WL_OPEN\n',
                    '    WL_OPEN\n    P68_ADD(p68_segments[%d], 1);\n' % i)
        source = source[:begin] + body + source[end:]
    support = '\n/* Phase68 diagnostic only: atomic counters invalidate timings. */\n'
    support += '#if DEVICE\n#error Phase68 counters require CPU\n#endif\n'
    support += '#define P68_ADD(v, n) __atomic_fetch_add(&(v), (unsigned long long)(n), __ATOMIC_RELAXED)\n'
    support += '#define P68_READ(v) __atomic_load_n(&(v), __ATOMIC_RELAXED)\n'
    support += 'static unsigned long long p68_counts[%d], p68_classes[32], p68_invalid, p68_segments[%d];\n' % (len(names), len(starts))
    support += r'''
static void p68_report(void) {
  unsigned long long words = 0, segments = 0;
  for (unsigned i = 0; i < 32; ++i) words += P68_READ(p68_classes[i]) * (1ull << i);
  for (unsigned i = 0; i < sizeof(p68_segments)/sizeof(*p68_segments); ++i) segments += P68_READ(p68_segments[i]);
  fputs("{\"kind\":\"phase68-native-counts\",", stderr);
'''
    for i, name in enumerate(names):
        support += '  fprintf(stderr, "\\\"%s\\\":%%llu,", P68_READ(p68_counts[%d]));\n' % (name, i)
    support += '  fprintf(stderr, "\\\"requestedWords\\\":%llu,\\\"invalidClassCalls\\\":%llu,\\\"hostSegmentEntries\\\":%llu,\\\"genericClosureEntries\\\":%llu,", words, P68_READ(p68_invalid), segments, P68_READ(p68_segments[' + str(generic[0]) + ']));\n'
    support += r'''
  fputs("\"allocationClassCounts\":[", stderr);
  for (unsigned i = 0; i < 32; ++i) fprintf(stderr, "%s%llu", i ? "," : "", P68_READ(p68_classes[i]));
  fputs("],\"segments\":{", stderr);
  int comma = 0;
  for (unsigned i = 0; i < sizeof(p68_segments)/sizeof(*p68_segments); ++i) {
    unsigned long long n = P68_READ(p68_segments[i]);
    if (n) { fprintf(stderr, "%s\"%u\":%llu", comma ? "," : "", i, n); comma = 1; }
  }
  fputs("}}\n", stderr);
}
static int p68_arguments(int argc, char** argv) {
  int threads = 0, gpu = 0;
  for (int i = 1; i < argc && strcmp(argv[i], "--"); ++i) {
    if (!strcmp(argv[i], "--threads")) { if (++i == argc || strcmp(argv[i], "1")) return 0; threads = 1; }
    else if (!strcmp(argv[i], "--gpu")) { if (++i == argc || strcmp(argv[i], "off")) return 0; gpu = 1; }
  }
  return threads && gpu;
}
'''
    miss = re.findall(r'^OUTLINE (?:Loc|u64) heap_alloc_miss\(Env e, (?:Cls|u32) cls\) \{$', source, re.M)
    assert len(miss) == 1
    source = once(source, miss[0], support + '\n' + miss[0])
    signatures = [
        r'INLINE (?:Loc|u64) heap_alloc\(Env e, (?:Cls|u32) cls\) \{',
        r'OUTLINE (?:Loc|u64) heap_alloc_miss\(Env e, (?:Cls|u32) cls\) \{',
        r'INLINE void heap_free\(Env e, (?:Cls|u32) cls, (?:Loc|u64) loc\) \{',
        r'INLINE Term term_keep\(Env e, Term t(?:, u32 k)?\) \{',
        r'FAR void term_drop\(Env e, Term t\) \{',
        r'OUTLINE Term rfc_wrap\(Env e, Term t, u32 cnt\) \{',
        r'INLINE void rfc_bump\(Env e, (?:Loc|u64) r, u32 k\) \{',
    ]
    for i, pattern in enumerate(signatures):
        anchors = re.findall('^' + pattern + '$', source, re.M)
        assert len(anchors) == 1, pattern
        extra = '\n  P68_ADD(p68_counts[%d], 1);' % i
        if i == 0:
            extra += '\n  if ((unsigned)cls < 32) P68_ADD(p68_classes[(unsigned)cls], 1); else P68_ADD(p68_invalid, 1);'
        if i == 6:
            extra += '\n  P68_ADD(p68_counts[7], k);'
        source = once(source, anchors[0], anchors[0] + extra)
    source = once(source, '      if ((a32_sub_rel(p, 1) & RFC_CNT) != 1) {',
                  '      P68_ADD(p68_counts[8], 1);\n      if ((a32_sub_rel(p, 1) & RFC_CNT) != 1) {')
    source = once(source, 'int main(int argc, char** argv) {', r'''int main(int argc, char** argv) {
  if (!p68_arguments(argc, argv) || atexit(p68_report)) {
    fputs("Phase68 counters require --threads 1 --gpu off and atexit\n", stderr);
    return 125;
  }
''')
    return source, mapping


def derive(source, output):
    source, output = Path(source).resolve(strict=True), Path(output).resolve()
    receipt = Path(str(source) + '.json')
    checked = json.loads(receipt.read_text())
    inputs = [identity(source), identity(receipt), identity(__file__)]
    assert checked['complete'] and checked['target'] == 'c'
    assert checked['observation']['status'] == 'ok' and checked['observation']['checked']
    assert checked['output'] == inputs[0]
    code, segments = instrument(source.read_text())
    output.mkdir(parents=True, exist_ok=False)
    generated = output / 'program.c'
    generated.write_text(code)
    report = dict(kind='phase68-native-counts-derivation', complete=True,
        diagnosticOnly=True, timingValid=False, role=checked['role'], inputs=inputs,
        parentEmission=checked['output'], sourceInput=checked['input'],
        output=identity(generated), segments=segments,
        limitations='Atomic instrumentation perturbs optimization and execution. Counts are whole-process including IO. Class c requests 2^c eight-byte words; this is capacity, not live memory, RSS or allocator misses. termKeep/termDrop count entries, not semantic retained values. rfcDecrementOperations counts actual shared-cell decrement sites including recursive drops. Segment frequencies are not time percentages. Misses are allocator local-list misses, not necessarily system allocations. Differences between repetitions include digest/formatting differences. Runtime revisions differ between roles.')
    for item in inputs:
        assert identity(item['path']) == item
    (output / 'derivation.json').write_text(json.dumps(report, indent=2) + '\n')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    print(json.dumps(derive(args.source, args.output)['output']))
