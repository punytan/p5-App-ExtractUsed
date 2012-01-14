package App::ExtractUsed::Script;
use strict;
use warnings;
use version;
use App::ExtractUsed;
our $VERSION = '0.01';

sub new {
    my ($class, $args) = @_;

    my $version = $args->{perl}
        ? version->new($args->{perl})
        : $^V ;

    my $extract = App::ExtractUsed->new(
        skip_namespace   => $args->{skip},
        min_perl_version => $version,
    );

    bless {
        dir  => $args->{dir},
        file => $args->{file},
        extract => $extract,
    }, $class;
}

sub run {
    my ($self) = @_;
    my @lines;

    unless (scalar @{$self->{dir}}, @{$self->{file}}) {
        push @{$self->{dir}}, 'lib', 't';

        # TODO: get the namespace of this project
        # i.e. push @{$args->{skip}}, "Detected::Namespace";
    }

    for my $dir (@{ $self->{dir} }) {
        my $sub = $dir =~ m<^t/?>
            ? "test_requires" : "requires";

        for my $module ($self->{extract}->from_dir_under($dir)) {
            push @lines, qq{$sub '$module';};
        }
    }

    for my $file (@{ $self->{file} }) {
        my $sub = $file =~ m<^t/?>
            ? "test_requires" : "requires";

        for my $module ($self->{extract}->from_file($file)) {
            push @lines, qq{$sub '$module';};
        }
    }

    print "$_\n" for @lines;
}

1;
__END__
