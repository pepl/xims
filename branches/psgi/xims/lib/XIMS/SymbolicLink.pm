
=head1 NAME

XIMS::SymbolicLink -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SymbolicLink;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SymbolicLink;

use strict;
use parent qw( XIMS::Object );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );


=head2    my $target = $symlink->target( [ $object ] );

=head3 Parameter

    $object    (optional) :  XIMS::Object instance of new target

=head3 Returns

    $target : XIMS::Object where "symname_to_doc_id" property points to

=head3 Description

Sets/Gets target of symbolic link

=cut

sub target {
    my $self = shift;
    my $target = shift;

    if ( $target ) {
        $self->symname_to_doc_id( $target->document_id() );
        return $target;
    }
    else {
        return XIMS::Object->new( document_id => $self->symname_to_doc_id() );
    }
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

Copyright (c) 2002-2011 The XIMS Project.

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

