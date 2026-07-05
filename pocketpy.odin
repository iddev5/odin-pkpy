/*
 *  Copyright (c) 2026 blueloveTH
 *  Distributed Under The MIT License
 *  https://github.com/pocketpy/pocketpy
 */
package pocketpy

foreign import lib {
	"libs/libpocketpy.a"
}


// clang-format off
PK_VERSION             :: "2.1.8"
PK_VERSION_MAJOR            :: 2
PK_VERSION_MINOR            :: 1
PK_VERSION_PATCH            :: 8
PK_ENABLE_OS                :: 1
PK_ENABLE_THREADS           :: 1
PK_ENABLE_DETERMINISM       :: 0
PK_ENABLE_WATCHDOG          :: 0
PK_ENABLE_CUSTOM_SNAME      :: 0
PK_ENABLE_MIMALLOC          :: 0
PK_GC_MIN_THRESHOLD     :: 20000
PK_VM_STACK_SIZE        :: 16384
PK_MAX_CO_VARNAMES          :: 64

/*************** internal settings ***************/
// This is the maximum character length of a module path
PK_MAX_MODULE_PATH_LEN      :: 63

// This is some math constants
PK_M_PI                     :: 3.1415926535897932384
PK_M_E                      :: 2.7182818284590452354
PK_M_DEG2RAD                :: 0.017453292519943295
PK_M_RAD2DEG                :: 57.29577951308232

// Hash table load factor (smaller ones mean less collision but more memory)
// For class instance
PK_INST_ATTR_LOAD_FACTOR    :: 0.67

// For class itself
PK_TYPE_ATTR_LOAD_FACTOR    :: 0.5
PY_SYS_PLATFORM          :: 5
PY_SYS_PLATFORM_STRING   :: "linux"
PK_IS_DESKTOP_PLATFORM   :: 1

c11_vec2i :: struct #raw_union {
	using _: struct {
		x, y: i32,
	},

	data: [2]i32,
	_i64: i64,
}

c11_vec3i :: struct #raw_union {
	using _: struct {
		x, y, z: i32,
	},

	data: [3]i32,
}

c11_vec2 :: struct #raw_union {
	using _: struct {
		x, y: f32,
	},

	data: [2]f32,
}

c11_vec3 :: struct #raw_union {
	using _: struct {
		x, y, z: f32,
	},

	data: [3]f32,
}

c11_mat3x3 :: struct #raw_union {
	using _: struct {
		_11, _12, _13: f32,
		_21, _22, _23: f32,
		_31, _32, _33: f32,
	},

	m:    [3][3]f32,
	data: [9]f32,
}

c11_color32 :: struct #raw_union {
	using _: struct {
		r: u8,
		g: u8,
		b: u8,
		a: u8,
	},

	data: [4]u8,
	_u32: u32,
}

py_OpaqueName :: struct {}

/// A pointer that represents a python identifier. For fast name resolution.
py_Name :: ^py_OpaqueName

/// An integer that represents a python type. `0` is invalid.
py_Type :: i16

/// A 64-bit integer type. Corresponds to `int` in python.
py_i64 :: i64

/// A 64-bit floating-point type. Corresponds to `float` in python.
py_f64 :: f64

/// A generic destructor function.
py_Dtor :: proc "c" (rawptr)

import "core:c"

py_TValue :: struct {
	type:   py_Type,
	is_ptr: c.bool,
	extra:  c.int,
	using _: struct #raw_union {
		_i64:   i64,
		_chars: [16]i8,
	},
}

/// A string view type. It is helpful for passing strings which are not null-terminated.
c11_sv :: struct {
	data: cstring,
	size: i32,
}

/// A generic reference to a python object.
py_Ref :: ^py_TValue

/// A reference which has the same lifespan as the python object.
py_ObjectRef :: ^py_TValue

/// A global reference which has the same lifespan as the VM.
py_GlobalRef :: ^py_TValue

/// A specific location in the value stack of the VM.
py_StackRef :: ^py_TValue

/// An item reference to a container object. It invalidates when the container is modified.
py_ItemRef :: ^py_TValue

/// An output reference for returning a value. Only use this for function arguments.
py_OutRef :: ^py_TValue
py_Frame  :: struct {}

// An enum for tracing events.
py_TraceEvent :: enum u32 {
	LINE = 0,
	PUSH = 1,
	POP  = 2,
}

py_TraceFunc :: proc "c" (frame: ^py_Frame, _: py_TraceEvent)

/// A struct contains the callbacks of the VM.
py_Callbacks :: struct {
	/// Used by `__import__` to load a source or compiled module.
	importfile: proc "c" (path: cstring, data_size: ^i32) -> cstring,

	/// Called before `importfile` to lazy-import a C module.
	lazyimport: proc "c" (cstring) -> py_GlobalRef,

	/// Used by `print` to output a string.
	print: proc "c" (cstring),

	/// Flush the output buffer of `print`.
	flush: proc "c" (),

	/// Used by `input` to get a character.
	getchr: proc "c" () -> i32,

	/// Used by `gc.collect()` to mark extra objects for garbage collection.
	gc_mark: proc "c" (f: proc "c" (val: py_Ref, ctx: rawptr), ctx: rawptr),

	/// Used by `PRINT_EXPR` bytecode.
	_bool: proc "c" (^i32) -> proc "c" (py_Ref) -> i32,
}

/// A struct contains the application-level callbacks.
py_AppCallbacks :: struct {
	on_vm_ctor: proc "c" (index: i32),
	on_vm_dtor: proc "c" (index: i32),
}

/// Native function signature.
/// @param argc number of arguments.
/// @param argv array of arguments. Use `py_arg(i)` macro to get the i-th argument.
/// @return `true` if the function is successful or `false` if an exception is raised.
py_CFunction :: proc "c" (argc: int, argv: [^]py_TValue) -> i32

/// Python compiler modes.
/// + `EXEC_MODE`: for statements.
/// + `EVAL_MODE`: for expressions.
/// + `SINGLE_MODE`: for REPL or jupyter notebook execution.
/// + `RELOAD_MODE`: for reloading a module without allocating new types if possible.
py_CompileMode :: enum u32 {
	/// Python compiler modes.
	/// + `EXEC_MODE`: for statements.
	/// + `EVAL_MODE`: for expressions.
	/// + `SINGLE_MODE`: for REPL or jupyter notebook execution.
	/// + `RELOAD_MODE`: for reloading a module without allocating new types if possible.
	EXEC_MODE   = 0,

	/// Python compiler modes.
	/// + `EXEC_MODE`: for statements.
	/// + `EVAL_MODE`: for expressions.
	/// + `SINGLE_MODE`: for REPL or jupyter notebook execution.
	/// + `RELOAD_MODE`: for reloading a module without allocating new types if possible.
	EVAL_MODE   = 1,

	/// Python compiler modes.
	/// + `EXEC_MODE`: for statements.
	/// + `EVAL_MODE`: for expressions.
	/// + `SINGLE_MODE`: for REPL or jupyter notebook execution.
	/// + `RELOAD_MODE`: for reloading a module without allocating new types if possible.
	SINGLE_MODE = 2,

	/// Python compiler modes.
	/// + `EXEC_MODE`: for statements.
	/// + `EVAL_MODE`: for expressions.
	/// + `SINGLE_MODE`: for REPL or jupyter notebook execution.
	/// + `RELOAD_MODE`: for reloading a module without allocating new types if possible.
	RELOAD_MODE = 3,
}

@(default_calling_convention="c")
foreign lib {
	/// Initialize pocketpy and the default VM.
	py_initialize :: proc() ---

	/// Finalize pocketpy and free all VMs. This opearation is irreversible.
	/// After this call, you cannot use any function from this header anymore.
	py_finalize :: proc() ---

	/// Get the current VM index.
	py_currentvm :: proc() -> i32 ---

	/// Switch to a VM.
	/// @param index index of the VM ranging from 0 to 16 (exclusive). `0` is the default VM.
	py_switchvm :: proc(index: i32) ---

	/// Reset the current VM.
	py_resetvm :: proc() ---

	/// Reset All VMs.
	py_resetallvm :: proc() ---

	/// Get the current VM context. This is used for user-defined data.
	py_getvmctx :: proc() -> rawptr ---

	/// Set the current VM context. This is used for user-defined data.
	py_setvmctx :: proc(ctx: rawptr) ---

	/// Setup the callbacks for the current VM.
	py_callbacks :: proc() -> ^py_Callbacks ---

	/// Setup the application callbacks
	py_appcallbacks :: proc() -> ^py_AppCallbacks ---

	/// Set `sys.argv`. Used for storing command-line arguments.
	py_sys_setargv :: proc(argc: i32, argv: ^cstring) ---

	/// Set the trace function for the current VM.
	py_sys_settrace :: proc(func: py_TraceFunc, reset: bool) ---

	/// Invoke the garbage collector.
	py_gc_collect :: proc() -> i32 ---

	/// Wrapper for `PK_MALLOC(size)`.
	py_malloc :: proc(size: i32) -> rawptr ---

	/// Wrapper for `PK_REALLOC(ptr, size)`.
	py_realloc :: proc(ptr: rawptr, size: i32) -> rawptr ---

	/// Wrapper for `PK_FREE(ptr)`.
	py_free :: proc(ptr: rawptr) ---

	/// A shorthand for `True`.
	py_True :: proc() -> py_GlobalRef ---

	/// A shorthand for `False`.
	py_False :: proc() -> py_GlobalRef ---

	/// A shorthand for `None`.
	py_None :: proc() -> py_GlobalRef ---

	/// A shorthand for `nil`. `nil` is not a valid python object.
	py_NIL :: proc() -> py_GlobalRef ---

	/// Get the current source location of the frame.
	py_Frame_sourceloc :: proc(frame: ^py_Frame, lineno: ^i32) -> cstring ---

	/// Python equivalent to `globals()` with respect to the given frame.
	py_Frame_newglobals :: proc(frame: ^py_Frame, out: py_OutRef) ---

	/// Python equivalent to `locals()` with respect to the given frame.
	py_Frame_newlocals :: proc(frame: ^py_Frame, out: py_OutRef) ---

	/// Get the function object of the frame.
	/// Returns `NULL` if not available.
	py_Frame_function :: proc(frame: ^py_Frame) -> py_StackRef ---

	/// Compile a source string into a code object.
	/// Use python's `exec()` or `eval()` to execute it.
	py_compile :: proc() -> i32 ---

	/// Compile a `.py` file into a `.pyc` file.
	py_compilefile :: proc() -> i32 ---

	/// Run a compiled code object.
	py_execo :: proc() -> i32 ---

	/// Run a source string.
	/// @param source source string.
	/// @param filename filename (for error messages).
	/// @param mode compile mode. Use `EXEC_MODE` for statements `EVAL_MODE` for expressions.
	/// @param module target module. Use NULL for the main module.
	/// @return `true` if the execution is successful or `false` if an exception is raised.
	py_exec :: proc(source: cstring, filename: cstring, mode: py_CompileMode, module: py_Ref) -> i32 ---

	/// Evaluate a source string. Equivalent to `py_exec(source, "<string>", EVAL_MODE, module)`.
	py_eval :: proc() -> i32 ---

	/// Run a source string with smart interpretation.
	/// Example:
	/// `py_newstr(py_r0(), "abc");`
	/// `py_newint(py_r1(), 123);`
	/// `py_smartexec("print(_0, _1)", NULL, py_r0(), py_r1());`
	/// `// "abc 123" will be printed`.
	py_smartexec :: proc() -> i32 ---

	/// Evaluate a source string with smart interpretation.
	/// Example:
	/// `py_newstr(py_r0(), "abc");`
	/// `py_smarteval("len(_)", NULL, py_r0());`
	/// `int res = py_toint(py_retval());`
	/// `// res will be 3`.
	py_smarteval :: proc() -> i32 ---

	/// Create an `int` object.
	py_newint :: proc(py_OutRef, py_i64) ---

	/// Create a trivial value object.
	py_newtrivial :: proc(out: py_OutRef, type: py_Type, data: rawptr, size: i32) ---

	/// Create a `float` object.
	py_newfloat :: proc(py_OutRef, py_f64) ---

	/// Create a `bool` object.
	py_newbool :: proc(py_OutRef, bool) ---

	/// Create a `str` object from a null-terminated string (utf-8).
	py_newstr :: proc(py_OutRef, cstring) ---

	/// Create a `str` object with `n` UNINITIALIZED bytes plus `'\0'`.
	py_newstrn :: proc(py_OutRef, i32) -> cstring ---

	/// Create a `str` object from a `c11_sv`.
	py_newstrv :: proc(py_OutRef, c11_sv) ---

	/// Create a formatted `str` object.
	py_newfstr :: proc(py_OutRef, cstring, #c_vararg ..any) ---

	/// Create a `bytes` object with `n` UNINITIALIZED bytes.
	py_newbytes :: proc(_: py_OutRef, n: i32) -> ^u8 ---

	/// Create a `None` object.
	py_newnone :: proc(py_OutRef) ---

	/// Create a `NotImplemented` object.
	py_newnotimplemented :: proc(py_OutRef) ---

	/// Create a `...` object.
	py_newellipsis :: proc(py_OutRef) ---

	/// Create a `nil` object. `nil` is an invalid representation of an object.
	/// Don't use it unless you know what you are doing.
	py_newnil :: proc(py_OutRef) ---

	/// Create a `nativefunc` object.
	py_newnativefunc :: proc(out: py_OutRef, func: py_CFunction) ---

	/// Create a `function` object.
	py_newfunction :: proc(out: py_OutRef, sig: cstring, f: i32, docstring: cstring, slots: i32) -> py_Name ---

	/// Create a `boundmethod` object.
	py_newboundmethod :: proc(out: py_OutRef, self: py_Ref, func: py_Ref) ---

	/// Create a new object.
	/// @param out output reference.
	/// @param type type of the object.
	/// @param slots number of slots. Use `-1` to create a `__dict__`.
	/// @param udsize size of your userdata.
	/// @return pointer to the userdata.
	py_newobject :: proc(out: py_OutRef, type: py_Type, slots: i32, udsize: i32) -> rawptr ---

	/// Convert a null-terminated string to a name.
	py_name :: proc(cstring) -> py_Name ---

	/// Convert a name to a null-terminated string.
	py_name2str :: proc(py_Name) -> cstring ---

	/// Convert a name to a python `str` object with cache.
	py_name2ref :: proc(py_Name) -> py_GlobalRef ---

	/// Convert a `c11_sv` to a name.
	py_namev :: proc(c11_sv) -> py_Name ---

	/// Convert a name to a `c11_sv`.
	py_name2sv :: proc(py_Name) -> c11_sv ---

	/// Bind a function to the object via "decl-based" style.
	/// @param obj the target object.
	/// @param sig signature of the function. e.g. `add(x, y)`.
	/// @param f function to bind.
	py_bind :: proc(obj: py_Ref, sig: cstring, f: i32) ---

	/// Bind a method to type via "argc-based" style.
	/// @param type the target type.
	/// @param name name of the method.
	/// @param f function to bind.
	py_bindmethod :: proc(type: py_Type, name: cstring, f: i32) ---

	/// Bind a static method to type via "argc-based" style.
	/// @param type the target type.
	/// @param name name of the method.
	/// @param f function to bind.
	py_bindstaticmethod :: proc(type: py_Type, name: cstring, f: i32) ---

	/// Bind a function to the object via "argc-based" style.
	/// @param obj the target object.
	/// @param name name of the function.
	/// @param f function to bind.
	py_bindfunc :: proc(obj: py_Ref, name: cstring, f: i32) ---

	/// Bind a property to type.
	/// @param type the target type.
	/// @param name name of the property.
	/// @param getter getter function.
	/// @param setter setter function. Use `NULL` if not needed.
	py_bindproperty :: proc(type: py_Type, name: cstring, getter: i32, setter: i32) ---

	/// Bind a magic method to type.
	py_bindmagic :: proc(type: py_Type, name: py_Name, f: i32) ---

	/// Convert an `int` object in python to `int64_t`.
	py_toint :: proc(py_Ref) -> py_i64 ---

	/// Get the address of the trivial value object (16 bytes).
	py_totrivial :: proc(py_Ref) -> rawptr ---

	/// Convert a `float` object in python to `double`.
	py_tofloat :: proc(py_Ref) -> py_f64 ---

	/// Cast a `int` or `float` object in python to `double`.
	/// If successful, return true and set the value to `out`.
	/// Otherwise, return false and raise `TypeError`.
	py_castfloat :: proc() -> i32 ---

	/// 32-bit version of `py_castfloat`.
	py_castfloat32 :: proc() -> i32 ---

	/// Cast a `int` object in python to `int64_t`.
	py_castint :: proc() -> i32 ---

	/// Convert a `bool` object in python to `bool`.
	py_tobool :: proc() -> i32 ---

	/// Convert a `type` object in python to `py_Type`.
	py_totype :: proc(py_Ref) -> py_Type ---

	/// Convert a user-defined object to its userdata.
	py_touserdata :: proc(py_Ref) -> rawptr ---

	/// Convert a `str` object in python to null-terminated string.
	py_tostr :: proc(py_Ref) -> cstring ---

	/// Convert a `str` object in python to char array.
	py_tostrn :: proc(_: py_Ref, size: ^i32) -> cstring ---

	/// Convert a `str` object in python to `c11_sv`.
	py_tosv :: proc(py_Ref) -> c11_sv ---

	/// Convert a `bytes` object in python to char array.
	py_tobytes :: proc(_: py_Ref, size: ^i32) -> ^u8 ---

	/// Resize a `bytes` object. It can only be resized down.
	py_bytes_resize :: proc(_: py_Ref, size: i32) ---

	/// Create a new type.
	/// @param name name of the type.
	/// @param base base type.
	/// @param module module where the type is defined. Use `NULL` for built-in types.
	/// @param dtor destructor function. Use `NULL` if not needed.
	py_newtype :: proc(name: cstring, base: py_Type, module: py_GlobalRef, dtor: py_Dtor) -> py_Type ---

	/// Check if the object is exactly the given type.
	py_istype :: proc() -> i32 ---

	/// Get the type of the object.
	py_typeof :: proc(self: py_Ref) -> py_Type ---

	/// Check if the object is an instance of the given type.
	py_isinstance :: proc() -> i32 ---

	/// Check if the derived type is a subclass of the base type.
	py_issubclass :: proc() -> i32 ---

	/// Get type by module and name. e.g. `py_gettype("time", py_name("struct_time"))`.
	/// Return `0` if not found.
	py_gettype :: proc(module: cstring, name: py_Name) -> py_Type ---

	/// Check if the object is an instance of the given type exactly.
	/// Raise `TypeError` if the check fails.
	py_checktype :: proc(ref: py_Ref, type: py_Type) -> i32 ---

	/// Check if the object is an instance of the given type or its subclass.
	/// Raise `TypeError` if the check fails.
	py_checkinstance :: proc() -> i32 ---

	/// Get the magic method from the given type only.
	/// Return `nil` if not found.
	py_tpgetmagic :: proc(type: py_Type, name: py_Name) -> py_GlobalRef ---

	/// Search the magic method from the given type to the base type.
	/// Return `NULL` if not found.
	py_tpfindmagic :: proc(_: py_Type, name: py_Name) -> py_GlobalRef ---

	/// Search the name from the given type to the base type.
	/// Return `NULL` if not found.
	py_tpfindname :: proc(_: py_Type, name: py_Name) -> py_ItemRef ---

	/// Get the base type of the given type.
	py_tpbase :: proc(type: py_Type) -> py_Type ---

	/// Get the type object of the given type.
	py_tpobject :: proc(type: py_Type) -> py_GlobalRef ---

	/// Get the type name.
	py_tpname :: proc(type: py_Type) -> cstring ---

	/// Disable the type for subclassing.
	py_tpsetfinal :: proc(type: py_Type) ---

	/// Set attribute hooks for the given type.
	py_tphookattributes :: proc(type: py_Type, getattribute: proc "c" (py_Ref, py_Name) -> i32, setattribute: proc "c" (py_Ref, py_Name, py_Ref) -> i32, delattribute: proc "c" (py_Ref, py_Name) -> i32, getunboundmethod: proc "c" (py_Ref, py_Name) -> i32) ---

	/// Get the current `function` object on the stack.
	/// Return `NULL` if not available.
	/// NOTE: This function should be placed at the beginning of your decl-based bindings.
	py_inspect_currentfunction :: proc() -> py_StackRef ---

	/// Get the current `module` object where the code is executed.
	/// Return `NULL` if not available.
	py_inspect_currentmodule :: proc() -> py_GlobalRef ---

	/// Get the current frame object.
	/// Return `NULL` if not available.
	py_inspect_currentframe :: proc() -> ^py_Frame ---

	/// Python equivalent to `globals()`.
	py_newglobals :: proc(py_OutRef) ---

	/// Python equivalent to `locals()`.
	py_newlocals :: proc(py_OutRef) ---

	/// Get the i-th register.
	/// All registers are located in a contiguous memory.
	py_getreg :: proc(i: i32) -> py_GlobalRef ---

	/// Set the i-th register.
	py_setreg :: proc(i: i32, val: py_Ref) ---

	/// Get the last return value.
	/// Please note that `py_retval()` cannot be used as input argument.
	py_retval :: proc() -> py_GlobalRef ---

	/// Get an item from the object's `__dict__`.
	/// Return `NULL` if not found.
	py_getdict :: proc(self: py_Ref, name: py_Name) -> py_ItemRef ---

	/// Set an item to the object's `__dict__`.
	py_setdict :: proc(self: py_Ref, name: py_Name, val: py_Ref) ---

	/// Delete an item from the object's `__dict__`.
	/// Return `true` if the deletion is successful.
	py_deldict :: proc() -> i32 ---

	/// Prepare an insertion to the object's `__dict__`.
	py_emplacedict :: proc(self: py_Ref, name: py_Name) -> py_ItemRef ---

	/// Apply a function to all items in the object's `__dict__`.
	/// Return `true` if the function is successful for all items.
	/// NOTE: Be careful if `f` modifies the object's `__dict__`.
	py_applydict :: proc() -> i32 ---

	/// Clear the object's `__dict__`. This function is dangerous.
	py_cleardict :: proc(self: py_Ref) ---

	/// Get the i-th slot of the object.
	/// The object must have slots and `i` must be in valid range.
	py_getslot :: proc(self: py_Ref, i: i32) -> py_ObjectRef ---

	/// Set the i-th slot of the object.
	py_setslot :: proc(self: py_Ref, i: i32, val: py_Ref) ---

	/// Get variable in the `builtins` module.
	py_getbuiltin :: proc(name: py_Name) -> py_ItemRef ---

	/// Get variable in the `__main__` module.
	py_getglobal :: proc(name: py_Name) -> py_ItemRef ---

	/// Set variable in the `__main__` module.
	py_setglobal :: proc(name: py_Name, val: py_Ref) ---

	/// Get the i-th object from the top of the stack.
	/// `i` should be negative, e.g. (-1) means TOS.
	py_peek :: proc(i: i32) -> py_StackRef ---

	/// Push the object to the stack.
	py_push :: proc(src: py_Ref) ---

	/// Push a `nil` object to the stack.
	py_pushnil :: proc() ---

	/// Push a `None` object to the stack.
	py_pushnone :: proc() ---

	/// Push a `py_Name` to the stack. This is used for keyword arguments.
	py_pushname :: proc(name: py_Name) ---

	/// Pop an object from the stack.
	py_pop :: proc() ---

	/// Shrink the stack by n.
	py_shrink :: proc(n: i32) ---

	/// Get a temporary variable from the stack.
	py_pushtmp :: proc() -> py_StackRef ---

	/// Get the unbound method of the object.
	/// Assume the object is located at the top of the stack.
	/// If return true:  `[self] -> [unbound, self]`.
	/// If return false: `[self] -> [self]` (no change).
	py_pushmethod :: proc() -> i32 ---

	/// Evaluate an expression and push the result to the stack.
	/// This function is used for testing.
	py_pusheval :: proc() -> i32 ---

	/// Call a callable object via pocketpy's calling convention.
	/// You need to prepare the stack using the following format:
	/// `callable, self/nil, arg1, arg2, ..., k1, v1, k2, v2, ...`.
	/// `argc` is the number of positional arguments excluding `self`.
	/// `kwargc` is the number of keyword arguments.
	/// The result will be set to `py_retval()`.
	/// The stack size will be reduced by `2 + argc + kwargc * 2`.
	py_vectorcall :: proc(argc: u16, kwargc: u16) -> i32 ---

	/// Call a function.
	/// It prepares the stack and then performs a `vectorcall(argc, 0, false)`.
	/// The result will be set to `py_retval()`.
	/// The stack remains unchanged if successful.
	py_call :: proc() -> i32 ---

	/// Call a type to create a new instance.
	py_tpcall :: proc() -> i32 ---

	/// Call a `py_CFunction` in a safe way.
	/// This function does extra checks to help you debug `py_CFunction`.
	py_callcfunc :: proc() -> i32 ---

	/// Perform a binary operation.
	/// The result will be set to `py_retval()`.
	/// The stack remains unchanged after the operation.
	py_binaryop :: proc() -> i32 ---

	/// lhs + rhs
	py_binaryadd :: proc() -> i32 ---

	/// lhs - rhs
	py_binarysub :: proc() -> i32 ---

	/// lhs * rhs
	py_binarymul :: proc() -> i32 ---

	/// lhs / rhs
	py_binarytruediv :: proc() -> i32 ---

	/// lhs // rhs
	py_binaryfloordiv :: proc() -> i32 ---

	/// lhs % rhs
	py_binarymod :: proc() -> i32 ---

	/// lhs ** rhs
	py_binarypow :: proc() -> i32 ---

	/// lhs << rhs
	py_binarylshift :: proc() -> i32 ---

	/// lhs >> rhs
	py_binaryrshift :: proc() -> i32 ---

	/// lhs & rhs
	py_binaryand :: proc() -> i32 ---

	/// lhs | rhs
	py_binaryor :: proc() -> i32 ---

	/// lhs ^ rhs
	py_binaryxor :: proc() -> i32 ---

	/// lhs @ rhs
	py_binarymatmul :: proc() -> i32 ---

	/// lhs == rhs
	py_eq :: proc() -> i32 ---

	/// lhs != rhs
	py_ne :: proc() -> i32 ---

	/// lhs < rhs
	py_lt :: proc() -> i32 ---

	/// lhs <= rhs
	py_le :: proc() -> i32 ---

	/// lhs > rhs
	py_gt :: proc() -> i32 ---

	/// lhs >= rhs
	py_ge :: proc() -> i32 ---

	/// Python equivalent to `lhs is rhs`.
	py_isidentical :: proc() -> i32 ---

	/// Python equivalent to `bool(val)`.
	/// 1: true, 0: false, -1: error
	py_bool :: proc(val: py_Ref) -> i32 ---

	/// Compare two objects.
	/// 1: lhs == rhs, 0: lhs != rhs, -1: error
	py_equal :: proc(lhs: py_Ref, rhs: py_Ref) -> i32 ---

	/// Compare two objects.
	/// 1: lhs < rhs, 0: lhs >= rhs, -1: error
	py_less :: proc(lhs: py_Ref, rhs: py_Ref) -> i32 ---

	/// Python equivalent to `callable(val)`.
	py_callable :: proc() -> i32 ---

	/// Get the hash value of the object.
	py_hash :: proc() -> i32 ---

	/// Get the iterator of the object.
	py_iter :: proc() -> i32 ---

	/// Get the next element from the iterator.
	/// 1: success, 0: StopIteration, -1: error
	py_next :: proc(py_Ref) -> i32 ---

	/// Python equivalent to `str(val)`.
	py_str :: proc() -> i32 ---

	/// Python equivalent to `repr(val)`.
	py_repr :: proc() -> i32 ---

	/// Python equivalent to `len(val)`.
	py_len :: proc() -> i32 ---

	/// Python equivalent to `getattr(self, name)`.
	py_getattr :: proc() -> i32 ---

	/// Python equivalent to `setattr(self, name, val)`.
	py_setattr :: proc() -> i32 ---

	/// Python equivalent to `delattr(self, name)`.
	py_delattr :: proc() -> i32 ---

	/// Python equivalent to `self[key]`.
	py_getitem :: proc() -> i32 ---

	/// Python equivalent to `self[key] = val`.
	py_setitem :: proc() -> i32 ---

	/// Python equivalent to `del self[key]`.
	py_delitem :: proc() -> i32 ---

	/// Get a module by path.
	py_getmodule :: proc(path: cstring) -> py_GlobalRef ---

	/// Create a new module.
	py_newmodule :: proc(path: cstring) -> py_GlobalRef ---

	/// Reload an existing module.
	py_importlib_reload :: proc() -> i32 ---

	/// Import a module.
	/// The result will be set to `py_retval()`.
	/// -1: error, 0: not found, 1: success
	py_import :: proc(path: cstring) -> i32 ---

	/// Check if there is an unhandled exception.
	py_checkexc :: proc() -> i32 ---

	/// Check if the unhandled exception is an instance of the given type.
	/// If match, the exception will be stored in `py_retval()`.
	py_matchexc :: proc() -> i32 ---

	/// Clear the unhandled exception.
	/// @param p0 the unwinding point. Use `NULL` if not needed.
	py_clearexc :: proc(p0: py_StackRef) ---

	/// Print the unhandled exception.
	py_printexc :: proc() ---

	/// Format the unhandled exception and return a null-terminated string.
	/// The returned string should be freed by the caller.
	py_formatexc :: proc() -> cstring ---

	/// Raise an exception by type and message. Always return false.
	py_exception :: proc(type: py_Type, fmt: cstring, #c_vararg args: ..any) -> i32 ---

	/// Raise an exception object. Always return false.
	py_raise                        :: proc() -> i32 ---
	KeyError                        :: proc() -> i32 ---
	StopIteration                   :: proc() -> i32 ---
	py_debugger_waitforattach       :: proc(hostname: cstring, port: u16) ---
	py_debugger_status              :: proc() -> i32 ---
	py_debugger_exceptionbreakpoint :: proc(exc: py_Ref) ---
	py_debugger_exit                :: proc(code: i32) ---

	/// Create a `tuple` with `n` UNINITIALIZED elements.
	/// You should initialize all elements before using it.
	py_newtuple      :: proc(_: py_OutRef, n: i32) -> py_ObjectRef ---
	py_tuple_data    :: proc(self: py_Ref) -> py_ObjectRef ---
	py_tuple_getitem :: proc(self: py_Ref, i: i32) -> py_ObjectRef ---
	py_tuple_setitem :: proc(self: py_Ref, i: i32, val: py_Ref) ---
	py_tuple_len     :: proc(self: py_Ref) -> i32 ---

	/// Create an empty `list`.
	py_newlist :: proc(py_OutRef) ---

	/// Create a `list` with `n` UNINITIALIZED elements.
	/// You should initialize all elements before using it.
	py_newlistn     :: proc(_: py_OutRef, n: i32) ---
	py_list_data    :: proc(self: py_Ref) -> py_ItemRef ---
	py_list_getitem :: proc(self: py_Ref, i: i32) -> py_ItemRef ---
	py_list_setitem :: proc(self: py_Ref, i: i32, val: py_Ref) ---
	py_list_delitem :: proc(self: py_Ref, i: i32) ---
	py_list_len     :: proc(self: py_Ref) -> i32 ---
	py_list_swap    :: proc(self: py_Ref, i: i32, j: i32) ---
	py_list_append  :: proc(self: py_Ref, val: py_Ref) ---
	py_list_emplace :: proc(self: py_Ref) -> py_ItemRef ---
	py_list_clear   :: proc(self: py_Ref) ---
	py_list_insert  :: proc(self: py_Ref, i: i32, val: py_Ref) ---

	/// Create an empty `dict`.
	py_newdict :: proc(py_OutRef) ---

	/// -1: error, 0: not found, 1: found
	py_dict_getitem :: proc(self: py_Ref, key: py_Ref) -> i32 ---

	/// true: success, false: error
	py_dict_setitem :: proc() -> i32 ---

	/// -1: error, 0: not found, 1: found (and deleted)
	py_dict_delitem :: proc(self: py_Ref, key: py_Ref) -> i32 ---

	/// -1: error, 0: not found, 1: found
	py_dict_getitem_by_str :: proc(self: py_Ref, key: cstring) -> i32 ---

	/// -1: error, 0: not found, 1: found
	py_dict_getitem_by_int :: proc(self: py_Ref, key: py_i64) -> i32 ---

	/// true: success, false: error
	py_dict_setitem_by_str :: proc() -> i32 ---

	/// true: success, false: error
	py_dict_setitem_by_int :: proc() -> i32 ---

	/// -1: error, 0: not found, 1: found (and deleted)
	py_dict_delitem_by_str :: proc(self: py_Ref, key: cstring) -> i32 ---

	/// -1: error, 0: not found, 1: found (and deleted)
	py_dict_delitem_by_int :: proc(self: py_Ref, key: py_i64) -> i32 ---

	/// true: success, false: error
	py_dict_apply :: proc() -> i32 ---

	/// noexcept
	py_dict_len :: proc(self: py_Ref) -> i32 ---

	/// Create an UNINITIALIZED `slice` object.
	/// You should use `py_setslot()` to set `start`, `stop`, and `step`.
	py_newslice :: proc(py_OutRef) -> py_ObjectRef ---

	/// Create a `slice` object from 3 integers.
	py_newsliceint :: proc(out: py_OutRef, start: py_i64, stop: py_i64, step: py_i64) ---

	/************* random module *************/
	py_newRandom      :: proc(out: py_OutRef) ---
	py_Random_seed    :: proc(self: py_Ref, seed: py_i64) ---
	py_Random_random  :: proc(self: py_Ref) -> py_f64 ---
	py_Random_uniform :: proc(self: py_Ref, a: py_f64, b: py_f64) -> py_f64 ---
	py_Random_randint :: proc(self: py_Ref, a: py_i64, b: py_i64) -> py_i64 ---

	/************* array2d module *************/
	py_newarray2d        :: proc(out: py_OutRef, width: i32, height: i32) ---
	py_array2d_getwidth  :: proc(self: py_Ref) -> i32 ---
	py_array2d_getheight :: proc(self: py_Ref) -> i32 ---
	py_array2d_getitem   :: proc(self: py_Ref, x: i32, y: i32) -> py_ObjectRef ---
	py_array2d_setitem   :: proc(self: py_Ref, x: i32, y: i32, val: py_Ref) ---

	/************* vmath module *************/
	py_newvec2    :: proc(out: py_OutRef, _: c11_vec2) ---
	py_newvec3    :: proc(out: py_OutRef, _: c11_vec3) ---
	py_newvec2i   :: proc(out: py_OutRef, _: c11_vec2i) ---
	py_newvec3i   :: proc(out: py_OutRef, _: c11_vec3i) ---
	py_newcolor32 :: proc(out: py_OutRef, _: c11_color32) ---
	py_newmat3x3  :: proc(out: py_OutRef) -> ^c11_mat3x3 ---
	py_tovec2     :: proc(self: py_Ref) -> c11_vec2 ---
	py_tovec3     :: proc(self: py_Ref) -> c11_vec3 ---
	py_tovec2i    :: proc(self: py_Ref) -> c11_vec2i ---
	py_tovec3i    :: proc(self: py_Ref) -> c11_vec3i ---
	py_tomat3x3   :: proc(self: py_Ref) -> ^c11_mat3x3 ---
	py_tocolor32  :: proc(self: py_Ref) -> c11_color32 ---

	/************* json module *************/
	/// Python equivalent to `json.dumps(val)`.
	py_json_dumps :: proc() -> i32 ---

	/// Python equivalent to `json.loads(val)`.
	py_json_loads :: proc() -> i32 ---

	/************* pickle module *************/
	/// Python equivalent to `pickle.dumps(val)`.
	py_pickle_dumps :: proc() -> i32 ---

	/// Python equivalent to `pickle.loads(val)`.
	py_pickle_loads :: proc() -> i32 ---

	/************* pkpy module *************/
	/// Begin the watchdog with `timeout` in milliseconds.
	/// `PK_ENABLE_WATCHDOG` must be defined to `1` to use this feature.
	/// You need to call `py_watchdog_end()` later.
	/// If `timeout` is reached, `TimeoutError` will be raised.
	py_watchdog_begin :: proc(timeout: py_i64) ---

	/// Reset the watchdog.
	py_watchdog_end    :: proc() ---
	py_profiler_begin  :: proc() ---
	py_profiler_end    :: proc() ---
	py_profiler_reset  :: proc() ---
	py_profiler_report :: proc() -> cstring ---

	/************* Others *************/
	time_ns           :: proc() -> i64 ---
	time_monotonic_ns :: proc() -> i64 ---

	/// An utility function to read a line from stdin for REPL.
	py_replinput :: proc(buf: cstring, max_size: i32) -> i32 ---
}

/// Python favored string formatting.
/// %d: int
/// %i: py_i64 (int64_t)
/// %f: py_f64 (double)
/// %s: const char*
/// %q: c11_sv
/// %v: c11_sv
/// %c: char
/// %p: void*
/// %t: py_Type
/// %n: py_Name
py_PredefinedType :: enum u32 {
	nil                   = 0,
	object                = 1,
	type                  = 2,  // py_Type
	int                   = 3,
	float                 = 4,
	bool                  = 5,
	str                   = 6,
	str_iterator          = 7,
	list                  = 8,  // c11_vector
	tuple                 = 9,  // N slots
	list_iterator         = 10, // 1 slot
	tuple_iterator        = 11, // 1 slot
	slice                 = 12, // 3 slots (start, stop, step)
	range                 = 13,
	range_iterator        = 14,
	module                = 15,
	function              = 16,
	nativefunc            = 17,
	boundmethod           = 18, // 2 slots (self, func)
	super                 = 19, // 1 slot + py_Type
	BaseException         = 20,
	Exception             = 21,
	bytes                 = 22,
	namedict              = 23,
	locals                = 24,
	code                  = 25,
	dict                  = 26,
	dict_iterator         = 27, // 1 slot
	property              = 28, // 2 slots (getter + setter)
	star_wrapper          = 29, // 1 slot + int level
	staticmethod          = 30, // 1 slot
	classmethod           = 31, // 1 slot
	NoneType              = 32,
	NotImplementedType    = 33,
	ellipsis              = 34,
	generator             = 35,

	/* builtin exceptions */
	SystemExit            = 36,
	KeyboardInterrupt     = 37,
	StopIteration         = 38,
	SyntaxError           = 39,
	RecursionError        = 40,
	OSError               = 41,
	NotImplementedError   = 42,
	TypeError             = 43,
	IndexError            = 44,
	ValueError            = 45,
	RuntimeError          = 46,
	TimeoutError          = 47,
	ZeroDivisionError     = 48,
	NameError             = 49,
	UnboundLocalError     = 50,
	AttributeError        = 51,
	ImportError           = 52,
	AssertionError        = 53,
	KeyError              = 54,

	/* stdc */
	stdc_Memory           = 55,
	stdc_Char             = 56,
	stdc_UChar            = 57,
	stdc_Short            = 58,
	stdc_UShort           = 59,
	stdc_Int              = 60,
	stdc_UInt             = 61,
	stdc_Long             = 62,
	stdc_ULong            = 63,
	stdc_LongLong         = 64,
	stdc_ULongLong        = 65,
	stdc_Float            = 66,
	stdc_Double           = 67,
	stdc_Pointer          = 68,
	stdc_Bool             = 69,

	/* vmath */
	vec2                  = 70,
	vec3                  = 71,
	vec2i                 = 72,
	vec3i                 = 73,
	mat3x3                = 74,
	color32               = 75,

	/* array2d */
	array2d_like          = 76,
	array2d_like_iterator = 77,
	array2d               = 78,
	array2d_view          = 79,
	chunked_array2d       = 80,
}

