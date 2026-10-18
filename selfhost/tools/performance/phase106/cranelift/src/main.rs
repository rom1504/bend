//! A small experimental consumer, not a second Bend compiler or production backend.
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{types, AbiParam, InstBuilder, MemFlags, Signature, Type, Value};
use cranelift_codegen::settings::{self, Configurable};
use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext, Variable};
use cranelift_module::{default_libcall_names, DataDescription, FuncId, Linkage, Module};
use cranelift_object::{ObjectBuilder, ObjectModule};
use serde::Deserialize;
use std::collections::{BTreeMap, BTreeSet};
use std::{env, fs, process, time::Instant};

type Result<T> = std::result::Result<T, String>;

#[derive(Clone, Copy, Debug, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
enum Ty {
    U32,
    U64,
    Ptr,
}
impl Ty {
    fn native(self, pointer: Type) -> Type {
        match self {
            Self::U32 => types::I32,
            Self::U64 => types::I64,
            Self::Ptr => pointer,
        }
    }
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct Program {
    version: u32,
    entry: String,
    functions: Vec<Function>,
}
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct Binding {
    name: String,
    #[serde(rename = "type")]
    ty: Ty,
}
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct Function {
    name: String,
    params: Vec<Binding>,
    result: Ty,
    #[serde(default)]
    locals: Vec<Binding>,
    body: Vec<Stmt>,
}

#[derive(Deserialize)]
#[serde(tag = "kind", rename_all = "snake_case", deny_unknown_fields)]
enum Expr {
    Const {
        value: u64,
        #[serde(rename = "type")]
        ty: Ty,
    },
    Var {
        name: String,
    },
    Bin {
        op: String,
        lhs: Box<Expr>,
        rhs: Box<Expr>,
    },
    Call {
        name: String,
        args: Vec<Expr>,
    },
    Func {
        name: String,
    },
    Ptradd {
        ptr: Box<Expr>,
        bytes: Box<Expr>,
    },
    Icall {
        callee: Box<Expr>,
        args: Vec<Expr>,
        params: Vec<Ty>,
        result: Ty,
    },
    Alloc {
        bytes: Box<Expr>,
    },
    Load {
        ptr: Box<Expr>,
        offset: i32,
        #[serde(rename = "type")]
        ty: Ty,
    },
}
#[derive(Deserialize)]
#[serde(tag = "kind", rename_all = "snake_case", deny_unknown_fields)]
enum Stmt {
    Set {
        name: String,
        value: Expr,
    },
    If {
        cond: Expr,
        #[serde(rename = "then")]
        yes: Vec<Stmt>,
        #[serde(rename = "else")]
        no: Vec<Stmt>,
    },
    While {
        cond: Expr,
        body: Vec<Stmt>,
    },
    Return {
        value: Expr,
    },
    Store {
        ptr: Expr,
        offset: i32,
        value: Expr,
        #[serde(rename = "type")]
        ty: Ty,
    },
    Free {
        ptr: Expr,
    },
}

fn pure(e: &Expr) -> bool {
    match e {
        Expr::Const { .. } | Expr::Var { .. } | Expr::Func { .. } => true,
        Expr::Bin { lhs, rhs, .. } => pure(lhs) && pure(rhs),
        Expr::Ptradd { ptr, bytes } => pure(ptr) && pure(bytes),
        _ => false,
    }
}
fn need_pure(e: &Expr) -> Result<()> {
    if pure(e) {
        Ok(())
    } else {
        Err("effectful nested expression is outside v1".into())
    }
}
fn same(actual: Ty, expected: Ty) -> Result<()> {
    if actual == expected {
        Ok(())
    } else {
        Err(format!("type mismatch: {actual:?}, expected {expected:?}"))
    }
}
fn name_ok(name: &str) -> bool {
    !name.is_empty()
        && name.bytes().all(|b| b.is_ascii_alphanumeric() || b == b'_')
        && !name.as_bytes()[0].is_ascii_digit()
}

#[derive(Clone)]
struct Decl {
    id: FuncId,
    params: Vec<Ty>,
    result: Ty,
    signature: Signature,
}
struct Runtime {
    calloc: FuncId,
    free: FuncId,
    abort: FuncId,
}
struct Lower<'a, 'b> {
    b: FunctionBuilder<'a>,
    module: &'b mut ObjectModule,
    functions: &'b BTreeMap<String, Decl>,
    runtime: &'b Runtime,
    variables: BTreeMap<String, (Variable, Ty)>,
    pointer: Type,
    result: Ty,
}

impl Lower<'_, '_> {
    fn variable(&self, name: &str) -> Result<(Variable, Ty)> {
        self.variables
            .get(name)
            .copied()
            .ok_or_else(|| format!("unknown variable {name}"))
    }
    fn arguments(&mut self, args: &[Expr], params: &[Ty]) -> Result<Vec<Value>> {
        if args.len() != params.len() {
            return Err("call arity mismatch".into());
        }
        args.iter()
            .zip(params)
            .map(|(arg, ty)| {
                need_pure(arg)?;
                let (value, actual) = self.expr(arg)?;
                same(actual, *ty)?;
                Ok(value)
            })
            .collect()
    }
    fn expr(&mut self, expr: &Expr) -> Result<(Value, Ty)> {
        match expr {
            Expr::Const { value, ty } => {
                if (*ty == Ty::U32 && *value > u32::MAX as u64) || (*ty == Ty::Ptr && *value != 0) {
                    return Err(
                        "constant outside declared type (only null pointer constants)".into(),
                    );
                }
                Ok((
                    self.b.ins().iconst(ty.native(self.pointer), *value as i64),
                    *ty,
                ))
            }
            Expr::Var { name } => {
                let (var, ty) = self.variable(name)?;
                Ok((self.b.use_var(var), ty))
            }
            Expr::Ptradd { ptr, bytes } => {
                need_pure(ptr)?;
                need_pure(bytes)?;
                let (ptr, pty) = self.expr(ptr)?;
                same(pty, Ty::Ptr)?;
                let (bytes, bty) = self.expr(bytes)?;
                same(bty, Ty::U32)?;
                let bytes = self.b.ins().uextend(self.pointer, bytes);
                Ok((self.b.ins().iadd(ptr, bytes), Ty::Ptr))
            }
            Expr::Bin { op, lhs, rhs } => {
                need_pure(lhs)?;
                need_pure(rhs)?;
                let (a, ty) = self.expr(lhs)?;
                let (b, rhs_ty) = self.expr(rhs)?;
                same(rhs_ty, ty)?;
                if ty == Ty::Ptr && op != "eq" && op != "ne" {
                    return Err("pointer arithmetic is outside v1".into());
                }
                let cc = match op.as_str() {
                    "eq" => Some(IntCC::Equal),
                    "ne" => Some(IntCC::NotEqual),
                    "ult" => Some(IntCC::UnsignedLessThan),
                    "ule" => Some(IntCC::UnsignedLessThanOrEqual),
                    "ugt" => Some(IntCC::UnsignedGreaterThan),
                    "uge" => Some(IntCC::UnsignedGreaterThanOrEqual),
                    _ => None,
                };
                if let Some(cc) = cc {
                    let v = self.b.ins().icmp(cc, a, b);
                    return Ok((self.b.ins().uextend(types::I32, v), Ty::U32));
                }
                let v = match op.as_str() {
                    "add" => self.b.ins().iadd(a, b),
                    "sub" => self.b.ins().isub(a, b),
                    "mul" => self.b.ins().imul(a, b),
                    "and" => self.b.ins().band(a, b),
                    "or" => self.b.ins().bor(a, b),
                    "xor" => self.b.ins().bxor(a, b),
                    "shl" | "lshr" => {
                        let shift = self
                            .b
                            .ins()
                            .band_imm(b, if ty == Ty::U32 { 31 } else { 63 });
                        if op == "shl" {
                            self.b.ins().ishl(a, shift)
                        } else {
                            self.b.ins().ushr(a, shift)
                        }
                    }
                    _ => return Err(format!("unsupported binary operation {op}")),
                };
                Ok((v, ty))
            }
            Expr::Call { name, args } => {
                let d = self
                    .functions
                    .get(name)
                    .cloned()
                    .ok_or_else(|| format!("unknown callee {name}"))?;
                let args = self.arguments(args, &d.params)?;
                let callee = self.module.declare_func_in_func(d.id, self.b.func);
                let call = self.b.ins().call(callee, &args);
                Ok((self.b.inst_results(call)[0], d.result))
            }
            Expr::Func { name } => {
                let d = self
                    .functions
                    .get(name)
                    .ok_or_else(|| format!("unknown function address {name}"))?;
                let callee = self.module.declare_func_in_func(d.id, self.b.func);
                Ok((self.b.ins().func_addr(self.pointer, callee), Ty::Ptr))
            }
            Expr::Icall {
                callee,
                args,
                params,
                result,
            } => {
                need_pure(callee)?;
                let (target, ty) = self.expr(callee)?;
                same(ty, Ty::Ptr)?;
                let args = self.arguments(args, params)?;
                let mut signature = self.module.make_signature();
                signature.params = params
                    .iter()
                    .map(|ty| AbiParam::new(ty.native(self.pointer)))
                    .collect();
                signature
                    .returns
                    .push(AbiParam::new(result.native(self.pointer)));
                let sig = self.b.import_signature(signature);
                let call = self.b.ins().call_indirect(sig, target, &args);
                Ok((self.b.inst_results(call)[0], *result))
            }
            Expr::Alloc { bytes } => {
                need_pure(bytes)?;
                let (bytes, ty) = self.expr(bytes)?;
                same(ty, Ty::U32)?;
                let bytes = self.b.ins().uextend(self.pointer, bytes);
                let one = self.b.ins().iconst(self.pointer, 1);
                let zero = self.b.ins().icmp_imm(IntCC::Equal, bytes, 0);
                let bytes = self.b.ins().select(zero, one, bytes);
                let calloc = self
                    .module
                    .declare_func_in_func(self.runtime.calloc, self.b.func);
                let call = self.b.ins().call(calloc, &[one, bytes]);
                let ptr = self.b.inst_results(call)[0];
                let failed = self.b.ins().icmp_imm(IntCC::Equal, ptr, 0);
                let bad = self.b.create_block();
                let good = self.b.create_block();
                self.b.ins().brif(failed, bad, &[], good, &[]);
                self.b.switch_to_block(bad);
                let abort = self
                    .module
                    .declare_func_in_func(self.runtime.abort, self.b.func);
                self.b.ins().call(abort, &[]);
                // libc abort cannot return; this successor keeps IR well formed.
                self.b.ins().jump(good, &[]);
                self.b.switch_to_block(good);
                Ok((ptr, Ty::Ptr))
            }
            Expr::Load { ptr, offset, ty } => {
                need_pure(ptr)?;
                if *offset < 0 {
                    return Err("negative memory offset is outside v1".into());
                }
                let (ptr, actual) = self.expr(ptr)?;
                same(actual, Ty::Ptr)?;
                Ok((
                    self.b
                        .ins()
                        .load(ty.native(self.pointer), MemFlags::new(), ptr, *offset),
                    *ty,
                ))
            }
        }
    }
    fn body(&mut self, body: &[Stmt]) -> Result<bool> {
        for (index, stmt) in body.iter().enumerate() {
            let terminal = self.stmt(stmt)?;
            if terminal {
                if index + 1 != body.len() {
                    return Err("statement after terminal control flow".into());
                }
                return Ok(true);
            }
        }
        Ok(false)
    }
    fn stmt(&mut self, stmt: &Stmt) -> Result<bool> {
        match stmt {
            Stmt::Set { name, value } => {
                let (var, expected) = self.variable(name)?;
                let (value, actual) = self.expr(value)?;
                same(actual, expected)?;
                self.b.def_var(var, value);
            }
            Stmt::Return { value } => {
                let (value, actual) = self.expr(value)?;
                same(actual, self.result)?;
                self.b.ins().return_(&[value]);
                return Ok(true);
            }
            Stmt::If { cond, yes, no } => {
                need_pure(cond)?;
                let (cond, ty) = self.expr(cond)?;
                same(ty, Ty::U32)?;
                let yes_block = self.b.create_block();
                let no_block = self.b.create_block();
                let merge = self.b.create_block();
                self.b.ins().brif(cond, yes_block, &[], no_block, &[]);
                self.b.switch_to_block(yes_block);
                let yes_ends = self.body(yes)?;
                if !yes_ends {
                    self.b.ins().jump(merge, &[]);
                }
                self.b.switch_to_block(no_block);
                let no_ends = self.body(no)?;
                if !no_ends {
                    self.b.ins().jump(merge, &[]);
                }
                if yes_ends && no_ends {
                    return Ok(true);
                }
                self.b.switch_to_block(merge);
            }
            Stmt::While { cond, body } => {
                need_pure(cond)?;
                let header = self.b.create_block();
                let loop_body = self.b.create_block();
                let exit = self.b.create_block();
                self.b.ins().jump(header, &[]);
                self.b.switch_to_block(header);
                let (cond, ty) = self.expr(cond)?;
                same(ty, Ty::U32)?;
                self.b.ins().brif(cond, loop_body, &[], exit, &[]);
                self.b.switch_to_block(loop_body);
                if !self.body(body)? {
                    self.b.ins().jump(header, &[]);
                }
                self.b.switch_to_block(exit);
            }
            Stmt::Store {
                ptr,
                offset,
                value,
                ty,
            } => {
                need_pure(ptr)?;
                need_pure(value)?;
                if *offset < 0 {
                    return Err("negative memory offset is outside v1".into());
                }
                let (ptr, pty) = self.expr(ptr)?;
                same(pty, Ty::Ptr)?;
                let (value, actual) = self.expr(value)?;
                same(actual, *ty)?;
                self.b.ins().store(MemFlags::new(), value, ptr, *offset);
            }
            Stmt::Free { ptr } => {
                need_pure(ptr)?;
                let (ptr, ty) = self.expr(ptr)?;
                same(ty, Ty::Ptr)?;
                let free = self
                    .module
                    .declare_func_in_func(self.runtime.free, self.b.func);
                self.b.ins().call(free, &[ptr]);
            }
        }
        Ok(false)
    }
}

fn signature(module: &ObjectModule, params: &[Ty], result: Ty) -> Signature {
    let pointer = module.target_config().pointer_type();
    let mut sig = module.make_signature();
    sig.params = params
        .iter()
        .map(|ty| AbiParam::new(ty.native(pointer)))
        .collect();
    sig.returns.push(AbiParam::new(result.native(pointer)));
    sig
}
fn runtime(module: &mut ObjectModule) -> Result<Runtime> {
    let pointer = module.target_config().pointer_type();
    let mut sig = module.make_signature();
    sig.params = vec![AbiParam::new(pointer), AbiParam::new(pointer)];
    sig.returns.push(AbiParam::new(pointer));
    let calloc = module
        .declare_function("calloc", Linkage::Import, &sig)
        .map_err(|e| e.to_string())?;
    sig.params.truncate(1);
    sig.returns.clear();
    let free = module
        .declare_function("free", Linkage::Import, &sig)
        .map_err(|e| e.to_string())?;
    sig.params.clear();
    let abort = module
        .declare_function("abort", Linkage::Import, &sig)
        .map_err(|e| e.to_string())?;
    Ok(Runtime {
        calloc,
        free,
        abort,
    })
}

fn build(program: &Program, opt: &str) -> Result<Vec<u8>> {
    if program.version != 1 {
        return Err("unsupported IR version".into());
    }
    if program.functions.is_empty() || program.functions.len() > 1024 {
        return Err("function count outside 1..1024".into());
    }
    let mut flags = settings::builder();
    flags.set("opt_level", opt).map_err(|e| e.to_string())?;
    flags.set("is_pic", "true").map_err(|e| e.to_string())?;
    flags
        .set("enable_verifier", "true")
        .map_err(|e| e.to_string())?;
    let isa = cranelift_native::builder()
        .map_err(str::to_owned)?
        .finish(settings::Flags::new(flags))
        .map_err(|e| e.to_string())?;
    let obj = ObjectBuilder::new(isa, "bend-phase106", default_libcall_names())
        .map_err(|e| e.to_string())?;
    let mut module = ObjectModule::new(obj);
    let pointer = module.target_config().pointer_type();
    if pointer != types::I64 {
        return Err("v1 requires a 64-bit host".into());
    }
    let mut declarations = BTreeMap::new();
    for f in &program.functions {
        if !name_ok(&f.name) || declarations.contains_key(&f.name) {
            return Err(format!("invalid/duplicate function name {}", f.name));
        }
        let params: Vec<Ty> = f.params.iter().map(|p| p.ty).collect();
        let sig = signature(&module, &params, f.result);
        let id = module
            .declare_function(&format!("bend_ir_{}", f.name), Linkage::Local, &sig)
            .map_err(|e| e.to_string())?;
        declarations.insert(
            f.name.clone(),
            Decl {
                id,
                params,
                result: f.result,
                signature: sig,
            },
        );
    }
    let entry = declarations
        .get(&program.entry)
        .cloned()
        .ok_or("entry does not exist")?;
    if entry.result != Ty::U32 || entry.params.contains(&Ty::Ptr) {
        return Err("entry requires scalar arguments and u32 result".into());
    }
    let rt = runtime(&mut module)?;
    for f in &program.functions {
        let decl = &declarations[&f.name];
        let mut context = module.make_context();
        context.func.signature = decl.signature.clone();
        let mut builder_context = FunctionBuilderContext::new();
        {
            let mut b = FunctionBuilder::new(&mut context.func, &mut builder_context);
            let first = b.create_block();
            b.append_block_params_for_function_params(first);
            b.switch_to_block(first);
            let mut variables = BTreeMap::new();
            let mut names = BTreeSet::new();
            for (i, binding) in f.params.iter().chain(&f.locals).enumerate() {
                if !name_ok(&binding.name) || !names.insert(binding.name.clone()) {
                    return Err("invalid/duplicate local name".into());
                }
                let var = Variable::from_u32(i as u32);
                b.declare_var(var, binding.ty.native(pointer));
                let value = if i < f.params.len() {
                    b.block_params(first)[i]
                } else {
                    b.ins().iconst(binding.ty.native(pointer), 0)
                };
                b.def_var(var, value);
                variables.insert(binding.name.clone(), (var, binding.ty));
            }
            let mut lower = Lower {
                b,
                module: &mut module,
                functions: &declarations,
                runtime: &rt,
                variables,
                pointer,
                result: f.result,
            };
            if !lower.body(&f.body)? {
                return Err(format!("function {} falls through", f.name));
            }
            lower.b.seal_all_blocks();
            lower.b.finalize();
        }
        module
            .define_function(decl.id, &mut context)
            .map_err(|e| format!("{}: {e}", f.name))?;
    }
    // Stable testing ABI: arguments are an array of unsigned words, result u32.
    let wrapper_sig = signature(&module, &[Ty::Ptr], Ty::U32);
    let wrapper = module
        .declare_function("phase106_entry", Linkage::Export, &wrapper_sig)
        .map_err(|e| e.to_string())?;
    let mut ctx = module.make_context();
    ctx.func.signature = wrapper_sig;
    let mut fbc = FunctionBuilderContext::new();
    {
        let mut b = FunctionBuilder::new(&mut ctx.func, &mut fbc);
        let first = b.create_block();
        b.append_block_params_for_function_params(first);
        b.switch_to_block(first);
        let args_ptr = b.block_params(first)[0];
        let mut args = Vec::new();
        for (i, ty) in entry.params.iter().enumerate() {
            let v = b
                .ins()
                .load(types::I64, MemFlags::new(), args_ptr, (i * 8) as i32);
            args.push(if *ty == Ty::U32 {
                b.ins().ireduce(types::I32, v)
            } else {
                v
            });
        }
        let callee = module.declare_func_in_func(entry.id, b.func);
        let call = b.ins().call(callee, &args);
        let value = b.inst_results(call)[0];
        b.ins().return_(&[value]);
        b.seal_all_blocks();
        b.finalize();
    }
    module
        .define_function(wrapper, &mut ctx)
        .map_err(|e| e.to_string())?;
    let arity = module
        .declare_data("phase106_arity", Linkage::Export, false, false)
        .map_err(|e| e.to_string())?;
    let mut data = DataDescription::new();
    data.define(
        (entry.params.len() as u32)
            .to_ne_bytes()
            .to_vec()
            .into_boxed_slice(),
    );
    data.set_align(4);
    module
        .define_data(arity, &data)
        .map_err(|e| e.to_string())?;
    module.finish().emit().map_err(|e| e.to_string())
}

fn run() -> Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 3 || args.len() > 4 {
        return Err(
            "usage: bend-native-ir-cranelift INPUT.json OUTPUT.o [none|speed|speed_and_size]"
                .into(),
        );
    }
    let start = Instant::now();
    let input = fs::read(&args[1]).map_err(|e| e.to_string())?;
    if input.len() > 16 * 1024 * 1024 {
        return Err("input exceeds 16 MiB prototype limit".into());
    }
    let program: Program = serde_json::from_slice(&input).map_err(|e| e.to_string())?;
    let opt = args.get(3).map(String::as_str).unwrap_or("speed");
    let parse_ms = start.elapsed().as_secs_f64() * 1000.0;
    let object = build(&program, opt)?;
    fs::write(&args[2], &object).map_err(|e| e.to_string())?;
    println!(
        "{}",
        serde_json::json!({"status":"ok","backend":"cranelift-0.121.2","opt":opt,
        "functions":program.functions.len(),"object_bytes":object.len(),"parse_ms":parse_ms,
        "total_ms":start.elapsed().as_secs_f64()*1000.0})
    );
    Ok(())
}
fn main() {
    if let Err(error) = run() {
        eprintln!("phase106 Cranelift: {error}");
        process::exit(2);
    }
}
