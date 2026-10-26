# Original planner body with one profitability-selected checker call.
@unsafe
def p86_plan_loaded(+seed: P86Seed, +load: FPrefixLoad) -> P86Plan:
  match seed load:
    case P86Seed{base, book, fresh, ready, +world} FPrefixLoad{trace, prefix, suffix, eligible}:
      match trace:
        case FLoadTrace{result, done, sources}:
          match result:
            case FResult{+original, +error, imports}:
              kc(P86Plan, String.is_empty(error),
                u => p86_plan_checked(load, world, original, nt_choose(DResult,p143cg_enough(suffix,256),
                  v => p143cb_program(load,Nil{},world,True{}),
                  v => check_program_diagnostic_world(load,Nil{},world))),
                u => P86PlanError{"parse: " ++ error})

# Module: /home/ai/bend2/build/publish/bend/selfhost/build/phase88/cache-js01/entry.bend:524

