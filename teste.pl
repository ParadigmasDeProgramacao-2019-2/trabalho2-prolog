:- dynamic discipline/2.

% Fatos
discipline(0,44).
discipline(44,55).
discipline(55,92).
discipline(92, 88).
discipline(88, 73).
discipline(73,132).
discipline(0,188).
discipline(188, 82).
discipline(82, 78).
discipline(78, 203).

forget(X):-
    forgetAux(X), fail.

forgetAux(X):-
    retract(X).
    
% memoriza(X):-
%     forget(X), assert(X).
%memoriza(X):-
    %assertz(X).

get_next(Cod):-
    discipline(Cod, Prox),
    write(Prox),
    write(" --> "),
    assertz(discipline(0, Prox)),
    forgetAux(discipline(Cod, Prox)).

search_no_req :-
    discipline(0, Cod),
    retract(discipline(0, Cod)),
    get_next(Cod),
    search_no_req.

print_no_req :-
    findall(Cod, discipline(0, Cod), Values),
    print_list(Values).
    
print_list([]).
print_list([H|T]) :- write(H), write(" --> "), print_list(T).

start_topsort :- 
    print_no_req,
    search_no_req. 

% search_pre_req(Cod) :-
%     discipline(Pre, Cod),
%     write(Cod),
%     write(" -> "),
%     search_pre_req(Pre).

