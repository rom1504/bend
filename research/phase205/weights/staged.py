"""Counterfactual only. Apply published per-case source ratios to frozen weights."""
import gzip
import json
from pathlib import Path
R=Path(__file__).resolve().parents[3]
def read(name):
    with gzip.open(R/name) as f:
        return json.load(f)
weights=json.loads((R/'research/phase205/weights/results01.json').read_text())['cases']
rows={w['id']:w for w in weights}
lex=read('research/phase200/lex/lex-token03-verified.json.gz')
more=read('research/phase200/lex/lex-stage01-verified.json.gz')
ratios={'lexer':lex['candidateOverBaseline']}
for case in more['cases']:
    if case['id'] in rows:
        ratios[case['id']]=case['ratios']['candidate']/case['ratios']['baseline']
text=read('research/phase200/text/measurements.json.gz')
ratios.update({k:c['ratios']['distributed']['stock'] for k,c in text['cases'].items()})
assert len(ratios)==5
savings={k:rows[k]['candidate']['seconds']*(1-r) for k,r in ratios.items()}
x=sum(w['candidate']['seconds'] for w in weights)
c=sum(w['c']['seconds'] for w in weights)
print(json.dumps(dict(scope='Counterfactual at Phase200 fixed weights. Source speedups were timed separately against their own x86 executable. No compiler or suite rerun.',ratios=ratios,savings=savings,
  projectedFixedRatio=(x-sum(savings.values()))/c,projectedLexerOnly=(x-sum(v for k,v in savings.items() if 'lexer' in k))/c),indent=2))
