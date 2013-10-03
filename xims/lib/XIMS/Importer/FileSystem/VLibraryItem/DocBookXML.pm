
=head1 NAME

XIMS::Importer::FileSystem::VLibraryItem::DocBookXML -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer::FileSystem::VLibraryItem::DocBookXML;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer::FileSystem::VLibraryItem::DocBookXML;

use common::sense;
use parent qw(XIMS::Importer::FileSystem::XML XIMS::Importer::Object::VLibraryItem::DocBookXML);
use File::Basename;


sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->SUPER::handle_data( $location, 1 );
    my $root = $self->get_rootelement( $location, nochunk => 1 );
    return unless $root;

    # hacky, tracky - there is no such thing as SUPER::SUPER :-|
    # the vl* methods need an already created object with a document_id to assign the foreign
    # key mappings
    XIMS::Importer::import( $self, $object );

    $self->vlproperties_from_document( $root, $object );

    # bidok specific .zip import -- to be replaced by auto generated pdf-version
    #my ( $stripped_location ) = ( $location =~ s|(.*)\..*$|$1| );
    #my $zip_location .= $stripped_location.'.zip';

    my @filerefs = $root->findnodes( '//@fileref' );
    if ( @filerefs and scalar @filerefs > 0 ) {
        my $importer = XIMS::Importer::FileSystem->new( User => $self->user, Parent => $object );
        foreach my $fileref ( @filerefs ) {
            my $filename = $fileref->to_literal();

            $filename =~ s#\.(/|\\)##; # clean up the filename
            next if $filename =~ m#/|\\#; # only import filerefs in the same dir for now

            $filename = dirname($location).'/'.$filename;
            if ( not -f $filename ) {
                XIMS::Debug( 3, "could not find referenced file '$filename'" );
                next;
            }
            if ( $importer->import( $filename ) ) {
                print "'$filename' imported successfully.\n";
            }

            else {
                print "Import of '$filename' failed.\n";
            }
        }
    }

    return $object;
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

