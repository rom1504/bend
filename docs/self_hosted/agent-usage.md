# Agent usage and budget checkpoints

The leader uses Astra at high. Reserve Astra ultra for a bounded difficult
design or correctness question, normally one specialist at a time. Start those
specialists with a fresh context containing the relevant files, evidence and
one concrete deliverable. Routine execution, result collection and reporting
should not need another Ultra agent. This is a working policy, not a model
configuration change or a measured savings guarantee.

`selfhost/tools/development/usage.py` reads the local Codex thread database
read-only and bounded tails of its rollout logs. It follows parent-thread links
to include descendants. It exports token counters, current model/effort metadata
and the last reported rate-limit event; it never exports conversation content,
reads credentials, contacts a service or invokes a model. The local schema is
an implementation detail and may need adaptation after Codex updates.

From the repository root, before and after a work block:

```sh
mkdir -p selfhost/build/usage
python3 selfhost/tools/development/usage.py --snapshot selfhost/build/usage/start.json
python3 selfhost/tools/development/usage.py \
  --baseline selfhost/build/usage/start.json \
  --snapshot selfhost/build/usage/end.json \
  --output-token-budget 20000 --quota-points-per-hour 2
```

Use fresh filenames. The numbers above are illustrative, not an agreed user
budget. Capture checkpoints before/after experiments or roughly every 30 minutes;
avoid extra model turns merely to poll usage. Interval output includes the five
largest output-token consumers. Exit 2 means a supplied advisory threshold was
exceeded: stop new expensive delegation, summarize progress and reassess the
next experiment. This script cannot enforce a hard platform limit.

Token totals are **not quota cost**. Cached input is a subset of input, and
reasoning is a subset of output. Model/effort fields describe the latest known
configuration, not every historical request. Limit events can be stale or
absent, and account-wide usage may include unrelated sessions. Percent-per-hour
is calculated only across comparable windows with the same reset timestamp;
there is no invented conversion between tokens, dollars and subscription quota.
Counter resets and unavailable telemetry produce explicit warnings.

Start with at most two routine specialists concurrently and one Ultra specialist
only when it can resolve a specific hard question. Reuse scripts for validation
and evidence collection, write one report per experiment, and avoid duplicating
the same review across several agents. Measure completed useful work per quota
point before increasing concurrency.

Official background: [reasoning effort](https://developers.openai.com/api/docs/guides/reasoning)
and [Codex pricing and usage](https://learn.chatgpt.com/docs/pricing).
