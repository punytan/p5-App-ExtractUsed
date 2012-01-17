use strict;
use Test::More;
use App::ExtractUsed;

{
    my $extract = App::ExtractUsed->new(
        skip_namespace => ['Module::Extract::Use'],
    );

    my $expected = join "|", sort ();
    my $got = join "|", sort $extract->from_file('lib/App/ExtractUsed.pm');

    ok $expected eq $got, "skip_namespace";
}

{
    my $extract = App::ExtractUsed->new;

    my $expected = join "|", sort "App::ExtractUsed";
    my $got = join "|", sort $extract->from_file("t/PseudoLibs/t/01_util.t");

    ok $expected eq $got, "skip the namespace: t::";
}

done_testing;

