package casting_types

import py "../.."

import "core:fmt"

main :: proc () {
	py.initialize()
	defer py.finalize()

	// string
	py.newstr(py.r0(), "Hello World")
	str := py.tostr(py.r0());
	fmt.printfln("str: %s", str)

	// int
	py.newint(py.r1(), 10)
	int_ := py.toint(py.r1())
	fmt.printfln("int: %d", int_)

	// float
	py.newfloat(py.r2(), 10.5)
	float := py.tofloat(py.r2())
	fmt.printfln("float: %f", float)

	// tuple (r3)
	p := py.newtuple(py.r3(), 3)
	p[0] = py.r0()^
	p[1] = py.r1()^
	p[2] = py.r2()^
	if !py.repr(py.r3()) {
		py.printexc()
		return
	}
	fmt.printfln("tuple: %s", py.tostr(py.retval()))

	// list (r4)
	py.newlist(py.r4())
	py.list_append(py.r4(), py.r0())
	py.list_append(py.r4(), py.r1())
	py.list_append(py.r4(), py.r2())
	if !py.repr(py.r4()) {
		py.printexc()
		return
	}
	fmt.printfln("list: %s", py.tostr(py.retval()))

	py.newdict(py.r5())
	py.dict_setitem_by_str(py.r5(), "str", py.r0())
	py.dict_setitem_by_str(py.r5(), "int", py.r1())
	py.dict_setitem_by_str(py.r5(), "float", py.r2())
	py.dict_setitem_by_str(py.r5(), "tuple", py.r3())
	py.dict_setitem_by_str(py.r5(), "list", py.r4())
	if !py.repr(py.r5()) {
		py.printexc()
		return
	}
	fmt.printfln("dict: %s", py.tostr(py.retval()))
}