
=head1 NAME

XIMS::Exporter -- holds the base classes for the filesystem export

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Exporter;

=head1 DESCRIPTION

This module holds the base classes required for the filesystem
export.  these classes are ment to be loaded for any export
done. Because of this the classes are bundled together in a single
module. I think this reduces loading time, since the code is loaded
all at the same time.

the exporter has a simple concept:
it exports every object to an outputsystem if it can find a
specialized output class.

the exporter wraps the following structure for the calling application:

 +------------------------------------------------------+
 |                XIMS::Exporter::OT                    |
 |       (where OT is the special object type)          |
 | +---------+ +--------+ +------+ +--------------+     |
 | |   XML   | | Binary | | Link | | FS_Container | ... |
 | +---------+ +--------+ +------+ +--------------+     |
 +------------------------------------------------------+
                         ||
                         \/
 +------------------------------------------------------+
 |                XIMS::Exporter::Output                |
 |                 (not implemented yet)                |
 +------------------------------------------------------+

commonly a specialized exporter class specifies only which of type
data it has to be exported. on this for XML data and Container, the
specialized Exporter class may define, which filters to use (in case
of XML data) or how to handle any extra data (meta data, extra
definitions etc.) in case of Containers.

[MORE EXPLAINATIONS]
as the schema shows, XIMS::Exporter knows 4 basic types of data to
export: XML, Binary data, Links and filesystem containers.  the XML
class implements the same algorithm as XIMS::CGI::getDOM(), so one
can specifiy any special filters to use in the specialized class.

in future implementations the XIMS::Exporter will use an abstract
output layer to hide special output systems. This should make it
possible to have make use of XIMS in different presentation
environments (e.g. parts of the system may run with DAV, some parts
may be localy installed others may only be reached by SOAP/XMLRPC or
ssh. the output layer should hide this information from the
exporter.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Exporter;

use common::sense;

use XIMS;
use XIMS::SAX;
use XML::LibXML::SAX::Builder;
use XML::LibXSLT;

use IO::File;
#use Data::Dumper;

use XIMS::Object; # just to be failsafe




=head2 new()

=head3 Parameter

    $param{Provider} : the xims dataprovider. (optional, may be set in
                       publish/unpublish)

    $param{Basedir} : the base directory for filesystem export (optional, may
                      be set in publish/unpublish)

    $param{Stylesheet} : a xsl stylesheet used to generate exported DOMS
                         (optional, may be set in publish/unpublish)

=head3 Returns

    $self : exporter class

=head3 Description

    $exporter = XIMS::Exporter->new( %param );

Constructor of the XIMS::Exporter. It creates the Exporter Class and
initialises it.

the provider option is required to toggle the publishing state of the
processed object and to allow XIMS::SAX to fetch additional information from
the database.

the mandatory basedir option marks the root directory for all exported files.
This directory is added to all relative application paths.

=cut

sub new {
    XIMS::Debug( 5, "called" );

    my $class = shift;
    my %param = @_;
    my %data;

    $data{Provider}   = $param{Provider}   if defined $param{Provider};
    $data{Provider} ||= XIMS::DATAPROVIDER();
    $data{Basedir}    = $param{Basedir}    if defined $param{Basedir};
    $data{Stylesheet} = $param{Stylesheet} if defined $param{Stylesheet};
    $data{User}       = $param{User}       if defined $param{User};

    my $self = bless \%data, $class;

    return $self;
}



=head2    publish()

=head3 Parameter

    $param{Object} : the object to be processed (mandatory)
    $param{Basedir}    : the base directory for filesystem export
                         (optional, may be set in constructor)
    $param{Stylesheet} : a xsl stylesheet used to generate exported DOMS
                         (optional, may be set in constructor)

=head3 Returns

    $retval : undef on error

=head3 Description

$boolean = $exporter->publish( %param );

Handles the create sequence of the exporter.

=cut

sub publish {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    unless ( $param{Object} ) {
        XIMS::Debug( 3, "No object to publish!" );
        return;
    }
    my $object          = delete $param{Object};

    # allow developer-friendly method invocation...
    $self->{Provider}   = delete $param{Provider}   if defined $param{Provider};
    $self->{Basedir}    = delete $param{Basedir}    if defined $param{Basedir};
    $self->{User}       = delete $param{User}       if defined $param{User};

    my $forceancestorpublish;
    $forceancestorpublish = delete $param{force_ancestor_publish} if defined $param{force_ancestor_publish};

    # since it is likely that one Exporter instance should publish objects of different
    # object type we have to let the helper select the appropiate stylesheet
    # for each single object unless it is overridden with $param{Stylesheet};
    $self->{Stylesheet} = defined $param{Stylesheet} ? delete $param{Stylesheet} : undef;

    # anything left in the %param hash is considered an option to be forwarded
    # from the outside to the handler...
    my %options = %param;

    # ...but do a sanity-check
    unless ( defined $self->{Provider} and defined $self->{Basedir} ) {
        XIMS::Debug( 2, "Insufficient parameters for publishing, Basedir needed!" );
        return;
    }

    my $helper = XIMS::Exporter::Helper->new();
    $self->{Stylesheet} ||= $helper->stylesheet( $object );

    # build the object processor based on the object_type
    my $handler = $helper->exporterclass(
                                       Provider   => $self->{Provider},
                                       Basedir    => $self->{Basedir},
                                       Stylesheet => $self->{Stylesheet},
                                       User       => $self->{User},
                                       Object     => $object,
                                       Options    => \%options,
                                       );
    return unless $handler;

    # handle any ancestors, create folders where needed.
    #
    # first the exporter has to approve which object we have to deal with.
    # this is very important for nested data structures:
    #
    # if an object has not a parentlist containing only fs_container,
    # XIMS::Exporter must not export that object since that one exists
    # somewhere else.
    #
    # how to handle this is left to the application. the exporter will
    # only indicate an error.
    #
    if ( $handler->test_ancestors() ) {
        my $added_path = '';
        if (scalar @{$handler->{Ancestors}} > 0) {
            my $last_path = '';
            foreach my $ancestor ( @{$handler->{Ancestors}} ) {

                $added_path .= '/' . $ancestor->location;

                # since we don't want autoindexes to be rewritten automatically,
                # we create only unpublished ancestors
                if ( not($ancestor->published()) or defined $forceancestorpublish and $ancestor->published() ) {
                    XIMS::Debug( 4, "Creating ancestor container." );
                    my $anc_handler = $helper->exporterclass(
                                                     Provider   => $self->{Provider},
                                                     Basedir    => $handler->{Basedir} . $last_path,
                                                     User       => $self->{User},
                                                     Object     => $ancestor,
                                                     Options    => {norecurse => 1}
                                                    );
                    return unless $anc_handler;

                    my %options;
                    $options{mkdironly} = 1 if defined $forceancestorpublish;

                    $anc_handler->create( %options );
                }   # end if ancestor not published
                $last_path = $added_path;
            }   # end foreach ancestor

        }

        # publish the object itself
        $handler->{Basedir} .= $added_path;
    }

    my $retval = $handler->create();
    if ( $retval and not defined $param{no_dependencies_update} ) {
        $self->update_dependencies( handler => $handler );
    }

    return $retval;
}



=head2    unpublish()

=head3 Parameter

    $param{Object} : the object to be processed (mandatory)

=head3 Returns

    $retval : undef on error

=head3 Description

$bool = $exporter->unpublish( %param )

handles the remove sequence of XIMS::Exporter

=cut

sub unpublish {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    unless ( $param{Object} ) {
        XIMS::Debug( 3, "No object to unpublish!" );
        return;
    }

    # allow developer-friendly method invocation...
    $self->{Provider}   = delete $param{Provider}   if defined $param{Provider};
    $self->{Basedir}    = delete $param{Basedir}    if defined $param{Basedir};
    $self->{User}       = delete $param{User}       if defined $param{User};
    my $object          = delete $param{Object};

    # anything left in the %param hash is considered an option to be forwarded
    # from the outside to the handler...
    my %options = %param;

    # ...but do a sanity-check
    unless ( defined $self->{Provider} and defined $self->{Basedir} ) {
        XIMS::Debug( 2, "Insufficient parameters for publishing, Basedir needed!" );
        return;
    }

    # build the object processor based on the object_type
    my $helper = XIMS::Exporter::Helper->new();
    my $handler = $helper->exporterclass(
                                       Provider   => $self->{Provider},
                                       Basedir    => $self->{Basedir},
                                       Stylesheet => $self->{Stylesheet},
                                       User       => $self->{User},
                                       Object     => $object,
                                       Options    => \%options,
                                       );
    return unless $handler;

    #
    # the unpublish function will remove only real objects from the
    # output system. a real object is one, that has only FS_container
    # as ancestors.
    #
    if ( $handler->test_ancestors() ) {
        # handle any ancestors
        my $added_path = '';
        if (scalar @{$handler->{Ancestors}} > 0) {
            # phish: i wonder if not all ancestors must be recreated to get rid off stale
            #        links (e.g. for auto_indexer!).
            my $last_path = '';
            foreach my $ancestor ( @{$handler->{Ancestors}} ) {
                next unless $ancestor->object_type->is_fs_container();
                $added_path .= '/' . $ancestor->location;

                # pepl: huh!!!!????
                next; # remove this line if all ancestors will be recreated

                XIMS::Debug( 4, "reCreating ancestor container." );
                my $anc_handler = $helper->exporterclass(
                                             Provider   => $self->{Provider},
                                             Basedir    => $handler->{Basedir} . $last_path,
                                             User       => $self->{User},
                                             Object     => $ancestor,
                                             Options    => {norecurse => 1}
                                            );
                return unless $anc_handler;

                $anc_handler->create(); # should stop here on error ... !?
                $last_path = $added_path;
            }
        }
        $handler->{Basedir} .= $added_path;
    }

    my $retval = $handler->remove();
    if ( $retval and not defined $param{no_dependencies_update} ) {
        $self->update_dependencies( handler => $handler );
    }
    return $retval;
}



=head2   update_dependencies()

=head3 Parameter

   $params{handler}    : The exporter handler instance.

=head3 Description

$exporter->update_dependencies( %params );

This method (un)publishes related and/or depending objects. For this
it calls

* update_related()

  - (Re)publishes objects that are referred to by image_id, style_id, feed_id,
    or css_id. If that objects are not published yet, they will be published.

  - Republishes published objects referred to by symname_to_doc_id (Portlets and
    Symlinks) of of the object or its ancestors

* update_parent()

  updates autoindex, container.xml of parent

=cut

sub update_dependencies {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %params = @_;

    my $handler = $params{handler};

    $handler->update_related();
    $handler->update_parent() unless $handler->{Object}{_cached_parent_id} == 1;
}

1;

=head1 XIMS::Exporter::Helper

=cut

package XIMS::Exporter::Helper;


sub new {
   my $class = shift;
   my %args = @_;
   return bless (\%args, $class);
}

sub stylesheet {
    my ($self, $object) = @_;
    my $stylename = lc( $object->object_type->fullname() );
    $stylename =~ s/::/_/;

    my $stylefilename = 'export_' . $stylename . '.xsl';
    my $stylesheetfile;

    # Check for a custom export stylesheet in an assigned stylesheet folder
    my $stylesheet = $object->stylesheet();
    if ( defined $stylesheet and $stylesheet->published() ) {
        XIMS::Debug( 4, "Checking for custom export stylesheet from assigned folder" );
        my $pubstylepath = XIMS::PUBROOT() . $stylesheet->location_path() . '/' . $stylefilename;
         if ( -f $pubstylepath and -r $pubstylepath ) {
                XIMS::Debug( 4, "Using custom export stylesheet '$pubstylepath'" );
                $stylesheetfile = $pubstylepath;
         }
    }
    # Use default export stylesheet if there is no custom one
    if ( not defined $stylesheetfile )  {
        $stylesheetfile = XIMS::XIMSROOT() . '/stylesheets/exporter/' . $stylefilename;
    }
    return $stylesheetfile;
}

sub classname {
    my ($self, $object) = @_;
    my $classname = 'XIMS::Exporter::' . $object->object_type->fullname();

    return $classname;
}

sub exporterclass {
    my $self = shift;
    my %args = @_;

    my $object = $args{Object};
    return unless $object;

    my $exporter_class = $self->classname( $object );

    my $exporter;
    ## no critic (ProhibitStringyEval)
    eval {
        $exporter = $exporter_class->new( %args );
    };
    if ( $@ ) {
        eval "require $exporter_class;";
        if ( $@ ) {
            XIMS::Debug( 2, "could not not load exporter class: $@" );
            return;
        }
        $exporter = $exporter_class->new( %args );
    }
    ## use critic
    return $exporter;
}

1;


=head1 XIMS::Exporter::Handler

this package is the base class for folder and object!!!

=cut

package XIMS::Exporter::Handler;

use XIMS::AppContext;



=head2    new()

=head3 Parameter

    $param{Object}     : the object being synch'd
    $param{Provider}   : the dataprovider instance
    $param{Stylesheet} : the stylesheet used for DOM export
    $param{Basedir}    : the rootdirectory for the exported data.

=head3 Returns

    $self : the Exporter Object Handler Class

=head3 Description

$object = XIMS::Exporter::Handler->new( %param );

The XIMS::Exporter::Handler class provides the common functions of
XIMS::Exporter::Object and XIMS::Exporter::Folder. One of them is
the class constructor.

ubu-note: every handler is now atomic in the sense that each handler
gets its own object.

=cut

sub new {
    XIMS::Debug( 5, "called" );
    my $class = shift;
    my %param = @_;

    my $self = bless {}, $class;

    $self->{Provider}    = $param{Provider}       if defined $param{Provider};
    $self->{Stylesheet}  = $param{Stylesheet}     if defined $param{Stylesheet};
    $self->{Object}      = $param{Object}         if defined $param{Object};
    $self->{User}        = $param{User}           if defined $param{User};
    $self->{Exportfile}  = $param{exportfilename} if defined $param{exportfilename};
    $self->{Options}     = $param{Options} || {};
    $self->{AppContext}  = XIMS::AppContext->new();
    my $bdir;
    $bdir                = $param{Basedir}        if defined $param{Basedir};
    $self->{Ancestors}   = $param{Ancestors}      if defined $param{Ancestors};

    if ( defined $bdir and -d $bdir ) {
        XIMS::Debug( 4, "export directory '$bdir' exists" );
        if ( -r $bdir and -w $bdir and -x $bdir ) {
            # ok, the base directory is ok
            XIMS::Debug( 4, "export directory has correct permissions" );
            $self->{Basedir} = $bdir;
        }
        else {
            XIMS::Debug( 2, "access to export directory $bdir denied!" );
            return;
        }
    }
    elsif ( defined $bdir and not -d $bdir ) {
        XIMS::Debug( 2, "export directory does not exist -> " . $bdir );
        return;
    }

    # for recursion...
    my $helper = XIMS::Exporter::Helper->new();
    $self->{Stylesheet} ||= $helper->stylesheet( $self->{Object} );

    # ancestors
    if ( not defined $self->{Ancestors} ) {
        # >> do we really need to load all the full ancestor object data? <<
        my $cachekey = $self->{Object}->parent_id();
        my $ancestors;
        if ( defined $self->{Provider}->{ocache}->{ancs}->{$cachekey} ) {
            $ancestors = $self->{Provider}->{ocache}->{ancs}->{$cachekey};
        }
        else {
            $ancestors = $self->{Object}->ancestors();
            # remove /root
            shift @{$ancestors};
            $self->{Provider}->{ocache}->{ancs}->{$cachekey} = $ancestors;
        }
        $self->{Ancestors} = $ancestors;
    }

    my @keys = ( $self->{Object}->id(), $self->{User}->id(), 'nfst' );
    my $cachekey = join('.', @keys);
    if ( defined $self->{Provider}->{ocache}->{kids}->{$cachekey} ) {
        $self->{Children} = $self->{Provider}->{ocache}->{kids}->{$cachekey};
    }
    else {
        # publish only non-fs-container children here
        my @non_fscont_types = map { $_->id() } grep { $_->is_fs_container == 0 }  values %{ XIMS::OBJECT_TYPES() };
        my @children = $self->{Object}->children_granted( User => $self->{User}, object_type_id => \@non_fscont_types, published => 1 );
        $self->{Children} = $self->{Provider}->{ocache}->{kids}->{$cachekey} = \@children;
    }

    return $self;
}



=head2    toggle_publish_state()

=head3 Parameter

    $state: '0' or '1'.

=head3 Returns

    nothing

=head3 Description

$self->toggle_publish_state( $state );

This helper function is only used to change the publish state of an
object. For this a temporary Object is created, to avoid overriding
existing information without notice or intention.

The method is called be the exporter, after the creation or
removement has done.

=cut

sub toggle_publish_state {
    XIMS::Debug( 5, "called" );
    my ( $self, $state ) = @_;
    $state ||= '0'; # perl's "0 is undef" weirdness.

    if ( $state eq '0' ) {
        return $self->{Object}->unpublish( User => $self->{User} );
    }
    else {
        if ( $self->{Options} and ref $self->{Options} and exists $self->{Options}->{no_pubber} ) {
            return $self->{Object}->publish( User => $self->{User}, no_pubber => 1 );
        }
        else {
            return $self->{Object}->publish( User => $self->{User} );
        }
    }
}

sub create { return; }

sub update { return; }



=head2    remove()

=head3 Parameter

    none: handled via properites

=head3 Returns

    $retval : undef on error

=head3 Description

$self->remove();

=cut

sub remove {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;
    my $object = $param{Object};

    my $dead_file = $self->{Exportfile} || $self->{Basedir} . '/' . $self->{Object}->location;

    # -w is false for broken symlinks
    unless ( -w $dead_file or -l $dead_file ) {
        XIMS::Debug( 2, "Cannot remove filesystem object '$dead_file'. File does not exist." );

        # if the current object is not a FS object, we must mark it as
        # unpublished here.
        $self->toggle_publish_state( '0' ) unless $self->test_ancestors();

        return;
    }


    XIMS::Debug( 4, "trying to remove $dead_file" );

    # delete the item
    eval {
        unlink $dead_file || die $!;
    };

    if ( $@ ) {
        my $err = $@;
        XIMS::Debug( 2, "Cannot remove filesystem object '$dead_file': $err" );
        return;
    }

    # mark the document as published
    XIMS::Debug( 4, "toggling publish state of the object" );
    $self->toggle_publish_state( '0' );

    return 1;
}




=head2    test_ancestors()

=head3 Parameter

    none: handled via properties

=head3 Returns

    $retval : undef on failure

=head3 Description

$errcode = $self->test_ancestors();

commonly an object will be published to the output system. only
if one ancestor is *not* a fs_container this should be
denied. This function tests if a certain object should be
created.

=cut

sub test_ancestors {
    my $self = shift;
    my $retval = undef;

    # is this really needed?
    if ( defined $self->{Ancestors} and scalar @{ $self->{Ancestors} } ) {
        # the following line is safe since we have at least two OTs by default
        my %types = map { $_->id() => 1 } $self->{Provider}->object_types( is_fs_container => 1, properties => [qw(id)] );
        my @ancestors  = grep { exists $types{$_->object_type_id} } @{$self->{Ancestors}};
        if ( scalar( @ancestors ) == scalar(  @{ $self->{Ancestors} } ) ) {
            #
            # the function returns TRUE only if all ancestors are FS container
            #
            $retval = 1;
        }
    }

    return $retval;
}


=head2    update_related()

=head3 Parameter

    none

=head3 Returns

    $boolean : True or False for updating related objects

=head3 Description

my $boolean = $self->update_related();

- (Re)publishes objects that are referred to by image_id, style_id, or css_id.
If that objects are not published yet, they will be published.
- Republishes published objects referred to by symname_to_doc_id (Portlets
and Symlinks) of of the object or its ancestors - Republishes Documents if
current object is a DocumentLink

=cut

sub update_related {
    XIMS::Debug( 5, "called" );
    my ( $self, %params ) = @_;

    my $object = $self->{Object};
    my $helper = XIMS::Exporter::Helper->new();

    my $stylesheet = $object->stylesheet( explicit => 1 );
    my $css        = $object->css( explicit => 1 );
    my $image      = $object->image( explicit => 1 );
    my $feed      = $object->feed( explicit => 1 );

    my @referenced_by = $object->referenced_by_granted( User => $self->{User}, include_ancestors => 1, published => 1 );

    # Check for a DocumentLink and republish the corresponding Document (Parent)
    if ( $object->object_type->name() eq 'URLLink' ) {
        my $parent_mime_type = $object->parent->data_format->mime_type();
        if ( $parent_mime_type ne 'application/x-container' ) {
            push( @referenced_by, $object->parent() );
        }
    }

    foreach my $obj ( @referenced_by, $image, $css, $stylesheet, $feed ) {
        next unless defined $obj;
        my $base = XIMS::PUBROOT() . $obj->location_path();
        my $basedir = $base;
        $basedir =~ s#/[^/]+$##;
        my $obj_handler = $helper->exporterclass(
                                            Provider       => $self->{Provider},
                                            exportfilename => $base,
                                            User           => $self->{User},
                                            Object         => $obj,
                                            Basedir        => $basedir,
                                          );
        return unless $obj_handler;

        # check if the object's ancestors are published # '
        if ( $obj_handler->test_ancestors() ) {
            foreach my $ancestor ( reverse @{$obj_handler->{Ancestors}} ) {
                last if $ancestor->published();
                XIMS::Debug( 4, "Creating ancestor container" );
                my $anc_filename = XIMS::PUBROOT() . $ancestor->location_path();
                my $anc_dir = $anc_filename;
                $anc_dir =~ s#/[^/]+$##;

                # pop and pass ancestors so that they do not get looked up again
                pop @{$obj_handler->{Ancestors}};
                my $anc_handler = $helper->exporterclass(
                                                 Provider       => $self->{Provider},
                                                 exportfilename => $anc_filename,
                                                 User           => $self->{User},
                                                 Object         => $ancestor,
                                                 Basedir        => $anc_dir,
                                                 Options        => {norecurse => 1},
                                                 Ancestors      => $obj_handler->{Ancestors}
                                                );
                unless ( $anc_handler and $anc_handler->create() ) {
                    XIMS::Debug( 2, "Ancestor of '" . $object->title() .  "' could not be published!" );
                    last;
                }
            }
        }

        if ( $obj_handler->create( ) ) {
            XIMS::Debug( 4, "Related object published" );
            XIMS::Debug( 6, "Related object was " . $obj->location_path() );
        }
        else {
            XIMS::Debug( 3, "Related object '" . $obj->location_path() . "' could not be published" );
        }
    }
    return 1;
}



=head2  update_parent()

=head3 Parameter

    none

=head3 Returns

    $boolean : True or False for updating the parent

=head3 Description

my $boolean = $self->update_parent();

Updates the autoindex and container.xml of the parent object

=cut

sub update_parent {
    XIMS::Debug( 5, "called" );
    my ( $self, %params ) = @_;

    my $object = $self->{Object};
    my $parent = $self->{Ancestors}->[-1];

    # check if we got a container object
    return unless $parent->object_type->is_fs_container();

    my $helper = XIMS::Exporter::Helper->new();
    my $base = XIMS::PUBROOT() . $parent->location_path();
    my $basedir = $base;
    $basedir =~ s#/[^/]+$##;
    my $handler = $helper->exporterclass(
                                     Provider       => $self->{Provider},
                                     User           => $self->{User},
                                     Object         => $parent,
                                     Options        => {norecurse => 1},
                                     exportfilename => $base,
                                     Basedir        => $basedir,
                                     Ancestors      => $self->{Ancestors}
                                    );
    unless ( $handler and $handler->create() ) {
        XIMS::Debug( 2, "Parent of '" . $object->title() .  "' could not be republished!" );
        return;
    }

    return 1;
}

1;

=head1 XIMS::Exporter::NULL

the NULL exporter simply toggles the publish state, but do no cause
any output. This exporter is usefull for object types, that need the
publish state on, but have no representation in the filesystem as a
standalone object.

since XIMS::Exporter::NULL will not create any output, this function
must return 'undef', to avoid any parent handling.

=cut

package XIMS::Exporter::NULL;



use common::sense;
use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::Handler );

sub test_ancestors {
    return;
}

sub create {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    return $self->toggle_publish_state( '1' );

}

sub remove {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    return $self->toggle_publish_state( '0' );
}

1;

=head1 XIMS::Exporter::XMLChunk

abstract class that covers all objects that need to
write/remove XML files to disk.

=cut


package XIMS::Exporter::XMLChunk;


use common::sense;
use vars qw( @ISA );

use XIMS::SAX::Generator::Exporter;
use XIMS::SAX::Filter::ContentIDPathResolver;

@ISA = qw( XIMS::Exporter::Handler );



=head2 create()

=head3 Parameter


=head3 Returns

    $retval : undef on error

=head3 Description

$self->create( %param )

=cut

sub create {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    # generate DOM
    my $raw_dom = $self->generate_dom();

    unless ( $raw_dom ) {
        XIMS::Debug( 3, "no dom created" );
        return;
    }

    # THEN we have to do the transformation of the DOM, as the output should
    # contain using XSL.
    my $transd_dom = $self->transform_dom( $raw_dom );

    unless ( defined $transd_dom ) {
        XIMS::Debug( 3, "transformation failed" );
        return;
    }

    XIMS::Debug( 4, "transformation succeeded" );
    my $document_path = $self->{Exportfile} || $self->{Basedir} . '/' . $self->{Object}->location;

    XIMS::Debug( 4, "trying to write the object to $document_path" );

    my $document_fh = IO::File->new( $document_path, 'w' );

    if ( defined $document_fh ) {
        # Exporter stylesheets generate UTF-8 encoded documents. Make sure
        # that they get written out as such
        binmode( $document_fh, ':encoding(UTF-8)' );

        print $document_fh $transd_dom->toString(1);
        # $transd_dom->toFH($document_fh,1);
        $document_fh->close;
        XIMS::Debug( 4, "document written to $document_path" );
    }
    else {
        XIMS::Debug( 2, "Error writing file '$document_path': $!" );
        return;
    }

    # mark the document as published
    XIMS::Debug( 4, "toggling publish state of the object" );
    $self->toggle_publish_state( '1' ) unless $self->isa('XIMS::Exporter::AutoIndexer');

    return 1;
}




=head2    generate_dom()

=head3 Parameter

    none: uses $self->{Object}. Maybe add params for encoding, stylesheet PIs
    or whatever at some point?

=head3 Returns

    $retval : The objects DOM, undef on error

=head3 Description

$self->generate_dom( %param );

This is a helper function that transforms an object into a DOM
by using XIMS::SAX.

=cut

sub generate_dom {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    my $dom;
    my $object;

    # interface friendliness
    if ( defined $param{Object} ) {
        $object = $param{Object};
    }
    else {
        $object = $self->{Object};
    }

    if ( defined $object ) {
        my $handler = XML::LibXML::SAX::Builder->new();

        my $controller   = undef;
        my @sax_filters = $self->set_sax_filters();

        if ( scalar @sax_filters > 0 ) {
            XIMS::Debug(6, "got filters: " . join(',', @sax_filters) );
            $controller = XIMS::SAX->new( Handler => $handler,
                                          FilterList => \@sax_filters);
            # $controller->set_filterlist( @sax_filters );
        }
        else {
            XIMS::Debug(6, "got no filters" );
            $controller = XIMS::SAX->new( Handler => $handler );
        }


        XIMS::Debug( 2, "no SAX controller!" ) unless $controller; # should never happen.
        my $generator = $self->set_sax_generator();
        $controller->set_generator( $generator );

        my $ctxt = $self->{AppContext};
        $ctxt->object( $object );
        $ctxt->user( $self->{User} );

        # Using $self->{Options}->{appendexportfilters}, child
        # classes can influence the ordering of the SAX-Filter list
        # the controller uses. If set, the filter list the SAX
        # generator returns is prepended to the one the Exporter child
        # classes return via set_filterlist().  Different filter
        # sequences are neccessary for the different needs content
        # expanders like portlet or annotation collectors one the one
        # side, have in relation to body content resolvers on the
        # other side. While the former need to be before
        # XML::Filter::CharacterChunk (set by the generator) in the
        # filter chain to have its expanded content to be parsed as a
        # chunk, the other ones need to be after it to be able to work
        # with the SAX events generated by it.

        $dom = $controller->parse( $ctxt, $self->{Options}->{appendexportfilters} );

        XIMS::Debug( 2, "something went wrong" ) unless $dom;
    }
    else {
        XIMS::Debug( 2, "no object found to export" );
    }

    return $dom;
}

=head2    set_sax_generator()

=head3 Parameter

    none

=head3 Returns

    $retval : instance of XIMS::SAX::Generator::Exporter

=head3 Description

$self->set_sax_generator();

Allows Exporter subclasses to use other SAX Generators than the default
XIMS::SAX::Generator::Exporter

=cut

sub set_sax_generator {
    XIMS::Debug( 5, "called" );
    my $self  = shift;

    return XIMS::SAX::Generator::Exporter->new();
}

=head2    transform_dom()

=head3 Parameter

    $dom: the DOM to be transformed.

=head3 Returns

    $retval : the transformed DOM, undef on error

=head3 Description

$self->transform_dom( $dom );

This is a helper function that transforms a DOM into another one
by using XSLT.

=cut

sub transform_dom {
    XIMS::Debug( 5, "called" );
    my ( $self, $dom ) = @_;

    my $stylesheet = $self->{Stylesheet};
    if ( defined $stylesheet and -f $stylesheet and -r $stylesheet ) {
        my $style;
        my $parser = XML::LibXML->new();
        my $xslt   = XML::LibXSLT->new();

        XIMS::Debug( 4, "filename is $stylesheet" );

        unless ( XIMS::DEBUGLEVEL < 6 and $style = $XIMS::STYLE_CACHE{$stylesheet} ) {
            eval {
                $style = $xslt->parse_stylesheet( $parser->parse_file( $stylesheet ) );
            };
            if( $@ ) {
                XIMS::Debug( 3, "Stylesheet problem:\n $@ \n" );
                return;
            }

            # cache parsed stylesheet
            $XIMS::STYLE_CACHE{$stylesheet} = $style;
        }

        my $transformed_dom;
        eval {
            $transformed_dom = $style->transform( $dom );
        };
        if( $@ ) {
            XIMS::Debug( 3, "Broken Transformation: ". $@ );
            return;
        }
        XIMS::Debug( 4, "Transformation done" );
        return $transformed_dom;
    }
    else {
        #
        # in case no stylesheet file has given the function simply
        # returns the untransformed DOM
        #
        XIMS::Debug( 4, "dom has not been transformed" );
        return $dom;
    }
    return;
}

# default, should be overwritten by classes inheriting from this base class.
sub set_sax_filters {
    XIMS::Debug( 5, "called" );
    my $self  = shift;

    my $filter = XIMS::SAX::Filter::ContentIDPathResolver->new( Provider       => $self->{Provider},
                                                                ResolveContent => [ qw( STYLE_ID SYMNAME_TO_DOC_ID DEPARTMENT_ID ) ]  );

    return ($filter);
}

1;

=head1 XIMS::Exporter::Binary

abstract class that covers all objects that need to write/remove binary/plain
files to disk.

Binary data is everything that is neither XML data, FS Container nor Symbolic
link

=cut

package XIMS::Exporter::Binary;

use common::sense;
use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::Handler );


=head2    create()

=head3 Parameter

    $param{-location} : (mandatory)
    $param{Object}   : (mandatory)

=head3 Returns

    $retval : undef on error

=head3 Description

$self->create( %param );

=cut

sub create {
    XIMS::Debug( 5, "called" );

    my ( $self, %param ) = @_;

    my $document_path =  $self->{Exportfile} || $self->{Basedir} . '/' . $self->{Object}->location;

    XIMS::Debug( 4, "trying to write the object to $document_path" );

    # create the item on disk

    my $document_fh = IO::File->new( $document_path, 'w' );

    if ( defined $document_fh ) {
        binmode( $document_fh, ':raw' );

        # Despite binmode :raw, the virtual utf-8 IO layer will be used
        # This Binary handler may also get utf-8 flagged strings (e.g. XML object type)
        # Encode::_utf8_off will not directly work on $self->{Object}->body but only on copies
        # To save copying or adding more logic, we just disable the IO layer magic by using bytes here... 
        use bytes;
        print $document_fh $self->{Object}->body;
        $document_fh->close;
        no bytes;
        XIMS::Debug( 4, "document written" );
    }
    else {
        XIMS::Debug( 2, "Error writing file '$document_path': $!" );
        return;
    }


    # mark the document as published
    XIMS::Debug( 4, "toggling publish state of the object" );
    $self->toggle_publish_state( '1' );

    my $binmeta_generator =  XIMS::Exporter::BinMeta->new( Provider   => $self->{Provider},
                                                           Basedir    => $self->{Basedir},
                                                           Object     => $self->{Object},
                                                           User       => $self->{User},
                                                           Stylesheet => XIMS::XIMSROOT() . "/stylesheets/exporter/export_binmeta.xsl",
                                                       );

    return $binmeta_generator->create();
}

sub remove {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $binmeta_generator =  XIMS::Exporter::BinMeta->new( Provider   => $self->{Provider},
                                                           Basedir    => $self->{Basedir},
                                                           Object     => $self->{Object},
                                                           User       => $self->{User},
                                                       );
    $binmeta_generator->remove();

    XIMS::Debug( 5, "done" );
    return $self->SUPER::remove( @_ );
}

1;


=head1 XIMS::Exporter::Folder

lowlevel class for folder objs.

=cut

package XIMS::Exporter::Folder;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::XMLChunk );
use File::Path;
use common::sense;



=head2 create()

=head3 Parameter

    $param->{-path}   : (mandatory)
    $param->{-folder} : (mandatory)

=head3 Returns

    $retval : undef on error

=head3 Description

$self->create( $param );

=cut

sub create {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    my $retval;

    my $new_path = $self->{Exportfile} || $self->{Basedir} . "/" . $self->{Object}->location();

    if ( -d $new_path ) {
        XIMS::Debug( 4, "Directory '$new_path' exists, no need to create." );
    }
    else {
        # create new folder.
        XIMS::Debug( 4, "Creating directory '$new_path'" );

        eval {
            mkdir( $new_path, 0755 ) ||  die $!;
        };

        if ( $@ ) {
            my $err = $@;
            XIMS::Debug( 3, "Error creating directory '$new_path': $err" );
            return;
        }
    }

    if ( not exists $param{mkdironly} ) {
        #
        # generate metadata
        #

        # delete children cache so that autoindex and container.xml will be
        # up-to-date
        delete $self->{Provider}->{ocache}->{kids};

        # first, the object DOM
        my $raw_dom = $self->generate_dom();

        unless ( $raw_dom ) {
            XIMS::Debug( 2, "metadata cannot be generated" );
            return;
        }

        # then, transform it...

        my $transd_dom = $self->transform_dom( $raw_dom );

        unless ( $transd_dom ) {
            XIMS::Debug( 2, "transformation failed" );
            return;
        }

        # build the path

        my $meta_path = $new_path . '/' . $self->{Object}->location() . '.container.xml';
        XIMS::Debug( 4, "metadata file is $meta_path" );

        # write the file...
        my $meta_fh = IO::File->new( $meta_path, 'w' );

        if ( defined $meta_fh ) {
            binmode( $meta_fh, ':encoding(UTF-8)' );
            print $meta_fh $transd_dom->toString();
            $meta_fh->close;
            XIMS::Debug( 4, "metadata-dom written" );
        }
        else {
            XIMS::Debug( 2, "Error writing file '$meta_path': $!" );
            return;
        }

        # auto-indexing
        # MUST come after any children were published above since
        # publishing states may have changed in this session.

        my $autoindex = $self->{Object}->attribute_by_key( 'autoindex' );
        # if attribute is not explictly set to 0, we do autoindexing
        if ( not defined $autoindex or $autoindex == 1 ) {
            my $idx_generator =  XIMS::Exporter::AutoIndexer->new( Provider   => $self->{Provider},
                                                                   Basedir    => $self->{Basedir},
                                                                   User       => $self->{User},
                                                                   Object     => $self->{Object},
                                                                   Options    => {norecurse => 1},
                                                                   Ancestors  => $self->{Ancestors},
                                                               );
            $idx_generator->create();
        }
        elsif ( $autoindex == 0 ) {
            my $autoindex_file = $new_path . '/' . XIMS::AUTOINDEXFILENAME();
            eval { unlink $autoindex_file } if -f $autoindex_file;
        }
    }

    # mark the folder as published
    XIMS::Debug( 4, "toggling publish state of the object" );
    $self->toggle_publish_state( '1' );


    return 1;
}

=head2    remove()

=head3 Parameter


=head3 Returns

    $retval : undef on error

=head3 Description

$self->remove();

=cut

sub remove {
    XIMS::Debug( 5, "called" );
    my ( $self, $param ) = @_;

    my $kill_path = $self->{Basedir} . "/" . $self->{Object}->location();

    if ( defined $self->{Children} and scalar @{$self->{Children}} ) {
        my $helper = XIMS::Exporter::Helper->new();
        foreach my $kind ( @{$self->{Children}} ) {
            my $reaper = $helper->exporterclass(
                         Provider   => $self->{Provider},
                         Basedir    => $self->{Basedir} . '/' . $self->{Object}->location,
                         User       => $self->{User},
                         Object     => $kind
                        );
            return unless ($reaper and $reaper->remove());
        }
    }

    # kill the meta file
    unlink $kill_path . '/' . $self->{Object}->location . ".container.xml";

    # kill the autoindex if exists
    if ( -f $kill_path . '/' . XIMS::AUTOINDEXFILENAME() ) {
        unlink $kill_path . '/' . XIMS::AUTOINDEXFILENAME();
    }

    # and now, remove AxKit's stylecache dir...
    if ( -d $kill_path . '/.xmlstyle_cache' ) {
        eval {
            File::Path::rmtree( $kill_path . '/.xmlstyle_cache' ) || die $!;
        };
        if ( $@ ) {
            my $err = $@;
            XIMS::Debug( 2, "Error deleting cach dir: $err" );
        }
    }

    # finally, drop the dir.
    rmdir( $kill_path ) || do { XIMS::Debug( 2, "can't remove directory '$kill_path' " . $! ); return; };


    # mark the folder as not published.
    XIMS::Debug( 4, "marking folder as unpublished again :)" );
    $self->toggle_publish_state( '0' );

    return 1;
}

1;

=head1  XIMS::Exporter::Document

lowlevel class for document objs.

=cut

package XIMS::Exporter::Document;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::XMLChunk );

use XIMS::SAX::Filter::ContentIDPathResolver;
use XIMS::SAX::Filter::Attributes;


=head2   remove()

=head3 Parameter


=head3 Returns

    $retval : undef on error

=head3 Description

$self->remove();

=cut

sub remove {
    XIMS::Debug( 5, "called" );
    my ( $self, $param ) = @_;

    # unpublish all document links
    if ( defined $self->{Children} and scalar @{$self->{Children}} ) {
        my $helper = XIMS::Exporter::Helper->new();
        foreach my $kind ( @{$self->{Children}} ) {
            next unless $kind->object_type->name eq 'URLLink';
            my $reaper = $helper->exporterclass(
                                          Provider   => $self->{Provider},
                                          User       => $self->{User},
                                          Object     => $kind
                                        );
            return unless ($reaper and $reaper->remove());
        }
    }

    return $self->SUPER::remove();
}



=head2    set_sax_filters()

=head3 Parameter

    @parameter: same parameterlist as XIMS::Exporter::XMLChunk uses

=head3 Description

$self->set_sax_filters(@parameter)

internally called.


=cut

sub set_sax_filters {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @retval = ();

    push @retval, XIMS::SAX::Filter::ContentIDPathResolver->new( Provider => $self->{Provider},
                                                                 PrependSiteRootURL => $self->{Options}->{PrependSiteRootURL},
                                                                 ResolveContent => [ qw( DEPARTMENT_ID
                                                                                         SYMNAME_TO_DOC_ID ) ] );

    push @retval, XIMS::SAX::Filter::Attributes->new();
    # the following is needed to give the ContentLinkResolver SAXy events from the body
    # (i.e. have XIMS::SAX::Filter::ContentLinkResolver AFTER XIMS::SAX::Filter::CharacterChunk in the filter list)
    $self->{Options}->{appendexportfilters} = 1;

    return @retval;
}



=head2    generate_dom()

=head3 Parameter

    @parameter: same parameterlist as XIMS::Exporter::XMLChunk uses

=head3 Description

$self->generate_dom(@parameter)

internally called.

The document exporter should export significant information as
well. this information is indirectly stored as child objects.  the
exporter must only export the information, that is marked as public
available. These object therefore must be published in advance.

=cut

sub generate_dom {
    my $self = shift;
    $self->{AppContext}->properties->content->getchildren->objecttypes( [ qw( URLLink ) ] );
    return $self->SUPER::generate_dom( @_ );
}

1;


=head1 XIMS::Exporter::AutoIndexer

Internal class for creating the auto index.

=cut

package XIMS::Exporter::AutoIndexer;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::XMLChunk );

use XIMS::SAX::Filter::ContentIDPathResolver;

sub generate_dom {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    # temporarily set department id to document for object roots to trick the
    # auto index to point to the correct ou.xml
    my $department_id = $self->{Object}->department_id();
    if ( $self->{Object}->object_type->is_objectroot() ) {
        $self->{Object}->department_id( $self->{Object}->document_id() ) ;
    }

    my $dom = $self->SUPER::generate_dom( @_ );

    # set back
    $self->{Object}->department_id( $department_id ) ;

    return unless $dom;

    # after a second thought, i guess it would be better to convert the DOM
    # with an exporter stylesheet instead of letting a stylesheet called from
    # AxKit do the work. why? because of having ONE common schema for dumb
    # end-userstylesheet-designers making things easier for them.
    # exporter_document_autoindex.xsl should create a file quite similar to
    # the result of exporter_document.xsl

    $self->{Stylesheet} = XIMS::XIMSROOT() . '/stylesheets/exporter/' . XIMS::AUTOINDEXEXPORTSTYLESHEET();
    $self->{Exportfile} = XIMS::PUBROOT() . $self->{Object}->location_path() . '/' . XIMS::AUTOINDEXFILENAME();

    return $dom;
}

sub set_sax_filters {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @retval = ();

    push @retval, XIMS::SAX::Filter::ContentIDPathResolver->new( Provider => $self->{Provider},
                                                                 ResolveContent => [ qw( DEPARTMENT_ID ) ] );

    XIMS::Debug( 5, "done" );
    return @retval;
}


1;

=head1 XIMS::Exporter::Portlet

lowlevel class for pork cutlet objs. ;->

=cut

package XIMS::Exporter::Portlet;



use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::XMLChunk );

use XIMS::SAX::Filter::PortletCollector;
use XIMS::SAX::Filter::ContentIDPathResolver;
use XIMS::SAX::Filter::ContentObjectPropertyResolver;

sub set_sax_filters {
    XIMS::Debug( 5, "called" );
    my $self  = shift;
    my @retval;
    unshift @retval, XIMS::SAX::Filter::ContentIDPathResolver->new( Provider => $self->{Provider},
                                                                    ResolveContent => [ qw( DEPARTMENT_ID ) ] ),
                     XIMS::SAX::Filter::ContentObjectPropertyResolver->new( User           => $self->{User},
                                                                            ResolveContent => [ qw( image_id ) ],
                                                                            Properties     => [ qw( abstract content_length ) ],
                                                                          );

    my $filter = XIMS::SAX::Filter::PortletCollector->new( Provider => $self->{Provider},
                                                           Object   => $self->{Object},
                                                           User     => $self->{User},
                                                           Export   => 1,
                                                         );

    unshift @retval, $filter;
    XIMS::Debug( 5, "done" );
    return @retval;
}

sub create {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    $self->{AppContext}->properties->content->childrenbybodyfilter( 1 );

    XIMS::Debug( 5, "done" );
    return $self->SUPER::create( @_ );
}

1;


=head1 XIMS::Exporter::DepartmentRoot

lowlevel class for DepartmentRoot objs.

=cut

package XIMS::Exporter::DepartmentRoot;



use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::Folder );

sub create {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    $self->SUPER::create( @_ );

    my $idx_generator =  XIMS::Exporter::OUIndexer->new( Provider   => $self->{Provider},
                                                         Basedir    => $self->{Basedir},
                                                         Object     => $self->{Object},
                                                         User       => $self->{User},
                                                         Stylesheet => XIMS::XIMSROOT() . "/stylesheets/exporter/export_department_ou.xsl",
                                                       );
    XIMS::Debug( 5, "done" );
    return $idx_generator->create();
}

sub remove {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $idx_generator =  XIMS::Exporter::OUIndexer->new( Provider   => $self->{Provider},
                                                         Basedir    => $self->{Basedir},
                                                         Object     => $self->{Object},
                                                         User       => $self->{User},
                                                       );
    $idx_generator->remove();

    XIMS::Debug( 5, "done" );
    return $self->SUPER::remove( @_ );
}

1;

=head1 XIMS::Exporter::OUIndexer

lowlevel class for DepartmentRoot objs.

=cut


package XIMS::Exporter::OUIndexer;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::XMLChunk );

use XIMS::SAX::Filter::DepartmentExpander;
use XIMS::SAX::Filter::ContentIDPathResolver;
use XIMS::SAX::Filter::Attributes;

sub set_sax_filters {
    XIMS::Debug( 5, "called" );
    my $self  = shift;
    my @filter = ();

    push @filter, XIMS::SAX::Filter::DepartmentExpander->new( Object   => $self->{Object},
                                                              User     => $self->{User},
                                                              Export   => 1,
                                                            );
    push @filter, XIMS::SAX::Filter::ContentIDPathResolver->new( Provider => $self->{Provider},
                                                                 ResolveContent => [ qw( STYLE_ID IMAGE_ID CSS_ID SCRIPT_ID FEED_ID) ],
                                                               );

    push @filter, XIMS::SAX::Filter::Attributes->new();
    XIMS::Debug( 5, "done" );
    return @filter;
}

sub create {
    XIMS::Debug( 5, "called");
    my $self = shift;

    my $container_path = $self->{Object}->location_path();
    my $ou_path = XIMS::PUBROOT() . '/' . $container_path;
    $ou_path .= '/' unless $container_path eq '';
    $ou_path .= 'ou.xml';

    $self->{Exportfile} = $ou_path;
    return $self->SUPER::create( @_ );
}

sub remove {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $container_path = $self->{Object}->location_path();
    my $ou_path = XIMS::PUBROOT() . '/' . $container_path;
    $ou_path .= '/' unless $container_path eq '';
    $ou_path .= 'ou.xml';

    unlink( $ou_path );

    XIMS::Debug( 5, "done" );
    # return $self->SUPER::remove( @_ );
}

1;


=head1 XIMS::Exporter::NewsItem

lowlevel class for newsitem objs.

=cut

package XIMS::Exporter::NewsItem;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::Document );

use XIMS::SAX::Filter::ContentIDPathResolver;
use XIMS::SAX::Filter::ContentObjectPropertyResolver;

sub set_sax_filters {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @retval = ();

    push @retval, XIMS::SAX::Filter::ContentIDPathResolver->new( Provider => $self->{Provider},
                                                                 ResolveContent => [ qw(
                                                                                        department_id
                                                                                        symname_to_doc_id
                                                                                       ) ]
                                                                 ),
                  XIMS::SAX::Filter::ContentObjectPropertyResolver->new( User           => $self->{User},
                                                                         ResolveContent => [ qw( image_id ) ],
                                                                         Properties     => [ qw( abstract ) ]
                                                                         );

    push @retval, XIMS::SAX::Filter::Attributes->new();

    $self->{Options}->{appendexportfilters} = 1;

    return @retval;
}

1;



=head1 XIMS::Exporter::File

lowlevel class for File objs.

=cut


package XIMS::Exporter::File;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::Binary );


1;


=head1 XIMS::Exporter::XML

lowlevel class for XSLStylesheet objs.

=cut

package XIMS::Exporter::XML;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::Binary );


1;


=head1 XIMS::Exporter::XSLStylesheet

lowlevel class for XSLStylesheet objs.

=cut

package XIMS::Exporter::XSLStylesheet;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::XML );


1;

=head1 XIMS::Exporter::XSPScript

lowlevel class for XSPScript objs. ALERT! this is just a dummy!

=cut

package XIMS::Exporter::XSPScript;


use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::XML );

1;

=head1 XIMS::Exporter::URLLink

lowlevel class for URLLink objs.

=cut

package XIMS::Exporter::URLLink;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::NULL );


1;


=head1 XIMS::Exporter::SymbolicLink

lowlevel class for SymbolicLink objs.

=cut

package XIMS::Exporter::SymbolicLink;



use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::Handler );



=head2    create()

=head3 Parameter


=head3 Returns

    $retval : undef on error

=head3 Description

$self->create( %param )

=cut

sub create {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    my $retval;
    my $newfile = $self->{Basedir} . "/" . $self->{Object}->location();

    my $oldfile = XIMS::PUBROOT() . $self->{Provider}->location_path( document_id => $self->{Object}->symname_to_doc_id() );

    # make links down the hierarchy relative
    $oldfile =~ s/$self->{Basedir}\///;

    if ( -l $newfile ) {
        XIMS::Debug( 4, "link $newfile already exists - removing" );
        return unless $self->remove();
    }

    eval {
        symlink( $oldfile, $newfile ) || die $!;
    };

    if ( $@ ) {
        my $err = $@;
        XIMS::Debug( 2, "error creating symlink '$newfile': $err" );
        return;
    }
    else {
        XIMS::Debug( 4, "created symlink '$newfile'" );
    }

    XIMS::Debug( 4, "toggling publish state of the object" );
    $self->toggle_publish_state( '1' );
}

1;


=head1 XIMS::Exporter::AxPointPresentation

lowlevel class for AxPointPresentation objs.

=cut

package XIMS::Exporter::AxPointPresentation;


use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::XMLChunk );


1;


=head1 XIMS::Exporter::Image

lowlevel class for Image objs.

=cut

package XIMS::Exporter::Image;


use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::Binary );


1;


=head1 XIMS::Exporter::sDocBookXML

lowlevel class for sDocBookXML objs.

=cut

package XIMS::Exporter::sDocBookXML;



use vars qw( @ISA );
use XIMS::SAX::Filter::ContentIDPathResolver;

@ISA = qw( XIMS::Exporter::XMLChunk );

sub set_sax_filters {
    my $self = shift;
    my @retval = ();

    push @retval, XIMS::SAX::Filter::ContentIDPathResolver->new( Provider => $self->{Provider},
                                                                 ResolveContent => [ qw( DEPARTMENT_ID
                                                                                         SYMNAME_TO_DOC_ID ) ] );

    return @retval;
}

1;


=head1 XIMS::Exporter::Portal

Portal Exporter class

=cut

package XIMS::Exporter::Portal;



use vars qw(@ISA);
@ISA=qw( XIMS::Exporter::XMLChunk );

use XIMS::SAX::Filter::ContentIDPathResolver;

sub set_sax_filters {
    XIMS::Debug( 5, "called" );
    my $self  = shift;

    my $filter = XIMS::SAX::Filter::ContentIDPathResolver->new( Provider       => $self->{Provider},
                                                                ResolveContent => [ qw( STYLE_ID SYMNAME_TO_DOC_ID DEPARTMENT_ID ) ]  );

    return ($filter);
}

sub create {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    $self->{AppContext}->properties->content->getchildren->objecttypes( [ qw( SymbolicLink ) ] );

    return $self->SUPER::create( @_ );
}

1;


=head1 XIMS::Exporter::SiteRoot

lowlevel class for AnonDiscussionForum objs.

=cut

package XIMS::Exporter::SiteRoot;



use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::DepartmentRoot );


1;

=head1 XIMS::Exporter::Gallery

lowlevel class for folder objs.

=cut

package XIMS::Exporter::Gallery;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::XMLChunk );
use File::Path;
use common::sense;

use XIMS::SAX::Filter::ContentIDPathResolver;
use XIMS::SAX::Filter::Attributes;

sub set_sax_filters {
    XIMS::Debug( 5, "called" );
    my $self  = shift;
    my @filter = ();

    push @filter, XIMS::SAX::Filter::ContentIDPathResolver->new( Provider => $self->{Provider},
                                                                 ResolveContent => [ qw( STYLE_ID IMAGE_ID CSS_ID SCRIPT_ID FEED_ID) ],
                                                               );

    push @filter, XIMS::SAX::Filter::Attributes->new();
    XIMS::Debug( 5, "done" );
    return @filter;
}

=head2 create()

=head3 Parameter

    $param->{-path}   : (mandatory)
    $param->{-folder} : (mandatory)

=head3 Returns

    $retval : undef on error

=head3 Description

$self->create( $param );

=cut

sub create {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    my $retval;

    my $new_path = $self->{Exportfile} || $self->{Basedir} . "/" . $self->{Object}->location();

    if ( -d $new_path ) {
        XIMS::Debug( 4, "Directory '$new_path' exists, no need to create." );
    }
    else {
        # create new folder.
        XIMS::Debug( 4, "Creating directory '$new_path'" );

        eval {
            mkdir( $new_path, 0755 ) ||  die $!;
        };

        if ( $@ ) {
            my $err = $@;
            XIMS::Debug( 3, "Error creating directory '$new_path': $err" );
            return;
        }
    }

    if ( not exists $param{mkdironly} ) {
        #
        # generate metadata
        #

        # delete children cache so that autoindex and container.xml will be
        # up-to-date
        delete $self->{Provider}->{ocache}->{kids};

        # first, the object DOM
        my $raw_dom = $self->generate_dom();

        unless ( $raw_dom ) {
            XIMS::Debug( 2, "metadata cannot be generated" );
            return;
        }

        # then, transform it...

        my $transd_dom = $self->transform_dom( $raw_dom );

        unless ( $transd_dom ) {
            XIMS::Debug( 2, "transformation failed" );
            return;
        }

        # build the path

        my $meta_path = $new_path . '/' . $self->{Object}->location() . '.container.xml';
        XIMS::Debug( 4, "metadata file is $meta_path" );

        # write the file...
        my $meta_fh = IO::File->new( $meta_path, 'w' );

        if ( defined $meta_fh ) {
            binmode( $meta_fh, ':encoding(UTF-8)' );
            print $meta_fh $transd_dom->toString();
            $meta_fh->close;
            XIMS::Debug( 4, "metadata-dom written" );
        }
        else {
            XIMS::Debug( 2, "Error writing file '$meta_path': $!" );
            return;
        }
        ########## gallery index exp ########
        # first, the object DOM
        my $raw_dom2 = $self->generate_dom_gallery();

        unless ( $raw_dom2 ) {
            XIMS::Debug( 2, "metadata cannot be generated" );
            return;
        }
        my $transd_dom2 = $self->transform_dom_gallery( $raw_dom2 );

        unless ( $transd_dom2 ) {
            XIMS::Debug( 2, "transformation failed" );
            return;
        }
        
        my $meta_path2 = $new_path . '/galleryindex.html';
        XIMS::Debug( 4, "index file is $meta_path2" );
        # write the file...
        my $meta_fh2 = IO::File->new( $meta_path2, 'w' );

        if ( defined $meta_fh2 ) {
            binmode( $meta_fh2, ':encoding(UTF-8)' );
            print $meta_fh2 $transd_dom2->toString();
            $meta_fh2->close;
            XIMS::Debug( 4, "metadata-dom written" );
        }
        else {
            XIMS::Debug( 2, "Error writing file '$meta_path2': $!" );
            return;
        }
        ###

        ########## image index exp ########
        # first, the object DOM
        my $raw_dom2 = $self->generate_dom_galleryimages();

        unless ( $raw_dom2 ) {
            XIMS::Debug( 2, "metadata cannot be generated" );
            return;
        }
        my $transd_dom2 = $self->transform_dom_gallery( $raw_dom2 );

        unless ( $transd_dom2 ) {
            XIMS::Debug( 2, "transformation failed" );
            return;
        }

        my $meta_path2 = $new_path . '/images.htm';
        XIMS::Debug( 4, "index file is $meta_path2" );
        # write the file...
        my $meta_fh2 = IO::File->new( $meta_path2, 'w' );

        if ( defined $meta_fh2 ) {
            binmode( $meta_fh2, ':encoding(UTF-8)' );
            print $meta_fh2 $transd_dom2->toString();
            $meta_fh2->close;
            XIMS::Debug( 4, "metadata-dom written" );
        }
        else {
            XIMS::Debug( 2, "Error writing file '$meta_path2': $!" );
            return;
        }
        ###
    }

    # mark the folder as published
    XIMS::Debug( 4, "toggling publish state of the object" );
    $self->toggle_publish_state( '1' );


    return 1;
}

=head2    remove()

=head3 Parameter


=head3 Returns

    $retval : undef on error

=head3 Description

$self->remove();

=cut

sub remove {
    XIMS::Debug( 5, "called" );
    my ( $self, $param ) = @_;

    my $kill_path = $self->{Basedir} . "/" . $self->{Object}->location();

    if ( defined $self->{Children} and scalar @{$self->{Children}} ) {
        my $helper = XIMS::Exporter::Helper->new();
        foreach my $kind ( @{$self->{Children}} ) {
            my $reaper = $helper->exporterclass(
                         Provider   => $self->{Provider},
                         Basedir    => $self->{Basedir} . '/' . $self->{Object}->location,
                         User       => $self->{User},
                         Object     => $kind
                        );
            return unless ($reaper and $reaper->remove());
        }
    }

    # kill the meta file
    unlink $kill_path . '/' . $self->{Object}->location . ".container.xml";

    # kill the autoindex if exists (i.e. the object was converted from XIMS::Folder)
    if ( -f $kill_path . '/' . XIMS::AUTOINDEXFILENAME() ) {
        unlink $kill_path . '/' . XIMS::AUTOINDEXFILENAME();
    }
    # kill the gallery index
    if ( -f $kill_path . '/' . "galleryindex.html" ) {
        unlink $kill_path . '/' . "galleryindex.html";
    }
    # kill the images.htm if exists
    if ( -f $kill_path . '/' . "images.htm") {
        unlink $kill_path . '/' . "images.htm";
    }

    # and now, remove AxKit's stylecache dir...
    if ( -d $kill_path . '/.xmlstyle_cache' ) {
        eval {
            File::Path::rmtree( $kill_path . '/.xmlstyle_cache' ) || die $!;
        };
        if ( $@ ) {
            my $err = $@;
            XIMS::Debug( 2, "Error deleting cach dir: $err" );
        }
    }

    # finally, drop the dir.
    rmdir( $kill_path ) || do { XIMS::Debug( 2, "can't remove directory '$kill_path' " . $! ); return; };


    # mark the folder as not published.
    XIMS::Debug( 4, "marking folder as unpublished again :)" );
    $self->toggle_publish_state( '0' );

    return 1;
}


=head2    transform_dom()

=head3 Parameter

    $dom: the DOM to be transformed.

=head3 Returns

    $retval : the transformed DOM, undef on error

=head3 Description

$self->transform_dom( $dom );

This is a helper function that transforms a DOM into another one
by using XSLT.

=cut

sub transform_dom_gallery {
    XIMS::Debug( 5, "called" );
    my ( $self, $dom ) = @_;

    my $stylesheet = $self->{Stylesheet};
    if ( defined $stylesheet and -f $stylesheet and -r $stylesheet ) {
        my $xsl_dom;
        my $style;
        my $parser = XML::LibXML->new();
        my $xslt   = XML::LibXSLT->new();

        XIMS::Debug( 4, "filename is $stylesheet" );
        eval {
            $xsl_dom  = $parser->parse_file( $stylesheet );
        };
        if ( $@ ) {
            XIMS::Debug( 3, "Could not parse stylesheet file: ". $@ );
            return;
        }

        eval {
            $style = $xslt->parse_stylesheet( $xsl_dom );
            # $style = $xslt->parse_stylesheet_file( $file );
        };
        if( $@ ) {
            XIMS::Debug( 2, "Error in Stylesheet: ". $@ );
            return;
        }

        my $transformed_dom;
        eval {
            $transformed_dom = $style->transform( $dom );
        };
        if( $@ ) {
            XIMS::Debug( 3, "Broken Transformation: ". $@ );
            return;
        }
        XIMS::Debug( 4, "Transformation done" );
        return $transformed_dom;
    }
    else {
        #
        # in case no stylesheet file has given the function simply
        # returns the untransformed DOM
        #
        XIMS::Debug( 4, "dom has not been transformed" );
        return $dom;
    }
    return;
}

sub generate_dom_gallery {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    # temporarily set department id to document for object roots to trick the
    # auto index to point to the correct ou.xml
    my $department_id = $self->{Object}->department_id();
    if ( $self->{Object}->object_type->is_objectroot() ) {
        $self->{Object}->department_id( $self->{Object}->document_id() ) ;
    }

    my $dom = $self->SUPER::generate_dom( @_ );

    # set back
    $self->{Object}->department_id( $department_id ) ;

    return unless $dom;

    # after a second thought, i guess it would be better to convert the DOM
    # with an exporter stylesheet instead of letting a stylesheet called from
    # AxKit do the work. why? because of having ONE common schema for dumb
    # end-userstylesheet-designers making things easier for them.
    # exporter_document_autoindex.xsl should create a file quite similar to
    # the result of exporter_document.xsl

    $self->{Stylesheet} = XIMS::XIMSROOT() . '/stylesheets/exporter/export_galleryindex.xsl'; # . XIMS::AUTOINDEXEXPORTSTYLESHEET();
    # warn "\n gallery locationpath : ".$self->{Object}->location_path();
    $self->{Exportfile} = XIMS::PUBROOT() . $self->{Object}->location_path() . '/.galleryindex.html'; # . XIMS::AUTOINDEXFILENAME();

    return $dom;
}

sub generate_dom_galleryimages {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    # temporarily set department id to document for object roots to trick the
    # auto index to point to the correct ou.xml
    my $department_id = $self->{Object}->department_id();
    if ( $self->{Object}->object_type->is_objectroot() ) {
        $self->{Object}->department_id( $self->{Object}->document_id() ) ;
    }

    my $dom = $self->SUPER::generate_dom( @_ );

    # set back
    $self->{Object}->department_id( $department_id ) ;

    return unless $dom;

    # after a second thought, i guess it would be better to convert the DOM
    # with an exporter stylesheet instead of letting a stylesheet called from
    # AxKit do the work. why? because of having ONE common schema for dumb
    # end-userstylesheet-designers making things easier for them.
    # exporter_document_autoindex.xsl should create a file quite similar to
    # the result of exporter_document.xsl

    $self->{Stylesheet} = XIMS::XIMSROOT() . '/stylesheets/exporter/export_galleryimages.xsl'; # . XIMS::AUTOINDEXEXPORTSTYLESHEET();
    # warn "\n gallery locationpath : ".$self->{Object}->location_path();
    $self->{Exportfile} = XIMS::PUBROOT() . $self->{Object}->location_path() . '/.images.htm'; # . XIMS::AUTOINDEXFILENAME();

    return $dom;
}

1;

=head1 XIMS::Exporter::BinMeta

export metadata for binary types as RDF/XML.

=cut

package XIMS::Exporter::BinMeta;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::XMLChunk );

# use XIMS::SAX::Filter::DepartmentExpander;
# use XIMS::SAX::Filter::ContentIDPathResolver;
use XIMS::SAX::Filter::Attributes;

sub set_sax_filters {
    XIMS::Debug( 5, "called" );
    my $self  = shift;
    my @filter = ();

    push @filter, XIMS::SAX::Filter::Attributes->new();
    
    return @filter;
}

sub create {
    XIMS::Debug( 5, "called");
    my $self = shift;

    $self->{Exportfile} = $self->_path;
    return $self->SUPER::create( @_ );
}

sub remove {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    unlink( $self->_path );

    XIMS::Debug( 5, "done" );
    # return $self->SUPER::remove( @_ );
}

sub _path {
    my $self = shift;
    return XIMS::PUBROOT() . '/' . $self->{Object}->location_path() . '.rdf';
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

