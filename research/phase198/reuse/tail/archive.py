"""Archive small raw program/guard receipts, preserving the original failed batch."""

import gzip
import io
import tarfile
from pathlib import Path

from recover import BUILD, CASES, HERE, ROOT, read


def main():
    run = BUILD / "reuse-public-tail01"
    report = read(run / "report.json")
    assert report["complete"] and [r["id"] for r in report["rows"]] == CASES
    files = {
        BUILD/"heap-tail-auth01/report.json", BUILD/"heap-tail-auth01/emission.json",
        BUILD/"heap-pair-plan02.json", BUILD/"heap-pair-emission01/report.json",
        BUILD/"heap-pair-emission01/heap/report.json", BUILD/"heap-api03/report.json",
        BUILD/"heap-controls03/report.json", run/"report.json", run/"build.stdout", run/"build.stderr",
        run/"linked/report.json", run/"linked/programs.manifest.json",
    }
    for name in ("heap-api03", "heap-controls03", "heap-pair-emission01", "reuse-public-tail01"):
        files.update([
            BUILD/(name+"-guard")/"process.json", BUILD/(name+"-guard")/"retention.json",
            ROOT/"selfhost/build-retention/phase198"/(name+"-close")/"report.json",
        ])
    for case in CASES:
        directory = run/"linked"/case
        files.update([directory/"machine/report.json", directory/"oracle-process.json",
                      directory/"oracle.stdout", directory/"oracle.stderr"])
    controls = read(BUILD/"heap-controls03/report.json")
    for machine in controls["machines"]:
        files.update(Path(machine[field]["file"]) for field in ("stdout", "stderr"))
    with (HERE/"receipts.tar.gz").open("wb") as raw:
        with gzip.GzipFile(fileobj=raw, mode="wb", mtime=0, filename="") as gz:
            with tarfile.open(fileobj=gz, mode="w") as archive:
                for file in sorted(files):
                    data = file.read_bytes()
                    assert len(data) < 4 * 1024 * 1024, file
                    member = tarfile.TarInfo(str(file.relative_to(ROOT)))
                    member.size = len(data)
                    member.mode = 0o644
                    archive.addfile(member, io.BytesIO(data))
    print("Archived", len(files), "small primary receipts")


if __name__ == "__main__":
    main()
