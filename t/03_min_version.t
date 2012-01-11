use strict;
use version;
use Test::More;
use App::ExtractUsed;

{
    my $extract = App::ExtractUsed->new(
        min_perl_version => version->new('5.8.1'),
    );

    my $expected = join "|", sort qw(JSON::PP);
    my $got = join "|", sort $extract->from_file('t/PseudoLibs/lib/JSON/PP.pm');

    ok $expected eq $got, "min_perl_version";
}

{
    my $extract = App::ExtractUsed->new(
        min_perl_version => version->new('5.14.1'),
    );

    my $expected = join "|", sort qw();
    my $got = join "|", sort $extract->from_file('t/PseudoLibs/lib/JSON/PP.pm');

    ok $expected eq $got, "min_perl_version";
}

done_testing;

