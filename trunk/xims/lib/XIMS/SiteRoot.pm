# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SiteRoot;

use strict;
use vars qw( $VERSION @ISA );
use XIMS::DepartmentRoot;
use XIMS::DataFormat;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::DepartmentRoot');

##
#
# SYNOPSIS
#    XIMS::SiteRoot->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $dept: XIMS::SiteRoot instance
#
# DESCRIPTION
#    Constructor
#

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'SiteRoot' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

##
#
# SYNOPSIS
#    my $url = $siteroot->url( [ $url ] );
#
# PARAMETER
#    $url    (optional) : SiteRoot URL to be set (will be set as 'title' internally)
#
# RETURNS
#    $url : SiteRoot URL (='title')
#
# DESCRIPTION
#    Get/set accessor for SiteRoot URL. Internally, the SiteRoot is the content object's title.
#
sub url {
    my $self = shift;
    my $url = shift;

    if ( $url ) {
        $self->title( $url );
    }
    else {
        return $self->title();
    }
    return $url;
}

1;
