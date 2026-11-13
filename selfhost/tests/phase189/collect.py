#!/usr/bin/env python3
"""Collect completed release evidence; no compiler or benchmark executes."""
from pathlib import Path
import hashlib
import json
import struct

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build/phase189'
OUT = ROOT / 'implementation/phase189'


def pin(file):
    data = file.read_bytes()
    return dict(file=str(file.relative_to(ROOT)), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def sections(file):
    data = file.read_bytes()
    assert data[:6] == b'\x7fELF\x02\x01'
    offset = struct.unpack_from('<Q', data, 40)[0]
    stride, count, names_index = struct.unpack_from('<HHH', data, 58)
    rows = [struct.unpack_from('<IIQQQQIIQQ', data, offset + i * stride) for i in range(count)]
    names_row = rows[names_index]
    names = data[names_row[4]:names_row[4]+names_row[5]]
    return {names[row[0]:].split(b'\0', 1)[0].decode():
            dict(bytes=row[5], sha256=hashlib.sha256(data[row[4]:row[4]+row[5]]).hexdigest())
            for row in rows if row[1] != 8}


reports = {}
for name, file in {
    'reproduction': BUILD/'native-n3-01/report.json',
    'native64': BUILD/'native64-01/report.json',
    'runtime10': BUILD/'runtime10-01/report.json',
    'preparation': BUILD/'release-proposal01/report.json',
    'audit': BUILD/'release-proposal01/audit.json',
    'installation': BUILD/'install01/report.json',
    'publication': BUILD/'publish-assets01/report.json',
    'public': BUILD/'public01/report.json',
    'retention': ROOT/'selfhost/build-retention/phase189/reserve-recovery01/summary.json',
}.items():
    document = json.loads(file.read_text())
    if name != 'retention':
        assert document.get('complete') is True and not document.get('error'), (name, document.get('error'))
        assert not document.get('changedInputs'), name
    reports[name] = dict(pin=pin(file), report=document)

before = json.loads((BUILD/'before-current.json').read_text())
current_file = ROOT/'selfhost/manifests/current.json'
current = json.loads(current_file.read_text())
for name in ('qbe', 'js', 'nativeCli'):
    assert current['components'][name] == before['components'][name], name
assert current['source']['identity'] == before['source']['identity']
assert current['components']['x86']['defaultEmission'] == 'object'
assert current['gateStatus']['qualified'] is True
assert current['components']['x86']['image']['sha256'] == '942b88c7f3049113ddeb9a3e6d2f502c73c36675508f42a3652ced53da3ae098'
n2_file = ROOT/'selfhost/build/phase188/native-self-object05/program'
n3_file = BUILD/'native-n3-01/program'
n2_sections, n3_sections = sections(n2_file), sections(n3_file)
different = sorted(name for name in set(n2_sections) | set(n3_sections)
                   if n2_sections.get(name) != n3_sections.get(name))
assert different == ['.note.gnu.build-id', '.strtab', '.symtab'], different
result = dict(kind='phase189-direct-object-default-evidence', version=1, complete=True,
    installed=True, mathematicalProof=False, performanceCampaign=False,
    method=pin(Path(__file__)), before=pin(BUILD/'before-current.json'), selector=pin(current_file),
    preservedComponents=['qbe','js','nativeCli'], previousX86=before['components']['x86'],
    selectedX86=current['components']['x86'], reports=reports,
    linkedComparison=dict(n2=pin(n2_file), n3=pin(n3_file),
                          differingSections=different, n2Sections=n2_sections, n3Sections=n3_sections))
OUT.mkdir(exist_ok=True)
(OUT/'evidence.json').write_text(json.dumps(result, indent=2)+'\n')
print('Evidence written:', OUT/'evidence.json')
