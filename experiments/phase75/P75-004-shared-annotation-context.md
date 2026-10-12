# P75-004: reuse the checked indexed context for native annotation

The native host currently leaves contextBook as a plain definition list.
annotate_selected and j_layout_error each call book_context on that same list,
rebuilding its index and rescanning all binder IDs. reach_book also looks up
through the plain list. Use the already qualified book_context_world admission
(or ordinary book_context fallback) for native requests too. No new compiler
algorithm or API: the existing Bend context is shared across these phases.
Check exact complete C against compiler02; retain raw public context behavior.

Candidate09 narrows this host reuse to owned native requests. Injected API
clients retain the previous native call sequence; JavaScript behavior is unchanged.
