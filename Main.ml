open MyMutex

let _ =
	let f = (fun () -> print_string "in thread\n") in
	let t = Thread.create f () in
	Thread.join t;
	print_int (Thread.id t);
	print_string ("hello" ^ "\n");;

let lock' (tid : int) = print_string ((string_of_int tid) ^ " lock\n")
let unlock' (tid : int) = print_string ((string_of_int tid) ^ " ulock\n")
let f' = fun (tid : int)
	-> for i = 0 to 1000000 do lock' tid; unlock' tid done;;

let _ =
	let mutex = ref { held=false ; rn=0 ; holder=[] } in
	let rm = Mutex.create () in
	let olock (tid : int) (tmode : mode) = 
		let quitloop = ref false in
			while not !quitloop do
				Mutex.lock rm;
				let (r, m) = myLock tmode tid !mutex in
				mutex := m;
				Mutex.unlock rm;
				quitloop := r
			done
		in
	let ounlock (tid : int) =
		Mutex.lock rm;
		mutex := myUnlock tid !mutex;
		Mutex.unlock rm
		in
	let f = (fun ((tid', tmode') : int * mode) -> (for i=0 to 10 do
		match tmode' with
		| Write -> olock tid' tmode'; print_string ("writer " ^ (string_of_int tid') ^ " get lock\n"); ounlock tid'
		| Read -> olock tid' tmode'; print_string ("reader " ^ (string_of_int tid') ^ " get lock\n"); ounlock tid' done)) in
	let t1 = Thread.create f (1, Write) in
	let t2 = Thread.create f (2, Read) in
	let t3 = Thread.create f (3, Read) in
	let t4 = Thread.create f (4, Write) in
	let t5 = Thread.create f (5, Read) in
	Thread.join t1; Thread.join t2; Thread.join t3; Thread.join t4; Thread.join t5; print_string "end\n"
