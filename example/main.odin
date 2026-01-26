package main

import pkpy ".."

main :: proc () {
	pkpy.py_initialize()
	defer {
		pkpy.py_finalize()
	}

	/*
	ok := pkpy.py_exec("print('Hello World!')", "<string>", pkpy.EXEC_MODE, nil);
	if !ok {
		pkpy.py_printexc()
		return
	}
	*/
}
