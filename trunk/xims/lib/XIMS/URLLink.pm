
=head1 NAME

XIMS::URLLink -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    use XIMS::URLLink;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::URLLink;

use strict;
use base qw( XIMS::Object );
use XIMS::DataFormat;
use LWP::UserAgent;

use Data::Dumper;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );



=head2    XIMS::URLLink->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from ...

=head3 Returns

    $urllink: XIMS::URLLink instance

=head3 Description

Constructor

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'URL' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}



=head2    XIMS::URLLink->check( [$url] )

=head3 Parameter

    $url: optional URL to check. If missing the object->location is checked

=head3 Returns

    $status: 1 if HTTP-Response code begins with 2 or 3
             0 if HTTP-Response code begins with 4 or 5

=head3 Description

Checks the HTTP-Status of the URL-link and stores 
the result in ci_content
* status: status line (code and message)
* status_checked_timestamp: date and time of last check

=cut

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

Copyright (c) 2002-2007 The XIMS Project.

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

