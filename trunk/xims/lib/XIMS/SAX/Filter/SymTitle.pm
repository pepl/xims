# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::SymTitle;

use warnings;
use strict;

use XML::SAX::Base;
use XIMS::Object;

use vars qw( @ISA );
@ISA = qw( XML::SAX::Base );

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );

    $self->{symid} = "";
    return $self;
}

sub start_element {
    my $self = shift;
    my $elem = shift;

    if ( $elem->{LocalName} eq "object" ) {
        $self->{filter_title} = 1;
    }

    if ( $elem->{LocalName} eq "children" ) {
        if ( defined $self->{original_ttl_e} ) {
            if ( defined $self->{symid}
                 and defined $self->{langid}
                 and length $self->{symid}
                 and $self->{symid} > 0 ) {
                # in this case we must resolve the title of the
                # refered object.
                XIMS::Debug( 6, "fetching the real title ( " . $self->{symid} . "," . $self->{langid} . ")" );
                my $lang = $self->{langid};
                my $object = XIMS::Object->new( document_id => $self->{symid}, language_id => $lang );

                $self->{original_ttl} = $object->title;
                XIMS::Debug( 6, "got title: '" . $self->{original_ttl} . "'" );
            }

            $self->SUPER::start_element( $self->{original_ttl_e} );
            $self->SUPER::characters( { Data => $self->{original_ttl} } );
            $self->SUPER::end_element( $self->{original_ttl_e} );

            $self->{symid} = undef;
            $self->{langid} = undef;
        }
    }

    if ( $elem->{LocalName} eq "title"
         and $self->{filter_title} == 1 ) {
        $self->{in_title} = 1;
        $self->{original_ttl_e} = $elem;
        $self->{original_ttl}   = "";
    }
    else {
        if ( $elem->{LocalName} eq "symname_to_doc_id" ) {
            $self->{symname} = 1;
        }

        if ( $elem->{LocalName} eq "language_id" ) {
            $self->{language} = 1;
            $self->{langid} = "";
        }
        $self->SUPER::start_element( $elem );
    }
}

sub end_element {
    my $self = shift;
    my $elem = shift;

    if ( defined $elem->{LocalName} ) {
        if ( $elem->{LocalName} eq "title" ) {
            $self->{in_title} = 0;
            return;
        }

        if ( $elem->{LocalName} eq "symname_to_doc_id" ) {
            delete $self->{symname};
        }

        if ( $elem->{LocalName} eq "language_id" ) {
            delete $self->{language};
        }

        if ( $elem->{LocalName} eq "object" ) {
            if ( defined $self->{original_ttl_e} ) {
                if ( defined $self->{symid}
                     and defined $self->{langid}
                     and length $self->{symid}
                     and $self->{symid} > 0 ) {
                    # in this case we must resolve the title of the
                    # refered object.
                    XIMS::Debug( 6, "fetching the real title ( " . $self->{symid} . "," . $self->{langid} . ")" );
                    my $lang = $self->{langid};
                    my $object = XIMS::Object->new( document_id => $self->{symid}, language_id => $lang );

                    $self->{original_ttl} = $object->title;
                    XIMS::Debug( 6, "got title: '" . $self->{original_ttl} . "'" );
                }

                $self->SUPER::start_element( $self->{original_ttl_e} );
                $self->SUPER::characters( { Data => $self->{original_ttl} } );
                $self->SUPER::end_element( $self->{original_ttl_e} );

                delete $self->{symid};
                delete $self->{langid};
            }
        }
    }

    $self->SUPER::end_element( $elem );

}

sub characters {
    my $self = shift;
    my $data = shift;

    if ( defined $data->{Data} ) {
        if ( defined $self->{filter_title}
             and $self->{filter_title} == 1
             and defined $self->{in_title}
             and $self->{in_title} == 1 ) {
            $self->{original_ttl} .= $data->{Data};
            return;
        }

        if ( defined $self->{symname} ) {
            $self->{symid} .= $data->{Data};
        }

        if ( defined $self->{language} ) {
            $self->{langid} .= $data->{Data};
        }
    }

    $self->SUPER::characters( $data );
}

1;
