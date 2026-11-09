#!/bin/sh
# Metadata transport only; the root lane separately checks and executes this API.
set -eu
out="$1"
python3 - "$out-source" <<'PYROOT'
import json,pathlib,re,sys
out=pathlib.Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=False)
manifest=json.loads(pathlib.Path('selfhost/src/compiler.json').read_text())
# Add lexical fixture references to maintained definitions before the first
# dependency extraction. This selects declarations; it does not check Bend.
fixture_paths=[*pathlib.Path('selfhost/tests/phase188').glob('*.bend'),
 *[pathlib.Path('selfhost/tests/phase186')/(name+'-controls.bend') for name in
 ['inline-effects','private','expression','float-values']],
 *[pathlib.Path('selfhost/tests/phase187')/('object-'+name+'-controls.bend') for name in ['elf','parse','encode']]]
refs=set(re.findall(r'\b[A-Za-z_][A-Za-z_0-9.]*', '\n'.join(p.read_text() for p in fixture_paths)))
defs=set()
for relative in dict.fromkeys(manifest['modules']+manifest['profiles']['x86'].get('modules',[])):
 defs.update(re.findall(r'^def ([A-Za-z_][A-Za-z_0-9.]*)',pathlib.Path('selfhost',relative).read_text(),re.M))
for name in sorted((refs&defs)|{'x188_render','x188_assemble','x187_assemble'}):
 if name not in manifest['profiles']['x86']['roots']:manifest['profiles']['x86']['roots'].append(name)
(out/'api-source.json').write_text(json.dumps(manifest,indent=2)+'\n')
PYROOT
python3 -B selfhost/tools/build/source.py assemble --manifest "$out-source/api-source.json" --root selfhost --profile x86 --out "$out-source/compiler.bend" --map "$out-source/source-map.json"
python3 -B selfhost/tests/phase181/prepare.py --parent-source "$out-source/compiler.bend" \
 --module selfhost/tests/phase188/legacy-adapters.bend \
 --module selfhost/tests/phase186/inline-effects-controls.bend \
 --module selfhost/tests/phase188/callee-save-controls.bend \
 --module selfhost/tests/phase186/private-controls.bend \
 --module selfhost/tests/phase188/parallel-controls.bend \
 --module selfhost/tests/phase186/expression-controls.bend \
 --module selfhost/tests/phase188/call-argument-controls.bend \
 --module selfhost/tests/phase186/float-values-controls.bend \
 --module selfhost/tests/phase188/xmm-controls.bend \
 --module selfhost/tests/phase188/u32-float-controls.bend \
 --module selfhost/tests/phase187/object-elf-controls.bend \
 --module selfhost/tests/phase187/object-parse-controls.bend \
 --module selfhost/tests/phase187/object-encode-controls.bend \
 --export x188_render --export x188_assemble --export x187_assemble \
 --export p186ie_validate --export p186ie_controls --export p186ie_emit \
 --export p186_sv_controls --export p186_sv_emit \
 --export p186pm_validate --export p186pm_controls --export p186pm_emit \
 --export p186mv_validate --export p186mv_controls --export p186mv_emit \
 --export p186ce_validate --export p186ce_controls --export p186ce_emit \
 --export p186ca_controls --export p186ca_emit \
 --export p186fv_validate --export p186fv_controls --export p186fv_emit \
 --export p186xm_validate --export p186xm_controls --export p186xm_emit \
 --export p186uf_controls --export p186uf_emit \
 --export p187el_controls --export p187el_object --export p187el_assembly \
 --export x187_parse_controls --export x187ec_controls --out "$out"
