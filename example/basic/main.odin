package basic

import py "../.."
import "core:fmt"
import "base:runtime"
import "core:mem"

int_add :: proc "c" (argc: int, argv: [^]py.py_TValue) -> i32 {
	context = runtime.default_context()

	if(argc != 2) {
		return py.py_exception(43, "expected %d arguments, got %d", 2, argc)
	}

	if py.py_checktype(&argv[0], 3) == 0 {
		return 0
	}
	if py.py_checktype(&argv[1], 3) == 0 {
		return 0
	}

	a := py.py_toint(&argv[0])
	b := py.py_toint(&argv[1])

	fmt.printfln("inside: %s %s", a, b)

	py.py_newint(py.py_retval(), a + b)
	return 1
}

// py_check_args_count :: proc (argc: int)

py_tmpr0 :: proc () -> py.py_GlobalRef {
	return py.py_getreg(8)
}

main :: proc () {
	py.py_initialize()

	ok: i32 = py.py_exec("print(f\"Hello World!\")", "<string>", .EXEC_MODE, nil)
	if ok == 0 {
		// error
	}

	// Create a list
	r0: py.py_Ref = py_tmpr0()
	py.py_newlistn(r0, 3)
	py.py_newint(py.py_list_getitem(r0, 0), 9)
	py.py_newint(py.py_list_getitem(r0, 1), 11)
	py.py_newint(py.py_list_getitem(r0, 2), 27)

	f_sum: py.py_Ref = py.py_getbuiltin(py.py_name("sum"))
	py.py_push(f_sum)
	py.py_pushnil()
	py.py_push(r0)

	ok2 := py.py_vectorcall(1, 0)
	if ok2 == 0 {
		// error
	}

	fmt.println("Sum of the list:", py.py_toint(py.py_retval()))

	py.py_newnativefunc(r0, int_add)
	py.py_setglobal(py.py_name("add"), r0)

	ok3 := py.py_exec("add(7, 4)", "<string>", .EVAL_MODE, nil)
	if ok3 == 0 {
		// error
		py.py_printexc()
	}

	res: py.py_i64 = py.py_toint(py.py_retval())
	fmt.println("Sum of 2 variables:", res)

	py.py_finalize()
}