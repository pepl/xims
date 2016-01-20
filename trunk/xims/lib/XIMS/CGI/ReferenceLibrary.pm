
=head1 NAME

XIMS::CGI::ReferenceLibrary

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::ReferenceLibrary;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::ReferenceLibrary;

use common::sense;
use parent qw(XIMS::CGI::Folder);
use XIMS::VLibAuthor;
use XIMS::ReferenceLibraryItem;
use XIMS::RefLibReferenceType;
use XIMS::RefLibSerial;
use XIMS::RefLibReferencePropertyValue;
use XIMS::Importer::Object::ReferenceLibraryItem;
use XIMS::QueryBuilder::ReferenceLibrary;
use XML::LibXML;
use File::Temp qw/ tempfile unlink0 /;
use Locale::TextDomain ('info.xims');


sub registerEvents {
    XIMS::Debug( 5, "called");
    my $self = shift;
    XIMS::CGI::registerEvents( $self,
        qw(
          create
          edit
          store
          obj_acllist
          obj_acllight
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          import_prompt
          import
          reflibsearch
          )
        );
}


# #############################################################################
# RUNTIME EVENTS

=head2 event_init()

=cut

sub event_init {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # let X:S:G:S handle all events beside search
    $ctxt->sax_generator( 'XIMS::SAX::Generator::ReferenceLibrary' ) unless $self->testEvent($ctxt) eq 'search';
    return $self->SUPER::event_init( $ctxt );
}

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $style = $self->param('style');
    if ( defined $style and $style =~ /^[-\w]+$/ ) {
        $ctxt->properties->application->style( $style );
    }

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $limit;
    if ( defined $self->param('onepage') or defined $style ) {
        $limit = undef;
    }
    else {
        $limit = 20;
        $offset ||= 0;
        $offset = $offset * $limit;
    }
    my $order = 'last_modification_timestamp DESC';

    my %childrenargs;
    my $date = $self->param('date');
    my $author_id = $self->param('author_id');
    my $serial_id = $self->param('serial_id');
    my $reference_type_id = $self->param('reference_type_id');
    my $workgroup_id = $self->param('workgroup_id');

    # May come in as latin1 via gopublic
    my $author_lname = XIMS::utf8_sanitize( scalar $self->param('author_lname') );
    if ( defined $author_lname ) {
        $self->param( 'author_lname', $author_lname ); # update CGI param, so that stylesheets get the right one
    }
    $author_lname ||= $self->param('author_lname'); # fallback

    # The following parameter can be used to specify a title for the citation listing
    # Since it *may* come in as latin1 depending on the pubstylesheet encoding,
    # we have to make sure that it will be utf8 encoded.
    my $ptitle = XIMS::utf8_sanitize( scalar $self->param('ptitle') );
    if ( defined $ptitle ) {
        $self->param( 'ptitle', $ptitle );
    }

    if ( defined $date and $date =~ /^[0-9-: T]+$/ ) { # allow ISO-8601 dates without timezone
        $childrenargs{date} = "%$date%";
    }
    if ( defined $reference_type_id and $reference_type_id =~ /^\d+$/ ) {
        $childrenargs{reference_type_id} = $reference_type_id;
    }
    if ( defined $workgroup_id and $workgroup_id =~ /^\d+$/ ) {
        $childrenargs{workgroup_id } = "%$workgroup_id%";
    }
    if ( defined $author_id and $author_id =~ /^\d+$/ ) {
        $childrenargs{author_id} = $author_id;
    }
    elsif ( defined $author_lname and $author_lname =~ /^[^()!?_^`´'"]{2,}/ ) { # '
        $author_lname =~ s#\*#%#g;
        $author_lname =~ s#%%#%#g;
        $childrenargs{author_lname} = $author_lname;
    }
    if ( defined $serial_id and $serial_id =~ /^\d+$/ ) {
        $childrenargs{serial_id} = $serial_id;
    }
    if ( defined $ctxt->session->auth_module() eq 'XIMS::Auth::Public'
              or $ctxt->session->user->id() == XIMS::PUBLICUSERID() ) {
        $childrenargs{published} = 1;
    }

    my ( $child_count, $children ) = $ctxt->object->items_granted( limit => $limit, offset => $offset, order => $order, %childrenargs );

    $ctxt->objectlist( [ $child_count, $children ] );

    # This prevents the loading of XML::Filter::CharacterChunk and thus saving some ms...
    $ctxt->properties->content->escapebody( 1 );

    return 0;
}

=head2 event_reflibsearch()

=cut

sub event_reflibsearch {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $style = $self->param('style');
    if ( defined $style and $style =~ /^[-\w]+$/ ) {
        $ctxt->properties->application->style( $style );
    }
    else {
        $ctxt->properties->application->style( 'default' );
    }

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $limit;
    if ( defined $self->param('onepage') or defined $style ) {
        $limit = undef;
    }
    else {
        $limit = 20;
        $offset ||= 0;
        $offset = $offset * $limit;
    }
    my $order = 'last_modification_timestamp DESC';

    my $search = XIMS::utf8_sanitize( scalar $self->param('reflibsearch') );
    if ( defined $search ) {
        $self->param( 'reflibsearch', $search ); # update CGI param, so that stylesheets get the right one
    }
    $search ||= scalar $self->param('reflibsearch'); # fallback

    # The following parameter can be used to specify a title for the citation listing
    # Since it *may* come in as latin1 depending on the pubstylesheet encoding,
    # we have to make sure that it will be utf8 encoded.
    my $ptitle = XIMS::utf8_sanitize( scalar $self->param('ptitle'));
    if ( defined $ptitle ) {
        $self->param( 'ptitle', $ptitle );
    }

    unless ( defined $search and length($search) >= 2 and length($search) <= 128 ) {
        return $self->sendError( $ctxt, __"A valid search string is needed." );
    }

    my $allowed = q{\!a-zA-Z0-9ÀÁÂÃÅÆÇÈÉÊËÐÑÒÓÔÕØÙÚÛàáâãåæçèéêëìíîïðñòóôõøùúûüýöäüßÖÄÜß%:\-<>\/\(\)\\.,\*&\?\+\^'\"\$\;\[\]~};
    my $qb = XIMS::QueryBuilder::ReferenceLibrary->new( { search => $search,
                                                          allowed => $allowed,
                                                          extraargs => { reflib => $ctxt->object() } } );

    if ( not defined $qb ) {
        return $self->sendError( $ctxt, __"Querybuilder could not be instantiated." );
    }

    my ( $child_count, $children ) = $ctxt->object->items_granted( limit => $limit, offset => $offset, order => $order, criteria => $qb->criteria() );

    $ctxt->objectlist( [ $child_count, $children ] );

    # This prevents the loading of XML::Filter::CharacterChunk and thus saving some ms...
    $ctxt->properties->content->escapebody( 1 );

    return 0;
}

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );

    return $self->SUPER::event_edit( $ctxt );
}

=head2 event_copy()

=cut

sub event_copy {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, __"Copying ReferenceLibraries is not implemented." );
}

=head2 event_delete()

=cut

sub event_delete {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, __"Deleting ReferenceLibraries is not implemented." );
}

=head2 event_delete_prompt()

=cut

sub event_delete_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, __"Deleting ReferenceLibraries is not implemented." );
}

=head2 event_import_prompt()

=cut

sub event_import_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style( 'import_prompt' );
}

=head2 event_import()

=cut

sub event_import {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $privmask = $ctxt->session->user->object_privmask( $ctxt->object() );
    return $self->event_access_denied( $ctxt ) unless $privmask & XIMS::Privileges::CREATE();

    my $body;
    my $fh = $self->upload( 'file' );
    if ( defined $fh ) {
        my $buffer;
        while ( read($fh, $buffer, 1024) ) {
            $body .= $buffer;
        }
    }
    else {
        $body = $self->param( 'body' );
        if ( defined $body and length $body ) {
            # Converter needs latin1
            $body = Text::Iconv->new("UTF-8", "ISO-8859-1")->convert($body);
        }
    }

    unless ( defined $body and length $body ) {
        XIMS::Debug( 3, "Need some text to import" );
        $self->sendError( $ctxt, __"Need some text to import." );
        return 0;
    }

    # setup up input format filter map
    my %sourcetypemap = (
                      'BibTeX' => 'bib2xml',
                      'COPAC' => 'copac2xml',
                      'Endnote' => 'end2xml',
                      'ISI' => 'isi2xml',
                      'Pubmed' => 'med2xml',
                      'RIS' => 'ris2xml',
                      'MODS' => undef,
                      );

    my $importformat = $self->param('importformat');
    if ( not exists $sourcetypemap{$importformat} ) {
        XIMS::Debug( 3, "Unknown Import Format" );
        $self->sendError( $ctxt, __"Unknown Import Format." );
        return 0;
    }

    # convert to MODS if neccessary
    if ( defined $sourcetypemap{$importformat} ) {
        # Use format converter binaries available at
        # http://www.scripps.edu/~cdputnam/software/bibutils/bibutils.html
        # TODO: take path from config, or use Perl Module (if available)
        my $inputformatfilterpath = '/usr/local/bin/';
        my $inputformatfilter = $inputformatfilterpath . $sourcetypemap{$importformat};
        if ( not -f $inputformatfilter ) {
            XIMS::Debug( 3, "Could not find import filter binary $inputformatfilter" );
            $self->sendError( $ctxt, __"Could not find import filter." );
            return 0;
        }


        # write body to temporary file
        my ($tmpfh, $tmpfilename) = tempfile();
        print $tmpfh $body;

        # convert input file
        my $modsbody;
        eval {
            $modsbody = `$inputformatfilter $tmpfilename`;
        };
        if ( $@ ) {
            XIMS::Debug( 2, "Could not execute '$inputformatfilter $tmpfilename': $@" );
            $self->sendError( $ctxt, __"Could not convert input file." );
            return 0;
        }
        if ( not defined $modsbody ) {
            XIMS::Debug( 2, "Inputformat filter returned empty string" );
            $self->sendError( $ctxt, __"Could not convert input file." );
            return 0;
        }
        else {
            $body = $modsbody;
        }

        if ( not unlink0($tmpfh, $tmpfilename) ) {
            XIMS::Debug( 2, "Could not unlink temporary file." . $!);
        }
    }

    #warn Dumper "modsbody: " . $body;

    my $parser = XML::LibXML->new();
    my $doc;
    eval {
        $doc = $parser->parse_string( $body );
    };
    if ( $@ ) {
        XIMS::Debug( 3, "Could not parse: $@" );
        $self->sendError( $ctxt, __"Could not parse input MODS file." );
        return 0;
    }

    $doc->setEncoding( 'UTF-8' );

    my $root = $doc->documentElement();
    $root->setNamespace('http://www.loc.gov/mods/v3','m',0);
    $root->setNamespace('http://www.ndltd.org/standards/metadata/etdms/1.0/','etd',0);
    $root->setNamespace('http://xims.info/ns/ReferenceLibrary','reflib',0);

    my $titlecallback = sub { my $v = $_[0]->findnodes('m:title')->[0]->textContent();
                              my $s = $_[0]->findnodes('m:subTitle');
                              $v .= '. ' . $s->[0]->textContent() if $s->size;
                              return $v if defined $v; };

    #
    # Set up the MODS -> property mapping
    #
    my %propertymap = (
    # Concat optional subtitles
    title => [ "m:titleInfo", $titlecallback ],
    btitle => [ "m:relatedItem[\@type='host']/m:titleInfo", $titlecallback ],
    date => [ "m:originInfo/m:dateIssued" ],
    chron => [ "" ],
    ssn => [ "" ],
    quarter => [ "" ],
    volume => [ "m:relatedItem[\@type='host']/m:part/m:detail[\@type='volume']/m:number|m:part/m:detail[\@type='volume']/m:number"],
    part => [ "m:relatedItem[\@type='host']/m:part/m:detail[\@type='part']/m:title|m:part/m:detail[\@type='part']/m:title"],
    issue => [ "m:relatedItem[\@type='host']/m:part/m:detail[\@type='issue']/m:number|m:part/m:detail[\@type='issue']/m:number" ],
    spage => [ "m:relatedItem[\@type='host']/m:part/m:extent[\@unit='page']/m:start|m:relatedItem[\@type='host']/m:part/m:detail[\@type='page']/m:number|m:part/m:extent[\@unit='page']/m:start|m:part/m:detail[\@type='page']/m:number", sub { my $v = $_[0]->textContent(); $v =~ /^(\d+)\-?/; return $1 } ],
    epage => [ "m:relatedItem[\@type='host']/m:part/m:extent[\@unit='page']/m:end|m:relatedItem[\@type='host']/m:part/m:detail[\@type='page']/m:number|m:part/m:extent[\@unit='page']/m:end|m:part/m:detail[\@type='page']/m:number", sub { my $v = $_[0]->textContent(); $v =~ /\-?(\d+)$/; return $1 } ],
    pages => [ "" ],
    artnum => [ "" ],
    isbn => [ "m:identifier[\@type='isbn']" ],
    coden =>[ "m:identifier[\@type='coden']" ],
    sici => [ "m:identifier[\@type='sici']" ],
    place => [ "m:originInfo/m:place/m:placeTerm" ],
    pub => [ "m:originInfo/m:publisher" ],
    edition => [ "m:originInfo/m:edition" ],
    tpages => [ "m:relatedItem[\@type='host']/m:part/m:extent[\@unit='page']/m:total|m:part/m:extent[\@unit='page']/m:total", sub { my $v = $_[0]->textContent(); $v =~ /\-?(\d+)$/; return $1 } ],
    series => [ "" ],
    issn => [ "m:identifier[\@type='issn']" ],
    bici => [ "m:identifier[\@type='bici']" ],
    co => [ "" ],
    inst => [ "" ],
    advisor => [ "" ],
    degree => [ "etd:degree/etd:name" ],
    identifier => [ "m:identifier[\@type='oai' or \@type='doi']" ],
    preprint_identifier => [ "m:relatedItem[\@type='otherVersion']/m:identifier[\@type='preprint']" ],
    status => [ "m:status" ],
    conf_venue => [ "m:relatedItem[\@type='host']/m:location/m:physicalLocation|m:relatedItem[\@type='host']/m:originInfo/m:place/m:placeTerm" ],
    conf_date => [ "m:relatedItem[\@type='host']/m:part/m:date" ],
    conf_title => [ "m:relatedItem[\@type='host']/m:titleInfo", $titlecallback ],
    conf_sponsor => [ "" ],
    conf_url => [ "" ],
    url => [ "m:location/m:url[\@displayLabel!='Alternative Version']" ],
    url2 => [ "m:location/m:url[\@displayLabel='Alternative Version']" ],
    access_timestamp => [ "" ],
    citekey => [ "m:identifier[\@type='citekey']" ],
    workgroup => [ "reflib:workgroup" ],
    project => [ "reflib:project" ],
    thesis_inprocess => [ "reflib:thesis_inprocess" ],
    quality_criterion => [ "reflib:quality_criterion" ],
                  );

    my %genremapping = ( periodical => 'Article',
                        book => 'Book',
                        "conference publication" => 'Proceeding',
                        report => 'Report',
                        eprint => 'Preprint',
                        preprint => 'Preprint',
                        theses => 'Dissertation' );

    my $modsimported = 0;

    foreach my $mods ( $root->findnodes("/m:modsCollection/m:mods") ) {
        my $title = XIMS::clean( XIMS::nodevalue( $mods->findnodes( "m:titleInfo/m:title" ) ) );
        # In case of genre 'Book', the book's title will be there to find:
        $title ||= XIMS::clean( XIMS::nodevalue( $mods->findnodes( "m:relatedItem[\@type='host']/m:titleInfo/m:title" ) ) );
        next unless defined $title;

        # Which Genre are we on?
        my $genre = XIMS::clean( XIMS::nodevalue( $mods->findnodes( "m:relatedItem[\@type='host']/m:genre[\@authority='marc']" ) ) );
        $genre ||= XIMS::clean( XIMS::nodevalue( $mods->findnodes( "m:genre" ) ) );
        if ( exists $genremapping{$genre} ) {
            $genre = $genremapping{$genre};
        }
        $genre ||= 'Document'; # Our fallback genre
        XIMS::Debug( 4, "Genre is $genre" );

        # Handle authors and editors
        my @authors;
        my @editors;
        foreach my $authorn ( $mods->findnodes("m:name") ) {
            my $lastname = XIMS::clean( XIMS::nodevalue( $authorn->findnodes("m:namePart[\@type='family']") ) );
            next unless ( defined $lastname and length $lastname );
            my $firstname = XIMS::clean( XIMS::nodevalue( $authorn->findnodes("m:namePart[\@type='given' and position() = 1]") ) );
            my $middlename = XIMS::clean( XIMS::nodevalue( $authorn->findnodes("m:namePart[\@type='given' and position() = 2]") ) );
            $middlename = '' unless defined $middlename;
            my $role = XIMS::clean( XIMS::nodevalue( $authorn->findnodes("m:role/m:roleTerm[\@authority='marcrelator' and \@type='text']") ) );

            my $vlibauthor = XIMS::VLibAuthor->new( lastname => XIMS::escapewildcard( $lastname ),
                                                    middlename => $middlename,
                                                    firstname => $firstname,
                                                    document_id => $ctxt->object->document_id,
                                                    );
            if ( not (defined $vlibauthor and $vlibauthor->id) ) {
                $vlibauthor = XIMS::VLibAuthor->new();
                $vlibauthor->lastname( $lastname );
                $vlibauthor->middlename( $middlename ) if ( defined $middlename and length $middlename );
                $vlibauthor->firstname( $firstname ) if ( defined $firstname and length $firstname );
                $vlibauthor->document_id( $ctxt->object->document_id );
                if ( not $vlibauthor->create() ) {
                    XIMS::Debug( 3, "Could not create VLibauthor $lastname" );
                    next;
                }
                else {
                    XIMS::Debug( 4, "Created VLibauthor $lastname" );
                }
            }
            if ( $role eq 'author' ) {
                push( @authors, $vlibauthor );
            }
            elsif ( $role eq 'editor' ) {
                push( @editors, $vlibauthor );
            }
        }

        # Handle properties
        my %propertyvalues;
        foreach my $propertyn ( sort keys %propertymap ) {
            next unless length $propertymap{$propertyn}->[0];
            my $node = $mods->findnodes( $propertymap{$propertyn}->[0] );
            next unless $node->size;
            if ( defined $propertymap{$propertyn}->[1] ) {
                $propertyvalues{$propertyn} = XIMS::clean( $propertymap{$propertyn}->[1]( $node->shift ) );
            }
            else {
                $propertyvalues{$propertyn} = XIMS::clean( XIMS::nodevalue( $node->shift ) );
            }
        }
        # In case of genre 'Book' btitle is title...
        $propertyvalues{title} ||= $title;

        # Create the object
        my $object = XIMS::ReferenceLibraryItem->new( User => $ctxt->session->user );
        my $reference_type = XIMS::RefLibReferenceType->new( name => $genre );
        if ( defined $reference_type ) {
            my $reference = XIMS::RefLibReference->new->data( reference_type_id => $reference_type->id() );
            $object->reference( $reference );

            my $importer = XIMS::Importer::Object::ReferenceLibraryItem->new( User => $ctxt->session->user(), Parent => $ctxt->object() );
            my $identifier = XIMS::trim( scalar $self->param( 'identifier' ) );
            if ( defined $identifier and defined $propertyvalues{identifier} and not $importer->check_duplicate_identifier( $propertyvalues{identifier} ) ) {
                XIMS::Debug( 3, "Reference with the same identifier already exists." );
                next;
            }
            $object->location( 'dummy.xml' );
            if ( $importer->import( $object ) ) {
                XIMS::Debug( 4, "Import of ReferenceLibraryItem successful." );
                $object->location( $object->document_id() . '.' . $object->data_format->suffix());
                $reference->document_id( $object->document_id() );
                if ( $reference->create() ) {
                    XIMS::Debug( 4, "Successfully created reference object." );
                    $modsimported++;
                }
                else {
                    XIMS::Debug( 4, "Could not create reference object." );
                    next;
                }
            }
            else {
                XIMS::Debug( 4, "Could not import ReferenceLibraryItem" );
                next;
            }
        }
        else {
            XIMS::Debug( 4, "Import of reference $title failed" );
            next;
        }

        # Set abstract
        my $abstract = XIMS::clean( XIMS::nodevalue( $mods->findnodes( "m:abstract" ) ) );
        $object->abstract( substr($abstract,0,2000) ) if ( defined $abstract and length $abstract );

        # Store the properties
        foreach my $property ( $object->property_list() ) {
            #print $property->name() . ": " . $propertyvalues{ $property->name() } . "<br/>";

            my $value = $propertyvalues{ $property->name() };
            next unless defined $value;

            my $reflibpropval = XIMS::RefLibReferencePropertyValue->new->data( property_id => $property->id(),
                                                                               reference_id => $object->reference->id(),
                                                                               value => $value );
            if ( not $reflibpropval->create() ) {
                XIMS::Debug( 3, "Could not set value of " .  $property->name() );
            }

            $object->{_title} = $value if $property->name() eq 'title';
            $object->{_date} = $value if $property->name() eq 'date';
        }

        # Associate authors and editors
        $object->vleauthors( @authors ) if scalar @authors;
        $object->vleeditors( @editors ) if scalar @editors;

        # Associate serial publication if volume and btitle properties have values and we are dealing with an Article
        if ( $genre eq 'Article' and defined $propertyvalues{'volume'} and length $propertyvalues{'volume'} and defined $propertyvalues{'btitle'} and length $propertyvalues{'btitle'} ) {
            my $serial = XIMS::RefLibSerial->new( title => XIMS::escapewildcard( $propertyvalues{'btitle'} ) );
            if ( not defined $serial ) {
                $serial = XIMS::RefLibSerial->new->data( title => $propertyvalues{'btitle'} );
                if ( not $serial->create() ) {
                    XIMS::Debug( 4, "Could not create serial " . $propertyvalues{'btitle'} );
                }
            }
            if ( not $object->vleserial( $serial ) ) {
                XIMS::Debug( 4, "Could not assign serial " . $serial->title() );
            }
        }

        # Update title
        $object->update_title( $object->{_date}, $object->{_title}, @authors );

        # Store back
        if ( not $object->update() ) {
            XIMS::Debug( 2, "updating of import object failed" );
        }

        XIMS::Debug( 4, "Imported $genre " . $object->title );
    }

    $ctxt->properties->application->style( 'import_result' );
    #    my %message = (
    #                   i18nkey => 'reflib_importresult',
    #                   data => [ $modsimported, $root->findvalue( 'count(/m:modsCollection/m:mods)' ) ],
    #                  );

    #$ctxt->session->message( \%message  );

    $ctxt->session->message(
        __x("Imported {num_imported} of {num_total} items",
            num_imported => $modsimported,
            num_total => $root->findvalue('count(/m:modsCollection/m:mods)')
        )
    );

    return 0;
}

=head2 event_authors()

=cut

sub event_authors {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style( "authors" );

    return 0;
}

=head2 event_author()

=cut

sub event_author {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $authorid = $self->param('author_id');
    unless ( $authorid ) {
        my $authorfirstname  = $self->param('author_firstname');
        my $authormiddlename = $self->param('author_middlename');
        my $authorlastname   = $self->param('author_lastname');

        my $author;
        my $author_type;
        if ( $authorlastname and $authorfirstname ) {
            XIMS::Debug( 4, "high chance for personal author" );
            $author = XIMS::VLibAuthor->new( firstname   => $authorfirstname,
                                             middlename  => $authormiddlename,
                                             lastname    => $authorlastname,
                                             document_id => $ctxt->object->document_id,);
            if ( $author and $author->id() ) {
                $author_type = "personal";
            }
        }

        unless ( $author_type ) {
            if ( $authorlastname ) {
                XIMS::Debug( 4, "high chance for corporate author" );
                $author = XIMS::VLibAuthor->new( lastname    => $authorlastname,
                                                 object_type => 1,
                                                 document_id => $ctxt->object->document_id,);
                if ( $author and $author->id() ) {
                    $author_type = "corporate";
                }
            }
            else { return 0; }
        }

        if ( $author_type ) {
            $authorid = $author->id();
        }
        else { return 0; }
    }

    $ctxt->properties->content->getformatsandtypes( 1 );

    my @objects = $ctxt->object->vlitems_byauthor_granted(  author_id => $authorid,
                                                            order => 'title'
                                                 );
    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style( "objectlist" ) ;

    return 0;
}

=head2 event_publish_prompt()

=cut

sub event_publish_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

    $ctxt->properties->application->styleprefix('common_publish');
    $ctxt->properties->application->style('prompt');

    return 0;
}

=head2 event_publish()

=cut

sub event_publish {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->publish_gopublic( @_ );
}

=head2 event_unpublish()

=cut

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->unpublish_gopublic( @_ );
}


# END RUNTIME EVENTS
# #############################################################################
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

