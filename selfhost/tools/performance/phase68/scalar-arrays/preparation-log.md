# Preparation observations

The first data-only invocation refused before creating its output directory:
it required the emission observation to equal a two-key dictionary, while the
actual checked receipt also contains type/proof/phase/file metadata. The
source controller now checks the required status, checked, typeAccepted and
exitCode fields while retaining the full receipt identity. No C was compiled
or target executed; no prior derived output was overwritten.
