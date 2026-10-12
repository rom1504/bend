#!/usr/bin/env python3
"""Instrument one existing adapter entry in diagnostic C, without executing it."""
import argparse
import importlib.util
import json
import os
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
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {0}
    out = args.out.resolve()
    assert out.is_relative_to(HERE.parents[4]/'selfhost/build/phase70') and not out.exists()
    before = audit_module.pin(args.c)
    source = args.c.read_text()
    audit = audit_module.audit(source, args.owner, 'active', 1)
    start, end = audit_module.function_span(source, audit['privateNames'][1])
    body = source[start:end]
    changed = body[:1] + '\np70_observer_adapter_entered();\n' + body[1:]
    derived = source[:start] + changed + source[end:]
    marker = '#define err_seen(H)    (DEVICE && a32_load(a32_at(H, H_ERROR_CODE)) != 0)'
    assert derived.count(marker) == 1
    helpers = r'''
#if !DEVICE
static unsigned p70_observer_adapter_count;
static void p70_observer_adapter_entered(void) {
  if (__atomic_add_fetch(&p70_observer_adapter_count, 1, __ATOMIC_RELAXED) == 1) {
    fprintf(stderr, "PHASE70_OBSERVER_ADAPTER_ENTERED\n"); fflush(stderr);
  }
}
static void p70_observer_adapter_finish(void) {
  if (__atomic_load_n(&p70_observer_adapter_count, __ATOMIC_RELAXED) == 0) {
    fprintf(stderr, "PHASE70_OBSERVER_ADAPTER_NOT_REACHED\n"); fflush(stderr); _exit(91);
  }
}
__attribute__((constructor)) static void p70_observer_adapter_register(void) {
  atexit(p70_observer_adapter_finish);
}
#endif
'''
    derived = derived.replace(marker, marker + '\n' + helpers)
    out.mkdir(parents=True)
    target = out/'program.c'
    target.write_text(derived)
    assert audit_module.pin(args.c) == before
    plan = dict(kind='phase70-observer-active-path-v1', owner=args.owner, source=before,
        output=audit_module.pin(target), producer=audit_module.pin(__file__),
        auditProducer=audit_module.pin(HERE/'emission-audit-v2.py'), sourceAudit=audit,
        exactFunctionBefore=body, exactFunctionAfter=changed, insertedHelpers=helpers,
        stderrMarker='PHASE70_OBSERVER_ADAPTER_ENTERED\n', targetsExecuted=False,
        oracle='Require exactly one stderr marker; after removing that whole line, stdout/stderr/exit must equal the original control golden. Normal return additionally fails if adapter was never reached. Runtime fail-stop preserves its original _exit and is qualified by the already flushed entry marker.',
        scope='Diagnostic execution coverage only; atomic counter and stderr marker are excluded from performance measurements. No error policy, seq flag, generated ownership branch, or source result changes.')
    (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
    print(json.dumps(dict(plan=audit_module.pin(out/'plan.json'), targetsExecuted=False)))


if __name__ == '__main__':
    main()
