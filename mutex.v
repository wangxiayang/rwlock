Require Import List.
Import ListNotations.

Require Import Coq.Arith.Peano_dec.

Section Mutex.

Definition Thread := nat.

Record Mutex := mkMutex { held : bool ; rn : nat ; holder : list Thread }.

Definition mm := mkMutex true 0 [0].

Inductive Mode := 
| Write : Mode
| Read : Mode.

Definition Lock (mode : Mode) (thread : Thread) (mutex : Mutex) : bool * Mutex :=
	match mode with
| Write => if eq_nat_dec (rn mutex) 0 then (true, (mkMutex true 0 [thread])) else (false, mutex)
	| Read => if eq_nat_dec (rn mutex) 0 then
				if held mutex then (false, mutex) else (true, mkMutex true 1 [thread])
			else (true, mkMutex true (1 + rn mutex) (thread :: holder mutex))
	end.

Fixpoint inlist (a : nat) (l : list nat) : bool :=
	match l with
	| [] => false
	| a' :: l' => if eq_nat_dec a a' then true else inlist a l'
	end.

Fixpoint rmlist (a : nat) (l : list nat) : list nat :=
	match l with
	| [] => l
	| a' :: l' => if eq_nat_dec a' a then l' else a' :: (rmlist a l')
	end.

Definition Unlock (thread : Thread) (mutex : Mutex) : Mutex :=
	match held mutex with
	| true => if 
	inlist thread (holder mutex) then mkMutex false ((rn mutex) - 1) (rmlist thread (holder mutex)) else mutex
	| false => mutex
	end. 

End Mutex.
