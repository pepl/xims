
=head1 NAME

XIMS::NewsItem -- Like NewsItem, but location can be set by user

=head1 VERSION

$Id: NewsItem2.pm 2183 2009-01-03 16:45:48Z pepl $

=head1 SYNOPSIS

    use XIMS::NewsItem2;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::NewsItem2;

use common::sense;
use parent qw( XIMS::Document );
use XIMS::Importer::Object;


=head2 add_image()

=cut

sub add_image {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $img_object = shift;

    my $obj_importer = XIMS::Importer::Object->new( User => $img_object->User(), Parent => $img_object->parent() );
    my $id = $obj_importer->import( $img_object );
    if ( defined( $id ) ) {
        $self->image_id( $id );
    }
    else {
        XIMS::Debug( 3, "could not create new image object. Perhaps it already exists." );
    }
    return $id;
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

Copyright (c) 2002-2015 The XIMS Project.

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

