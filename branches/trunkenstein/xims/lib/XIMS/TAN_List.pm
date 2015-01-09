
=head1 NAME

XIMS::TAN_List

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::TAN_List;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::TAN_List;

use common::sense;
use parent qw( XIMS::Text );




=head2    XIMS::TAN_List->new( %args )

=head3 Parameter

    %args: recognized keys are the fields from ...

=head3 Returns

    $tan_list: XIMS::TAN_List instance

=head3 Description

Constructor

=cut


sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'TAN_List' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}



=head2    XIMS::TAN_List->number()

=head3 Parameter

    none

=head3 Returns

    Number of TANs in List

=head3 Description



=cut

sub number {
    my $self = shift;
    my $number = shift;
    my $retval;

    if ( defined $number and length $number ) {
        $self->attribute( number => $number );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('number');
    }

    return $retval;
}



=head2    XIMS::TAN_List->create_TANs()

=head3 Parameter

    number of TANs to create

=head3 Returns


    coma seperated string of TANs

=head3 Description



=cut

sub create_TANs {
    XIMS::Debug ( 5, "called" );
    my $self = shift;
    my $number = shift;

    my %tanlist;
    my $tanlist;
    my $TAN_length = 8; # Length of created TANs
    my @TAN_charpool = qw( 1 2 3 4 5 6 7 8 9 ); # Characters/Numbers which the TAN is build of
    my $TAN;

    srand();

    while ( $number ) {
        $TAN = '';
        for (my $i = $TAN_length; $i > 0; $i--) {
            $TAN .= $TAN_charpool[ rand( @TAN_charpool ) ];
        }
        redo if $tanlist{$TAN}; # if TAN already exists redo creation of TAN
        $tanlist{$TAN} = 1;
        $number--;
    }

    foreach my $key ( keys( %tanlist ) ) {
        if ( $tanlist ) {
            $tanlist .= ",$key";
        }
        else {
            $tanlist = $key;
        }
    }

    return $tanlist;
}



=head2    XIMS::TAN_List->verify()

=head3 Parameter

    TAN

=head3 Returns

    true if TAN is in the list
    false if TAN is not in the list

=head3 Description



=cut

sub verify {
    my $self = shift;
    my $TAN_to_verify = shift;

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

