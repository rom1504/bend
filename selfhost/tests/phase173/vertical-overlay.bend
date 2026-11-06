# Experimental complete-request route. Store compaction never calls nc_compact.
# All downstream lowering, static checks, certificates, final graph verifier,
# QBE rendering and native execution remain the maintained implementation.
@unsafe
def nc_compact(t):
  p173v_store_compact(t)
