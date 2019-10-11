:- dynamic disciplina/2.

% Fatos
disciplina(0,44).
disciplina(44,55).
disciplina(55,92).
disciplina(188,92).
disciplina(92, 88).
disciplina(88, 73).
disciplina(73,132).
disciplina(0,188).
disciplina(188, 82).

% %  pegar todos os requisitos da materia atual
% pegar_req(Pre, Cod) :- 
%     disciplina(Pre, Cod).
% pegar_req(Prepre, Cod) :- 
%     disciplina(Pre, Cod),
%     pegar_req(Prepre, Pre).

% find_update_req(Cod) :-
    %disciplina( Cod, _ ).
    %esquece(disciplina( _ , Cod )).
    % memoriza(disciplina( 0, Prox )).

esquece(X):-
    esqueceAux(X), fail.

esqueceAux(X):-
    retract(X).
    
% memoriza(X):-
%     esquece(X), assert(X).
%memoriza(X):-
    %assertz(X).

get_next(Cod):-
    disciplina(Cod, Prox),
    assertz(disciplina(0, Prox)),
    esqueceAux(disciplina(Cod, Prox)).

search_no_req(Cod) :-
    disciplina(0, Cod),
    writeln(Cod),
    retract(disciplina(0, Cod)),
    get_next(Cod).


search_pre_req(Cod) :-
    disciplina(Pre, Cod),
    write(Cod),
    write(" -> "),
    search_pre_req(Pre).
