%% MySQL result record:
-ifndef(MYSQL_HRL).
-define(MYSQL_HRL,0).

-record(mysql_result,
	{fieldinfo=[],
	 rows=[],
	 affectedrows=0,
	 error=""}).

-endif.