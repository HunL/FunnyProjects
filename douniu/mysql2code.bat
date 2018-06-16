rem check whether it's necessary to compile mysql libary

if not exist ebin/db_sql.beam (for %%f in (gameserver/lib/mysql/*.erl) do erlc -I include -o ebin gameserver/lib/mysql/%%f)
if not exist ebin/db_sql.beam erlc -I include -o ebin gameserver/lib/db_sql.erl

for %%f in (tools/mysql2code/*.erl) do erlc -I include -o ebin tools/mysql2code/%%f
erlc -I include -o ebin gameserver/lib/lib_map.erl
cd ebin
erl -s mysql2code -s init stop
rem erl -s mysql2code init_mysql -s init stop
rem erl -s mysql2code process_terrain -s init stop

cd ../
rem for %%f in (cfg_gen_code/*.erl) do erlc -I include -o ebin cfg_gen_code/%%f

pause

