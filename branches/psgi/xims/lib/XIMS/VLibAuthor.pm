
=head1 NAME

XIMS::VLibAuthor -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::VLibAuthor;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::VLibAuthor;

use strict;
use base qw( XIMS::AbstractClass Class::Accessor::Fast );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @Fields = @{XIMS::Names::property_interface_names( resource_type() )};

our @compound_lastnames = (
    qr/Von (Der )?/i,        # Dutch or German
    qr/Van (De(n|r)? )?/i,
    qr/Den /i,
    qr/Dell([a|e])? /i,      # Italian
    qr/Dalle /i,
    qr/D[a|e]ll'/i,          # '
    qr/Dela /i,
    qr/Del /i,
    qr/De .+/i,
    qr/D[a|i,|u] /i,
    qr/L[a|e|o] /i,
    qr/[D|L|O]'/i,           # 'italian, irish or French
    qr/St\.? /i,             # abbreviation for Saint
    qr/San /i,               # Spanish
    qr/ y /i,                #
    qr/[A|E]l /i,            # Arabic, Greek,
    qr/Bin /i,               # Hebrew
    qr/Ap /i,                # Welsh
    qr/Ben /i,               # Hebrew
);

=head2 fields()

=cut

sub fields {
    return @Fields;
}

=head2 resource_type()

=cut

sub resource_type {
    my $rt = __PACKAGE__;
    $rt =~ s/.*://;
    return $rt;
}

__PACKAGE__->mk_accessors( @Fields );



=head2    my $author = XIMS::VLibAuthor->new( [ %args ] );

=head3 Parameter

   C<$args{ id }>: an existing entry's id.

   C<$args{ lastname }>: author's lastname or a organization's name.

   C<$args{ middlename }>

   C<$args{ firstname }>

   C<$args{ object_type }>: object type; 1 := organisation,
                             (0|undef|q{}) := person.

   C<$args{document_id}>: document_id of the library this entry belongs
                          to.

   C<$args{suffix}>

   C<$args{email}>

   C<$args{url}>


=head3 Returns

   An instance of XIMS::VLibAuthor.

=head3 Description

   Fetches existing authors or creates a new instance of
   XIMS::VLibAuthor.

   Proper ways to call are:

   - without parameters;

   - with id;

   - with document_id, lastname, object_type and optionally further
     attributes;

   - with document_id, lastname, middlename, firstname and optionally
     further attributes;

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args  = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args) ) > 0 ) {
        if (defined( $args{id} )
            or (    defined( $args{lastname} )
                and defined( $args{middlename} )
                and defined( $args{firstname} )
                and defined( $args{document_id} ) )
            or (    defined( $args{lastname} )
                and defined( $args{object_type} )
                and defined( $args{document_id} ) )
            )
        {
            # Change the empty string to undef; In this cases, we want
            # these attributes in the DB to be NULL; (i.e.: no middlename)
            if ( ( exists $args{middlename} and $args{middlename} eq q{} ) ) {
                $args{middlename} = undef;
            }
            if ( ( exists $args{firstname} and $args{firstname} eq q{} ) ) {
                $args{firstname} = undef;
            }

            my $rt = ref($self);
            $rt =~ s/.*://;
            my $method = 'get' . $rt;
            my $data   = $self->data_provider->$method(%args);

            if ( defined($data) ) {
                $self->data( %{$data} );
            }
            else {
                return;
            }

        }
        else {
            $self->data(%args);
        }
    }
    return $self;
}

=head2 parse_namestring()

=cut

sub parse_namestring {
    my $name = shift;

    my ($firstname, $middlename, $lastname, $suffix);
    ($name, $suffix) = split(",", XIMS::trim($name));

    # Split firstname and middlename initials
    $name =~ s/^(\w)\.(\w)\./$1. $2./;

    $name = escape_compound_lastnames( $name );

    my $namefrags = XIMS::tokenize_string( $name );
    if ( scalar @$namefrags == 3 ) {
        ($firstname, $middlename, $lastname) = @$namefrags;
    }
    elsif ( scalar @$namefrags == 2 ) {
        ($firstname, $lastname) = @$namefrags;
    }
    else {
        XIMS::Debug( 3, "Could not parse name: $name" );
        return;
    }

    $lastname = unescape_compound_lastnames( $lastname );
    $middlename = '' unless defined $middlename;
    if ( defined $lastname and length $lastname ) {
        return { firstname => $firstname, middlename => $middlename, lastname => $lastname, suffix => $suffix };
    }
    else {
        return;
    }
}

=head2 escape_compound_lastnames()

=cut

sub escape_compound_lastnames {
    my $name = shift;

    foreach my $compound ( @compound_lastnames ) {
        if ( $name =~ $compound ) {
            #warn "$name matches $compound\n";
            my $escaped_match = my $match = $&;
            $escaped_match =~ s/ /__/g;
            $name =~ s/$match/$escaped_match/e;
            last;
        }
    }

    return $name;
}

=head2 unescape_compound_lastnames()

=cut

sub unescape_compound_lastnames {
    my $name = shift;
    $name =~ s/__/ /g;
    return $name;
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

