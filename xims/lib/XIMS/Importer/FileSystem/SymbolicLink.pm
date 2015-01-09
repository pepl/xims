
=head1 NAME

XIMS::Importer::FileSystem::SymbolicLink

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer::FileSystem::SymbolicLink;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer::FileSystem::SymbolicLink;

use common::sense;
use parent qw( XIMS::Importer::FileSystem );
use XIMS::Object;
use File::Basename;


sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->SUPER::handle_data( $location );
    my $targetlocation = readlink $location;
    return unless $targetlocation;

    my $parent_path = $self->parent->location_path();
    my $exp = $targetlocation;
    my $dirname = dirname($location);
    if ( $exp =~ m|^\.\./| ) {
        my $anclevel = ( $exp =~ tr|../|../| );
        $anclevel = ($anclevel + 1) / 3;
        my $ancestors = $self->parent->ancestors();
        my $i = scalar @{$ancestors} + 1 - $anclevel;
        my $relparent = ${@{$ancestors}}[$i];
        next unless $relparent;
        $exp =~ s|\.\./||g;
        $exp = $relparent->location_path() . "/" . $exp;
    }
    elsif ( $exp =~ m|^\./| or $exp =~ m{^[^\./]|^[^/]}) {
        $exp =~ s/^\.\///;
        $exp = "$parent_path/$dirname/$exp";
    }
    elsif ( $exp =~ m|^/| ) {
        my $cwd = `pwd`;
        chomp $cwd;
        $exp =~ s|$cwd||;
        $exp = "$parent_path$exp";
    }

    my $targetobj = XIMS::Object->new( path => $exp );
    if ( $targetobj and $targetobj->id() ) {
        $object->symname_to_doc_id( $targetobj->document_id() );
    }
    else {
        XIMS::Debug( 3, "Could not resolve symlink $location, $targetlocation, $exp" );
        return;
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

