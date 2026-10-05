# P48-008: Direct proved String.append values

Status: independent checked-source semantics and actual Unicode screen PASS;
retain for integrated qualification, no installed-release claim.

Hypothesis: canonical JWNative String.append of two independently proved String
values can emit primitive concatenation instead of a generic runtime call and
argument vector, retaining original source/host guards and public fallback.
String allocation is unchanged. This is not a wider native whitelist.

Mechanism: [design](../../design/phase48/native-values.md) and
[checked outcome](../../implementation/phase48/native-values.md).
The candidate is `checked-native01`, API
`ea62fafd65cd04b173015e09e786fbeede7b4485fa79a842a57a5f5a1eaa1eeb`,
against selected Phase47 array06 API
`28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`.
Both use runtime
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

Falsifiers: changed full value, coercion/demand order, native/global/prototype
mutation behavior, partial/raw entry or Error/reentry; lack of ordinary worker
activation; unfavorable compiler/runtime/size tradeoff. Saved-output prototypes
do not grant source qualification.

The independent controls pass 7 ordinary points, 1372 full Unicode/tuple/record
values and 18 boundary cases. The separate corpus AST counter probe passes exact
checked output/catalog/image joins and full strings; ordinary Unicode16/64
execute 178/706 private concats. Morning executes none and remains neutral.

The fresh `native-screen01` screen passes all 3 points / 27 samples in 21.42 s.
Unicode16 changes 91.2131→75.0995 μs (1.215× gain, 3.384× TypeScript);
Unicode64 changes 239.571→157.580 μs (1.520×, 1.818× TypeScript).
Morning changes 236.631→231.980 μs with zero private concats; this cannot be
attributed to the mechanism. Ranges and substantial Morning half-sample drift
are retained in the outcome; these sample counts are not significance tests.

Evidence: [independent suite](../../selfhost/build/phase48/native-controls01/report.json),
[actual corpus probe](../../selfhost/build/phase48/native-corpus-controls01/report.json),
[fresh screen](../../selfhost/build/phase48/native-screen01/report.json), and
[compact hash-bound summary](../../implementation/phase48/evidence/native-screen.json).
Screen SHA-256:
`08b2b1362948cb550e5f74a8e4905eb5c22a4145664b1388957f542138061730`;
corpus probe SHA-256:
`ac5dac5f8a15f87184771e1df922e9d8697818dfdf3ee0fd17e179f0069c152f`.
No targets were executed by this documentation owner; 27 saved sample summaries
and full first-result identities were recomputed read-only.

Promotion remains separate: qualify the combined image and its costs/broad
corpus before release. Other native leaves and the deferred entry-guard work
cannot inherit these passes or gains.
