# Copyright (c) 2002-2006 The XIMS Project.
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

        my @doclinks_object_type_ids;
        if ( $self->get_documentlinks() ) {
            my $ot;
            foreach my $name ( qw( URLLink SymbolicLink ) ) {
                $ot = XIMS::ObjectType->new( name => $name );
                push(@doclinks_object_type_ids, $ot->id()) if defined $ot;
            }
        }

        if ( defined $cols and ref $cols and scalar @{$cols} ) {
            XIMS::Debug( 6, "getting custom properties: " . join( "," , @$cols ));
            # add a list of base properties
            push( @{$cols}, qw( id document_id parent_id object_type_id
                                data_format_id symname_to_doc_id location title position) );
            $childrenargs{properties} = $cols;

        }
        my $direct_filter = $self->get_direct_filter();
        my $method = 'children_granted';
        my $depth = $self->get_depth();
        if ( defined $depth and length $depth and $depth > 1 ) {
            $method = 'descendants_granted';
            $childrenargs{maxlevel} = $depth;
        }
        my $latest_sortkey = $self->get_latest_sortkey();
        my $order = 'last_modification_timestamp';
        if ( defined $latest_sortkey and length $latest_sortkey and $latest_sortkey eq 'valid_from_timestamp' ) {
            $order = $latest_sortkey;
        }
        @children = $object->$method( %childrenargs, %{$direct_filter}, marked_deleted => undef, limit => $self->get_latest(), order => "$order DESC" );
        if ( @children  and scalar( @children ) ) {
            XIMS::Debug( 6, "found n = " . scalar( @children ) . " objects" );
            my $location_path;
            foreach my $o ( @children ) {
                my $cacheddfname = "_cached_data_format_id".$o->data_format_id();
                $self->{$cacheddfname} ||= $o->data_format->name();
                if ( defined $self->{$cacheddfname} and $self->{$cacheddfname} eq 'URL' ) {
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

                $o->{body} = $o->body() if grep { $_ eq 'body' } @{$cols};
                $o->{content_length} = $o->content_length if grep { $_ eq 'content_length' } @{$cols};

                $o->{location} = XIMS::xml_escape($o->{location});
                $o->{title} = XIMS::xml_escape_noquot($o->{title});
                $o->{location_path} = XIMS::xml_escape($location_path);

                # check if documentlink objects should be added
                if ( $self->get_documentlinks() ) {
                    XIMS::Debug( 4, "looking for documentlinks" );
                    my %cargs = %childrenargs;
                    $cargs{object_type_id} = \@doclinks_object_type_ids;
                    delete $cargs{maxlevel};
                    my @links = $o->children_granted( %cargs );
                    push( @children, @links) if scalar @links;
                }
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
    my $content = $self->get_content();
    if ( defined $content ) {
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
    my $latest;
    my $content = $self->get_content();
    if ( defined $content ) {
        $latest = $content->getChildrenByTagName( "latest" )->string_value();
    }
    if ( defined $latest and $latest ne '0' ) {
        XIMS::Debug( 6, "got latest $latest" );
        return $latest;
    }
    return undef;
}

sub get_latest_sortkey {
    my $self = shift;
    my $latest_sortkey;
    my $content = $self->get_content();
    if ( defined $content ) {
        $latest_sortkey = $content->getChildrenByTagName( "latest_sortkey" )->string_value();
    }
    if ( defined $latest_sortkey and ( $latest_sortkey eq 'last_modification_timestamp' or $latest_sortkey eq 'valid_from_timestamp' ) ) {
        XIMS::Debug( 6, "got latest_sortkey $latest_sortkey" );
        return $latest_sortkey;
    }
    return undef;
}

sub get_depth {
    my $self = shift;
    my $depth;
    my $content = $self->get_content();
    if ( defined $content ) {
        $depth = $content->getChildrenByTagName( "depth" )->string_value();
    }
    if ( defined $depth and $depth ne '0' ) {
        XIMS::Debug( 6, "got depth $depth" );
        return $depth;
    }
    return undef;
}


sub get_documentlinks {
    my $self = shift;
    my $documentlinks;
    my $content = $self->get_content();
    if ( defined $content ) {
        $documentlinks = $content->getChildrenByTagName( "documentlinks" )->string_value();
    }
    if ( defined $documentlinks and $documentlinks eq '1' ) {
        return 1;
    }
    return undef;
}

# not yet rewritten code and thus currently unused code ahead

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
