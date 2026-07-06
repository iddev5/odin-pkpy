package bind_simple_fn

import py "../.."

add_int :: proc "c" (argc: int, argv: [^]py.TValue) -> i32 {
	NUM_ARGS :: 2
	if(argc != NUM_ARGS) {
		return py.exception(43, "expected %d arguments, got %d", NUM_ARGS, argc)
	}

	if !py.checktype(&argv[0], 3) {
		return 0
	}
	if !py.checktype(&argv[1], 3) {
		return 0
	}

	a := py.toint(&argv[0])
	b := py.toint(&argv[1])

	py.newint(py.retval(), a + b)
	return 1
}

main :: proc () {
	py.initialize()
	defer py.finalize()

	__main__ := py.getmodule("__main__")
	py.bindfunc(__main__, "add", add_int)

	if !py.exec("print(f\"Result is: {add(3, 7) * 2}\")", "main.py", .EXEC_MODE, nil) {
		py.printexc()
		return
	}
}