:- use_module(library(http/json)).
:- use_module(library(http/http_open)).
:- use_module(library(lists)).

:- dynamic(habilitation_name/2).
:- dynamic(discipline_name/2).
:- dynamic(requirements/2).


% Requirement format: ["requirement_code"]
is_requirement([], _) :- fail, !.
is_requirement([H | T], Code) :- writeln(H), 
                                requirements(Code, H);
                               is_requirement(T, Code), !.

% :- dynamic(known/2).

%! iss_data(-Data) is det.
%  get JSON ISS location data from open notify api and read in as dict
iss_data(Data, URL) :-
    setup_call_cleanup(
        http_open(URL, In, [request_header('Accept'='application/json')]),
        json_read_dict(In, Data),
        close(In)
    ).

% cached_iss_data(Data, URL) :-
%     known(data, Data) ;
%     iss_data(Data, URL),
%     assert(known(data, Data)).

% walk_list([], _ ).
% walk_list([H | T], H) :- walk_list([], T).

get_habilitation([]).
get_habilitation([H | T]) :-
    get_informations(H),
    get_habilitation(T).

% get_habilitation([H | _]) :-
%     get_informations(H).

get_informations(H) :-
    Disciplines = H.get(disciplines),
    Name = H.get(name),
    CodeStr = H.get(code),
    atom_number(CodeStr, Code),
    assertz(habilitation_name(Code, Name)),

    % write(Disciplines),
    % writeln(Code),
    % writeln(Name),
    get_period(Disciplines).

get_period([]).
get_period([H | T]) :-
    % write(H),
    get_discipline(H),
    get_period(T).

get_discipline([]).
get_discipline([H | T]) :-
    % write(H),
    get_code_name(H),
    get_discipline(T).

get_code_name([H, B | _]) :-
    atom_number(H, Code),
    assertz(discipline_name(Code, B)),
    % writeln(H), % codigo
    % writeln(B),
    get_discipline_json(Code).

get_discipline_json(Code) :-
    string_chars(URL, "http://mwapi.herokuapp.com/discipline/"),
    string_concat(URL, Code, FINALURL),
    % writeln(FINALURL),
    % cached_iss_data(Data, FINALURL),
    iss_data(Data, FINALURL),
    get_discipline_requirements(Data, Code).
    % iss_data(Data, FINALURL),
    % write(Data).
    
% get_discipline_data(Data, Code) :-
%     get_discipline_requirements(Data, Code).
%     % Requirements = Data.get(requirements),
%     % get_requirement(Requirements).

get_discipline_requirements([], Code) :-
    assertz(requirements(Code, [])).

get_discipline_requirements([H | _], Code) :-
    Requirements = H.get(requirements),
    % writeln(Code),
    % writeln(Requirements),
    % writeln(Requirements),
    set_requirement(Requirements, Code).

set_requirement([], _).
set_requirement([H | T], Code) :-
    % assertz(requirements(Code, [H])),
    % writeln([H]),
    get_format_requirements_in_list(H, Code),
    set_requirement(T, Code).

% get_requirement([], _, _).
% get_requirement([H | T], List, Result) :-
%     append(List, [H]),
%     Result = List,
%     get_requirement(T, List, Result).
    
% :- dynamic get_elements/2.

get_elements(Code) :-
    % cached_iss_data(Data, "http://mwapi.herokuapp.com/habilitations"),
    % iss_data(Data, "http://mwapi.herokuapp.com/habilitations"),
    string_chars(URL, "http://mwapi.herokuapp.com/habilitation/"),
    string_concat(URL, Code, FINALURL),
    iss_data(Data, FINALURL),
    get_habilitation(Data).

% get_elements(H, Discipline) :- 
%     cached_iss_data(Data),
%     walk_list(Data, H),
%     get_informations(H, Discipline).

printa_lista([]).
printa_lista([H | T]) :-
    % writeln(H),
    atom_number(H, H),
    printa_lista(T).

get_format_requirements_in_list(Requirements, Code) :-
    writeln(Requirements),
    split_string(Requirements, ",", " ", Filtered),
    writeln(Filtered),
    set_with_list(Filtered, Code).

set_with_list([], _).
set_with_list([H | T], Code) :-
    writeln(H),
    assertz(requirements(Code, H)),
    set_with_list(T, Code).

% get_format_requirements_in_list(Requirements, Code) :-
%     atomic_list_concat(ListRequirements, ",", Requirements),
%     converter(ListRequirements, Filtered),
%     assertz(requirements(Code, Filtered)),
%     writeln(Filtered).

converter(H, Result) :-
    converter_aux(H, [], Result).
converter_aux([], Acc, Result) :-
    Result = Acc.
converter_aux([H | T], Acc, Result) :-
    atom_number(H, L),
    append(Acc, [L], NewAcc),
    converter_aux(T, NewAcc, Result).