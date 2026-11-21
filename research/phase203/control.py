"""Check the full trial source separately, then exercise both real selectors."""
import argparse
import subprocess
from pathlib import Path
from assembly import ROOT

HERE = Path(__file__).resolve().parent

def check(out, source):
    out.mkdir(parents=True, exist_ok=False)
    bun = ROOT/"selfhost/.assets/bin/bun"
    upstream = ROOT/"selfhost/.bootstrap/upstream-phase182"
    def run(label, command):
        with (out/(label+".stdout")).open("xb") as stdout, (out/(label+".stderr")).open("xb") as stderr:
            subprocess.run(command, stdout=stdout, stderr=stderr, check=True)
    run("check", [bun, "selfhost/tools/build/check-source.mjs", "--source", source/"compiler.bend",
                  "--out", out/"check", "--manifest", "selfhost/build/phase198/progress-portfolio01/maintained/src/compiler.json",
                  "--upstream", upstream])
    run("api", [bun, "selfhost/tools/build/hosted.mjs", "acquire", "--source", source/"control.bend",
                "--exports", source/"exports.json", "--out", out/"api", "--engine", bun, "--upstream", upstream])
    run("control", [bun, HERE/"control.mjs", out/"api", out/"report.json"])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("out", type=Path)
    parser.add_argument("--source", type=Path, default=ROOT/"selfhost/build/phase203/candidate01")
    args = parser.parse_args()
    check(args.out.resolve(), args.source.resolve())
