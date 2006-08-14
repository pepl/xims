# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::AppContext;

use strict;
use base qw( XIMS::AbstractClass Class::Accessor );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @Fields = (
    'properties',
    'apache',
    'user', # used for user-management
    'userlist', # used for privilege managment
    'object', # used for content-object-management
    'objectlist', # used for content-object-listings like search results or site maps
    'userobjectlist', # used for content-object-listings with user context
    'bookmarklist', # used for bookmarklisting during user/role-management
    'objecttypelist', # used for objecttypelisting during user/role- object-type priv management
    'parent', # needed during object creation
    'session',
    'cookie',
    'sax_filter', # a reference to a list of SAX filter classes
    'sax_generator', # a reference to a SAX generator class
);
sub fields {
    return @Fields;
}

__PACKAGE__->mk_accessors( @Fields );

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        $self->data( %args );
    }

    $self->properties( Properties->new() ) unless $self->properties();

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
__PACKAGE__->mk_accessors(qw(cookie style styleprefix preservelocation keepsuffix));
1;

package Content;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(getchildren getformatsandtypes escapebody childrenbybodyfilter siblingscount resolveimage_id));
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
__PACKAGE__->mk_accessors(qw(objectid objecttypes level limit offset order addinfo columns));
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
