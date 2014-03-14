
=head1 NAME

XIMS::Names

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Names;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Names;

# This is a private class that cannot be used directly

use common::sense;

our %Properties = XIMS::Config::Names::Properties();
our @ResourceTypes = XIMS::Config::Names::ResourceTypes();

=head2 get_URI()

=cut

sub get_URI {
    my ($r_type, $property_name) = @_;
    XIMS::Debug( 1, "Unknown resource type '$r_type'!" ) unless grep { $_ eq $r_type} @ResourceTypes;
    if ( $r_type eq 'Object' ) {
        my ( $p, $t ) = reverse ( split /\./, $property_name );
        if ( $t ) {
            return $property_name;
        }
        my $re = qr(^.+?\.$property_name$);
        if ( grep { $_ =~ $re } @{$Properties{Content}} ) {
            return 'content' . '.' . $property_name;
        }
        else {
            return 'document' . '.' . $property_name;
        }
    }
    return $property_name =~ /\./go ? $property_name : lc( $r_type ) . '.' . $property_name;
}

=head2 property_list()

=cut

sub property_list {
    my $r_type = shift;
    if ( $r_type ) {
        return $Properties{$r_type};
    }
    else {
        return %Properties;
    }
}

=head2 property_interface_names()

=cut

sub property_interface_names {
    my $r_type = shift;
    return [] unless $r_type;
    my @out_list = map{ (split /\./, $_)[1] } @{property_list( $r_type )};
    return \@out_list;
}

=head2 resource_types()

=cut

sub resource_types {
    return @ResourceTypes;
}

=head2 properties()

=cut

sub properties {
    return %Properties;
}

=head2 valid_property()

=cut

sub valid_property {
    my ( $r_type, $prop_name ) = @_;
    return 1 if grep { $_ eq $prop_name } @{$Properties{$r_type}};
    return;
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

