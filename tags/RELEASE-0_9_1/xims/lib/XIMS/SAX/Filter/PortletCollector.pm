# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::PortletCollector;
use warnings;
use strict;
#
# This is a SAX Filter. this allows to send a datastring
# with some conditions in it. this filter will expand these conditions
# to real objects.
#
use XML::LibXML;
use XIMS::Object;
use XIMS::SAX::Filter::DataCollector;
@XIMS::SAX::Filter::PortletCollector::ISA = qw(XIMS::SAX::Filter::DataCollector);
use DBIx::SQLEngine::Criteria;
use DBIx::SQLEngine::Criteria::Or;
use DBIx::SQLEngine::Criteria::And;
# use DBIx::SQLEngine::Criteria::Not;
use DBIx::SQLEngine::Criteria::LiteralSQL;
use DBIx::SQLEngine::Criteria::Equality;

##
#
# SYNOPSIS
#    XIMS::SAX::Filter::PortletCollector->new( $param )
#
# PARAMETER
#    $param :
#
# RETURNS
#    XIMS::SAX::Filter::PortletCollector instance
#
# DESCRIPTION
#    none yet
#
sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->set_tagname( "children" );
    return $self;
}

##
#
# SYNOPSIS
#    $filter->handle_data
#
# PARAMETER
#    none
#
# RETURNS
#    nothing
#
# DESCRIPTION
#    none yet
#
sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $cols = $self->{Columns};
    if ( defined $cols and ref $cols  ) {
        XIMS::Debug( 6, "get " . join( "," , @$cols ));
    }
    return unless defined $self->{Object}
                  and $self->{Object}->symname_to_doc_id() and $self->{Object}->symname_to_doc_id() > 0;
    # fetch the objects
    # get the real object to filter:

    # use $dp->getObject here to filter properties
    my $object = XIMS::Object->new( document_id => $self->{Object}->symname_to_doc_id(), language_id => $self->{Object}->language_id() );

    if ( $object ) {
        my @children;
        my %childrenargs = ( User => $self->{User} );

        if ( $self->{Export} ) {
            $childrenargs{published} = 1;
        }

        my @object_type_ids;
        my $ot;
        foreach my $name ( $self->get_objecttypes() ) {
            $ot = XIMS::ObjectType->new( name => $name );
            push(@object_type_ids, $ot->id()) if defined $ot;
        }
        $childrenargs{object_type_id} = \@object_type_ids;

        #$cols ||= [];
        # why use not the default columns here?
        # because more columns are default, than a filter may contain.
        # this information here is the core document information that is
        # required to locate an object.
        #push @$cols, qw(MAJOR_ID MINOR_ID PARENT_ID LOCATION TITLE
        #                DATA_FORMAT_ID SYMNAME_TO_DOC_ID LANGUAGE_ID
        #                OBJECT_TYPE_ID LOB_LENGTH POSITION);
        #$param{-columns} = $cols;
        my $direct_filter = $self->get_direct_filter();
        @children = $object->children_granted( %childrenargs, %{$direct_filter}, marked_deleted => undef, limit => $self->get_latest(), order => 'last_modification_timestamp DESC' );
        if ( @children  and scalar( @children ) ) {
            XIMS::Debug( 6, "found n = " . scalar( @children ) . " child objects" );
            my $location_path;
            foreach my $o ( @children ) {
                if ( $o->data_format->name() eq 'URL' ) {
                    $location_path = $o->location();
                }
                elsif ( $self->{Export} ) {
                    if ( XIMS::RESOLVERELTOSITEROOTS() eq '1' ) {
                        $location_path = $o->location_path_relative();
                    }
                    else {
                        my $siteroot = $o->siteroot();
                        my $siteroot_url;
                        $siteroot_url = $o->siteroot->url() if $siteroot;
                        if ( $siteroot_url =~ m#/# ) {
                            $location_path = $siteroot_url . $o->location_path_relative();
                        }
                        else {
                            $location_path = XIMS::PUBROOT_URL() . $o->location_path();
                        }
                    }
                }
                else {
                    $location_path = $o->location_path();
                }
                # hmmmm, not good use $o->data() to be stored in $self->{Children} then things like adding LOCATION_PATH should be clean
                $o->body() if grep { lc($_) eq 'body' } @{$cols};
                $o = {$o->data()};
                $o->{location} = XIMS::xml_escape($o->{location});
                $o->{title} = XIMS::xml_escape($o->{title});
                $o->{location_path} = XIMS::xml_escape($location_path);
            }
            $self->push_listobject( @children );
        }
        else {
            XIMS::Debug( 6, "no objects found" );
        }
    }
    $self->SUPER::handle_data();
}

sub get_objecttypes {
    my $self = shift;
    my $fragment = $self->get_data_fragment;

    my @ots  = ();
    my @tags = ();
    my ($content) = grep {$_->nodeName eq "content" } $fragment->childNodes;
    if ( $content ) {
        @tags = $content->getChildrenByTagName( "object-type" );
    }
    else {
        @tags = grep {$_->nodeName eq "object-type" } $fragment->childNodes;
    }

    if ( scalar @tags ) {
        @ots = map { $_->getAttribute( "name" ) } @tags;
    }

    return @ots;
}

sub get_direct_filter {
    my $self = shift;
    my $fragment = $self->get_data_fragment;
    my %retval;
    my @fields = XIMS::Object::fields();
    my ( $filter ) = grep {$_->nodeName eq "filter" } $fragment->childNodes;
    if ( $filter ) {
        my @cnodes = $filter->childNodes;
        foreach my $node ( @cnodes) {
            next unless $node->nodeType == XML_ELEMENT_NODE;
            next unless grep { $node->nodeName() eq $_ } @fields;
            $retval{$node->nodeName()} = $node->string_value();
        }
    }
    return \%retval;
}

sub get_latest {
    my $self = shift;
    my $fragment = $self->get_data_fragment;
    my $latest;
    my ($content) = grep {$_->nodeName eq "content" } $fragment->childNodes;
    if ( $content ) {
        $latest = $content->getChildrenByTagName( "latest" )->string_value();
    }
    if ( defined $latest and $latest ne '0' ) {
        XIMS::Debug( 6, "got latest $latest" );
        return $latest;
    }
    return undef;
}


# not yet rewritten code and thus currently unused code ahead

sub get_level {
    my $self = shift;
    my $fragment = $self->get_data_fragment;
    my $depth;
    my ($content) = grep {$_->nodeName eq "content" } $fragment->childNodes;
    if ( $content ) {
        ($depth) = $content->getChildrenByTagName( "depth" );
    }
    else {
        ($depth) = grep {$_->nodeName eq "depth" } $fragment->childNodes;
    }
    if ( defined $depth ) {
        XIMS::Debug( 6, "have depth level" );
        my $level = $depth->getAttribute( "level" );
        $level ||= 1; # ignore invalid results
        return $level;
    }
    return 0;
}
sub build_or_filter {
    my $self = shift;
    my @tags = @_;
    my $retval = undef;
    my @conds = ();
    if ( scalar @tags ) {
        foreach my $tag ( @tags ) {
            next unless $tag->nodeType == XML_ELEMENT_NODE;
            my $tv = undef;

            if ( $tag->nodeName eq "child-object" ) {
                XIMS::Debug( 6, "NOT SUPPORTED YET\n" );
                next;
            }
            if ( $tag->nodeName eq "AND" ) {
                my @acn = $tag->childNodes;
                $tv = $self->build_and_filter( @acn );
            }
            if ( $tag->nodeName eq "NOT" ) {
                my @acn = $tag->childNodes;
                $tv = $self->build_not_filter( @acn );
            }
            if ( $tag->nodeName eq "last-modification-time"
                 or $tag->nodeName eq "creation-time"
                 or $tag->nodeName eq "published-time" ) {
                $tv = $self->build_date_filter( "OR", $tag );
            }
            if ( $tag->nodeName eq "new" ) {
                my $v = $tag->string_value;
                $v =~ s/\s+//g if defined $v;
                $tv = DBIx::SQLEngine::Criteria::LiteralSQL->new( "marked_new=" . ( $v > 0 ? 1:0 ) );
            }
            if ( defined $tv ) {
                push @conds, $tv;
            }
        }
    }
    return undef unless scalar @conds;
    return DBIx::SQLEngine::Criteria::Or->new( @conds );
}
sub build_not_filter {
    my $self = shift;
    my @tags =@_;
    my $retval = undef;
    if ( scalar @tags ) {
        $retval = $self->build_or_filter(@tags);
        if ( defined $retval ) {
            $retval = DBIx::SQLEngine::Criteria::Not->new( $retval );
        }
    }
    return $retval;
}
sub build_and_filter {
    my $self = shift;
    my @tags =@_;
    my $retval = undef;
    my @conds = ();
    if ( scalar @tags ) {
        foreach my $tag ( @tags ) {
            next unless $tag->nodeType == XML_ELEMENT_NODE;
            my $tv = undef;
            if ( $tag->nodeName eq "child-object" ) {
                XIMS::Debug( 6, "NOT SUPPORTED YET\n" );
                next;
            }
            if ( $tag->nodeName eq "OR" ) {
                my @acn = $tag->childNodes;
                $tv = $self->build_or_filter( @acn );
            }
            if ( $tag->nodeName eq "NOT" ) {
                my @acn = $tag->childNodes;
                $tv = $self->build_not_filter( @acn );
            }
            if ( $tag->nodeName eq "last-modification-time"
                 or $tag->nodeName eq "creation-time"
                 or $tag->nodeName eq "published-time" ) {
                $tv = $self->build_date_filter( "AND" , $tag );
            }
            if ( $tag->nodeName eq "new" ) {
                my $v = $tag->string_value;
                $v =~ s/\s+//g;
                $tv = DBIx::SQLEngine::Criteria::LiteralSQL->new( "marked_new=" . ( $v > 0 ? 1:0 ) );
            }
            if ( defined $tv ) {
                push @conds, $tv;
            }
        }
    }
    return undef unless scalar @conds;
    return DBIx::SQLEngine::Criteria::Or->new( @conds );
}
##
# this function should be aware about requests like "two days ago
# 'till now" or "last month content" the filter is aware about
# different conditions, so it is possible to filter against the
# various date fields we have.
# the current version of this g'damn builder version is very close to
# Oracle SQL it may not work with other systems.
sub build_date_filter {
    my $self = shift;
    my $BOOLOP = shift;
    my @tags = @_;
    my $retval;
    my ( $leftwrap, $rightwrap ) = ( "", "" );
    $retval = "" if scalar @tags;
    foreach my $t ( @tags ) {
        my @childnodes = $t->childNodes;
        my $name = "";
        next unless scalar @childnodes;

        $retval .= " $BOOLOP " if length $retval;
        if ( $t->nodeName eq "last-modification-time" ) {
            $name .= "last_modification_timestamp ";
        }
        elsif ( $t->nodeName eq  "creation-time" ) {
            $name .= "created_timestamp ";
        }
        elsif ( $t->nodeName eq "published-time" ) {
            $name .= "last_publication_timestamp";
        }
        my @tcn = $t->getChildrenByTagName( "value" );
        if ( scalar @tcn <= 0 ) {
            # complex date functions
            foreach my $cond ( @childnodes ) {
                my $value = "";
                my $last = 0 ;
                if ( $cond->nodeName eq "between" ){
                    $last = 0 ;
                    foreach my $node ( $cond->childNodes ) {
                        $value = "";
                        if ( length $value ) {
                            $value   .= " AND ";
                            $last = 1 ;
                        }
                        if ( $node->nodeName eq "value" ) {
                            $value .= "TO_DATE('" . $node->string_value . "')";
                        }
                        elsif ( $node->nodeName eq "intevall" ) {
                            $value .= "(SYSTDATE - ". $node->string_value . ")";
                        }
                        elsif ( $cond->nodeName eq "today" ) {
                            $retval .= "SYSDATE";
                        }
                        elsif ( $cond->nodeName eq "yesterday" ) {
                            $retval .= "(SYSDATE - 1)";
                        }
                        elsif ( $cond->nodeName eq "last-week" ) {
                            $retval .= "(SYSDATE - 7)";
                        }
                        last if $last;
                    }
                    $retval .= " ( $name BETWEEN $value ) ";
                }
                elsif ( $cond->nodeName eq "after" ) {
                    my ( $datenode ) = $cond->childNodes;
                    if ( defined $datenode ) {
                        $value = $datenode->string_value;
                        if ( $datenode->nodeName eq "value" ) {
                            $retval .= "$name >= TO_DATE('$value')";
                        }
                        elsif ( $datenode->nodeName eq "interval"
                                and  $value > 0) {
                            # interval in dates on default
                            $retval .= "( $name >= SYSDATE - $value )";
                        }
                        elsif ( $datenode->nodeName eq "yesterday" ) {
                            $retval .= "(SYSDATE - 1)";
                        }
                        elsif ( $datenode->nodeName eq "last-week" ) {
                            $retval .= "(SYSDATE - 7)";
                        }
                    }
                }
                elsif ( $cond->nodeName eq "today" ) {
                    $retval .= "$name = SYSDATE";
                }
                elsif ( $cond->nodeName eq "yesterday" ) {
                    $retval .= "$name = SYSDATE - 1";
                }
                elsif ( $cond->nodeName eq "last-week" ) {
                    $retval .= "$name = SYSDATE - 7";
                }
            }
        }
        elsif ( scalar @tcn > 1 ) {
            # IN exact dates
            my @values = map {"TO_DATE('".$_->string_value()."')"} grep { length $_->string_value() } @tcn;
            $retval .= "$name IN ( " . join( ",", @values ) ." )";
        }
        else {
            # only a single date
            # i think we should avoid this!
            my $value = $tcn[0]->string_value();
            if ( defined $value and length $value ) {
                $retval .= "$name = TO_DATE('$value')";
            }
            else {
                XIMS::Debug( 6, "Value tag contained no data" );
            }
        }
    }
    return undef unless defined $retval and length $retval;
    XIMS::Debug( 6, "use date literal $retval" );
    return DBIx::SQLEngine::Criteria::LiteralSQL->new ( $retval );
}

1;
