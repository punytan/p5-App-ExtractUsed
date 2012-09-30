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
    return (sort $self->grep_non_core(@modules));
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

    return (sort keys %modules);
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
    grep { $module =~ /^$_/ } @{ $self->{skip_namespace} }, "t::";
}

1;
__END__

=head1 NAME

App::ExtractUsed - Extracts used modules from your project

=head1 SYNOPSIS

    use App::ExtractUsed;
    my $extract = App::ExtractUsed->new;

    for my $module ($extract->from_dir_under('lib')) {
        print qq{requires '$module';\n};
    }

    for my $module ($extract->from_file('lib/App/ExtractUsed.pm')) {
        print qq{requires '$module';\n};
    }


=head1 DESCRIPTION

App::ExtractUsed is a CLI tool to extract used modules (without core modules) from your project.

See also L<bin/extractused>

=head1 METHODS

=head2 C<new(%options)>

    use version;
    my $extract = App::ExtractUsed->new(
        skip_namespace   => ['MyProject'],
        min_perl_version => version->new('5.8.1'),
    );

=head3 C<%options>

=over

=item * C<skip_namespace>

An arrayref of namespaces that should not be included in the dependent list.

=item * C<min_perl_version>

Specify the minimum version of perl. This parameter is used to decide the core modules.
Default value is C<$^V> (current running version).

=back

=head2 C<from_dir_under($directory)>

This method returns array of used modules (without core modules) from specified directory.

=head2 C<from_file($path)>

This method returns array of used modules (without core modules) from specified file.

=head1 AUTHOR

punytan E<lt>punytan@gmail.comE<gt>

=head1 SEE ALSO

L<bin/extractused>

L<Module::Extract::Use>

L<Module::CoreList>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
