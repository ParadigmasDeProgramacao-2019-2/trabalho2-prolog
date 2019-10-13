:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).

:- use_module(library(http/http_json)).
:- use_module(library(http/json_convert)).

:- http_handler(root(.),handle,[]).

:- dynamic json_discipline/1.

discipline(0,44).
discipline(44,55).
discipline(55,92).
discipline(92, 88).
discipline(88, 73).
discipline(73,132).
discipline(0,188).
discipline(188, 82).
discipline(82, 78).
discipline(78, 203).

:- json_object
    my_json(pre:integer, actual:integer),
    final_json(topological: list, disciplines: list).    

server(Port) :-
   http_server(http_dispatch,[port(Port)]).

read_jsons(Itens) :-
    findall(JSON , transform_to_json(JSON), Itens).

transform_to_json(JSON) :- 
    discipline(Pre, Cod),
    json_convert:prolog_to_json(my_json(Pre, Cod), JSON).

handle(Request) :-
   format(user_output,"Connected!~n",[]),
   http_read_json(Request, DictIn,[json_object(term)]),
   format(user_output,"Request is: ~p~n",[Request]),
   format(user_output,"DictIn is: ~p~n",[DictIn]),
   %read_jsons(Itens),
   %json_convert:prolog_to_json(Itens, _),
   read_jsons(Itens),
   json_convert:prolog_to_json(final_json([], Itens), JSON),
   reply_json(JSON).
