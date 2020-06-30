%%% -------------------------------------------------------------------
%%% @author : joqerlang
%%% @doc : ets dbase for master service to manage app info , catalog  
%%%
%%% -------------------------------------------------------------------
-module(orchistrate).
 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("config.hrl").


%-compile(export_all).
-export([simple_campaign/0,
	 update_info/3]).




%% ====================================================================
%% External functions
%% ====================================================================

%% @doc: update_catalog(GitUrl,Dir,FileName)->{ok,Config}|{error,Err} retreives the latets  config spec from git

-spec(update_info(GitUrl::string(),Dir::string(),FileName::string())->{ok,Config::[tuple()]}|{error,Err::string()}).
update_info(GitUrl,Dir,FileName)->
    os:cmd("rm -rf "++Dir),
    os:cmd("git clone "++GitUrl),
    {R,Info}=file:consult(filename:join(Dir,FileName)),
    {R,Info}.

%% --------------------------------------------------------------------
%% 
%%
%% --------------------------------------------------------------------
%% 1 Check missing services - try to start them
simple_campaign()->
    {ok,AppConfig}=file:consult(filename:join(?APP_CONFIG_DIR,?APP_CONFIG_FILE)),
    {ok,CatalogConfig}=file:consult(filename:join(?CATALOG_CONFIG_DIR,?CATALOG_CONFIG_FILE)),
    AvailableServices=dns_service:all(),
    io:format("AvailableServices ~p~n",[{?MODULE,?LINE,AvailableServices}]),

    Missing=[{ServiceId,Node}||{ServiceId,Node}<-AppConfig,
			       false==lists:member({ServiceId,Node},AvailableServices)],
    
    StartInfoMissing=create_start_info(Missing,CatalogConfig,[]),				    
    io:format("StartInfoMissing ~p~n",[{?MODULE,?LINE,StartInfoMissing}]),

    Debug=[rpc:call(Node,boot_service,start_service,[ServiceId,Type,Source])||{Node,ServiceId,Type,Source}<-StartInfoMissing],
    io:format("Debug ~p~n",[{?MODULE,?LINE,Debug}]),

    Obsolite=[{ServiceId,Node}||{ServiceId,Node}<-AvailableServices,
			    false==lists:member({ServiceId,Node},AppConfig)],	
    io:format("Obsolite ~p~n",[{?MODULE,?LINE,Obsolite}]),
    [rpc:call(Node,boot_service,stop_service,[ServiceId])||{ServiceId,Node}<-Obsolite],
    ok.

create_start_info([],_CatalogConfig,StartInfo)->
    StartInfo;
    
create_start_info([{ServiceId,Node}|T],CatalogConfig,Acc)->
    NewAcc=case lists:keyfind(ServiceId,1,CatalogConfig) of
	       false->
		   Acc;
	       {ServiceId,Type,Source} ->
		   [{Node,ServiceId,Type,Source}|Acc]
	   end, 
    create_start_info(T,CatalogConfig,NewAcc).
