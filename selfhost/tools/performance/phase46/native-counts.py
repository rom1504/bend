#!/usr/bin/env python3
"""Derive a CPU-only allocation/dispatch diagnostic from checked, saved C.

Usage: native-counts.py SOURCE.c NEW_DIRECTORY
Produces program.c and derivation.json; never compiles or executes a target.
Run the resulting binary with --threads 1 --gpu off before the program's --.
Its stderr JSON counts the whole process, including IO and warmups. Timings are
invalid for performance comparison. Allocation classes describe requested block
capacity, not useful fields, live memory, RSS, or allocator misses.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path


def identity(path):
    path = path.resolve(strict=True)
    content = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(content).hexdigest(), bytes=len(content))


SUPPORT = r'''
/* Phase46 saved-output diagnostic; not production code or valid timing. */
#if DEVICE
#error Phase46 native counters require the CPU backend
#else
static unsigned long long p46_heap_calls, p46_heap_classes[32];
static unsigned long long p46_invalid_classes, p46_segments, p46_closures;
static void p46_native_counts_report(void) {
  unsigned long long words = 0, classes[32];
  for (unsigned i = 0; i < 32; ++i) {
    classes[i] = __atomic_load_n(&p46_heap_classes[i], __ATOMIC_RELAXED);
    words += classes[i] * (1ull << i);
  }
  fprintf(stderr, "{\"kind\":\"phase46-native-counts\","
    "\"heapAllocCalls\":%llu,\"requestedWords\":%llu,"
    "\"invalidClassCalls\":%llu,\"hostSegmentEntries\":%llu,"
    "\"genericClosureEntries\":%llu,\"allocationClassCounts\":[",
    __atomic_load_n(&p46_heap_calls, __ATOMIC_RELAXED), words,
    __atomic_load_n(&p46_invalid_classes, __ATOMIC_RELAXED),
    __atomic_load_n(&p46_segments, __ATOMIC_RELAXED),
    __atomic_load_n(&p46_closures, __ATOMIC_RELAXED));
  for (unsigned i = 0; i < 32; ++i)
    fprintf(stderr, "%s%llu", i ? "," : "", classes[i]);
  fputs("]}\n", stderr);
}
static int p46_native_counts_arguments(int argc, char** argv) {
  int threads = 0, gpu = 0;
  for (int i = 1; i < argc && strcmp(argv[i], "--"); ++i) {
    if (!strcmp(argv[i], "--threads")) {
      if (++i == argc || strcmp(argv[i], "1")) return 0;
      threads = 1;
    } else if (!strcmp(argv[i], "--gpu")) {
      if (++i == argc || strcmp(argv[i], "off")) return 0;
      gpu = 1;
    }
  }
  return threads && gpu;
}
#endif
'''

ALLOC = r'''
#if !DEVICE
  __atomic_fetch_add(&p46_heap_calls, 1ull, __ATOMIC_RELAXED);
  if ((unsigned)cls < 32)
    __atomic_fetch_add(&p46_heap_classes[(unsigned)cls], 1ull, __ATOMIC_RELAXED);
  else __atomic_fetch_add(&p46_invalid_classes, 1ull, __ATOMIC_RELAXED);
#endif
'''

MAIN = r'''
  if (!p46_native_counts_arguments(argc, argv)) {
    fputs("Phase46 counters require --threads 1 --gpu off before --\n", stderr);
    return 125;
  }
  if (atexit(p46_native_counts_report)) {
    fputs("Phase46 counter report registration failed\n", stderr);
    return 125;
  }
'''


def replace_once(text, old, new):
    assert text.count(old) == 1, "Missing or ambiguous anchor: " + old[:100]
    return text.replace(old, new, 1)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    source = args.source.resolve(strict=True)
    emission = Path(str(source) + '.json')
    inputs = [identity(source), identity(emission), identity(Path(__file__))]
    checked = json.loads(emission.read_text())
    assert checked['complete'] is True and checked['target'] == 'c'
    assert checked['role'] in ('upstream', 'selfhost')
    assert checked['observation']['status'] == 'ok' and checked['observation']['checked'] is True
    assert Path(checked['output']['file']).resolve(strict=True) == source
    assert checked['output']['sha256'] == inputs[0]['sha256']
    original = source.read_text()
    assert 'p46_native_counts' not in original and 'p46_heap_calls' not in original
    allocator = re.findall(r'^INLINE (?:Loc|u64) heap_alloc\(Env e, (?:Cls|u32) cls\) \{$', original, re.M)
    assert len(allocator) == 1, 'Unknown allocator signature'
    allocation_anchor = allocator[0]
    host_open = '#define WL_OPEN    { WL_BANK u32 rn;'
    closure = re.findall(r'^  WL_CASE\((?:BEND_CLO_APPLY|FID_CLO_APPLY)\)\n  \{[^{}]*?    WL_OPEN\n', original, re.M)
    assert len(closure) == 1, 'Unknown generic closure entry'
    first_open = re.search(r'^    WL_OPEN$', original, re.M)
    assert first_open and first_open.start() > original.index(allocation_anchor)
    code = replace_once(original, allocation_anchor, SUPPORT + '\n' + allocation_anchor + ALLOC)
    code = replace_once(code, host_open, host_open + ' __atomic_fetch_add(&p46_segments, 1ull, __ATOMIC_RELAXED);')
    code = replace_once(code, closure[0], closure[0] + '#if !DEVICE\n    __atomic_fetch_add(&p46_closures, 1ull, __ATOMIC_RELAXED);\n#endif\n')
    code = replace_once(code, 'int main(int argc, char** argv) {', 'int main(int argc, char** argv) {' + MAIN)
    starts = list(re.finditer(r'^  WL_CASE\(([^)]+)\)', original, re.M))
    runtime = {'FID_ENTER', 'FID_EXIT', 'FID_IO_EMIT', 'FID_CLO_APPLY', 'BEND_CLO_APPLY'}
    bodies = [original[m.start():starts[i+1].start() if i+1 < len(starts) else len(original)]
              for i, m in enumerate(starts) if m.group(1) not in runtime]
    program = ''.join(bodies)
    report = dict(kind='phase46-native-counts-derivation', schemaVersion=1, complete=True,
        diagnosticOnly=True, timingValid=False, role=checked['role'], inputs=inputs,
        parentEmission=checked['output'], sourceInput=checked['input'],
        changes={'heapAllocatorDefinitions':1, 'hostSegmentMacros':1, 'genericClosureEntries':1,
                 'mainAtexitRegistration':1},
        staticShape={'programSegments':len(bodies), 'programHeapAllocSites':program.count('heap_alloc('),
                     'programTaskNodeSites':program.count('task_node(')},
        scope='Whole process, including warmup, IO and runtime work; CPU only, --threads 1 --gpu off.',
        interpretation='Class c requests 2^c words (8-byte words). Counts include reused blocks, not live/RSS memory. Host segment count includes runtime segments; it excludes iterations within one segment.',
        limitations='Atomic instrumentation changes code generation and timing. Report requires normal process exit; failed/signalled runs may lack a complete report. Compare checksums separately. Counters are unsigned 64-bit and intended for bounded runs.')
    for item in inputs:
        assert identity(Path(item['file'])) == item, 'Input changed while deriving'
    output = args.output.resolve()
    assert not output.exists(), 'Output directory must be fresh'
    output.mkdir(parents=True, exist_ok=False)
    generated = output / 'program.c'
    with generated.open('x') as handle:
        handle.write(code)
    report['output'] = identity(generated)
    with (output / 'derivation.json').open('x') as handle:
        json.dump(report, handle, indent=2)
        handle.write('\n')
    print(json.dumps({'complete':True, 'output':str(generated), 'diagnosticOnly':True}))


if __name__ == '__main__':
    main()
