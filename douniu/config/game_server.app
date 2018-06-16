{application, game_server,
    [   
        {description, "This is game server."},   
        {vsn, "1.0a"},      
        {modules, [game_server,mh_server_app,mh_sup,mh_networking]},
        {registered, [game_server]},   
        {applications, [kernel, stdlib]},   
        {mod, {mh_server_app, []}}  
    ]   
}.      