# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::URLLink;

use strict;
use base qw( XIMS::Object );
use XIMS::DataFormat;
use LWP::UserAgent;

use Data::Dumper;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    XIMS::URLLink->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $urllink: XIMS::URLLink instance
#
# DESCRIPTION
#    Constructor
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'URL' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

##
#
# SYNOPSIS
#    XIMS::URLLink->check( [$url] )
#
# PARAMETER
#    $url: optional URL to check. If missing the object->location is checked
#
# RETURNS
#    $status: 1 if HTTP-Response code begins with 2 or 3
#             0 if HTTP-Response code begins with 4 or 5
#
# DESCRIPTION
#    Checks the HTTP-Status of the URL-link and stores 
#    the result in ci_content
#       * status: status line (code and message)
#       * status_checked_timestamp: date and time of last check
#
sub check {
    my $self = shift;
    my $url = shift;
    
    $url = $self->location if (not $url);
    my $ua = LWP::UserAgent->new;
    $ua->agent('XIMS URL-Check');
    my $req = HTTP::Request->new(GET => $url);
    my $res = $ua->request( $req );
    #if object is already created store status as attributes
    if ($self->document_id()) {
        $self->status( $res->status_line );
        $self->status_checked_timestamp( $self->data_provider->db_now() );
    }
    return 1 if ($res->code =~ (/^[23]/));
    return 0;
}

1;

