:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).

:- use_module(library(http/http_json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_cors)).

:- http_handler(root(.),handle,[]).

:- set_setting(http:cors, [*]).

:- dynamic json_discipline/1.
:- dynamic ord_disc/1.
:- dynamic discipline/2.

:- use_module(library(http/http_parameters)).

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

forget_all_disciplines :-
    forget(discipline(Pre, Cod)),
    write(Pre),
    write(Cod);
    true.

forget_old_topord :-
    forget(ord_disc(Cod)),
    write(Cod);
    true.

:- json_object
    my_json(pre:integer, actual:integer),
    final_json(topological: list, disciplines: list),
    topological_ord(discipline: integer).    

read_jsons(Itens) :-
    findall(JSON , transform_to_json(JSON), Itens).

transform_to_json(JSON) :- 
    discipline(Pre, Cod),
    json_convert:prolog_to_json(my_json(Pre, Cod), JSON).

read_jsons_toporder(Itens) :-
    findall(JSON , transform_to_json_top_order(JSON), Itens).

transform_to_json_top_order(JSON) :- 
    ord_disc(Cod),
    json_convert:prolog_to_json(topological_ord(Cod), JSON).

handle(Request) :-
    cors_enable(Request,
                [ methods([get,post,delete])
                ]), 
   format(user_output,"Request is: ~p~n",[Request]),
   http_parameters(Request,
                        [ habilitation(Habilitation, []) % parameter to get habilitation
                        ]
    ),
   format(user_output,"Habilitation is: ~p~n",[Habilitation]),
   start_topsort,
   read_jsons_toporder(Ordtop),
   load_facts,
   read_jsons(Disciplines),
   json_convert:prolog_to_json(final_json(Ordtop, Disciplines), JSON),
   reply_json(JSON).

initialize_server :-
    http_server(http_dispatch,[port(3333)]).

% Topological order

forget(X):-
    forgetAux(X), fail.

forgetAux(X):-
    retract(X).

get_next(Cod):-
    discipline(Cod, Prox),
    assertz(ord_disc(Prox)),
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
print_list([H|T]) :- assertz(ord_disc(H)), print_list(T).

start_topsort :-
    forget_all_disciplines,
    forget_old_topord,
    load_facts, 
    print_topord;
    true. 