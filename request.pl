:- use_module(library(http/json)).
:- use_module(library(http/http_open)).
:- use_module(library(lists)).

:- dynamic(habilitation_name/2).
:- dynamic(discipline_name/2).
:- dynamic(requirements/2).

is_requirement(Requirement, Code) :- requirements(Code, Requirement).
% TODO tratar requisitos q têm mais de um elemento

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
    Code = H.get(code),

    assertz(habilitation_name(Code, Name)),

    % write(Disciplines),
    writeln(Code),
    writeln(Name),
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
    assertz(discipline_name(H, B)),
    % writeln(H),
    get_discipline_json(H).
    % writeln(B).

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
    writeln(Code),
    % writeln(Requirements),
    % writeln(Requirements),
    set_requirement(Requirements, Code).

set_requirement([], _).

set_requirement([H | T], Code) :-
    assertz(requirements(Code, [H])),
    writeln([H]),
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