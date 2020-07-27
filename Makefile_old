all:
	rm -rf app_config catalog node_config  logfiles *_service include *~ */*~ */*/*~;
	rm -rf */*.beam;
	rm -rf *.beam erl_crash.dump */erl_crash.dump */*/erl_crash.dump;
	cp src/*.app ebin;
	erlc -I ../include -o ebin src/*.erl;
doc_gen:
	rm -rf  node_config logfiles doc/*;
	erlc ../doc_gen.erl;
	erl -s doc_gen start -sname doc
test:
	rm -rf  include *_config catalog logfiles latest.log erl_crash.dump;
	rm -rf *.beam ebin/* test_ebin/* erl_crash.dump;
#	include
	git clone https://github.com/joq62/include.git;
#	app_config
	git clone https://github.com/joq62/app_config.git;
#	catalog
	git clone https://github.com/joq62/catalog.git;
	cp src/*app ebin;
	erlc -I include -o ebin src/*.erl;
	erlc -o test_ebin test_src/*.erl;
	rm -rf include;
	erl -pa ebin -pa test_ebin -s orchistrate_service_tests start -sname orchistrate_dir_test
