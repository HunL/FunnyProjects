-module(pt_35).

-export([read/2, write/2]).

-include("proto.hrl").


read(?PP_REFRESH_MARKET_LIST_REQ, Data) ->
    <<Type:16>> = Data,
    {ok, [Type]};

read(?PP_MARKET_SELL_REQ, Data) ->
    <<ItemId:64, Hour:8, Amount:16, UnitPrice:32, NeedAd:8, Rest/binary>> = Data,
    {BuyerName, <<>>} = pt:read_string(Rest),
    %BuyerName = "x120",
    {ok, [ItemId, Hour, Amount, UnitPrice, NeedAd, BuyerName]};

read(?PP_MARKET_BUY_REQ, Data) ->
    <<OrderId:64, Amount:16>> = Data,
    {ok, [OrderId, Amount]};

read(?PP_MARKET_CANCEL_SALE_REQ, Data) ->
    <<OrderId:64>> = Data,
    {ok, [OrderId]};

read(?PP_MARKET_SEND_AD_REQ, Data) ->
    <<OrderId:64>> = Data,
    {ok, [OrderId]};

read(?PP_REFRESH_MY_MARKET_LIST_REQ, _Data) ->
    {ok, []};

read(?PP_MARKET_SEARCH, Data) ->
    <<Len:16, BinKeys/binary>> = Data,

    Result =
        case Len == (size(BinKeys) / 4) of
            true -> [ModuleId || <<ModuleId : 32>> <= BinKeys];
            false -> []
        end,
    {ok, Result};

read(?PP_EXCHANGE_REQ, Data) ->
    <<Type:8, Amount:32>> = Data,
    {ok, [Type, Amount]};

read(?PP_MARKET_FETCH_INCOME_REQ, Data) ->
    <<Len:8, BinOrders/binary>> = Data,
    Result =
        case Len == (size(BinOrders) / 8) of
            true -> [OrderId || <<OrderId : 64>> <= BinOrders];
            false -> []
        end,
    {ok, Result};

read(?PP_MARKET_AGAIN_SALE_REQ, Data) ->
    <<OrderId:64>> = Data,
    {ok, [OrderId]};

read(?PP_MARKET_GET_ORDER_REQ, Data) ->
    <<OrderId:64>> = Data,
    {ok, [OrderId]};

read(?PP_SELL2ME_MARKET_LIST_REQ, <<>>) ->
    {ok, []};

read(?PP_REFRESH_VENDUE_LIST_REQ, Data) ->
    <<Type:16>> = Data,
    {ok, [Type]};

read(?PP_VENDUE_SELL_REQ, Data) ->
    <<GoodsType:8, ItemId:64, Hour:8, Amount:16, CurPrice:32, Price:32, NeedAd:8>> = Data,
    {ok, [GoodsType, ItemId, Hour, Amount, CurPrice, Price, NeedAd]};

read(?PP_VENDUE_BUY_REQ, Data) ->
    <<OrderId:64>> = Data,
    {ok, [OrderId]};

read(?PP_VENDUE_CANCEL_SALE_REQ, Data) ->
    <<OrderId:64>> = Data,
    {ok, [OrderId]};

read(?PP_VENDUE_SEND_AD_REQ, Data) ->
    <<OrderId:64>> = Data,
    {ok, [OrderId]};

read(?PP_REFRESH_MY_VENDUE_LIST_REQ, _Data) ->
    {ok, []};

read(?PP_VENDUE_SEARCH, Data) ->
    <<Len:16, BinKeys/binary>> = Data,

    Result =
        case Len == (size(BinKeys) / 5) of
            true -> [{GoodsType, ModuleId} || <<GoodsType : 8, ModuleId : 32>> <= BinKeys];
            false -> []
        end,
    {ok, Result};

read(?PP_VENDUE_GOOD_REQ, Data) ->
    <<OrderId:64>> = Data,
    {ok, [OrderId]};

read(?PP_VENDUE_BID_REQ, Data) ->
    <<OrderId:64, Price:32>> = Data,
    {ok, [OrderId, Price]};

read(?PP_VENDUE_MY_BID_LIST_REQ, _Data) ->
    {ok, []};

read(?PP_VENDUE_GET_ORDER_REQ, Data) ->
    <<Type:8, OrderId:64>> = Data,
    {ok, [Type, OrderId]};

read(?PP_MARKET_GET_UNDEAL_REQ, _) ->
    {ok, []};

read(?PP_TRADER_GET_GOOD_RE, _)->
	{ok, []};

read(?PP_TRADER_BUY_GOOD_RE, Data)->
	<<Flag:32, GoodId:32, Count:32>> = Data,
	{ok, [Flag, GoodId, Count]}.



write(?PP_REFRESH_MARKET_LIST_ACK, {Type, TotalPage, Page, Count, Data}) ->
    BinData = <<Type:16, TotalPage:16, Page:16, Count:16, Data/binary>>,
    {ok, pt:pack(?PP_REFRESH_MARKET_LIST_ACK, BinData)};

write(?PP_MARKET_SELL_ACK, Ret) ->
    {ok, pt:pack(?PP_MARKET_SELL_ACK, Ret)};

write(?PP_MARKET_BUY_ACK, {Ret, Type, Data}) ->
    {ok, pt:pack(?PP_MARKET_BUY_ACK, <<Ret, Type:16, Data/binary>>)};

write(?PP_MARKET_CANCEL_SALE_ACK, {Ret, OrderId, Income}) ->
    {ok, pt:pack(?PP_MARKET_CANCEL_SALE_ACK, <<Ret, OrderId:64, Income:32>>)};

write(?PP_MARKET_SEND_AD_ACK, Ret) ->
    {ok, pt:pack(?PP_MARKET_SEND_AD_ACK, Ret)};

write(?PP_REFRESH_MY_MARKET_LIST_ACK, {Count, Data}) ->
    BinData = << Count : 16, Data/binary >>,
    {ok, pt:pack(?PP_REFRESH_MY_MARKET_LIST_ACK, BinData)};

write(?PP_EXCHANGE_ACK, Ret) ->
    {ok, pt:pack(?PP_EXCHANGE_ACK, Ret)};

write(?PP_MARKET_FETCH_INCOME_ACK, {Ret, Data}) ->
    BinData = <<Ret, Data/binary>>,
    {ok, pt:pack(?PP_MARKET_FETCH_INCOME_ACK, BinData)};

write(?PP_MARKET_AGAIN_SALE_ACK, {Ret}) ->
    {ok, pt:pack(?PP_MARKET_AGAIN_SALE_ACK, <<Ret>>)};

write(?PP_MARKET_GET_ORDER_ACK, {Data}) ->
    {ok, pt:pack(?PP_MARKET_GET_ORDER_ACK, Data)};

write(?PP_SELL2ME_MARKET_LIST_ACK, {Len, OrderData}) ->
    Data = <<Len:16, OrderData/binary>>,
    {ok, pt:pack(?PP_SELL2ME_MARKET_LIST_ACK, Data)};

write(?PP_REFRESH_VENDUE_LIST_ACK, {Type, TotalPage, Page, Count, Data}) ->
    BinData = <<Type:16, TotalPage:16, Page:16, Count:16, Data/binary>>,
    {ok, pt:pack(?PP_REFRESH_VENDUE_LIST_ACK, BinData)};

write(?PP_VENDUE_SELL_ACK, Ret) ->
    {ok, pt:pack(?PP_VENDUE_SELL_ACK, Ret)};

write(?PP_VENDUE_BUY_ACK, {Ret, Type, OrderId}) ->
    {ok, pt:pack(?PP_VENDUE_BUY_ACK, <<Ret, Type:16, OrderId:64>>)};

write(?PP_VENDUE_CANCEL_SALE_ACK, {Ret, OrderId}) ->
    {ok, pt:pack(?PP_VENDUE_CANCEL_SALE_ACK, <<Ret, OrderId:64>>)};

write(?PP_VENDUE_SEND_AD_ACK, Ret) ->
    {ok, pt:pack(?PP_VENDUE_SEND_AD_ACK, Ret)};

write(?PP_REFRESH_MY_VENDUE_LIST_ACK, {Count, Data}) ->
    BinData = << Count : 16, Data/binary >>,
    {ok, pt:pack(?PP_REFRESH_MY_VENDUE_LIST_ACK, BinData)};

write(?PP_VENDUE_GOOD_ACK, {GoodsType, OrderId, Data}) ->
    BinData = << GoodsType : 8, OrderId : 64, Data/binary >>,
    {ok, pt:pack(?PP_VENDUE_GOOD_ACK, BinData)};

write(?PP_VENDUE_BID_ACK, {Ret, Type, OrderId, NewPrice}) ->
    BinData = << Ret, Type:16, OrderId:64, NewPrice:32 >>,
    {ok, pt:pack(?PP_VENDUE_BID_ACK, BinData)};

write(?PP_VENDUE_MY_BID_LIST_ACK, {Count, Data}) ->
    BinData = << Count : 16, Data/binary >>,
    {ok, pt:pack(?PP_VENDUE_MY_BID_LIST_ACK, BinData)};

write(?PP_VENDUE_GET_ORDER_ACK, {Type, Data}) ->
    BinData = << Type : 8, Data/binary >>,
    {ok, pt:pack(?PP_VENDUE_GET_ORDER_ACK, BinData)};

write(?PP_MARKET_GET_UNDEAL_ACK, {Type}) ->
    {ok, pt:pack(?PP_MARKET_GET_UNDEAL_ACK, <<Type>>)};

write(?PP_TRADER_GET_GOOD_ACK, {Falg, Goodlst})->
	Length  = length(Goodlst),
	HeadData = << Falg:32, Length:16>>,
	TailData = pack_goods_lst(Goodlst, <<>>),
    {ok, pt:pack(?PP_TRADER_GET_GOOD_ACK, <<HeadData/binary, TailData/binary >>)};

write(?PP_TRADER_BUY_GOOD_ACK, Ret)->
	 {ok, pt:pack(?PP_TRADER_BUY_GOOD_ACK, <<Ret:32>>)}.


pack_goods_lst([], Bin)-> Bin;
pack_goods_lst([H|Relst], Bin)->
	{GoodId,Price,Count} = H,
	{Type,_,_} = cfg_trader_config:get_trader_goodprice(GoodId),
	NewBin = <<GoodId:32, Type:32, Price:32, Count:32, Bin/binary>>,
	pack_goods_lst(Relst, NewBin).
