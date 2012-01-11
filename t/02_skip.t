use strict;
use Test::More;
use App::ExtractUsed;

my $extract = App::ExtractUsed->new(
    skip_namespace => ['Module::Extract::Use'],
);

my $expected = join "|", sort ();
my $got = join "|", sort $extract->from_file('lib/App/ExtractUsed.pm');

ok $expected eq $got, "skip_namespace";

done_testing;

