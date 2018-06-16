{application, account_server,
 	[
 		{description, "account server"},
 		{vsn, "1.0"},
 		{modules, [login_server,account_server,account_server_app]},
 		{registered, [account_server]},
 		{applications, [kernel, stdlib]},
 		{mod, {account_server_app, []}}
 	]
 }.