# P76-002: intrinsic classification admission

Source inspection found that every ordinary-definition test eagerly constructs
its primitive name and intrinsic template, even when its native flag is false.
Use explicit Bend pattern matching on that flag and retain the exact existing
classifier for marked definitions. This removes work across all lowering routes
without any result cache, source ABI change or generated C change. Screen exact
C and compare against Phase75; keep this separate from the larger pattern/IR
experiment. All finite well-formed raw KDef cases retain their Boolean result.

## Final decision

Retained in installed candidate12 together with lazy call admission and representation certificates. All twelve generated C files/binaries are exact previous artifacts; the combined paired comparison saves 6.28% B1/1.84% B2 request time. This is not an isolated attribution to this one helper.
