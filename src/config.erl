-module(config).
-behaviour(gen_server).

-export([start_link/0]).
-export([get/1]).

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([code_change/3]).
-export([terminate/2]).

%%%_* API ==============================================================
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

get(Key) -> gen_server:call(?MODULE, {get, Key}).

%%%_* Gen server callbacks =============================================
init([]) ->
  Data = file:read_file(application:get_env(config_file)),
  {ok, Scanned, _} = erl_scan:string(Data),
  {ok, Parsed} = erl_parse:parse_exprs(Scanned),
  {value, Result, _} = erl_eval:exprs(Parsed, []),
  {ok, #{config => Result}}.

handle_call({get, Key}, _From, #{config := ConfigMap} = S) ->
  R = case maps:is_key(Key, ConfigMap) of
        true  -> {ok,  maps:get(Key, ConfigMap)};
        false -> error
      end,
  {reply, R, S}.

handle_cast(Msg, State) -> {stop, {unexpected_cast, Msg}, State}.

handle_info(Msg, State) -> {stop, {unexpected_info, Msg}, State}.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

terminate(_Reason, _State) -> ok.
