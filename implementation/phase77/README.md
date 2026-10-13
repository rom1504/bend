# Phase77 native parity work

In progress. [Design](../../design/phase77/native-parity.md). Phase76 is the immutable
comparison baseline. The user permits explicitly reported temporary program-speed
regressions; correctness remains mandatory. No new performance claim yet.

## B2 deployment checkpoint

The unchanged Phase76 compiler12 B2 (`29da003b…`) is installed. The maintained
release tool now supports `--install-b2` and verifies the original checked B1,
equality derivation, self-emission, driver comparison, own-source check and exact
B3 reproduction from local inventoried files. The previous B1 release remains
preserved. No forged checked-B2 metadata or new mathematical proof is claimed.

13 package controls pass, including relocation, changed bytes, missing source
bindings, false fixed-point and failed own-source evidence. Installed/relocated
legacy42 and default24 pass. See `selfhost/build/phase77/package-controls02/` and
`release02/`; installation is `release01/job-install/`. Failed initial control
imports and the old legacy launcher's B1-only assertion are retained. The new
smoke derivative changes only that stage assertion and its runner path.

Existing paired Phase76 request ratios imply31% less default C-request time from
choosing B2 (2.752x B1 versus1.908x B2). This is not an algorithmic optimization
and not a new timing run. Compiler-source optimization follows this checkpoint.
