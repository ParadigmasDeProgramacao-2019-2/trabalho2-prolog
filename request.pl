:- use_module(library(http/json)).
:- use_module(library(http/http_open)).
:- use_module(library(lists)).

:- dynamic(habilitation_name/2).
:- dynamic(habilitation_discipline/2).
:- dynamic(requirements_alt/2).
:- dynamic(discipline_name/2).
:- dynamic(requirements/2).

forget(X):-
    forgetAux(X), fail.
forgetAux(X):-
    retract(X).
    
memorize(X):-
     forget(X), assertz(X).
memorize(X):-
    assertz(X).

% a partir do codigo de habilitacao, montar a url e pega o json e passa para a get_habilitation que pega os dados desse json
get_all_data_from_habilitation(Code) :-
    string_chars(URL, "http://mwapi.herokuapp.com/habilitation/"),
    string_concat(URL, Code, FINALURL),
    iss_data(Data, FINALURL),
    get_habilitations(Data).

% pega o JSON da API e retorna um dicionario
iss_data(Data, URL) :-
    setup_call_cleanup(
        http_open(URL, In, [request_header('Accept'='application/json')]),
        json_read_dict(In, Data),
        close(In)
    ).

% acesso ao elemento habilitation dentro do array
get_habilitations([]).
get_habilitations([H | T]) :-
    get_habilitation_data(H),
    get_habilitations(T).

% pega os dados de uma habilitacao a partir do json dela
get_habilitation_data(H) :-
    Disciplines = H.get(disciplines),
    Name = H.get(name),
    CodeStr = H.get(code),
    atom_number(CodeStr, Code),
    memorize(habilitation_name(Code, Name)),
    write('Codigo da habilitacao: '), writeln(Code),
    write('Nome da habilitacao: '), writeln(Name),
    get_period(Disciplines, Code).

% pega cada elemento do array de habilitacao, cada elemento eh um periodo
get_period([], _).
get_period([H | T], HabilitationCode) :-
    get_discipline(H, HabilitationCode),
    get_period(T, HabilitationCode).

% pega cada disciplina do periodo
get_discipline([], _).
get_discipline([H | T], HabilitationCode) :-
    get_discipline_code_name(H, HabilitationCode),    
    get_discipline(T, HabilitationCode).

% separa os atributos de codigo e nome da disciplina para salvar
get_discipline_code_name([H, B | _], HabilitationCode) :-
    atom_number(H, Code),
    memorize(discipline_name(Code, B)),
    memorize(habilitation_discipline(HabilitationCode, Code)),
    write('Codigo da disciplina: '), writeln(H),
    write('Nome da disciplina: '), writeln(B),
    get_discipline_json(Code).

% acesso a api para pegar o json com os dados da disciplina para pegar os pre requisitos
get_discipline_json(Code) :-
    string_chars(URL, "http://mwapi.herokuapp.com/discipline/"),
    string_concat(URL, Code, FINALURL),
    iss_data(Data, FINALURL),
    get_discipline_requirements(Data, Code).

% caso nao tenha oferta o json vem vazio, salva com vazio
get_discipline_requirements([], Code) :-
    memorize(requirements(Code, [])),
    memorize(requirements_alt(Code, [])).

% pegar os pre requisitos de cada disciplina
get_discipline_requirements([H | _], Code) :-
    Requirements = H.get(requirements),
    (
        Requirements == [] ->
        save_empty_requirement(Requirements, Code)
        ;
        set_requirement(Requirements, Code)
    ).

% salva como vazio os pre requisitos das disciplinas sem pre requisitos
save_empty_requirement([], Code) :-
    write('Pre-requisitos: '), writeln([]),
    memorize(requirements(Code, [])),
    memorize(requirements_alt(Code, 0)).

% salvar os requisitos como fatos
set_requirement([], _).
set_requirement([H | T], Code) :-
    get_format_requirements_in_list(H, Code),
    get_format_requirements_in_list_alt(H, Code),
    set_requirement(T, Code).

% formata em forma de lista de inteiros os pre requisitos
get_format_requirements_in_list(Requirements, Code) :-
    atomic_list_concat(ListRequirements, ",", Requirements),
    converter(ListRequirements, Filtered),
    write('Pre-requisitos: '), writeln(Filtered),
    memorize(requirements(Code, Filtered)).

% formata em inteiros os pre requisitos (alternativa para ordenacao topologica)
get_format_requirements_in_list_alt(Requirements, Code) :-
    split_string(Requirements, ",", " ", Filtered),
    set_with_element(Filtered, Code).

% separar os elementos e salvar (alternativa para ordenacao topologica)
set_with_element([], _).
set_with_element([H | T], Code) :-
    atom_number(H, ReqNumber),
    memorize(requirements_alt(Code, ReqNumber)),
    set_with_element(T, Code).

% converter elementos de string para inteiro
converter(H, Result) :-
    converter_aux(H, [], Result).
converter_aux([], Acc, Result) :-
    Result = Acc.
converter_aux([H | T], Acc, Result) :-
    atom_number(H, L),
    append(Acc, [L], NewAcc),
    converter_aux(T, NewAcc, Result).

% para imprimir uma lista
printa_lista([]).
printa_lista([H | T]) :-
    writeln(H),
    printa_lista(T).
