package App::ExtractUsed;
use strict;
use warnings;
our $VERSION = '0.01';
use Module::Extract::Use;
use Module::CoreList;
use File::Find;

sub new {
    my $class = shift;
    return bless {
        skip_namespace   => [],
        min_perl_version => $^V,
        @_,
        extractor => Module::Extract::Use->new,
    }, $class;
}

sub from_file {
    my ($self, $file) = @_;
    my @modules = $self->{extractor}->get_modules($file);
    return $self->grep_non_core(@modules);
}

sub from_dir_under {
    my ($self, $dir) = @_;
    my %modules;

    my $wanted = sub {
        if (-f $File::Find::name) {
            for my $module ($self->from_file($File::Find::name)) {
                $modules{$module}++;
            }
        }
    };

    File::Find::finddepth({
        wanted   => $wanted,
        no_chdir => 1,
    }, $dir);

    return keys %modules;
}

sub grep_non_core {
    my ($self, @used_modules) = @_;

    my @requires;
    for my $module (@used_modules) {
        my $release = Module::CoreList->first_release($module);
        if ($release) {
            if ($release > $self->{min_perl_version}) {
                # specified perl version has not the module as core
                push @requires, $module unless $self->skip($module);
            }
        } else {
            # the module is not core
            push @requires, $module unless $self->skip($module);
        }
    }

    return @requires;
}

sub skip {
    my ($self, $module) = @_;
    grep { $module =~ /^$_/ } @{ $self->{skip_namespace} };
}

1;
__END__

=head1 NAME

App::ExtractUsed -

=head1 SYNOPSIS

  use App::ExtractUsed;

=head1 DESCRIPTION

App::ExtractUsed is

=head1 AUTHOR

punytan E<lt>punytan@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
