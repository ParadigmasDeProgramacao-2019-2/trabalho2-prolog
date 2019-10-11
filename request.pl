:- use_module(library(http/json)).
:- use_module(library(http/http_open)).

:- dynamic(known/2).

open_notify_url("http://mwapi.herokuapp.com/habilitations").

%! iss_data(-Data) is det.
%  get JSON ISS location data from open notify api and read in as dict
iss_data(Data) :-
    open_notify_url(URL),
    setup_call_cleanup(
        http_open(URL, In, [request_header('Accept'='application/json')]),
        json_read_dict(In, Data),
        close(In)
    ).

cached_iss_data(Data) :-
    known(data, Data) ;
    iss_data(Data),
    assert(known(data, Data)).

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
    writeln(B).

% :- dynamic getElements/2.

getElements() :- 
    cached_iss_data(Data),
    get_habilitation(Data).

% getElements(H, Discipline) :- 
%     cached_iss_data(Data),
%     walk_list(Data, H),
%     get_informations(H, Discipline).