set MHXD_EBIN_PATH=D:\ecworkspace_372_64\mhxd_src\ebin

cd /d %MHXD_EBIN_PATH%

start "profiler" werl -s profiler -s init stop

del analysis.png
dot -Tpng analysis.dot -o analysis.png
analysis.png
