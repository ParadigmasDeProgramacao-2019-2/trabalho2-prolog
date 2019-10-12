:- dynamic discipline/2.

% Facts
load_facts :-
    assertz(discipline(0,44)),
    assertz(discipline(44,55)),
    assertz(discipline(55,92)),
    assertz(discipline(92, 88)),
    assertz(discipline(88, 73)),
    assertz(discipline(73,132)),
    assertz(discipline(0,188)),
    assertz(discipline(188, 82)),
    assertz(discipline(82, 78)),
    assertz(discipline(78, 203)).

% start here
menu:- nl,nl,tab(15), write('MWCosultas'),nl,nl,
    tab(1), writeln('Opções:'),
    tab(1),writeln('1) Ordenação topologica: '),
    tab(1),writeln('2) Sair '),
    read(Chose),
    (   
        Chose == 1 ->
            load_facts,
            write('\e[2J'),
            start_topsort,
            get0(_),
            get0(_),
            write('\e[2J')
        ;
            Chose == 2 ->
            fail
        ;
            writeln('INPUT INVALIDO, DIGITE NOVAMENTE!!!'),
            write('\e[2J'),
            menu
    ), 
    menu.


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

search_rest_req :-
    discipline(0, Cod),
    retract(discipline(0, Cod)),
    get_next(Cod),
    search_rest_req.

print_topord :-
    findall(Cod, discipline(0, Cod), Values),
    print_list(Values),
    search_rest_req.
    
print_list([]).
print_list([H|T]) :- write(H), write(" --> "), print_list(T).

start_topsort :- 
    print_topord;
    true. 
