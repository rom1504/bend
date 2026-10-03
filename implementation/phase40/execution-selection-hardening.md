# Selection hardening before consumption

The selector now recomputes every source-summary row from its unique raw report
case using maintained `run.summarize`. Statistics, ratios, paired rounds and
win/tie/loss counts must agree exactly. Drift, candidate change and range relation
are recomputed with the same arithmetic as the maintained execution summarizer.
Raw measured module hashes, point configuration and Node version are checked;
selected module-change, size-delta and catalog partition fields must also agree.

A lightweight negative test supplied the immutable full checked05 summary as both
inputs. All raw-row checks passed twice, then the mandatory three-point fresh
coverage assertion rejected the input. No target ran and no report was written.

The full checked05 evidence already contains two protocols: historical/variation
use budget600, while development/holdout use budget300. Each reused row retains its
original protocol and complete rotation. The three replacement ray points must
match their original budget600 protocol. Harness, Node binary and resource limits
must match across every group. This corrects an overly broad equality assertion
before first consumption; it adds no pooling or benchmark admission. The selected
report records the measurement protocol per row, alongside both compiler APIs.

Tree-agent read review confirmed pairing/report association and requested the
additional module-change/size/partition consistency checks, which were added.
