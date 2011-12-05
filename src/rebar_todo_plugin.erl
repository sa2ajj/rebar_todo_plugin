-module(rebar_todo_plugin).

-export([
    todo/2
]).

-define(TOP_COMMENT, "(This file is automatically generated and will be rewritten.)").
-define(DEFAULT_NAME, "TODO").
-define(DEFAULT_PATTERNS, ["include/*.hrl", "src/*.erl", "src/*.hrl"]).

todo(Config, _AppFile) ->
    BaseDir = rebar_config:get_global(base_dir, undefined),
    CurDir = rebar_utils:get_cwd(),
    if
        BaseDir == CurDir ->
            todo(rebar_config:get(Config, todo, undefined));

        true ->
            ok
    end.

todo(undefined) ->
    ok;
todo(ToDoConfig) ->
    Name = proplists:get_value(name, ToDoConfig, ?DEFAULT_NAME),
    WildCards = proplists:get_value(wildcards, ToDoConfig, ?DEFAULT_PATTERNS),
    Files = lists:sort(sets:to_list(lists:foldl(fun get_files/2, sets:new(), WildCards))),
    ToDos = parse_many(Files, dict:new()),
    case dict:size(ToDos) of
        0 ->
            rebar_log:log(error, "No TODO items are found.  ~s is not updated.\n", [Name]),
            case proplists:get_value(noerror, ToDoConfig, false) of
                true ->
                    ok;

                _ ->
                    {error, nothing_to_update}
            end;

        _ ->
            dump_todos(Name, ToDos)
    end.

get_files(WildCard, Acc) ->
    lists:foldl(fun add_regular_file/2, Acc, filelib:wildcard(WildCard)).

add_regular_file(Name, Set) ->
    case filelib:is_regular(Name) of
        true ->
            sets:add_element(Name, Set);

        false ->
            Set
    end.

parse_many(Args, Files) ->
    {ok, MP} = re:compile("(?P<kind>(TODO|FIXME|NOTE|XXX)):\s*(?P<text>.*)$"),
    lists:foldl(fun (X, Acc) -> parse_one(MP, X, Acc) end, Files, Args).

parse_one(MP, Name, Files) ->
    {ok, File} = file:read_file(Name),
    {ok, Tokens, _} = erl_scan:string(binary_to_list(File), 0, [return]),
    Comments = lists:filter(fun (X) -> element(1, X) =:= comment end, Tokens),
    HandleComment = fun({_, LineNo, Line}, Acc) ->
        case re:run(Line, MP, [{capture, [kind, text], binary}]) of
            nomatch ->
                Acc;

            {match, [Kind, Text]} ->
                dict:append(Kind, {Name, LineNo+1, Text}, Acc)
        end
    end,
    lists:foldl(HandleComment, Files, Comments).

dump_todos(Name, ToDos) ->
    case file:open(Name, [write]) of
        {ok, File} ->
            io:format(File, "~s\n", [?TOP_COMMENT]),
            lists:foreach(fun (Kind) ->
                            print_kind(File, Kind, dict:find(Kind, ToDos))
                        end, [<<"XXX">>, <<"FIXME">>, <<"TODO">>, <<"NOTE">>]),
            file:close(File),
            ok;

        {error, Error} ->
            rebar_log:log(error, "Could not open ~s for writing ~p\n", [Name, file:format_error(Error)])
    end.

print_kind(File, Kind, {ok, Items}) ->
    io:format(File, "\n~s:\n\n", [Kind]),
    lists:foreach(fun ({FName, LineNo, Text}) -> io:format(File, "~s:~b: ~s\n", [FName, LineNo, Text]) end, Items);
print_kind(_File, _Kind, error) ->
    ok.
