#!/usr/bin/env python3
"""Freeze one candidate-source challenge before viewing its tests or laws."""
import datetime
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent


def pin(path):
    b = path.read_bytes()
    return dict(path=str(path.relative_to(ROOT)), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


def save(path, value):
    with path.open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')


def main():
    file = 'selfhost/tools/performance/phase98/comparison/literal-helpers01.bend'
    source = (ROOT / file).read_text()
    before = '    case SCon{Chr{86}, SCon{Chr{97}, SCon{Chr{114}, SNil{}}}}: True{}'
    after = '    case SCon{Chr{86}, SCon{Chr{97}, SCon{Chr{114}, rest}}}: True{}'
    assert source.count(before) == 1
    changed = source.replace(before, after, 1).encode()
    identifier = 'bad06-literal-recognizer-accepts-prefix'
    witness = HERE / (identifier + '.witness.bend')
    with witness.open('x') as stream:
        stream.write('@unsafe\ndef p98_literal_prefix_actual() -> Bool:\n  p98_eq_var("Varx")\n\n')
        stream.write('@unsafe\ndef p98_literal_prefix_baseline_expected() -> Bool:\n  False{}\n\n')
        stream.write('@unsafe\ndef p98_literal_prefix_challenge_expected() -> Bool:\n  True{}\n')
    recipe = dict(schema='phase98-independent-challenge-v1', id=identifier, kind='bad',
        file=file, function='p98_eq_var', before=before, after=after,
        source=pin(ROOT/file), expectedOccurrences=1,
        line=source[:source.index(before)].count('\n')+1,
        changedSourceBytes=len(changed), changedSourceSha256=hashlib.sha256(changed).hexdigest(),
        expectedBehavior='An exact literal recognizer must reject a strict extension. Replacing the terminal empty string by an ignored tail turns equality into prefix matching.',
        witness=dict(expression='p98_eq_var("Varx")', returnType='Bool', baselineValueBend='False{}',
                     challengeValueBend='True{}', source=pin(witness)),
        provenance=dict(classification='synthetic-semantic-fault',
                        selection='Candidate helper source inspected after the first maintained-source freeze, but before its tests, laws, oracle, admission or outcomes.'),
        admission='predicted well-typed; root must check', domain='All finite String values.', targetsRun=False)
    save(HERE/(identifier+'.json'), recipe)
    save(HERE/'literal-manifest01.json', dict(schema='phase98-independent-challenge-supplement-v1',
        frozenAt=datetime.datetime.now(datetime.timezone.utc).isoformat(), method=pin(Path(__file__)),
        previous=pin(HERE/'manifest.json'), cases=[pin(HERE/(identifier+'.json'))],
        counts=dict(bad=1, good=0), targetsRun=False,
        protocol='Run unchanged frozen laws and finite tests first; preserve escapes before adding the independent Varx witness. Require helper admission for semantic rejection credit.'))


if __name__ == '__main__':
    main()
