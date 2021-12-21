-module(antidotec_pb_management).

-include_lib("antidote_pb_codec/include/antidote_pb.hrl").


-export([create_dc/2,
         get_connection_descriptor/1,
         connect_to_dcs/2]).

-define(TIMEOUT, 10000).

-spec create_dc(pid(), [node()]) -> ok | {error, antidote_pb_codec:error_code() | timeout}.
create_dc(Pid, Nodes) ->
    EncMsg = antidote_pb_codec:encode_request({create_dc, Nodes}),
    RawResponse = antidotec_pb_socket:call_infinity(Pid, {req, EncMsg, infinity}),
    case RawResponse of
        {error, timeout} -> {error, timeout};
        Result           ->
            {create_dc_response, Response} = antidote_pb_codec:decode_response(Result),
            Response
    end.

-spec get_connection_descriptor(pid()) -> {ok, binary()} | {error, antidote_pb_codec:error_code() | timeout}.
get_connection_descriptor(Pid) ->
    EncMsg = antidote_pb_codec:encode_request(get_connection_descriptor),
    RawResponse = antidotec_pb_socket:call_infinity(Pid, {req, EncMsg, ?TIMEOUT}),
    case RawResponse of
        {error, timeout} -> {error, timeout};
        Result           ->
            {get_connection_descriptor_response, Response} = antidote_pb_codec:decode_response(Result),
            Response
    end.

-spec connect_to_dcs(pid(), [binary()]) -> ok | {error, antidote_pb_codec:error_code()} | {error, timeout}.
connect_to_dcs(Pid, Descriptors) ->
    EncMsg = antidote_pb_codec:encode_request({connect_to_dcs, Descriptors}),
    RawResponse = antidotec_pb_socket:call_infinity(Pid, {req, EncMsg, ?TIMEOUT}),
    case RawResponse of
        {error, timeout} -> {error, timeout};
        Result           ->
            {connect_to_dcs_response, Response} = antidote_pb_codec:decode_response(Result),
            Response
    end.
