package basic

import py "../.."
import "core:fmt"
import "base:runtime"
import "core:mem"

int_add :: proc "c" (argc: int, argv: [^]py.TValue) -> i32 {
	context = runtime.default_context()

	if(argc != 2) {
		return py.exception(43, "expected %d arguments, got %d", 2, argc)
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

// check_args_count :: proc (argc: int)

tmpr0 :: proc () -> py.GlobalRef {
	return py.getreg(8)
}

main :: proc () {
	py.initialize()
	defer py.finalize()

	ok := py.exec("print(f\"Hello World!\")", "<string>", .EXEC_MODE, nil)
	if !ok {
		// error
		py.printexc()
		return
	}

	// Create a list
	r0: py.Ref = tmpr0()
	py.newlistn(r0, 3)
	py.newint(py.list_getitem(r0, 0), 9)
	py.newint(py.list_getitem(r0, 1), 11)
	py.newint(py.list_getitem(r0, 2), 27)

	f_sum: py.Ref = py.getbuiltin(py.name("sum"))
	py.push(f_sum)
	py.pushnil()
	py.push(r0)

	ok = py.vectorcall(1, 0)
	if !ok {
		// error
		py.printexc()
		return
	}

	fmt.println("Sum of the list:", py.toint(py.retval()))

	py.newnativefunc(r0, int_add)
	py.setglobal(py.name("add"), r0)

	ok = py.exec("add(7, 4)", "<string>", .EVAL_MODE, nil)
	if !ok {
		// error
		py.printexc()
		return
	}

	res: i64 = py.toint(py.retval())
	fmt.println("Sum of 2 variables:", res)
}