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
	let ff = (fun ((tid', tmode') : int * mode) -> (for i=0 to 10 do
		match tmode' with
		| Write -> olock tid' tmode'; print_string ("writer " ^ (string_of_int tid') ^ " get lock\n"); ounlock tid'
		| Read -> olock tid' tmode'; print_string ("reader " ^ (string_of_int tid') ^ " get lock\n"); ounlock tid' done)) in
	let _ = Random.init(10) in
	let x = ref 0 in
	let block' = (fun () -> ignore(Unix.select [] [] [] (Random.float 0.2))) in
	let block = for i = 1 to Random.int 1000 do ignore (Unix.getaddrinfo "localhost" "" []) done in
	let myyyyf = (fun (s : int * mode) -> 
		let (tid', _) = s in 
		for i = 0 to 1000000 do 
			x := !x + 1 done) in
	let t1 = Thread.create myyyyf (1, Write) in
	let t2 = Thread.create myyyyf (2, Read) in
	let t3 = Thread.create myyyyf (3, Read) in
	let t4 = Thread.create myyyyf (4, Write) in
	let t5 = Thread.create myyyyf (5, Read) in
	Thread.join t1; Thread.join t2; Thread.join t3; Thread.join t4; Thread.join t5; print_string ("final result is " ^ (string_of_int !x) ^ "\n")
