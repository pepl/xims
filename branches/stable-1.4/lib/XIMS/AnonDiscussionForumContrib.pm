
=head1 NAME

XIMS::AnonDiscussionForumContrib -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::AnonDiscussionForumContrib;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::AnonDiscussionForumContrib;

use strict;
use base qw( XIMS::Document );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 author()

=cut

sub author {
    my $self= shift;
    my $author = shift;
    my $retval;

    if ( defined $author and length $author ) {
        $self->attribute( author => __limit_string_length( $author ) );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('author');
    }

    return $retval;
}

=head2 email()

=cut

sub email {
    my $self= shift;
    my $email = shift;
    my $dontcheck = shift;
    my $retval;

    if ( defined $email and length $email ) {
        $self->attribute( email =>  __limit_string_length( $email ) );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('email');
    }

    return $retval;
}

=head2 coauthor()

=cut

sub coauthor {
    my $self= shift;
    my $author = shift;
    my $retval;

    if ( defined $author and length $author ) {
        $self->attribute( coauthor =>  __limit_string_length( $author ) );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('coauthor');
    }

    return $retval;
}

=head2 coemail()

=cut

sub coemail {
    my $self= shift;
    my $email = shift;
    my $dontcheck = shift;
    my $retval;

    if ( defined $email and length $email ) {
        $self->attribute( coemail =>  __limit_string_length( $email ) );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('coemail');
    }

    return $retval;
}

=head2 senderip()

=cut

sub senderip {
    my $self= shift;
    my $ip = shift;
    my $retval;

    if ( defined $ip and length $ip ) {
        $self->attribute( senderip => $ip );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('senderip');
    }

    return $retval;
}

# "static" function
# SYNOPSIS:
#
# __limit_string_length( $string, $length );
#
# PARAMETER:
#
# "$string" is the only obligatory paramenter
#
# DESCRIPTION:
#
# the default behaviour is to take a string, strip leading and
# trailing multiple whitespace, returning the first 30 characters as scalar.
# optionally give the wanted stringlength as second argument.
#

=head2 private functions/methods

=over

=item _limit_string_length()

=back

=cut

sub __limit_string_length {
    my ( $string, $length ) = @_;
    $length = 30 unless defined $length;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    $string = substr($string, 0, $length);

    return $string;
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

Copyright (c) 2002-2009 The XIMS Project.

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

