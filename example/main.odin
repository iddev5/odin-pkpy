package main

import pkpy ".."

main :: proc () {
	pkpy.py_initialize()
	defer {
		pkpy.py_finalize()
	}
	
	ok: i32 = pkpy.py_exec("i = 32 * 15.00003432; print(f\"Hello World! {i:.2f}\")", "<string>", .EXEC_MODE, nil);
	if ok == 0 {
		pkpy.py_printexc()
		return
	}
}
