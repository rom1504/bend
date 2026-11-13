# Experimental hook; selected production pipeline is unchanged by this file.
@unsafe
def x186_function_memory(symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,params,setup,x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_path_facts_body(x192_predicate_body(
        x186_private_body(params,setup,body))))))),ids)
