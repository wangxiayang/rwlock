Require Import List.
Import ListNotations.

Require Import Coq.Arith.EqNat.
Require Import Coq.Arith.Peano_dec.

Section Mutex.

Definition Thread := nat.

Record MyMutex := mkMutex { held : bool ; rn : nat ; holder : list Thread }.

Definition mm := mkMutex true 0 [0].

Inductive Mode := 
| Write : Mode
| Read : Mode.

Definition MyLock (mode : Mode) (thread : Thread) (mutex : MyMutex) : bool * MyMutex :=
	match mode with
	| Write => if negb (held mutex) then (true, (mkMutex true 0 [thread])) else (false, mutex)
	| Read => if beq_nat (rn mutex) 0 then
				if held mutex then (false, mutex) else (true, mkMutex true 1 [thread])
			else (true, mkMutex true (1 + rn mutex) (thread :: holder mutex))
	end.

Fixpoint inlist (a : nat) (l : list nat) : bool :=
	match l with
	| [] => false
	| a' :: l' => if beq_nat a a' then true else inlist a l'
	end.

Fixpoint rmlist (a : nat) (l : list nat) : list nat :=
	match l with
	| [] => l
	| a' :: l' => if beq_nat a' a then l' else a' :: (rmlist a l')
	end.

Definition MyUnlock (thread : Thread) (mutex : MyMutex) : MyMutex :=
	match held mutex with
	| true => if inlist thread (holder mutex) 
		then let l := rmlist thread (holder mutex) in
			if orb (beq_nat (rn mutex) 0) (beq_nat (rn mutex) 1) then
				mkMutex false 0 l
				else mkMutex true ((rn mutex) - 1) l
		else mutex
	| false => mutex
	end. 

Definition GetMutexResult (mode : Mode) (thread : Thread) (mutex : MyMutex) : bool
:= let (f, _) := MyLock mode thread mutex in f.

End Mutex.

Lemma lock_safe : forall mode thread mutex, (held mutex) = true -> (beq_nat (rn mutex) 0) = true -> (GetMutexResult mode thread mutex) = false.
Proof.
intros.
unfold GetMutexResult.
unfold MyLock.
destruct mode.
 rewrite H.
 simpl.
 trivial.

 rewrite H0.
 rewrite H.
 trivial.
Qed.

Theorem wwsafe : forall (m m' m'': MyMutex) (tid1 tid2 : Thread),
	(true, m') = MyLock Write tid1 m -> (false, m'') = MyLock Write tid2 m'.
