package bind_variadic_fn

import "base:runtime"
import "core:fmt"
import py "../.."

INPUT :: `
print("==> my_print(*args, sep=', ')")
my_print(1, '2', 3.0, True, [None, ('a', 'b')])

a = [i for i in range(5)]
my_print(*a, sep=' | ')

print("==> my_print_kw(sep='=', **kwargs)")
my_print_kw(a=1, b='2', c=3.0, d=True)
print()
my_print_kw(a=1, b='2', c=3.0, d=True, sep=': ')
`

my_print :: proc "c" (argc: int, argv: [^]py.TValue) -> bool {
	context = runtime.default_context()

	NUM_ARGS :: 2
	if argc != NUM_ARGS {
		// TODO
		return false
	}

	if !py.checktype(&argv[0], .tuple) do return false
	if !py.checktype(&argv[1], .str) do return false

	length := py.tuple_len(&argv[0])
	sep := py.tostr(&argv[1])

	for i: i32 = 0; i < length; i += 1 {
		item := py.tuple_getitem(&argv[0], i)
		if !py.str(item) do return false

		fmt.print(py.tostr(py.retval()))
		if i < length - 1 do fmt.print(sep)
	}
	fmt.println()
	py.newnone(py.retval())
	return true
}

my_print_kw_dict_apply :: proc "c" (key: py.Ref, value: py.Ref, ctx: rawptr) -> bool {
	context = runtime.default_context()
	
	sep := cstring(ctx)
	if !py.str(key) do return false

	fmt.print(py.tostr(py.retval()))
	if !py.str(value) do return false

	fmt.printfln("%s%s", sep, py.tostr(py.retval()))
	return true
}

my_print_kw :: proc "c" (argc: int, argv: [^]py.TValue) -> bool {
	NUM_ARGS :: 2
	if argc != NUM_ARGS {
		// TODO
		return false
	}

	if !py.checktype(&argv[0], .str) do return false
	if !py.checktype(&argv[1], .dict) do return false

	sep := py.tostr(&argv[0])
	if ok := py.dict_apply(&argv[1], my_print_kw_dict_apply, rawptr(sep)); !ok {
		return false
	}

	py.newnone(py.retval())
	return true
}

main :: proc () {
	py.initialize()
	defer py.finalize()

	__main__ := py.getmodule("__main__")
	py.bind(__main__, "my_print(*args, sep=', ')", my_print)
  	py.bind(__main__, "my_print_kw(sep='=', **kwargs)", my_print_kw)

	if !py.exec(INPUT, "main.py", .EXEC_MODE, nil) {
		py.printexc()
		return
	}
}