package main

import py "../.."

main :: proc () {
	py.initialize()
	defer py.finalize()
	
	if ok := py.exec("print(\"Hello World!\")", "<string>", .EXEC_MODE, nil); !ok {
		py.printexc()
		return
	}
}
