# P73-008: preserve instantiated field widths at erasure

The monomorphic field certificate cannot distinguish List<U32> from List<String>.
The checker already annotates each match with its instantiated input datatype.
Use the same specialized constructor telescope as runtime field erasure to retain
an eight-field scalar mask on native Mat.qty. This slot is native-only metadata;
source typing never sees it. Zero-quantity fields do not shift live indexes.
Unknown/dependent fields stay Term. Only the checked CPU macro enables casts;
raw/device remain opaque. This applies to all proven U32/F32/Char/Bool fields,
including Base and generic ADTs, without function/benchmark recognition.
Check mixed instantiations, erased fields, raw controls and byte-identical JS.

Candidate10 passes frontend36, JS closure equality and all12 native benchmark
oracles. It does not materially improve the intended cases against candidate08:
Array.map478→474ms, expression438→439, BST392→391, list322→324. Some whole-
campaign clocks drift together. Reject the additional metadata/analysis for now;
restore candidate08's erasure and bridge bytes before the final caching build.
