:- use_module(library(http/json)).
:- use_module(library(http/http_open)).
:- use_module(library(lists)).

:- dynamic(habilitation_name/2).
:- dynamic(habilitation_discipline/2).
:- dynamic(requirements_alt/2).
:- dynamic(discipline_name/2).
:- dynamic(requirements/2).

% Remove vários fatos da base
forget(X):-
    forgetAux(X), fail.

% Remove um fato da base
forgetAux(X):-
    retract(X).

% Esquece e memoriza um fato (para evitar duplicidade)
memorize(X):-
     forget(X), assertz(X).
memorize(X):-
    assertz(X).

% a partir do codigo de habilitacao, montar a url e pega o json e passa para a get_habilitation que pega os dados desse json
get_all_data_from_habilitation(Code) :-
    string_chars(URL, "http://mwapi.herokuapp.com/habilitation/"),
    string_concat(URL, Code, FINALURL),
    iss_data(Data, FINALURL),
    (
        Data == [] ->
            writeln('Esse codigo de habilitacao nao existe.'),
            main
        ;
            get_habilitations(Data)
    ).

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
    writeln('Disciplina sem oferta (nao eh possivel saber os pre requisitos)'),
    memorize(requirements([-], Code)),
    memorize(requirements_alt(-, Code)).

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
    memorize(requirements([], Code)),
    memorize(requirements_alt(0, Code)).

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
    memorize(requirements(Filtered, Code)).

% formata em inteiros os pre requisitos (alternativa para ordenacao topologica)
get_format_requirements_in_list_alt(Requirements, Code) :-
    split_string(Requirements, ",", " ", Filtered),
    set_with_element(Filtered, Code).

% separar os elementos e salvar (alternativa para ordenacao topologica)
set_with_element([], _).
set_with_element([H | T], Code) :-
    atom_number(H, ReqNumber),
    memorize(requirements_alt(ReqNumber, Code)),
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

% ---------------------------------------------------------------------------------------------------------------------------

main :-
    writeln('Digite o codigo da habilitacao para carregar os dados: '),
    read(CodeHabilitationInput),
    get_all_data_from_habilitation(CodeHabilitationInput),
    menu.

:- dynamic discipline/2. % Disciplinas da habilitação
:- dynamic made_dis/1. % Disciplinas cursadas pelo usuário
:- dynamic possible_dis_with_req/1. % Disciplinas que podem ser cursadas pelo usuário e que possuem pre requisitos

% % Criação de fatos em tempo de execução 
% load_facts :-
%     assertz(discipline(0,44)),
%     assertz(discipline(44,55)),
%     assertz(discipline(55,92)),
%     assertz(discipline(92, 88)),
%     assertz(discipline(88, 73)),
%     assertz(discipline(73,132)),
%     assertz(discipline(0,188)),
%     assertz(discipline(188, 82)),
%     assertz(discipline(82, 78)),
%     assertz(discipline(78, 203)).

% Menu principal com as funcionalidades do sistema
menu:- nl,nl,
    sign_made_disc,
    write('\e[2J'),  % Limpar tela
    tab(1), writeln('Opções:'),
    tab(1), writeln('1) Ordenação topológica: '),
    tab(1), writeln('2) Verificar todas matérias que posso cursar '),
    tab(1), writeln('3) Verificar se posso cursar matéria '),
    tab(1), writeln('4) Sair '),
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
            writeln('Disciplinas que você possui o pré-requisito:'),
            get_possible_disc_with_req,
            print_possible_dis_with_req,
            nl,nl,
            writeln('Disciplinas sem pré requisito:'),
            get_possible_disc
        ;
            Choice == 3 -> 
            nl,nl,
            read(Cod),
            (
                verify_discipline(Cod);
                verify_discipline_with_req(Cod);
                writeln('Você não possui o pré requisito para cursar a disciplina ou você já a cursou.')
            ),
            nl
        ;

            Choice == 4 -> % Força o programa a falhar
            fail
        ;
            writeln('OPÇÃO INVALIDA, DIGITE NOVAMENTE!!!'),
            write('\e[2J'),
            menu
    ), 
    menu.

sign_made_disc :- 
    nl,nl,tab(15), write('MWCosultas'),nl,nl,
    verify_answer('Deseja cadastrar disciplina cursada? (y/n) ', sign_new_discipline, sign_made_disc);
    true. 

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
            discipline_name(Disc, Name),
            write('\e[2J'),  % clear screen
            write('Codigo da disciplina adicionada: '), writeln(Disc),
            write('Nome da disciplina adicionada: '), writeln(Name),
            write('Disciplina registrada com sucesso!'), nl, nl
        ;
            string_chars(URL, "http://mwapi.herokuapp.com/discipline/"),
            string_concat(URL, Disc, FINALURL),
            iss_data(Data, FINALURL),
            (
                Data == [] ->
                    write('\e[2J'),
                    write('Não foi possível registrar a disciplina!'), nl, nl
                ;
                    get_discipline_data_from_json(Data),
                    write('Disciplina registrada com sucesso!'), nl, nl
            )
    ),
    verify_answer('Deseja cadastrar mais outra matéria? (y/n)', sign_new_discipline, sign_new_discipline).

get_discipline_data_from_json([H | _]) :-
    Code = H.get(code),
    Name = H.get(name),
    write('\e[2J'),  % clear screen
    write('Codigo da disciplina adicionada: '), writeln(Code),
    write('Nome da disciplina adicionada: '), writeln(Name),
    atom_number(Code, CodeInt),
    memorize(discipline_name(CodeInt, Name)).

search_disc(Cod) :-
    discipline_name(Cod, _).

start_topsort :- 
    print_topord;
    true. 

 print_topord :-
    findall(Cod, discipline(0, Cod), Values),
    print_list(Values),
    search_rest_req.

print_list([]).
print_list([H|T]) :- write(H), write(" --> "), print_list(T).

search_rest_req :-
    discipline(0, Cod),
    retract(discipline(0, Cod)),
    get_next(Cod),
    search_rest_req.

% Define próxima disciplina do fluxo como nó ralo, para realizar ordenação topológica
get_next(Cod):-
    discipline(Cod, Prox),
    write(Prox),
    write(" --> "),
    assertz(discipline(0, Prox)),
    forgetAux(discipline(Cod, Prox)).

% Pega disciplinas que o usuário pode cursar e não possuem pré requisitos
get_possible_disc :-
    requirements([], CodDisc),
    \+ made_dis(CodDisc),
    discipline_name(CodDisc, NameDisc),
    write('Codigo/Nome da disciplina: '), write(CodDisc), write(' - '), writeln(NameDisc),
    fail;
    write('').

% Pega disciplinas que o usuário pode cursar, pois possui seu pré requisito
get_possible_disc_with_req :-
    requirements(List, CodDisc),
    (
        List == [] ->
            false
        ;
            verify_list(List)

    ),
    \+ made_dis(CodDisc),
    memorize(possible_dis_with_req(CodDisc)),
    fail;
    write('').

print_possible_dis_with_req :-
    possible_dis_with_req(CodDisc),
    discipline_name(CodDisc, NameDisc),
    write('Codigo/Nome da disciplina: '), write(CodDisc), write(' - '), writeln(NameDisc),
    forget(possible_dis_with_req(CodDisc)),
    fail;
    write('').

% has_requirements([]) :- false.
% has_requirements([H | T]) :-
%     % se verify retornar true ele retorna true (ja tem), se retornar false vai pro proximo
%     (
%         H == [] ->
%             has_requirements(T)
%         ;
%             verify_list(H) ->
%                 true
%             ;
%                 has_requirements(T)
%     ).

verify_list([]).
verify_list([H | T]) :-
    (
        made_dis(H) ->
            true,
            verify_list(T)
        ;
            false
    ).

% Recebe como parâmetro uma disciplina que o usuário deseja cursar e verifica se ele pode ou não cursá-la (verifica somente disciplinas sem pré requisito)
verify_discipline(Disc) :-
    discipline(0, Disc),
    \+ made_dis(Disc),
    writeln('Disciplina sem pré requisitos, é possível cursar.').

% Recebe como parâmetro uma disciplina que o usuário deseja cursar e verifica se ele pode ou não cursá-la (verifica somente disciplinas com pré requisito)
verify_discipline_with_req(Disc) :-
    \+ made_dis(Disc),
    discipline(Cod, Disc),
    made_dis(Cod),
    writeln("Você possui o pré requisito para cursar a disciplina.").
