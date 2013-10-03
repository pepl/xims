
=head1 NAME

XIMS::SAX::Generator::SimpleDBItem -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Generator::SimpleDBItem;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Generator::SimpleDBItem;

use common::sense;
use parent qw( XIMS::SAX::Generator::Content );




=head2    $generator->prepare( $ctxt );

=head3 Parameter

    $ctxt : the appcontext object

=head3 Returns

    $doc_data : hash ref to be given to be mangled by XML::Generator::PerlData

=head3 Description



=cut

sub prepare {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    my $doc_data = $self->SUPER::prepare( $ctxt );

    my $simpledb = $ctxt->object->parent();
    bless $simpledb, 'XIMS::SimpleDB'; # parent isa XIMS::Object

    my %args = ();
    # Filter out member properties with gopublic==1 if the user comes in through gopublic
    $args{gopublic} = 1 if ($ctxt->session->auth_module() eq 'XIMS::Auth::Public' 
                         or $ctxt->session->user->id() == XIMS::PUBLICUSERID() );
    my @property_list = $simpledb->mapped_member_properties( %args );
    $doc_data->{member_properties} = { member_property => \@property_list };

    %args = ();
    if ( $ctxt->session->auth_module() eq 'XIMS::Auth::Public'
      or $ctxt->session->user->id() == XIMS::PUBLICUSERID() ) {
        my @property_ids = map { $_->{id} } @property_list;
        $args{property_id} = \@property_ids;
    }
    my @property_values = $ctxt->object->property_values( %args );
    $doc_data->{context}->{object}->{member_values} = { member_value => \@property_values };


    return $doc_data;
}

sub get_config {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my %opts = $self->SUPER::get_config();
    $opts{attrmap}->{member_property} = 'id';
    $opts{attrmap}->{member_value} = 'id';

    return %opts;
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

Copyright (c) 2002-2013 The XIMS Project.

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

