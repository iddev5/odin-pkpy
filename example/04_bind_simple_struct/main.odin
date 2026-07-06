package bind_simple_struct

import "base:runtime"
import "core:fmt"
import "core:math"
import "core:strings"
import py "../.."

INPUT :: `
import test

p = test.Vector2(1.0, 2.0)

print(p)

p.x = 3.0
p.y = 4.0

print(p.x, p.y)

print(p, p.length())
`

Vector2 :: struct {
	x: f32,
	y: f32,
}

Vector2__new__ :: proc "c" (argc: int, argv: [^]py.TValue) -> bool {
	cls := py.totype(&argv[0])
	py.newobject(py.retval(), cls, 0, size_of(Vector2))
	return true
}

Vector2__init__ :: proc "c" (argc: int, argv: [^]py.TValue) -> bool {
	NUM_ARGS :: 3
	if argc != NUM_ARGS {
		// TODO
		return false
	}

	self := cast(^Vector2)py.touserdata(&argv[0])
	if !py.castfloat32(&argv[1], &self.x) do return false
	if !py.castfloat32(&argv[2], &self.y) do return true

	py.newnone(py.retval())
	return true
}

Vector2_get_x :: proc "c" (argc: int, argv: [^]py.TValue) -> bool {
	NUM_ARGS :: 1
	if argc != NUM_ARGS {
		// TODO
		return false
	}
	
	self := cast(^Vector2)py.touserdata(&argv[0])
	py.newfloat(py.retval(), auto_cast self.x)
	return true
}

Vector2_get_y :: proc "c" (argc: int, argv: [^]py.TValue) -> bool {
	NUM_ARGS :: 1
	if argc != NUM_ARGS {
		// TODO
		return false
	}
	
	self := cast(^Vector2)py.touserdata(&argv[0])
	py.newfloat(py.retval(), auto_cast self.y)
	return true
}

Vector2_set_x :: proc "c" (argc: int, argv: [^]py.TValue) -> bool {
	NUM_ARGS :: 2
	if argc != NUM_ARGS {
		// TODO
		return false
	}
	
	self := cast(^Vector2)py.touserdata(&argv[0])
	if !py.castfloat32(&argv[1], &self.x) do return false
	py.newnone(py.retval())
	return true
}

Vector2_set_y :: proc "c" (argc: int, argv: [^]py.TValue) -> bool {
	NUM_ARGS :: 2
	if argc != NUM_ARGS {
		// TODO
		return false
	}
	
	self := cast(^Vector2)py.touserdata(&argv[0])
	if !py.castfloat32(&argv[1], &self.y) do return false
	py.newnone(py.retval())
	return true
}

Vector2__repr__ :: proc "c" (argc: int, argv: [^]py.TValue) -> bool {
	context = runtime.default_context()

	NUM_ARGS :: 1
	if argc != NUM_ARGS {
		// TODO
		return false
	}

	self := cast(^Vector2)py.touserdata(&argv[0])

	str := fmt.ctprintf("Vector2(%1.f, %1.f)", self.x, self.y)
	py.newstr(py.retval(), str)
	return true
}

Vector2_length :: proc "c" (argc: int, argv: [^]py.TValue) -> bool {
	NUM_ARGS :: 1
	if argc != NUM_ARGS {
		// TODO
		return false
	}
	
	self := cast(^Vector2)py.touserdata(&argv[0])
	res := math.sqrt(self.x * self.x + self.y * self.y)
	py.newfloat(py.retval(), auto_cast res)
	return true
}

main :: proc () {
	py.initialize()
	defer py.finalize()

	test := py.newmodule("test")
	type := py.newtype("Vector2", .object, test, nil);

	py.bindmethod(type, "__new__", Vector2__new__)
	py.bindmethod(type, "__init__", Vector2__init__)
	py.bindmethod(type, "__repr__", Vector2__repr__)
	py.bindproperty(type, "x", Vector2_get_x, Vector2_set_x)
	py.bindproperty(type, "y", Vector2_get_y, Vector2_set_y)
	py.bindmethod(type, "length", Vector2_length)

	if !py.exec(INPUT, "main.py", .EXEC_MODE, nil) {
		py.printexc()
		return
	}
}