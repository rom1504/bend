# Historical native lookup evidence

Historical source/image only. Physical intersections are subsets of active contexts, never added as separate time. Timeline is approximate sampled-thread CPU order; no exact Phase135/136 frontend wall-stage attribution, allocation counts, causal speedup or recurrence frequency.

| Active owner | All samples | Drop/fade within owner | Drop/fade of all samples | Borrowed equality of all samples |
|---|---:|---:|---:|---:|
| `nc_ctor_owned` | 7.48% | 52.99% | 3.97% | 0.73% |
| `lookup` | 5.43% | 48.76% | 2.65% | 0.58% |
| `f_find` | 5.20% | 50.97% | 2.65% | 0.91% |
| `has_name` | 2.92% | 0.00% | 0.00% | 2.19% |
| `p111v_get` | 4.43% | 41.90% | 1.86% | 0.07% |
| `index_remove` | 3.52% | 51.80% | 1.82% | 0.00% |

These intersections explain the shape of each active computation. They do not identify the original allocation site, distinguish reference decrements from actual frees, or prove that a cache can eliminate the entire context.

| Approximate sampled CPU window | Leading active owners |
|---|---|
| 0–30s | `f_find` 37.0%, `f_eq` 3.8%, `f_grow_base` 3.0% |
| 30–60s | `f_find` 28.7%, `lookup` 10.0%, `constructor_exists` 7.6% |
| 60–90s | `lookup` 31.3%, `index_remove` 23.3%, `p88_string_eq` 14.2% |
| 90–120s | `has_name` 20.8%, `index_remove` 12.8%, `p88_string_eq` 11.7% |
| 120–150s | `nc_ctor_owned` 46.2%, `has_name` 16.1%, `lookup` 6.4% |
| 150–180s | `nb_contains` 32.9%, `nc_ctor_owned` 8.6%, `nc_occurs` 8.1% |
| 180–210s | `nc_occurs` 16.4%, `nc_occurs_list` 11.1%, `nc_ctor_owned` 8.6% |
| 210–240s | `nc_ctor_owned` 19.1%, `p111v_value` 4.5%, `p111v_get` 3.8% |
| 240–270s | `p111v_get` 22.3%, `p113k_get` 12.2%, `p131i_insert` 7.1% |
| 270–300s | `p111v_get` 15.1%, `p111v_name_chars` 7.7%, `p131i_insert` 6.9% |
| 300–330s | `nc_ctor_owned` 10.1%, `p111v_get` 9.9%, `String.eq` 5.7% |
| 330–360s | `String.append` 28.7%, `p111q_body_text` 8.1%, `p111q_memory` 8.0% |
| 360–379s | `String.append` 19.6%, `[unknown]` 13.8%, `p111q_memory` 8.9% |

Early `f_find` and `lookup` concentration supports profiling parsing/name resolution first. The later repeated `nc_ctor_owned` appearances show that ownership queries cross boundaries; a table attached only before private lowering can miss earlier work. Neither observation assigns samples to measured frontend sub-stages.
