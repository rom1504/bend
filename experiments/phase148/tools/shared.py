"""Host transport/preparation only. Compiler semantics stay in checked Bend."""
import importlib.util
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import source as assembly
from common import fresh_output,pin,require,verify,write_json

# Reuse exact read-only Phase147 declaration closure and ADT literal transport.
# Its command-line recipe is not invoked; current source identity is checked here.
_previous=ROOT/'experiments/phase147/tools'
sys.path.insert(0,str(_previous))
import prepare as extraction
_spec=importlib.util.spec_from_file_location('phase147_literal_transport',_previous/'native-slice.py')
transport=importlib.util.module_from_spec(_spec);_spec.loader.exec_module(transport)
sys.path.remove(str(_previous))
extract,guard=extraction.extract,extraction.guard
literal,fields=transport.literal,transport.fields

def sources(modules):
    recipe=ROOT/'selfhost/src/compiler.json'
    canonical=assembly.maintained_assemble(recipe,ROOT/'selfhost','qbe')
    import hashlib
    identity=dict(bytes=len(canonical),sha256=hashlib.sha256(canonical).hexdigest())
    candidate=json.loads((ROOT/'implementation/phase147/candidate.json').read_text())
    require(identity=={k:candidate['source'][k]for k in ['bytes','sha256']},'Canonical source moved from explicit Phase147 boundary')
    inputs=[pin(__file__),pin(assembly.__file__),pin(extraction.__file__),pin(transport.__file__),
            pin(recipe),pin(ROOT/'implementation/phase147/candidate.json')]
    parts=[('canonical',canonical)]
    for file in modules:
        file=Path(file);parts.append((file.name,file.read_bytes()));inputs.append(pin(file))
    return parts,inputs,identity

def current_capture(file):
    report=json.loads(file.read_text());require(report['complete']and report['kind']=='phase147-verifier-input-capture','Completed actual capture required')
    for row in report['rows']:verify(row['data']);verify(row['source'])
    return report
