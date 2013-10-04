
=head1 NAME

XIMS::Iterator::Object -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Iterator::Object;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Iterator::Object;

use common::sense;
use parent qw( XIMS::Iterator );
use XIMS::Object;




=head2    my $iterator = XIMS::Iterator::Object->new( $arryref [, $cttid ] );

=head3 Parameter

    $arryref                        :  Reference to an array of XIMS::Object ids
                                       If $cttid is ommited, 'document_id'
                                       will be used for object lookup
    $cttid               (optional) :  If given, content 'id' is used for
                                       XIMS::Object lookup instead of
                                       'document_id'

=head3 Returns

    $iterator    : instance of XIMS::Iterator::Object

=head3 Description

Returns an iterator instance to iterate over XIMS::Objects. XIMS::Iterator::Object
subclasses Array::Iterator, see it's module documentation for available iterator
methods.

Example use:

my $iterator = XIMS::Iterator::Object->new(\@ids);
while (my $object = $iterator->getNext()) {
# do something with $object;
}

=cut

sub new {
    my ($class, $arryref, $cttid) = @_;

    ref($arryref) and ref($arryref) eq "ARRAY" ||
        die "Incorrect Type : First argument must be a reference to an array!\n";

    my $iterator = $class->SUPER::new( $arryref );

    if ( $cttid ) {
        $iterator->{lookup_key} = 'id';
    }
    else {
        $iterator->{lookup_key} = 'document_id';
    }

    return $iterator;
}

sub _getItem {
    my ($self, $iteratee, $index) = @_;
    my $id = $self->SUPER::_getItem( $iteratee, $index );
    return unless defined $id;
    my $o = XIMS::Object->new( $self->{lookup_key} => $id );
    defined $o ? $o : undef;
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

