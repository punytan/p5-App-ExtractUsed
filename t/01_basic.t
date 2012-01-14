use strict;
use Test::More;

use App::ExtractUsed;
my $extract = App::ExtractUsed->new;

isa_ok $extract, 'App::ExtractUsed';

{
    my $expected = join "|", sort qw(Module::Extract::Use);
    my $got = join "|", sort $extract->from_file('lib/App/ExtractUsed.pm');

    ok $expected eq $got, "from_file";
}

{
    my $expected = join "|", sort qw(Module::Extract::Use App::ExtractUsed);
    my $got = join "|", sort $extract->from_dir_under('lib');

    ok $expected eq $got, "from_dir_under";
}

done_testing;
