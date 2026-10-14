#!/usr/bin/env python3
"""Offline finite fixture generator; no Bend compiler or target execution."""
import hashlib, itertools, json, sys
from pathlib import Path

assert len(sys.argv) == 2, 'Usage: make-controls.py NEW_CONTROL.bend'
here = Path(__file__).resolve().parent
out = Path(sys.argv[1])
alphabet = [0, 97, 233, 128512]
corpus = [list(s) for n in range(3) for s in itertools.product(alphabet, repeat=n)]
extra = ['a\nb', 'a\tb', '\r\n', 'e\u0301', 'é', 'λ', '😀', '😁', '\ue000', '\U00010000', '\U0010ffff']
corpus += [[ord(c) for c in s] for s in extra]
for n in [1, 8, 64]:
    corpus += [[97]*n, [97]*n+[98], [97]*n+[99]]
seen = set()
corpus = [s for s in corpus if tuple(s) not in seen and not seen.add(tuple(s))]
helpers = here/'helpers.bend'
tail = here/'controls.tail.bend'
literal = 'def p88_corpus() -> List<&2, String>:\n  [\n' + ',\n'.join(
    '    p88_codes(['+', '.join(map(str,s))+'])' for s in corpus) + '\n  ]\n'
before_main, main_body = tail.read_text().rsplit('\ndef main()', 1)
source = 'import Base\n\n' + helpers.read_text() + '\n' + before_main + '\n' + literal + '\ndef main()' + main_body
with out.open('x') as f: f.write(source)
pin = lambda p: dict(file=str(p.resolve()), sha256=hashlib.sha256(p.read_bytes()).hexdigest(), bytes=p.stat().st_size)
report = dict(kind='phase88-string-finite-controls', source=pin(out), corpus=corpus,
              strings=len(corpus), pairs=len(corpus)**2,
              inputs=[pin(helpers),pin(tail),pin(Path(__file__))],
              checksPerPair=['Base equality','shared equality','owned-copy equality','Base order',
                             'shared order','owned-copy order','reused lengths','reused codepoint sums'])
with out.with_suffix('.json').open('x') as f: json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(dict(source=str(out), strings=len(corpus), pairs=len(corpus)**2)))
