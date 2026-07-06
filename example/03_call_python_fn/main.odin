package call_python_fn

import "core:fmt"
import py "../.."

INPUT :: `
def multiply(x, y):
    return x * y


class Multiplier:
    def __init__(self, x):
        self.x = x

    def multiply(self, y):
        return self.x * y
`

main :: proc () {
	py.initialize()
	defer py.finalize()

	if !py.exec(INPUT, "main.py", .EXEC_MODE, nil) {
		py.printexc()
		return
	}

	x: i64 = 10
	y: i64 = 3

	__main__ := py.getmodule("__main__")

	// multiply(x, y)
	if !py.getattr(__main__, py.name("multiply")) {
		py.printexc()
		return
	}

	py.push(py.retval()) // callable
	py.pushnil() // self or nil
	py.newint(py.pushtmp(), x) // arg1
	py.newint(py.pushtmp(), y) // arg2

	if !py.vectorcall(2, 0) {
		py.printexc()
		return
	}

	if py.isint(py.retval()) {
		res := py.toint(py.retval())
		fmt.printfln("multiply(10, 3): %d", res)
	}

	// Multipler(x).multiply(y)
	py.newint(py.r0(), x)
	py.newint(py.r1(), y)
	if !py.smarteval("Multiplier(_0).multiply(_1)", nil, py.r0(), py.r1()) {
		py.printexc()
		return
	}

	if py.isint(py.retval()) {
		res := py.toint(py.retval())
		fmt.printfln("Multiplier(10).multiply(3): %d", res)
	}
}