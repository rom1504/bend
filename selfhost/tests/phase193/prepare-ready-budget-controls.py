#!/usr/bin/env python3
"""Metadata-only preparation of the original ready controls against budget source.

Reuses immutable v2 fixtures and controls03 root/export choices. Runs only the
maintained Python source assembler/extractor; never invokes Bend/Bun/checking.
"""
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
PHASE = ROOT / "selfhost/build/phase193"


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def functions(text):
    lines = text.splitlines(); result = {}
    for index, line in enumerate(lines):
        match = re.match(r"def (x193\w+)\b", line)
        if not match:
            continue
        body = [line]; next_line = index + 1
        while next_line < len(lines) and lines[next_line].startswith(" "):
            body.append(lines[next_line]); next_line += 1
        result[match.group(1)] = "\n".join(body)
    return result


def main():
    canonical = ROOT / "selfhost/src/compiler.json"
    old_manifest = PHASE / "controls-manifest03.json"
    old_preparation = PHASE / "controls-api-source03/manifest.json"
    old_binding = PHASE / "controls-api-source03/base-binding.json"
    maintained = ROOT / "selfhost/src/back/x86/public-composition.bend"
    selected = PHASE / "selected-source02/compiler.bend"
    budget_api = PHASE / "budget-api-source01/compiler.bend"
    method = ROOT / "selfhost/tools/build/source.py"
    extractor = ROOT / "selfhost/tests/phase190/prepare-api.py"
    manifest_out = PHASE / "controls-manifest04.json"
    parent_out = PHASE / "controls-parent04"
    api_out = PHASE / "controls-api-source04"
    receipt = PHASE / "controls-prepare04.json"
    for fresh in (manifest_out, parent_out, api_out, receipt):
        assert not fresh.exists(), "Fresh destination required: " + str(fresh)
    assert pin(selected)["sha256"] == "fd95adc1bdc210bc3827c9dd3536b8e7289fb60c4e983f0e008714665239428a"
    selected_functions = functions(maintained.read_text())
    assert len(selected_functions) == 28
    for source in (selected, budget_api):
        other = functions(source.read_text())
        assert all(other.get(name) == body for name, body in selected_functions.items())
    old = json.loads(old_manifest.read_text())
    current = json.loads(canonical.read_text())
    preparation = json.loads(old_preparation.read_text())
    binding = json.loads(old_binding.read_text())
    assert old["profiles"]["x86"]["modules"] == current["profiles"]["x86"]["modules"]
    assert old["protectedDeclarations"] == current["protectedDeclarations"]
    roots = old["profiles"]["x86"]["roots"]
    assert roots == ["main", "p112w_index", "p111v_functions", "p111v_segments"]
    fixtures = [ROOT / "selfhost/tests/phase193/public-fusion-controls-v2.bend",
                ROOT / "selfhost/tests/phase193/ready-fusion-controls-v2.bend"]
    for fixture in fixtures:
        assert pin(fixture) in preparation["inputs"], "Changed original fixture: " + str(fixture)
    exports = preparation["exports"]
    inputs = [pin(path) for path in (__file__, canonical, old_manifest, old_preparation,
        old_binding, maintained, selected, budget_api, method, extractor, *fixtures)]
    spec = importlib.util.spec_from_file_location("phase193_control_source", method)
    source = importlib.util.module_from_spec(spec); spec.loader.exec_module(source)
    # First establish that the maintained ordinary profile is the frozen budget
    # source. The additional roots below exist only for fixture admission.
    ordinary = source.maintained_assemble(canonical, ROOT / "selfhost", "x86")
    assert ordinary == selected.read_bytes()
    current["profiles"]["x86"]["roots"] = roots
    manifest_out.write_text(json.dumps(current, indent=2) + "\n")
    parent, source_map = source.maintained_assemble(manifest_out, ROOT / "selfhost", "x86", True)
    parent_out.mkdir()
    (parent_out / "compiler.bend").write_bytes(parent)
    (parent_out / "source-map.json").write_text(json.dumps(source_map, indent=2) + "\n")
    command = [sys.executable, str(extractor), "--parent-source", str(parent_out / "compiler.bend"),
        "--assets", binding["assets"]["file"], "--out", str(api_out)]
    for fixture in fixtures:
        command.extend(["--module", str(fixture)])
    for name in exports[7:]:
        command.extend(["--export", name])
    process = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    (parent_out / "extract.stdout").write_bytes(process.stdout)
    (parent_out / "extract.stderr").write_bytes(process.stderr)
    report = dict(kind="phase193-budget-ready-controls-source-preparation", complete=False,
        targetsRun=False, compilerExecuted=False, inputs=inputs, command=command,
        extractionExitCode=process.returncode, manifest=pin(manifest_out),
        parentSource=pin(parent_out / "compiler.bend"), parentMap=pin(parent_out / "source-map.json"),
        selectedSource=pin(selected), comparedFunctionCount=28,
        selectedFunctionsEqualBudgetApi=True, maintainedProfileEqualsSelected=True,
        functionTextSha256=hashlib.sha256("\n\n".join(selected_functions[name] for name in sorted(selected_functions)).encode()).hexdigest(),
        fixtures=[pin(f) for f in fixtures], exports=exports,
        scope="Metadata transport only; same original v2 fixtures and export roots, current budget consumer. New source still needs checked API acquisition and the root-owned ready controls run.")
    try:
        assert process.returncode == 0, process.stderr.decode()
        final = json.loads((api_out / "manifest.json").read_text())
        assert final["complete"] and final["exports"] == exports and final["replacements"] == []
        actual = functions((api_out / "compiler.bend").read_text())
        assert all(actual.get(name) == body for name, body in selected_functions.items())
        assert all(pin(item["file"]) == item for item in inputs), "Inputs changed"
        report.update(complete=True, source=pin(api_out / "compiler.bend"),
            preparation=pin(api_out / "manifest.json"), exportManifest=pin(api_out / "exports.json"),
            preparedFunctionsEqualSelected=True)
    finally:
        receipt.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({key: report.get(key) for key in ("complete", "source", "comparedFunctionCount", "compilerExecuted")}))


if __name__ == "__main__":
    main()
