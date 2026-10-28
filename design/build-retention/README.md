# Rollout of build retention

Authorized by the user's "Ok go ahead" after the 2026-10-28 proposal review.
Start at e08be5c. Recover 5–10 GiB without losing unique evidence or damaging
installed/qualified/active work; introduce disk admission and an explicit
experiment-close workflow. No compiler optimization or native qualification run
is needed for these host-storage changes.

## Concrete cleanup

Use existing full closed-campaign capsules, starting with Phase61, then a
reviewed set across 42–65. The initial-policy.json file gives the exact allowed
roots and protected prefixes. Phase4/5 remain hot because unfinished Phase6 work
uses them; 6/68, 32 coordination state,107 acquisition, current native generations
and every other unlisted root are excluded. Preserve Phase66 prerequisite states,
archive header-declared protected artifacts, and authenticated current compiler
pins. The historical broad 94-folder deletion command is not used.

The tool first authenticates the whole archive (including split transport), every
member and current selected file. Plans record current modes/ownership/times:
older archives normalized executable modes, so their tar headers alone are not
sufficient restoration metadata. Shared inodes, symlinks, extended attributes,
other owners and changed/unarchived files remain untouched. A second explicit
apply authenticates the plan, rechecks all candidates, writes durable intent and
journals individual unlinks. Directories remain. Restore writes verified temporary
files and publishes without replacing existing paths.

Use the unchanged Phase32 execution-lock inode throughout each verify/apply/
restore operation. Archive bytes and plans stay outside pruned roots. Verify a
small restore into separate scratch before the first real apply and after a real
removal. Record exact allocated recovery separately from observed filesystem free
space, which can change because other projects share the mount.

## Recurrence prevention

Add a versioned successor to the historical guard. Require fresh declared output
roots and an explicit peak-disk budget, check reserve+budget after locking, and
monitor both filesystem pressure and produced blocks. Keep the existing process,
RSS, deadline and signal boundaries. Default reserve 5 GiB; sample accounting is not
a hard filesystem quota. Frozen earlier guard hashes stay unchanged.

Every new guarded run gets a retention record, including failures. Success is
not qualification. An explicit close command classifies the finished experiment,
archives its declared cold outputs and optionally prunes only verified members.
Qualified outputs remain hot by default. No timer guesses ownership from mtime;
no unattended arbitrary-directory garbage collection is installed.

Initial project 30/40 GiB levels remain review/admission targets pending the complete
protected-set inventory; do not silently disable all work because grandfathered
historical storage still exceeds them. Mount reserve and per-run budgets are the
first enforced gates. Review remaining cold bulk at each campaign close.

## Validation and delivery

Use bounded isolated filesystem/process tests: corrupted/truncated capsules,
unsafe members, stale source/policy, protection and ownership, split archives,
interrupted apply with durable intent, exact restoration and no-overwrite;
lock contention, low-disk admission, exhaustion during execution, output budget,
and unrelated-process survival. Never fill the real disk to test a guard.

Rehash current installed/qualified compiler and source pins after cleanup. Verify
one tiny native request with exact known QBE under the new guard after sufficient
space is recovered; no full self-build or repeated runtime benchmark is needed.
Publish the tools, explicit retention maps/receipts, recovery instructions, actual
free-space results, tests and limitations. Update current workflow documentation
and AGENTS to use the new guard; leave historical frozen campaigns intact.
