# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::AppContext;

use strict;
use vars qw($VERSION @ISA @Fields);
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };

use XIMS::AbstractClass;
#use Data::Dumper;

@ISA = qw( XIMS::AbstractClass );

sub fields {
    return @Fields;
}

BEGIN {
    @Fields = (
                'properties',
                'apache',
                'user', # used for user-management
                'userlist', # used for privilege managment
                'object', # used for content-object-management
                'objectlist', # used for content-object-listings like search results or site maps
                'userobjectlist', # used for content-object-listings with user context
                'bookmarklist', # used for bookmarklisting during user/role-management
                'parent', # needed during object creation
                'session',
                'cookie',
                'sax_filter', # a reference to a list of SAX filter classes
                'sax_generator', # a reference to a SAX generator class
   );
}


use Class::MethodMaker
    get_set => \@Fields;

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
use Class::MethodMaker
    get_set => [qw(application filter content)];
sub new {
    my $self = bless {}, shift;
    $self->application( Application->new() );
    $self->filter( Filter->new() );
    $self->content( Content->new() );
    return $self;
}
1;

package Application;
use Class::MethodMaker
    new     => 'new',
    get_set => [qw( nocache style styleprefix preservelocation keepsuffix )];
1;

package Filter;
use Class::MethodMaker
    new     => 'new',
    get_set => [];
1;

package Content;
use Class::MethodMaker
    get_set => [qw( getchildren getformatsandtypes escapebody childrenbybodyfilter siblingscount )];
                    # we have to check if childrenbybodyfilter is really needed
                    # currently it is used by portlet.pm only
sub new {
    my $self = bless {}, shift;
    $self->getchildren( GetChildren->new() );
    return $self;
}
1;

package GetChildren;
use Class::MethodMaker
    new     => 'new',
    get_set => [qw( objectid objecttypes level addinfo columns )];
                    # objectid    to get targetchildren for contentbrowsing
                    # objecttypes to filter specific objecttypes (useful for browsing for special objecttypes)
                    # level       to get more flexible containerviews or sitemaps
                    # addinfo     to get info on levels of hierarchy of chidlren,
                    #             timestamp of last modified child, and total count of
                    #             children
                    # columns     to select columns other than the default ones (do we want this?)

1;
