
=head1 NAME

GetChildren -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use GetChildren;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::AppContext;

use strict;
use Carp;
use base qw( XIMS::AbstractClass Class::Accessor );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @Fields = (
    'properties',
    'apache',
    'user', # used for user-management
    'userlist', # used for privilege managment
    'object', # used for content-object-management
    'objectlist', # used for content-object-listings like search results or site maps
    'objectlist_info', # used for objectlist metadata.
    'userobjectlist', # used for content-object-listings with user context
    'bookmarklist', # used for bookmarklisting during user/role-management
    'userprefslist', # used for userprefslisting during user/role-management
    'objecttypelist', # used for objecttypelisting during user/role- object-type priv management
    'parent', # needed during object creation
    'session',
    'cookie',
    'sax_filter', # a reference to a list of SAX filter classes
    'sax_generator', # a reference to a SAX generator class
);

=head2 fields()

=cut

sub fields {
    return @Fields;
}

__PACKAGE__->mk_accessors( @Fields );

=head2 new()

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        $self->data( %args );
    }

    $self->properties( Properties->new() ) unless $self->properties();
    #$self->apache( FakeApache->new(%args) ) unless $self->apache();
    return $self;
}

1;

package Properties;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(application content));

sub new {
    my $self = bless {}, shift;
    $self->application( Application->new() );
    $self->content( Content->new() );
    return $self;
}
1;

package Application;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(cookie style styleprefix preservelocation keepsuffix usepubui));
1;

package Content;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(getchildren getformatsandtypes escapebody childrenbybodyfilter siblingscount resolveimage_id objectlistpassthru));
                    # we have to check if childrenbybodyfilter is really needed
                    # currently it is used by portlet.pm only
sub new {
    my $self = bless {}, shift;
    $self->getchildren( GetChildren->new() );
    return $self;
}
1;

package GetChildren;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(objectid objecttypes level limit offset order addinfo columns showtrash));
                    # objectid    to get targetchildren for contentbrowsing
                    # objecttypes to filter specific objecttypes (useful for browsing for special objecttypes)
                    # level       to get more flexible containerviews or sitemaps
                    # limit       to limit the number of children (used for pagination)
                    # offset      to start at a certain offset at the children list (used for pagination)
                    # order       to order the children list (used for pagination)
                    # addinfo     to get info on levels of hierarchy of chidlren,
                    #             timestamp of last modified child, and total count of
                    #             children
                    # properties  to select properties other than the default ones (currently not used)

1;

# package FakeApache;
# # Idea and some code stolen from WebGUI::Session::Plack;
# use Carp;

# sub new {
#     my ( $class, %args ) = @_;
#     my $self = bless {
#         %args,
#         pnotes   => {},
#         connection => FakeApache::Connection->new($args{env}),
#         server   =>  FakeApache::Server->new($args{env}),
#         headers_out => Plack::Util::headers( [] ),    # use Plack::Util to manage response headers
#     }, $class;
#     return $self;
# }

# sub args {}
# sub content {}
# sub content_type {}
# sub custom_response {}
# sub dir_config {}
# sub get_basic_auth_pw {}
# sub get_server_port {}
# sub header_in {}
# sub header_out {}
# sub headers_in {}
# sub is_initial_req {}
# sub location {}
# sub log {}
# sub method {}
# sub no_cache {}
# sub note_basic_auth_failure {}
# sub parsed_uri {}
# sub path_info {}
# sub pnotes {}
# sub print {}
# sub protocol {}
# sub send_http_header {}
# sub server {}
# sub set_content_length {}
# sub set_last_modified {}
# sub status {}
# sub status_line {}
# sub uri {}

# our $AUTOLOAD;

# sub AUTOLOAD {
#     my $what = $AUTOLOAD;
#     $what =~ s/.*:://;
#     carp "!!plack->$what(@_)" unless $what eq 'DESTROY';
# }

# 1;


# package FakeApache::Connection;
# use Carp;
# sub new {
#     my ( $class, %args ) = @_;
#     my $self = bless {}, $class;
#     return $self;
# }

# #sub remote_ip {}

# our $AUTOLOAD;

# sub AUTOLOAD {
#     my $what = $AUTOLOAD;
#     $what =~ s/.*:://;
#     carp "!!plack->$what(@_)" unless $what eq 'DESTROY';
# }

# 1;

# package FakeApache::Server;
# use Carp;
# sub new {
#     my ( $class, %args ) = @_;
#     my $self = bless {}, $class;
#     return $self;
# }

# our $AUTOLOAD;

# sub AUTOLOAD {
#     my $what = $AUTOLOAD;
#     $what =~ s/.*:://;
#     carp "!!plack->$what(@_)" unless $what eq 'DESTROY';
# }

1;


__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>: yadda, yadda...

Optional section , remove if bogus

=head1 DEPENDENCIES

Optional section, remove if bogus.

=head1 INCOMPATABILITIES

Optional section, remove if bogus.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

copyright (c) 2002-2011 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

