#!/usr/bin/env python3
"""Source-only P70-008 image discriminator; never a shipping compiler image."""
import argparse
import difflib
import hashlib
import json
import os
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[4]


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def function(source, name):
    start = source.index('function '+name+'(')
    assert start == 0 or source[start-1] == '\n'
    after = re.search(r'^function ', source[start+1:], re.M)
    assert after
    end = start+1+after.start()
    return start, end, source[start:end]


def transform(source, role):
    name = '$no_route_one$' if role == 'b1' else '$jd$no_95_route_95_one'
    start, end, before = function(source,name)
    if role == 'b1':
        original = '  return $no_route_plan$(_book_0, _entry_0, _old_0, run_loop($no_observer_plan$(_book_0, _name_0, true)));'
        guarded = '''  return run_tail((($nb_contains$(($no_route_ready$(_old_0)), _name_0))) ? ((_x_2) => {
  return _old_0;
}) : ((_x_3) => {
  return $no_route_plan$(_book_0, _entry_0, _old_0, run_loop($no_observer_plan$(_book_0, _name_0, true)));
}), {$: "Unit"});'''
    else:
        original = '"NOEligibleEntry"))){return ('
        guarded = '"NOEligibleEntry"))){if($jd$nb_95_contains($jd$no_95_route_95_ready($x47402),$x47400)){return $x47402;}return ('
    assert before.count(original) == 1
    after = before.replace(original,guarded)
    output = source[:start]+after+source[end:]
    assert output.replace(after,before,1) == source
    return output, dict(function=name,startByte=len(source[:start].encode()),
        exactBefore=before,exactAfter=after,
        operation='Lazy exact ordinary-owner readiness test inside the existing eligible-entry branch; return unchanged NO_Route on membership. The actual Bend plan and all other functions remain byte-identical.')


def main():
    assert os.sched_getaffinity(0) == {0}
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--occurrence-derivation',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    args=ap.parse_args()
    assert not args.out.exists()
    assert args.out.resolve().is_relative_to(ROOT/'build/phase70')
    occ_pin=pin(args.occurrence_derivation)
    occurrence=json.loads(args.occurrence_derivation.read_text())
    assert occurrence['complete'] and occurrence['dataOnly'] and not occurrence['targetExecuted']
    args.out.mkdir(parents=True)
    rows=[]
    for occ in occurrence['rows']:
        role=occ['role']
        original=Path(occ['original']['file']); disabled=Path(occ['output']['file'])
        assert pin(original)==occ['original'] and pin(disabled)==occ['output']
        source=original.read_text(); off=disabled.read_text()
        skipped,edit=transform(source,role)
        both,off_edit=transform(off,role)
        assert edit['exactBefore']==off_edit['exactBefore'] and edit['exactAfter']==off_edit['exactAfter']
        assert source.count(occ['exactBefore'])==1 and skipped.count(occ['exactBefore'])==1
        assert skipped.replace(occ['exactBefore'],occ['exactAfter'],1)==both
        assert both.replace(edit['exactAfter'],edit['exactBefore'],1)==off
        for arm,content in [('ordinary-skip',skipped),('both',both)]:
            output=args.out/(role+'-'+arm+'.mjs')
            output.write_text(content)
            patch=args.out/(role+'-'+arm+'.patch')
            patch.write_text(''.join(difflib.unified_diff(source.splitlines(True),content.splitlines(True),fromfile=str(original),tofile=str(output))))
            rows.append(dict(role=role,arm=arm,original=pin(original),occurrenceOff=pin(disabled),
                output=pin(output),patch=pin(patch),observerEdit=edit,
                reverseOriginalVerified=True,commutesWithOccurrenceAblation=True))
        assert pin(original)==occ['original'] and pin(disabled)==occ['output']
    assert pin(args.occurrence_derivation)==occ_pin
    record=dict(kind='phase70-P008-saved-api-factorial-inputs-v1',complete=True,dataOnly=True,
        targetExecuted=False,shippingCandidate=False,producer=pin(__file__),occurrenceDerivation=occ_pin,
        bendProposal=pin(Path(__file__).with_name('ordinary-ready-v1.patch')),rows=rows,
        scope='Causal generated-source diagnostic only. B1 uses existing nt_choose closure/trampoline convention; B2 uses its direct literal choice convention. Whole original prefixes/suffixes and every other function are unchanged except the independent occurrence ablation in both arms. Require identical Numeric C at qualification; currently String.cmp is the only emitted observer and has no ordinary NF worker. Timing and correctness are not established here.')
    (args.out/'derivation.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(dict(derivation=pin(args.out/'derivation.json'),outputs=[r['output'] for r in rows])))


if __name__=='__main__':
    main()
