# Release smoke method

The [Phase66 successor](../../selfhost/tools/performance/phase66/release/derivation-v1.json)
records exact source transformations from the maintained Phase53 release
controllers. It targets upstream `059266225b77c8ca256ac6b25ee5c21449bab151`,
version `2.0.36`, and the 35-provider effect inventory. Its manifest SHA-256 is
`8fc443e1c094470dc55f450c326e8f966c8f8174a44a5ab506bd07dc2ab4026b`.

The legacy runner retains all 42 expectations, including installed and relocated
CLI, interpreter, JavaScript and C output checks. Only target/version metadata
and report labels change. The default runner is copied byte-for-byte and retains
all 24 checks, including partial library application, IO, explicit legacy mode,
relocation, runtime tamper refusal and restored integrity.

The plan generator requires the selected snapshot, live host and direct runtime
to agree. It additionally joins the bootstrap, compiler manifest and provider
manifest to the new revision. It only writes hash-bound future command lines;
installation and smoke execution still require root's final promotion decision
and serial resource guard. No target or installation was executed while
preparing this method, and no release success is claimed here.
