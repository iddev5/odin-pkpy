package main

import py "../.."

main :: proc () {
	py.initialize()
	defer {
		py.finalize()
	}
	
	ok: i32 = py.exec("print(\"Hello World!\")", "<string>", .EXEC_MODE, nil);
	if ok == 0 {
		py.printexc()
		return
	}
}
