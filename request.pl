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

walk_list([], _ ).
walk_list([H | T], H) :- walk_list([], T).

cached_iss_data(Data) :-
    known(data, Data) ;
    iss_data(Data),
    assert(known(data, Data)).

get_informations(H, Discipline) :-
    Discipline = H.get(disciplines).

:- dynamic getElements/2.

getElements(H, Discipline) :- 
    cached_iss_data(Data),
    walk_list(Data, H),
    get_informations(H, Discipline).

