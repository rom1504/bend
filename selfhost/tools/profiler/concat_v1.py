#!/usr/bin/env python3
"""Optional v1 concat events: reversible hooks and offline conservation checks.

Migrated from the measured Phase144 extension. Positive branch hooks remain
source-audited, not independently fixture-qualified. No target executes here.
"""
import argparse
import copy
import json
from pathlib import Path

COUNTERS = [('BP_CONCAT_ATTEMPTS', 'concat_attempts'), ('BP_CONCAT_NODES', 'concat_nodes_examined'), ('BP_CONCAT_EMPTY', 'concat_success_empty'), ('BP_CONCAT_SPLICE', 'concat_success_splice'), ('BP_CONCAT_STATIC', 'concat_refused_static_term'), ('BP_CONCAT_SHARED', 'concat_refused_shared_rfc'), ('BP_CONCAT_STATIC_TARGET', 'concat_refused_static_target')]
HOOKS = [('attempt', '  Term nil = term_pak(empty_cid, 0), node = left;', '  bend_profile_count(BP_CONCAT_ATTEMPTS, 1);\n  Term nil = term_pak(empty_cid, 0), node = left;'), ('node', '  while (node != nil) {', '  while (node != nil) {\n    bend_profile_count(BP_CONCAT_NODES, 1);'), ('static', '    if (term_loc(node) < HEAP_OFF) return 0;', '    if (term_loc(node) < HEAP_OFF) { bend_profile_count(BP_CONCAT_STATIC, 1); return 0; }'), ('shared', '      if ((cell & RFC_CNT) != 1) return 0;', '      if ((cell & RFC_CNT) != 1) { bend_profile_count(BP_CONCAT_SHARED, 1); return 0; }'), ('static-target', '      if (last < HEAP_OFF) return 0;', '      if (last < HEAP_OFF) { bend_profile_count(BP_CONCAT_STATIC_TARGET, 1); return 0; }'), ('empty', '  if (!last) {\n    return right;', '  if (!last) {\n    bend_profile_count(BP_CONCAT_EMPTY, 1);\n    return right;'), ('splice', '  return left;', '  bend_profile_count(BP_CONCAT_SPLICE, 1);\n  return left;')]


def materialize(diagnostic, support):
    text = diagnostic.decode()
    marker = 'uint64_t p125_rt_concat_typed('
    if text.count(marker) != 1:
        raise ValueError('Unique compatible typed concat function required')
    start = text.index(marker)
    end = text.index('\n}\n', start) + 3
    body = text[start:end]
    changed = body
    edits = []
    for label, old, new in HOOKS:
        if changed.count(old) != 1 or new in changed:
            raise ValueError('Unique uninjected concat hook required: ' + label)
        changed = changed.replace(old, new, 1)
        edits.append(dict(label=label, original=old, diagnostic=new, occurrences=1))
    reverse = changed
    for row in reversed(edits):
        if reverse.count(row['diagnostic']) != 1:
            raise ValueError('Ambiguous concat reverse hook')
        reverse = reverse.replace(row['diagnostic'], row['original'], 1)
    if reverse != body:
        raise ValueError('Concat hooks are not reversible')
    original_support = support.decode()
    oldenum = 'BP_REG_CLEAR_WORDS, BP_COUNTER_COUNT'
    newenum = 'BP_REG_CLEAR_WORDS, ' + ', '.join(k for k, _ in COUNTERS) + ', BP_COUNTER_COUNT'
    oldnames = '"register_words_copy_requested", "register_words_clear_requested"'
    newnames = oldnames + ',\n  ' + ', '.join('"' + name + '"' for _, name in COUNTERS)
    if original_support.count(oldenum) != 1 or original_support.count(oldnames) != 1:
        raise ValueError('Unextended v1 counter support required')
    extended = original_support.replace(oldenum, newenum, 1).replace(oldnames, newnames, 1)
    if extended.replace(newenum, oldenum, 1).replace(newnames, oldnames, 1) != original_support:
        raise ValueError('Counter support is not reversible')
    result = text[:start] + changed + text[end:]
    if result[:start] + body + result[start + len(changed):] != text:
        raise ValueError('Concat function boundary changed')
    return result.encode(), extended.encode(), edits


def extend_expectation(original):
    result = copy.deepcopy(original)
    names = [name for _, name in COUNTERS]
    if any(name in result['counterNames'] for name in names):
        raise ValueError('Control expectation already extended')
    result['counterNames'].extend(names)
    for row in [result['totals'], *result['rows'].values()]:
        row.update({name: 0 for name in names})
    result['limitations'].append('The seven concat counters are zero in the unchanged ABI fixture; this does not qualify their positive branches.')
    result['derivation'] += ' Additive concat columns are zero: this independent source never calls typed concat.'
    return result


def summarize(document):
    names = [name for _, name in COUNTERS]
    if document.get('schema') != 'bend-native-dispatch-events-v1' or not document.get('complete') or document.get('counter_overflow') or document.get('invalid_context_events') != 0:
        raise ValueError('Complete non-overflowed dispatch events required')
    actual = document['counter_names']
    base_names=json.loads((Path(__file__).parent/'controls/runtime-control.expected.json').read_text())['counterNames']
    if actual != base_names + names:
        raise ValueError('Exact additive v1 counter order required')
    if type(document['counts_enabled']) is not bool or type(document['segment_count']) is not int or document['segment_count']<0:
        raise ValueError('Invalid counter dimensions/mode')
    totals = dict.fromkeys(actual, 0)
    seen = set()
    for row in document['rows']:
        if type(row['fid']) is not int or not 0<=row['fid']<2**32:
            raise ValueError('Invalid counter FID')
        if row['fid'] in seen:
            raise ValueError('Duplicate counter FID')
        seen.add(row['fid'])
        counts = row['counts']
        if len(counts) != 23 or any(type(value) is not int or value < 0 for value in counts):
            raise ValueError('Malformed counter vector')
        fields = dict(zip(actual, counts))
        ends = sum(fields[name] for name in names[2:])
        if fields['concat_attempts'] != ends or fields['concat_nodes_examined'] < ends - fields['concat_success_empty']:
            raise ValueError('Concat outcome conservation failed')
        for name, value in fields.items():
            totals[name] += value
    if not document['counts_enabled']:
        if document['rows'] or document['counter_bytes'] != 0:
            raise ValueError('Disabled counters collected data')
    elif document['counter_bytes'] != (document['segment_count'] + 5) * 23 * 8:
        raise ValueError('Counter storage dimensions differ')
    attempts = totals['concat_attempts']
    refused = sum(totals[name] for name in names[4:])
    return dict(counts={name: totals[name] for name in names}, attempts=attempts, refusals=refused,
                refusalFraction=refused / attempts if attempts else None,
                nodesPerAttempt=totals['concat_nodes_examined'] / attempts if attempts else None,
                timingClaim=False, exactProgramOutputVerified=False,
                limitations=['Events cover the complete invocation, not only a timed kernel.',
                             'Node visits are not attributed to individual outcomes or source allocations.',
                             'Positive hooks are source-audited; independent ABI fixture covers old channels and new zero channels only.',
                             'Use the separate run receipt to establish exact ordinary program outputs.'])


def main():
    from runtime import pin, verify
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--events', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists():
        parser.error('Output must be fresh')
    source = pin(args.events)
    result = summarize(json.loads(args.events.read_text()))
    verify(source)
    args.out.write_text(json.dumps(dict(schema='bend-concat-events-summary-v1', complete=True,
                                      targetsRun=False, inputs=[source, pin(__file__),pin(Path(__file__).parent/'controls/runtime-control.expected.json')], **result), indent=2) + '\n')


if __name__ == '__main__':
    main()
