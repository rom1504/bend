#!/usr/bin/env python3
"""Derive diagnostic C; root alone compiles/runs it. No target subprocesses here."""
import argparse
import importlib.util
import json
import os
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('observer_emission_audit', HERE/'emission-audit-v2.py')
audit_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit_module)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('c', type=Path)
    parser.add_argument('owner')
    parser.add_argument('out', type=Path)
    parser.add_argument('--mode', required=True, choices=['pre-entry', 'post-observer', 'loop-poll'])
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {0}
    root = HERE.parents[4]
    out = args.out.resolve()
    assert out.is_relative_to(root/'selfhost/build/phase70') and not out.exists()
    before = audit_module.pin(args.c)
    source = args.c.read_text()
    checked = audit_module.audit(source, args.owner, 'active', 1)
    observed, adapter = checked['privateNames']
    mode = ['pre-entry', 'post-observer', 'loop-poll'].index(args.mode) + 1
    exact_macro = '#define err_seen(H)    (DEVICE && a32_load(a32_at(H, H_ERROR_CODE)) != 0)'
    assert source.count(exact_macro) == 1
    helpers = r'''
// DIAGNOSTIC ONLY: host emulation of shared-error visibility. Production
// host err_post remains fail-stop; no generated-body success path is replaced.
static unsigned p70_adapter_entered, p70_observer_entered, p70_visits;
static unsigned p70_observer_ok, p70_observer_failed, p70_injected, p70_wrapper_started;
static void p70_bad(const char* why) { fprintf(stderr, "PHASE70_DIAGNOSTIC_FAIL %s\n", why); fflush(stderr); _exit(91); }
static void p70_not_reached(void) { p70_bad("selected adapter not reached"); }
__attribute__((constructor)) static void p70_register(void) { atexit(p70_not_reached); }
static void p70_inject(Corpus H) { ++p70_injected; a32_store(a32_at(H, H_ERROR_CODE), ERR_FIDS); }
static Term p70_observer_zero(void) { ++p70_observer_failed; return 0; }
static Term p70_observer_one(void) { ++p70_observer_ok; return 1; }
static Term p70_adapter_one(void) { p70_bad("adapter succeeded after injected error"); return 1; }
static Term p70_adapter_zero(Corpus H) {
  if (p70_adapter_entered != 1 || p70_injected != 1 || p70_wrapper_started != 0 ||
      a32_load(a32_at(H, H_ERROR_CODE)) != ERR_FIDS) p70_bad("missing error or wrapper entered");
  if (P70_MODE == 1 && (p70_observer_entered || p70_observer_ok || p70_observer_failed)) p70_bad("pre-entry read observer");
  if (P70_MODE == 2 && (p70_observer_entered != 1 || p70_observer_ok != 1 || p70_observer_failed)) p70_bad("post-success path missing");
  if (P70_MODE == 3 && (p70_observer_entered != 1 || p70_observer_ok || p70_observer_failed != 1 || p70_visits != 4)) p70_bad("fourth loop poll not reached");
  printf("PHASE70_OBSERVER_ERROR_DIAGNOSTIC_PASS %d\n", P70_MODE); fflush(stdout); _exit(0);
}
'''.replace('P70_MODE', str(mode))
    replacements = []
    for name, role in [(observed, 'observer'), (adapter, 'adapter')]:
        start, end = audit_module.function_span(source, name)
        body = source[start:end]
        original = body
        if role == 'observer':
            body = body.replace('return 0;', 'return p70_observer_zero();')
            body = body.replace('return 1;', 'return p70_observer_one();')
            body = body[:1] + '\n++p70_observer_entered;\n' + body[1:]
            if mode == 3:
                assert body.count('u32 nf_poll = 0;') == 1 and body.count('nf_again:;') == 1
                assert 'goto nf_again;' in body, 'loop mode requires actual residual recursion'
                # Three normal transitions, then the existing fourth poll hits
                # the unchanged modulo4096 policy. No fake extra iterations.
                body = body.replace('u32 nf_poll = 0;', 'u32 nf_poll = 4092;')
                body = body.replace('nf_again:;', 'nf_again:;\nif (++p70_visits == 4) p70_inject(e.mem);')
        else:
            body = body.replace('return 0;', 'return p70_adapter_zero(e.mem);')
            body = body.replace('return 1;', 'return p70_adapter_one();')
            prefix = '\n++p70_adapter_entered;\nseq = false;\n'
            if mode == 1:
                prefix += 'p70_inject(e.mem);\n'
            body = body[:1] + prefix + body[1:]
            marker = 'Term no_scalar_result = no_observed[0];'
            assert body.count(marker) == 1
            body = body.replace(marker, '++p70_wrapper_started;\n' + marker)
            if mode == 2:
                call = re.search(r'if \(!' + re.escape(observed) + r'\(e, seq, no_observed[^\n]*\)\) \{ return p70_adapter_zero\(e.mem\); \}', body)
                assert call
                body = body[:call.end()] + '\np70_inject(e.mem);' + body[call.end():]
        replacements.append(dict(name=name, start=start, end=end, before=original, after=body))
    derived = source
    for item in sorted(replacements, key=lambda item: item['start'], reverse=True):
        derived = derived[:item['start']] + item['after'] + derived[item['end']:]
    replacement_macro = '#define err_seen(H)    (a32_load(a32_at(H, H_ERROR_CODE)) != 0)'
    derived = derived.replace(exact_macro, replacement_macro + '\n#if !DEVICE\n' + helpers + '\n#endif')
    out.mkdir(parents=True)
    target = out/'program.c'
    target.write_text(derived)
    assert audit_module.pin(args.c) == before
    plan = dict(kind='phase70-observer-error-diagnostic-v2', mode=args.mode, owner=args.owner,
        source=before, output=audit_module.pin(target), producer=audit_module.pin(__file__),
        auditProducer=audit_module.pin(HERE/'emission-audit-v2.py'), sourceAudit=checked,
        changes=replacements, macroBefore=exact_macro, macroAfter=replacement_macro,
        insertedHelpers=helpers, targetsExecuted=False,
        expectedStdout='PHASE70_OBSERVER_ERROR_DIAGNOSTIC_PASS '+str(mode)+'\n',
        expectedExit=0, executionRequiresThreads=1,
        scope='Diagnostic host emulation of shared-error visibility; actual observer/adapter branches, roots and runtime remain. Forced seq=false, instrumented returns, and process termination isolate failure before wrapper allocation. Loop mode offsets the poll counter and requires three real transitions before the fourth poll. Not production-host cancellation, physical GPU validation, a memory-leak claim, or performance evidence.')
    (out/'plan.json').write_text(json.dumps(plan, indent=2)+'\n')
    print(json.dumps(dict(plan=audit_module.pin(out/'plan.json'), targetsExecuted=False)))


if __name__ == '__main__':
    main()
