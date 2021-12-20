% вариант 11

% А не хочет входить в состав руководства, если Д не будет председателем.
condition1(A,_,_,_,D,_) :- D \= "председатель", A \= "безработный", !, fail.
condition1(_,_,_,_,_,_).

% Б не хочет входить в состав руководства, если ему придется быть старшим над В.
condition2(_,B,V,_,_,_) :- B == "председатель", V == "заместитель", !, fail.
condition2(_,B,V,_,_,_) :- B == "председатель", V == "секретарь", !, fail.
condition2(_,B,V,_,_,_) :- B == "заместитель", V == "секретарь", !, fail.
condition2(_,_,_,_,_,_).

% Б не хочет работать вместе с Е ни при каких условиях.
condition3(_,B,_,_,_,E) :- E \= "безработный", B \= "безработный", !, fail.
condition3(_,_,_,_,_,_).

% В не хочет работать, если в состав руководства войдут Д и Е вместе.
condition4(_,_,V,_,D,E) :- D \= "безработный", E \= "безработный", V \= "безработный", !, fail.
condition4(_,_,_,_,_,_).

% В не будет работать, если Е будет председателем, или если Б будет секретарем.
condition5(_,_,V,_,_,E) :- E == "председатель", V \= "безработный", !, fail.
condition5(_,B,V,_,_,_) :- B == "секретарь", V \= "безработный", !, fail.
condition5(_,_,_,_,_,_).

% Г не будет работать с В или Д, если ему придется подчиняться тому или другому.
condition6(_,_,V,G,_,_) :- V == "председатель", G == "заместитель", !, fail.
condition6(_,_,V,G,_,_) :- V == "председатель", G == "секретарь", !, fail.
condition6(_,_,V,G,_,_) :- V == "заместитель", G == "секретарь", !, fail.
condition6(_,_,_,G,D,_) :- D == "председатель", G == "заместитель", !, fail.
condition6(_,_,_,G,D,_) :- D == "председатель", G == "секретарь", !, fail.
condition6(_,_,_,G,D,_) :- D == "заместитель", G == "секретарь", !, fail.
condition6(_,_,_,_,_,_).

% Д не хочет быть заместителем председателя.
condition7(_,_,_,_,D,_) :- D == "заместитель", !, fail.
condition7(_,_,_,_,_,_).

% Д не хочет быть секретарем, если в состав руководства войдет Г.
condition8(_,_,_,G,D,_) :- G == "председатель", D == "секретарь", !, fail.
condition8(_,_,_,G,D,_) :- G == "заместитель", D == "секретарь", !, fail.
condition8(_,_,_,_,_,_).

% Д не хочет работать вместе с А, если Е не войдет в состав руководства.
condition9(A,_,_,_,D,E) :- D \= "безработный", A \= "безработный", E == "безработный", !, fail.
condition9(_,_,_,_,_,_).

% Е согласен работать только в том случае, если председателем будет либо он, либо В.
condition10(_,_,V,_,_,E) :- E == "заместитель", V \= "председатель", !, fail.
condition10(_,_,V,_,_,E) :- E == "секретарь", V \= "председатель", !, fail.
condition10(_,_,_,_,_,_).


% проверяем очередное рещение на соблюдение всех условий
all_conditions([A,B,V,G,D,E]) :-
    POSITIONS = ["председатель", "заместитель", "секретарь", "безработный", "безработный", "безработный"],
    permutation([A,B,V,G,D,E], POSITIONS),
    condition1(A,B,V,G,D,E),
    condition2(A,B,V,G,D,E),
    condition3(A,B,V,G,D,E),
    condition4(A,B,V,G,D,E),
    condition5(A,B,V,G,D,E),
    condition6(A,B,V,G,D,E),
    condition7(A,B,V,G,D,E),
    condition8(A,B,V,G,D,E),
    condition9(A,B,V,G,D,E),
    condition10(A,B,V,G,D,E).

% получаем все различные решения и выводим их
solve() :-
    setof([A,B,V,G,D,E], all_conditions([A,B,V,G,D,E]), [[X,Y,Z,O,P,U]]),
    write("A: "), write(X), nl,
    write("Б: "), write(Y), nl,
    write("В: "), write(Z), nl,
    write("Г: "), write(O), nl,
    write("Д: "), write(P), nl,
    write("Е: "), write(U), nl.

?- solve.
