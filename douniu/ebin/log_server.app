{application, log_server,
 	[
 		{description, "log server"},
 		{vsn, "1.0"},
 		{modules, [log_server,log_server_app]},
 		{registered, [log_server]},
 		{applications, [kernel, stdlib]},
 		{mod, {log_server_app, []}}
 	]
 }.