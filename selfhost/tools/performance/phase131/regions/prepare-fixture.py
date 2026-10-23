"""Freeze exact compiler kernels and pre-execution ordinary/timed oracles."""
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SOURCE = ROOT / 'selfhost/build/phase130/mode-source01/compiler.bend'
SHA = '995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def freeze(path, data):
    if not isinstance(data, str): data = json.dumps(data, indent=2, ensure_ascii=False) + '\n'
    data = data.encode()
    if path.exists(): assert path.read_bytes() == data, 'Changed frozen output: ' + str(path)
    else: path.write_bytes(data)
    return pin(path)


def main():
    assert pin(SOURCE)['sha256'] == SHA
    lines = SOURCE.read_text().splitlines(keepends=True)
    blocks = []
    spans = []
    names = ['KTerm','p88_string_eq_go','p98_eq_finish','p88_string_eq','p98_tag_eq_read','p98_tag_eq_finish','p98_tag_eq']
    for name in names:
        starts = [i for i,line in enumerate(lines) if re.match(r'^(?:def|type) '+re.escape(name)+r'(?:\(| is)',line)]
        assert len(starts) == 1, name
        start = starts[0]; end = start + 1
        while end < len(lines) and (not lines[end].strip() or lines[end][0].isspace() or lines[end].startswith(') -> ')): end += 1
        while not lines[end-1].strip(): end -= 1
        text = ''.join(lines[start:end]); blocks.append(text)
        spans.append(dict(name=name, firstLine=start+1,lastLine=end,sha256=hashlib.sha256(text.encode()).hexdigest()))
    common = 'import Base\n\n' + '\n'.join(blocks) + '\n'
    workload = (HERE/'workload.bend').read_text()
    output = '1\n0\n1\n1\n1\n1\n1\n0\n0\n1\n3\n3\n'
    expected = freeze(HERE/'expected.json',dict(status=0,stdout=output,stderr=''))
    stdout = freeze(HERE/'expected.stdout',output)
    cases = []
    for variant in ['compiler-tag','record-transfer']:
        call = 'p98_tag_eq(term,key)' if variant == 'compiler-tag' else 'p131_packet_query(packet,key)'
        miss = 'p98_tag_eq(term,"Mat")' if variant == 'compiler-tag' else 'p131_packet_query(packet,"Mat")'
        once = 'def p131_once(+term: KTerm, +packet: P131Packet, +key: String) -> U32:\n  U32.add(Bool.to_u32('+call+'),Bool.to_u32('+miss+'))\n\n'
        # Put the dependent once body after packet helpers but before repeat.
        at = workload.index('def p131_repeat(')
        text = common + workload[:at] + once + workload[at:]
        source = freeze(HERE/(variant+'.bend'),text)
        cases.append(dict(name=variant,source=source,expected=expected,expectedStdoutEvidence=expected))
    manifest = freeze(HERE/'cases.json',dict(complete=True,cases=cases))
    freeze(HERE/'oracle.json',dict(complete=True,frozenBeforeExecution=True,targetsRun=False,checked=False,
        inputs=[pin(SOURCE),pin(__file__),pin(HERE/'workload.bend')],extracted=spans,cases=manifest,
        ordinary=dict(expected=expected,stdout=stdout,method='Specified equality of explicit KTerm tags and packet labels; payload list [3,5,7] has length three. No target outputs used.'),
        timed=dict(argv=['100000'],expectedPrefix='1\n100000\n',lastLine='one unsigned elapsed integer in IO.now milliseconds',calibrated=False,
            method='Each repetition performs one successful and one failed equality, adding one modulo 2^32; sum is repetitions modulo 2^32.'),
        admission=dict(positive=['p98_tag_eq','p98_tag_eq_read','p131_packet_query','p131_packet_read'],negative=['p131_opaque_count','p131_opaque_escape']),
        scope='Exact source extraction and independent output construction, not checked admission, execution or performance evidence.'))
    print(json.dumps(dict(cases=manifest,expected=stdout)))


if __name__ == '__main__': main()
