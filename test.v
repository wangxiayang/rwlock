Require Import Coq.Arith.Peano_dec.
Require Import List.
Import ListNotations.

Fixpoint inlist (a : nat) (l : list nat) : bool :=
	match l with
	| [] => false
	| a' :: l' => if eq_nat_dec a a' then true else inlist a l'
	end.
