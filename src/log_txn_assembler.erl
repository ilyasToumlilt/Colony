%% Transaction assembler reads a stream of log operations and produces complete transactions.

-module(log_txn_assembler).
-include("antidote.hrl").
-include("inter_dc_repl.hrl").

%% API
-export([
  new_state/0,
  process/2,
  process_all/2]).

%% State
-record(state, {
  op_buffer :: dict:dict()
}).

%%%% API --------------------------------------------------------------------+

-spec new_state() -> #state{}.
new_state() -> #state{op_buffer = dict:new()}.

-spec process(#log_record{}, #state{}) -> {{ok, [#log_record{}]} | none, #state{}}.
process(LogRecord, State) ->
  Payload = LogRecord#log_record.log_operation,
  TxId = Payload#log_operation.tx_id,
  NewTxnBuf = find_or_default(TxId, [], State#state.op_buffer) ++ [LogRecord],
  case Payload#log_operation.op_type of
    commit -> {{ok, NewTxnBuf}, State#state{op_buffer = dict:erase(TxId, State#state.op_buffer)}};
    abort -> {none, State#state{op_buffer = dict:erase(TxId, State#state.op_buffer)}};
    _ -> {none, State#state{op_buffer = dict:store(TxId, NewTxnBuf, State#state.op_buffer)}}
  end.

-spec process_all([#log_record{}],#state{}) -> {[[#log_record{}]],#state{}}.
process_all(LogRecords, State) -> process_all(LogRecords, [], State).

-spec process_all([#log_record{}], [[#log_record{}]], #state{}) -> {[[#log_record{}]], #state{}}.
process_all([], Acc, State) -> {Acc, State};
process_all([H|T], Acc, State) ->
  {Result, NewState} = process(H, State),
  NewAcc = case Result of
    {ok, Txn} -> Acc ++ [Txn];
    none -> Acc
  end,
  process_all(T, NewAcc, NewState).

%%%% Methods ----------------------------------------------------------------+

-spec find_or_default(#tx_id{}, any(), dict:dict()) -> any().
find_or_default(Key, Default, Dict) ->
  case dict:find(Key, Dict) of
    {ok, Val} -> Val;
    _ -> Default
  end.
