open MyMutex;;

let _ = Random.init 2 in
let m = Mutex.create () in
let myMutex = ref {held=false ; rn=0; holder=[]} in
let c = Condition.create () in
let x = ref 0 in
let tlock (tid : int) (tmode : mode) =
	Mutex.lock m;
	let ms =
			match tmode with
			| Write -> "WRITE"
			| Read -> "READ" in
	let rec tlock' (tid : int) (tmode : mode) =
		let (r, myMutex') = MyMutex.myLock tmode tid !myMutex in
			print_string ("thread " ^ (string_of_int tid) ^ " acquires " ^ ms ^ " lock\n");
			myMutex := myMutex';
			if not r 
				then (Condition.wait c m; tlock' tid tmode)
				else (print_string ("[GOOD NEWS]thread " ^ (string_of_int tid) ^ " got " ^ ms ^ " lock\n"); Mutex.unlock m) in
		tlock' tid tmode
	in
let rec tunlock (tid : int) =
	Mutex.lock m;
	let myMutex' = MyMutex.myUnlock tid !myMutex in
		myMutex := myMutex';
		print_string ("[GOOD NEWS]thread " ^ (string_of_int tid) ^ " releases lock\n");
		Condition.signal c;
		Mutex.unlock m
	in
let w = (fun (tid : int) ->
	tlock tid Write;
	let s = !x in
	print_string ((string_of_int tid) ^ " writer got " ^ (string_of_int s) ^ "\n");
	ignore (Unix.select [] [] [] (Random.float 0.2));
	x := (s + 1);
	print_string ((string_of_int tid) ^ " writer updated to " ^ (string_of_int !x) ^ "\n");
	tunlock tid;) 
	in
let r = (fun (tid : int) ->
	tlock tid Read;
	let s = !x in
	print_string ((string_of_int tid) ^ " reader first got " ^ (string_of_int s) ^ "\n");
	ignore (Unix.select [] [] [] (Random.float 0.2));
	let s' = !x in
	print_string ((string_of_int tid) ^ " reader then got " ^ (string_of_int s') ^ "\n");
	tunlock tid;)
	in
let rec tcreate (n : int) =
	if n = 0 then []
	else let (f, s) = (
		let random = Random.float 1.0 in
		if random <= 0.2 then (w, "WRITE") else (r, "READ")
			) in
		let t = Thread.create f n in
		print_string ((string_of_int n) ^ " thread is in " ^ s ^ " mode\n");
		t :: tcreate (n-1)
	in
let tarray = tcreate 100 in
let rec wait (ta : Thread.t list) =
	match ta with
	| [] -> ()
	| t :: ta' -> Thread.join t; wait ta'
	in
	wait tarray;
	print_string ("finally " ^ (string_of_int !x) ^ "\n")
