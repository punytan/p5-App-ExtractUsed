use inc::Module::Install;
name 'App-ExtractUsed';
all_from 'lib/App/ExtractUsed.pm';

# requires '';
requires 'Module::Extract::Use';

install_script 'bin/extractused';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
