:- use_module(library(http/json)).
:- use_module(library(http/http_open)).

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
    writeln(H),
    get_discipline_json(H),
    writeln(B).

get_discipline_json(Code) :-
    string_chars(URL, "http://mwapi.herokuapp.com/discipline/"),
    string_concat(URL, Code, FINALURL),
    % writeln(FINALURL),
    % cached_iss_data(Data, FINALURL),
    iss_data(Data, FINALURL),
    get_discipline_data(Data).
    % iss_data(Data, FINALURL),
    % write(Data).

get_discipline_requirements([]).
get_discipline_requirements([H | _]) :-
    Requirements = H.get(requirements),
    % writeln(Requirements),
    get_requirement(Requirements).

get_discipline_data(Data) :-
    get_discipline_requirements(Data).
    % Requirements = Data.get(requirements),
    % get_requirement(Requirements).

get_requirement([]).
get_requirement([H | T]) :-
    writeln(H),
    get_requirement(T).

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