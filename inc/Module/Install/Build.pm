#line 1 "inc/Module/Install/Build.pm - /Library/Perl/5.8.1/Module/Install/Build.pm"
# $File: //depot/cpan/Module-Install/lib/Module/Install/Build.pm $ $Author: ingy $
# $Revision: #23 $ $Change: 1255 $ $DateTime: 2003/03/05 13:23:32 $ vim: expandtab shiftwidth=4

package Module::Install::Build;
$VERSION = '0.01';
use strict;
use vars qw(@ISA);
use Module::Install::Base; @ISA = qw(Module::Install::Base);

sub Build { $_[0] }

sub write {
    my $self = shift;
    die "Build->write() takes no arguments\n" if @_;

    my %args;
    my $build;

    $args{dist_name} = $self->name || $self->determine_NAME($self->{args});
    $args{license} = $self->license;
    $args{dist_version} = $self->version || $self->determine_VERSION($self->{args});
    $args{dist_abstract} = $self->abstract;
    $args{dist_author} = $self->author;
    $args{sign} = $self->sign;
    $args{no_index} = $self->no_index;

    foreach my $key (qw(build_requires requires recommends conflicts)) {
        my $val = eval "\$self->$key" or next;
        $args{$key} = { map @$_, @$val };
    }

    %args = map {($_, $args{$_})} grep {defined($args{$_})} keys %args;

    require Module::Build;
    $build = Module::Build->new(%args);
    $build->add_to_cleanup(split /\s+/, $self->clean_files);
    $build->create_build_script;
}

sub ACTION_reset {
    my ($self) = @_;
    die "XXX - Can't get this working yet";
    require File::Path;
    warn "Removing inc\n";
    rmpath('inc');
}

sub ACTION_dist {
    my ($self) = @_;
    die "XXX - Can't get this working yet";
}

# <ingy> DrMath: is there an OO way to add actions to Module::Build??
# <DrMath> ingy: yeah
# <DrMath> ingy: package MyBuilder; use w(Module::Build; @ISA = qw(w(Module::Build); sub ACTION_ingy
#           {...}
# <DrMath> ingy: then my $build = new MyBuilder( ...parameters... );
#           $build->write_build_script;


1;

__END__

#line 178
