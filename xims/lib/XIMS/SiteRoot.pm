
=head1 NAME

XIMS::SiteRoot -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    use XIMS::SiteRoot;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SiteRoot;

use strict;
use base qw( XIMS::DepartmentRoot );
use XIMS::DataFormat;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );



=head2    XIMS::SiteRoot->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from ...

=head3 Returns

    $dept: XIMS::SiteRoot instance

=head3 Description

Constructor

=cut


sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'SiteRoot' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}



=head2    my $url = $siteroot->url( [ $url ] );

=head3 Parameter

    $url    (optional) : SiteRoot URL to be set (will be set as 'title' internally)

=head3 Returns

    $url : SiteRoot URL (='title')

=head3 Description

Get/set accessor for SiteRoot URL. Internally, the SiteRoot is the content object's title.

=cut

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

