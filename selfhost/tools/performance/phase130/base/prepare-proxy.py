"""Extract exact checked decoder declarations; no compiler or target execution."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PAT = re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b', re.M)


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def blocks(text):
    hits = list(PAT.finditer(text))
    return {h[1]: text[h.start():hits[i+1].start() if i+1<len(hits) else len(text)] for i,h in enumerate(hits)}


def norm(text):
    return '\n'.join(x.rstrip() for x in text.splitlines() if x.strip() and not x.lstrip().startswith('#'))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--api-report', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase130')
    selection_file = ROOT / 'implementation/phase128/candidate.json'
    selected = json.loads(selection_file.read_text())
    assert selected['complete'] and selected['nativeQualified']
    api = json.loads(a.api_report.read_text()); assert api['complete'] and api['checked'] and api['status'] == 0
    sources = [Path(x).resolve() for x in api['command'] if x.endswith('.bend')]; assert len(sources)==1
    candidate = pin(sources[0]); assert candidate in api['inputs']
    parent = selected['source']; assert pin(parent['file']) == parent
    original = blocks(Path(parent['file']).read_text()); current = blocks(sources[0].read_text())
    decoder = ROOT / 'selfhost/tools/performance/phase88/base/decoder.bend'
    names = ['KTerm','KDef','KBasePrefixState','KBasePreparedWorld','FFreshPrefixState','FReadyPrefixState']
    names += list(blocks(decoder.read_text()))
    names += ['p86_read_eof','p86_read_more','p86_read_sized','p86_read_limit','p86_read_file']
    assert len(names)==len(set(names))
    assert [n for n in names if norm(original[n])!=norm(current[n])] == ['p88_u32']
    extras = blocks((HERE / 'word-pair.bend').read_text())
    assert all(norm(current[n])==norm(v) for n,v in extras.items())
    wrapper = (HERE / 'native-main.bend').read_text()
    inputs = [pin(__file__),pin(selection_file),parent,pin(a.api_report),candidate,api['api'],
              *api['inputs'],pin(decoder),pin(HERE/'word-pair.bend'),pin(HERE/'native-main.bend')]
    inputs = list({x['file']:x for x in inputs}.values())
    for row in inputs: assert pin(row['file'])==row
    out.mkdir(parents=True)
    variants = {}
    for label, definitions in [('decimal', original), ('word', current)]:
        text = 'import Base\n\n' + '\n'.join(definitions[n] for n in names)
        text += '\n' + '\n'.join(extras.values()) + '\n' + wrapper
        folder = out / label; folder.mkdir(); (folder/'main.bend').write_text(text)
        variants[label] = dict(source=pin(folder/'main.bend'),decoderSource=parent if label=='decimal' else candidate,
                               copiedDeclarations=names,semanticChange=[] if label=='decimal' else ['p88_u32'])
    report = dict(kind='phase130-decoder-proxy-source', complete=True, checked=False, targetsRun=False,
        inputs=inputs, variants=variants, begin=1, end=75066,
        scope='Exact selected/checked candidate decoder and Data declarations, shared read-only timing wrapper. Independently check/compile these new source files. Numeric decoder alone differs. Native output is a small liveness sentinel, not full-product equivalence; graph-aware hosted full-products/alias checks and complete request-QBE gates remain separate.')
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetsRun=False,variants=variants)))


if __name__ == '__main__':
    main()
