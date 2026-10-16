#!/usr/bin/env python3
"""C ablation approximating Bend's original-hint and logical TRMC worker policy."""
import importlib.util
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
ORIGINAL = Path(__file__).with_name('prepare.py')
spec = importlib.util.spec_from_file_location('p102_depth_c_base', ORIGINAL)
B = importlib.util.module_from_spec(spec); spec.loader.exec_module(B)
parse_graph = B.transform


def transform(source, limit=8192, passes=3):
    assert limit == 8192, 'Eligibility comes from original NF_INLINE, not a new C-size cutoff'
    _, parsed = parse_graph(source, limit, passes)
    physical = {r['name']:r for r in parsed['workers']}
    groups = {name:name for name in physical}
    for name in physical:
        if name.endswith('_trmc'):
            owner = name[:-len('_trmc')]
            assert owner in physical, ('Private loop lacks public owner', name)
            assert physical[owner]['originalHint'] == physical[name]['originalHint']
            groups[name] = owner
    logical = {}
    for name, row in physical.items():
        owner = groups[name]
        if name != owner or owner not in logical:
            logical[owner] = dict(name=owner, body=name, originalHint=row['originalHint'],
                callees=sorted({groups.get(c, c) for c in row['calls']}))
    eligible = {name for name,row in logical.items() if row['originalHint']=='NF_INLINE'}
    selected = set(); rounds = []
    for level in range(passes):
        previous = selected
        selected = {name for name in eligible if set(logical[name]['callees']) <= previous}
        assert previous <= selected
        rounds.append(dict(level=level,count=len(selected),added=sorted(selected-previous)))
    emitted = {name for name in physical if groups[name] in selected}
    edits = []
    pattern = re.compile(r'^NF_INLINE(?= Term (NF_FID_\w+)\()', re.M)
    for match in pattern.finditer(source):
        if match[1] not in emitted:
            edits.append(dict(offset=match.start(),old='NF_INLINE',new='INLINE'))
    pieces = []; cursor = 0
    for edit in edits:
        at = edit['offset']; pieces.extend([source[cursor:at],edit['new']]); cursor=at+len(edit['old'])
    pieces.append(source[cursor:]); candidate=''.join(pieces)
    parts=[];cursor=0;shift=0
    for edit in edits:
        at=edit['offset']+shift
        assert candidate[at:at+len(edit['new'])]==edit['new']
        parts.extend([candidate[cursor:at],edit['old']]);cursor=at+len(edit['new'])
        shift+=len(edit['new'])-len(edit['old'])
    parts.append(candidate[cursor:]);assert ''.join(parts)==source
    for name,row in physical.items(): row.update(logicalOwner=groups[name],selected=name in emitted)
    return candidate,dict(kind='phase102-logical-c-depth-inline',targetsRun=False,limit=limit,passes=passes,
        maximumForcedLogicalDepth=passes-1,definitions=len(physical),logicalWorkers=len(logical),
        originallyForced=parsed['originallyForced'],selected=len(emitted),logicalSelected=len(selected),
        demoted=parsed['originallyForced']-len(emitted),hintTokensChanged=len(edits),inverseExact=True,
        rounds=rounds,workers=list(physical.values()),logicalGraph=list(logical.values()),parser=B.pin(ORIGINAL),
        scope='Original NF_INLINE is the existing NC_Text-size eligibility; TRMC public/private pair '
              'shares inner dependencies and one hint. Actual C calls may still differ from NF_Worker.deps. '
              'Generated-C experiment, not actual Bend emission or native-image qualification.')


def controls():
    def f(name,calls='',hint='NF_INLINE'):
        return f'{hint} Term NF_FID_{name}(Env e);\n{hint} Term NF_FID_{name}(Env e) {{ {calls} return 1; }}\n'
    source=f('a')+f('b_trmc','NF_FID_a(e);')+f('b','NF_FID_b_trmc(e);')+f('c','NF_FID_b(e);')+f('d','NF_FID_c(e);')
    _, report=transform(source)
    assert {r['name'] for r in report['workers'] if r['selected']} == {'NF_FID_a','NF_FID_b','NF_FID_b_trmc','NF_FID_c'}
    _, report=transform(f('large',' '*9000)+f('ordinary',hint='INLINE')+f('missing','NF_FID_absent(e);')+f('cycle','NF_FID_cycle(e);'))
    assert {r['name'] for r in report['workers'] if r['selected']}=={'NF_FID_large'}
    return dict(complete=True,targetsRun=False,cases=['logical-TRMC-depth','shared-wrapper-inner-hint',
        'original-hint-size-eligibility','ordinary-refusal','missing-refusal','cycle-refusal','exact-inverse'])


if __name__=='__main__':
    B.transform=transform;B.controls=controls
    B.__file__=str(Path(__file__).resolve())
    B.main()
