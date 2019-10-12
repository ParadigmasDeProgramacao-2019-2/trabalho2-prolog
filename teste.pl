:- dynamic discipline/2.
:- dynamic made_dis/1.

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

search_disc(Cod) :-
    discipline(Cod, _);
    discipline(_, Cod).

verify_answer(Question, Function, Function2) :-
    nl,nl,nl, write(Question),nl, nl,
    read(Choice),
    (
        Choice == y -> 
            Function
        ;
        Choice == n ->
            fail
        ;
        writeln('OPÇÃO INVALIDA, DIGITE NOVAMENTE!!!'), nl, nl,
        Function2
    ).

sign_new_discipline :- 
    nl, nl, write('Digite o código da matéria feita: '),nl, nl,
    read(Disc),
    (
        search_disc(Disc) ->
            memorize(made_dis(Disc)),
            write('\e[2J'),  % clear screen
            write('Disciplina registrada com sucesso!'), nl, nl
        ;
            write('\e[2J'),
            write('Não foi possível registrar a disciplina!'), nl, nl
    
    ),
    verify_answer('Deseja cadastrar mais outra matéria? (y/n)', sign_new_discipline, sign_new_discipline).

sign_made_disc :- 
    nl,nl,tab(15), write('MWCosultas'),nl,nl,
    verify_answer('Deseja cadastrar disciplina cursada? (y/n) ', sign_new_discipline, sign_made_disc);
    true. 

% start here
menu:- nl,nl,
    sign_made_disc,
    write('\e[2J'),  % clear screen
    tab(1), writeln('Opções:'),
    tab(1),writeln('1) Ordenação topologica: '),
    tab(1),writeln('2) Sair '),
    read(Choice),
    (   
        Choice == 1 ->
            load_facts,
            write('\e[2J'),
            start_topsort,
            get0(_),
            get0(_),
            write('\e[2J')
        ;
            Choice == 2 ->
            fail
        ;
            writeln('OPÇÃO INVALIDA, DIGITE NOVAMENTE!!!'),
            write('\e[2J'),
            menu
    ), 
    menu.


forget(X):-
    forgetAux(X), fail.

forgetAux(X):-
    retract(X).
    
memorize(X):-
     forget(X), assertz(X).
memorize(X):-
    assertz(X).

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
