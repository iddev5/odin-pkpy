# Odin PocketPy

Odin bindings for [PocketPy](https://github.com/pocketpy/pocketpy)

The bindings were initially auto-generated with odin-c-bindgen and then modified manually. The API tries to be as similar to the upstream C API as possible however minor modifications have been done where needed.

NOTE: This library is work in progress, certain functions are still not present or broken

## How to use

1. Copy or clone this repository into your project
2. Compile the pocketpy library, scripts for some platforms are already provided.
```sh-session
# Linux
./pocketpy/build_linux.sh

# Windows
.\pocketpy\build_windows.bat
```
3. Import the library into your project

```odin
import py "odin-pkpy"
```

Checkout [example/](https://github.com/iddev5/odin-pkpy/tree/main/example) directory for detailed API usage.

```odin
package demo

import py "odin-pkpy"
import "core:fmt"

int_add :: proc "c" (argc: int, argv: [^]py.TValue) -> bool {
	NUM_ARGS :: 2
	if(argc != NUM_ARGS) {
		return py.exception(.TypeError, "expected %d arguments, got %d", NUM_ARGS, argc)
	}

	if !py.checktype(&argv[0], .int) do return false
	if !py.checktype(&argv[1], .int) do return false

	a := py.toint(&argv[0])
	b := py.toint(&argv[1])

	py.newint(py.retval(), a + b)
	return true
}

main :: proc () {
	py.initialize()
	defer py.finalize()

	ok := py.exec("print(f\"Hello World!\")", "<string>", .EXEC_MODE, nil)
	if !ok {
		py.printexc()
		return
	}

	r0 := py.tmpr0()
	py.newnativefunc(r0, int_add)
	py.setglobal(py.name("add"), r0)

	ok = py.exec("add(7, 4)", "<string>", .EVAL_MODE, nil)
	if !ok {
		py.printexc()
		return
	}

	res: i64 = py.toint(py.retval())
	fmt.println("Sum of 2 variables:", res)
}
```

Note: In order to update the pocketpy sources, you can use the `update_pkpy.sh` script file.

## API Design and Differences
The API is kept as similar as possible. For all the functions, the `py_` prefix has been dropped. So you can use it as `py.initialize()` vs `py.py_initialize()`.

The following functions have been renamed to avoid symbol name collision.

- `py_bool` -> `_bool`
- `py_import` -> `importlib`

Macros like `py_r0 py_r1 ... py_tmpr0 py_tmpr1 ... py_isint py_isfloat ... py_checkint py_checkfloat ...` have been converted to regular functions;

The `py_Type` is now an alias of `py_PredefinedType`, so in order to pass in custom types, explicit casting is required.

Certain macros are not present and it is recommend to do said things manually.

- `PY_CHECK_ARGC(n)` -> `if argc != n { return py.exception(...) }`
- `PY_CHECK_ARG_TYPE(i, type)` -> `if py.checktype(&argv[i], type) do return false` 
- `py_arg(i)` -> `&argv[i]`

## License

The project is licensed under BSD 3-Clause License
