
=head1 NAME

XIMS::CGI::Folder -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::Folder;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::Folder;

use strict;
use base qw( XIMS::CGI );

use Locale::TextDomain ('info.xims');

#

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# #############################################################################
# GLOBAL SETTINGS

=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->SUPER::registerEvents(
        (
            'create',       'edit',
            'store',        'obj_acllist',	'obj_acllight',
            'obj_aclgrant', 'obj_aclrevoke',
            'publish',      'publish_prompt', 'unpublish',
            'test_wellformedness', 'showtrashcan', 
            'deletemultiple_prompt','deletemultiple', 'undeletemultiple',
            'trashcanmultiple_prompt', 'trashcanmultiple', 
            'publishmultiple_prompt', 'publishmultiple', 'unpublishmultiple',
            'movemultiple_browse', 'movemultiple',
            'aclmultiple_prompt','aclgrantmultiple','aclrevokemultiple',
            @_
        )
    );
}

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default($ctxt);

    $ctxt->properties->content->getformatsandtypes(1);

    my $display_params = $self->get_display_params($ctxt);

    $ctxt->properties->content->getchildren->limit( $display_params->{limit} );
    $ctxt->properties->content->getchildren->offset(
        $display_params->{offset} );
    $ctxt->properties->content->getchildren->order( $display_params->{order} );
    $ctxt->properties->content->getchildren->showtrash( $display_params->{showtrashcan} );

    # not needed ATM, kept for reference.
    #     if ( defined $display_params->{style} ) {
    #         $ctxt->properties->application->style($display_params->{style});
    #     }

    # This prevents the loading of XML::Filter::CharacterChunk and thus saving
    # some ms...
    $ctxt->properties->content->escapebody(1);

    return 0;
}

=head2 event_showtrashcan()

=cut

sub event_showtrashcan {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default($ctxt);

    $ctxt->properties->content->getformatsandtypes(1);

    my $display_params = $self->get_display_params($ctxt);

    $ctxt->properties->content->getchildren->limit( $display_params->{limit} );
    $ctxt->properties->content->getchildren->offset($display_params->{offset} );
    $ctxt->properties->content->getchildren->order( $display_params->{order} );
    $ctxt->properties->content->getchildren->showtrash( $display_params->{showtrashcan} );

    # not needed ATM, kept for reference.
    #     if ( defined $display_params->{style} ) {
    #         $ctxt->properties->application->style($display_params->{style});
    #     }

	$ctxt->properties->application->style( "trashcan");
    # This prevents the loading of XML::Filter::CharacterChunk and thus saving
    # some ms...
    $ctxt->properties->content->escapebody(1);

    return 0;
}

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->expand_attributes($ctxt);

    return $self->SUPER::event_edit($ctxt);
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0
      unless $self->init_store_object($ctxt)
      and defined $ctxt->object();

    my $object = $ctxt->object();

    my $autoindex = $self->param('autoindex');

    if ( defined $autoindex and $autoindex eq 'false' ) {
        XIMS::Debug( 6, "autoindex: $autoindex" );
        $object->attribute( autoindex => '0' );
    }
    else {
        $object->attribute( autoindex => '1' );
    }

    my $pagerowlimit = $self->param('pagerowlimit');

    #empty or up to 2 figures.
    if ( defined $pagerowlimit and $pagerowlimit =~ /^\d{0,2}$/ ) {
        XIMS::Debug( 6, "pagerowlimit: $pagerowlimit" );
        $object->attribute( pagerowlimit => $pagerowlimit );
    }

    my $defaultsortby = $self->param('defaultsortby');

    if ( defined $defaultsortby ) {
        XIMS::Debug( 6, "defaultsortby: $defaultsortby" );
        my $currentvalue = $object->attribute_by_key('defaultsortby');
        if ( $defaultsortby ne 'position' or defined $currentvalue ) {
            $object->attribute( defaultsortby => $defaultsortby );
        }
    }

    my $defaultsort = $self->param('defaultsort');

    if ( defined $defaultsort ) {
        XIMS::Debug( 6, "defaultsort: $defaultsort" );
        my $currentvalue = $object->attribute_by_key('defaultsort');
        if ( $defaultsort ne 'asc' or defined $currentvalue ) {
            $object->attribute( defaultsort => $defaultsort );
        }
    }

    return $self->SUPER::event_store($ctxt);
}

=head2 event_deletemultiple()

=cut

sub event_deletemultiple {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my @ids = $self->param('multiselect');
    foreach(@ids){
    	my $obj = new XIMS::Object('id' => $_);
    	if(not ($obj->published())  and ($ctxt->session->user->object_privmask( $obj )& XIMS::Privileges::DELETE())){
    		$obj->delete(User => $ctxt->session->user);
    	}
    	else{
            XIMS::Debug( 4,  "Could not handle " . $obj->location() );
        }
    }
    XIMS::Debug( 4, "redirecting to the container" );
    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id ) );
    return 0;
}

=head2 event_deletemultiple_prompt()

=cut

sub event_deletemultiple_prompt {
	XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my @ids = $self->param('multiselect');
    my @objects;
    foreach(@ids){
    	my $obj = new XIMS::Object('id' => $_);
    	#warn $obj->location()." \t- ".$ctxt->session->user->object_privmask( $obj )." - ".XIMS::Privileges::DELETE();
    	if(not ($obj->published())  and ($ctxt->session->user->object_privmask( $obj )& XIMS::Privileges::DELETE())){
    		push(@objects, $obj);
    	}
        else{
            XIMS::Debug( 4,  "Could not handle " . $obj->location() );
        }
    }
    if ( scalar @objects ) {
    	$ctxt->objectlist( \@objects );
    }
    $ctxt->properties->content->getformatsandtypes(1);
    $ctxt->properties->application->styleprefix('common');
    $ctxt->properties->application->style('deletemultiple_confirm');
}

=head2 event_trashcanmultiple_prompt()

=cut

sub event_trashcanmultiple_prompt {
	XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my @ids = $self->param('multiselect');
    my @objects;
    foreach(@ids){
    	my $obj = new XIMS::Object('id' => $_);
    	#warn $obj->location()." \t- ".$ctxt->session->user->object_privmask( $obj )." - ".XIMS::Privileges::DELETE();
    	if(not ($obj->published())  and ($ctxt->session->user->object_privmask( $obj )& XIMS::Privileges::DELETE())){
    		push(@objects, $obj);
    	}
        else{
            XIMS::Debug( 4,  "Could not handle " . $obj->location() );
        }
    }
    if ( scalar @objects ) {
    	$ctxt->objectlist( \@objects );
    }
    $ctxt->properties->content->getformatsandtypes(1);
    $ctxt->properties->application->styleprefix('common');
    $ctxt->properties->application->style('trashcanmultiple_confirm');
}

=head2 event_trashcanmultiple()

=cut

sub event_trashcanmultiple {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my @ids = $self->param('multiselect');
    foreach(@ids){
    	my $obj = new XIMS::Object('id' => $_);
    	if(not ($obj->published())  and ($ctxt->session->user->object_privmask( $obj )& XIMS::Privileges::DELETE())){
            $obj->trashcan();
    	}
        else{
            XIMS::Debug( 4,  "Could not handle " . $obj->location() );
        }
    }
    XIMS::Debug( 4, "redirecting to the container" );
    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id ) );
    return 0;
}

=head2 event_undeletemultiple()

=cut

sub event_undeletemultiple {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my @ids = $self->param('multiselect');
    my @objects;
    foreach(@ids){
    	my $obj = new XIMS::Object('id' => $_);
    	if($ctxt->session->user->object_privmask( $obj )& XIMS::Privileges::DELETE()){
            $obj->undelete();
    	}
        else{
            XIMS::Debug( 4,  "Could not handle " . $obj->location() );
        }
    }
    XIMS::Debug( 4, "redirecting to the container" );
    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id ) );
    return 0;
}

=head2 event_publishnmultiple_prompt()

=cut

sub event_publishmultiple_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my @ids = $self->param('multiselect');
    my @objects;
    foreach(@ids){
    	my $obj = new XIMS::Object('id' => $_);
    	#warn $obj->location()." \t- ".$ctxt->session->user->object_privmask( $obj )." - ".XIMS::Privileges::DELETE();
        #    	if(not ($obj->published())  and ($ctxt->session->user->object_privmask( $obj )& XIMS::Privileges::DELETE())){
        #    		push(@objects, $obj);
        #    	}
    	if($ctxt->session->user->object_privmask( $obj )& XIMS::Privileges::PUBLISH()){
            push(@objects, $obj);
    	}
        else{
            XIMS::Debug( 4,  "Could not handle " . $obj->location() );
        }
    }
    if ( scalar @objects ) {
    	$ctxt->objectlist( \@objects );
    }
    XIMS::Debug( 4, "container - id:".$ctxt->object->id );
    $ctxt->properties->content->getformatsandtypes(1);
    $ctxt->properties->application->styleprefix('common');
    $ctxt->properties->application->style('publishmultiple_prompt');
}
=head2 event_publishmultiple()

=cut

sub event_publishmultiple {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my @ids = $self->param('multiselect');
    my @objects;
    require XIMS::Exporter;
    my $exporter = XIMS::Exporter->new(
        Provider => $ctxt->data_provider,
        Basedir  => XIMS::PUBROOT(),
        User     => $ctxt->session->user
    );
    my $no_dependencies_update = 1;
    if ( defined $self->param("update_dependencies")
             and $self->param("update_dependencies") == 1 )
        {
            $no_dependencies_update = undef;
        }
    my $obj;
    my @org_ids = @ids;
    my $user = $ctxt->session->user;
    foreach(@org_ids){
        $obj = new XIMS::Object('id' => $_);
        my @descendants = $obj->descendants_granted(
            User           => $user,
            marked_deleted => 0
			    );
        XIMS::Debug( 4, "Number of objects: ".(scalar @descendants + scalar @ids));
        if((scalar @descendants + scalar @ids) < XIMS::RECMAXOBJECTS()){
            foreach my $desc (@descendants) {
                if($user->object_privmask( $obj )& XIMS::Privileges::PUBLISH()){
                    push(@ids, $desc->id());
                }
            }
        }
        else{
            $ctxt->properties->application->styleprefix('common');
            $ctxt->properties->application->style('error');
            XIMS::Debug( 2, "to many objects in recursion" );
            $self->sendError( $ctxt, __x "Current limit is {rec_max_obj}. Please select fewer objects or disable recursion.", rec_max_obj => XIMS::RECMAXOBJECTS() );
            return 0;
        }
    }
    my $published = $self->SUPER::autopublish( $ctxt, $exporter, 'publish', \@org_ids, $no_dependencies_update, $self->param("recpublish") );
    XIMS::Debug( 4, "redirecting to the container" );
    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id ) );
    return 0;
}
=head2 event_unpublishnmultiple()

=cut

sub event_unpublishmultiple {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 4, "container - id:".$ctxt->object->id );
    my @ids = $self->param('multiselect');
    my @objects;
    require XIMS::Exporter;
    my $exporter = XIMS::Exporter->new(
        Provider => $ctxt->data_provider,
        Basedir  => XIMS::PUBROOT(),
        User     => $ctxt->session->user
    );
    my $no_dependencies_update = 1;
    if ( defined $self->param("update_dependencies")
             and $self->param("update_dependencies") == 1 )
	{
            $no_dependencies_update = undef;
	}
    #my $published = $self->autopublish( $ctxt, $exporter, 'publish', \@objects,
    #				$no_dependencies_update, $self->param("recpublish") );
    #	foreach ( @ids ) {
    #			warn $_;
    #		}
    #
    my $obj;
    my @org_ids = @ids;
    my $user = $ctxt->session->user;
    foreach(@org_ids){
        $obj = new XIMS::Object('id' => $_);
        my @descendants = $obj->descendants_granted(
            User           => $user,
            marked_deleted => 0
        );
        XIMS::Debug( 4, "Number of objects: ".(scalar @descendants + scalar @ids));
        if((scalar @descendants + scalar @ids) < XIMS::RECMAXOBJECTS()){
            foreach my $desc (@descendants) {
                if($user->object_privmask( $obj )& XIMS::Privileges::PUBLISH()){
                    push(@ids, $desc->id());
                }
            }
        }
        else{
            $ctxt->properties->application->styleprefix('common');
            $ctxt->properties->application->style('error');
            XIMS::Debug( 2, "to many objects in recursion" );
            $self->sendError( $ctxt, __x "Current limit is {rec_max_obj}. Please select fewer objects or disable recursion.", rec_max_obj => XIMS::RECMAXOBJECTS() );
            return 0;
        }
    }
    
    #
    my $published = $self->SUPER::autopublish( $ctxt, $exporter, 'unpublish', \@org_ids, $no_dependencies_update, $self->param("recpublish") );
    XIMS::Debug( 4, "redirecting to the container - id:".$ctxt->object->id );
    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id ) );
    return 0;
}

=head2 event_move_browsemultiple()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_move_browsemultiple(...)

=cut

sub event_movemultiple_browse {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	$ctxt->properties->application->styleprefix("common");
	$ctxt->properties->application->style("error");
	
	my @ids = $self->param('multiselect');
    my @objects;
    my $to = $self->param("to");
    if ( not( $to =~ /^\d+$/ ) ) {
		XIMS::Debug( 3, "Where to move?" );
		#$ctxt->session->error_msg( __ "Where to move?" );
		return 0;
	}
    foreach(@ids){
    	my $obj = new XIMS::Object('id' => $_);    	
    	if(not ($obj->published())  and ($ctxt->session->user->object_privmask( $obj )& XIMS::Privileges::MOVE())){    		
    		push(@objects, $obj);
    	}
    }
    $ctxt->properties->content->getchildren->level(1);
	$ctxt->properties->content->getchildren->objecttypes(
			[qw(Folder DepartmentRoot Gallery)] );	
	
	if ( scalar @objects ) {
		$ctxt->objectlist( \@objects );
	}
	$ctxt->properties->content->getformatsandtypes(1);
	$ctxt->properties->content->getchildren->objectid($to);
	$ctxt->properties->application->style("movemultiple_browse");
	
	return 0;
}

=head2 event_movemultiple()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_movemultiple(...)

=cut

sub event_movemultiple {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	#my $object = $ctxt->object();

	$ctxt->properties->application->styleprefix("common");
	$ctxt->properties->application->style("error");

#	my $current_user_object_priv =
#	  $ctxt->session->user->object_privmask($object);
#	return $self->event_access_denied($ctxt)
#	  unless $current_user_object_priv & XIMS::Privileges::MOVE();

	#if ( not $object->published() ) {
		my $to = $self->param("to");
		warn "\n\nTarget : ".$to;
		if ( not( length $to ) ) {
			XIMS::Debug( 3, "Where to move?" );
			#$ctxt->session->error_msg( __ "Where to move?" );
			return 0;
		}

		my $target;
		if (
			not(
				$target = XIMS::Object->new(
					path => $to,
					User => $ctxt->session->user
				)
				and $target->id()
			)
		  )
		{
			$ctxt->session->error_msg( __ "Invalid target path!" );
			return 0;
		}
		if ( $target->object_type->is_fs_container() ) {
			XIMS::Debug( 4, "we got a valid target" );
		}
		else {
			XIMS::Debug( 3, "Target is not a valid container" );
			$ctxt->session->error_msg( __ "Target is not a valid container" );
			return 0;
		}
	my @ids = $self->param('multiselect');
    foreach(@ids){
    	my $object = new XIMS::Object('id' => $_);
    	
    	if ( $object->document_id() == $target->document_id() ) {
			XIMS::Debug( 2, "target and source are the same" );			
			$ctxt->session->error_msg( __ "Target and source are the same. (Why would you want doing that?)");
			return 0;
		}
    	
		my @children = $target->children(
			location       => $object->location(),
			marked_deleted => 0
		);
		if ( scalar @children > 0 and defined $children[0] ) {
			XIMS::Debug( 2,"object with same location already exists in the target container"
			);
			$self->sendError(
				$ctxt,
				__x("Location '{location}' already exists in the target container.",
					location => $object->location()
				)
			);
			return 0;
		}

		if ( not $object->move( target => $target->document_id ) ) {
			$ctxt->session->error_msg("move failed!");
			return 0;
		}
#		else {
#			XIMS::Debug( 4, "move ok, redirecting to the parent" );
#			$self->redirect(
#				$self->redirect_path( $ctxt, $object->parent->id() ) );
#			return 0;
#		}
    }#end foreach
#	}
#	else {
#		XIMS::Debug( 3, "attempt to move published object" );
#		#$ctxt->session->error_msg(__ "Moving published objects has not been implemented yet." );
#		return 0;
#	}
	XIMS::Debug( 4, "move ok, redirecting to the parent" );
			$self->redirect(
				$self->redirect_path( $ctxt, $target->id() ) );
	return 0;
}

=head2 event_aclmultiple_prompt()

=cut

sub event_aclmultiple_prompt {
	XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my @ids = $self->param('multiselect');
    my @objects;
    foreach(@ids){
    	my $obj = new XIMS::Object('id' => $_);
    	#warn $obj->location()." \t- ".$ctxt->session->user->object_privmask( $obj )." - ".XIMS::Privileges::DELETE();
    	if($ctxt->session->user->object_privmask( $obj )& (XIMS::Privileges::GRANT() || XIMS::Privileges::GRANT_ALL())){
    		push(@objects, $obj);
    	}
#    	else{
#    		warn "geht nicht : ".$obj->location();
#    	}
    }
    if ( scalar @objects ) {
    	$ctxt->objectlist( \@objects );
    }
    $ctxt->properties->content->getformatsandtypes(1);
    $ctxt->properties->application->styleprefix('common');
    $ctxt->properties->application->style('aclmultiple_prompt');
}

#=head2 event_aclgrantmultiple()
#
#=cut
#
#sub event_aclgrantmultiple {
#	XIMS::Debug( 5, "called" );
#    my ( $self, $ctxt ) = @_;
#	
#	if($self->param('grantees')){
#		my @grantees;
#		foreach ( split( /\s*,\s*/, $self->param('grantees') ) ) {
#		    my $grantee = XIMS::User->new( name => $_ );
#			#unless $grantee and $grantee->id();
#			if($grantee and $grantee->id()){	
#				push @grantees, $grantee;
#			}
#			else{
#				XIMS::Debug( 4, "Grantee '" . $_ . "' could not be found.\n");
#			}
#		}
#		unless (scalar @grantees){
#			$ctxt->properties->application->styleprefix('common');
#			$ctxt->properties->application->style('error');
#			XIMS::Debug( 2, "none of provided grantees found" );
#			$self->sendError( $ctxt, __ "None of your provided grantees could befound." );
#			return 0;
#		}
#		
#		# build the privilege mask
#		my $bitmask = 0;
#		foreach my $priv ( XIMS::Privileges::list() ) {
#			my $lcname = 'acl_' . lc($priv);
#			if ( $self->param($lcname) ) {
#				{
#					## no critic (ProhibitNoStrict)
#					no strict 'refs';
#					$bitmask += &{"XIMS::Privileges::$priv"}();
#					## use strict
#				}
#			}
#		}
#		unless ($bitmask){
#			$ctxt->properties->application->styleprefix('common');
#			$ctxt->properties->application->style('error');
#			XIMS::Debug( 2, "No privileges provides" );
#			$self->sendError( $ctxt, __ "Please provide at least one privilege." );
#			return 0;
#		}
#		
#		my $recgrant = $self->param('recacl');
#	    my @ids = $self->param('multiselect');
#	    my $user = $ctxt->session->user();
#	    #my @objects;
#	    
#	    my $obj;
#	    #recursive
#		if ( $recgrant ) {
#			my @org_ids = @ids;
#			foreach(@org_ids){
#				$obj = new XIMS::Object('id' => $_);
#			    my @descendants = $obj->descendants_granted(
#			        User           => $user,
#			        marked_deleted => 0
#			    );
#			    XIMS::Debug( 4, "Number of objects: ".(scalar @descendants + scalar @ids));
#			    if((scalar @descendants + scalar @ids) < XIMS::RECMAXOBJECTS()){
#				    foreach my $desc (@descendants) {
#				    	if($user->object_privmask( $obj )& (XIMS::Privileges::GRANT() || XIMS::Privileges::GRANT_ALL())){
#							push(@ids, $desc->id());
#				    	}
#					}
#			    }
#			    else{
#			    	$ctxt->properties->application->styleprefix('common');
#					$ctxt->properties->application->style('error');
#					XIMS::Debug( 2, "to many objects in recursion" );
#					$self->sendError( $ctxt, __x "Current limit is {rec_max_obj}. Please select fewer objects or disable recursion.", rec_max_obj => XIMS::RECMAXOBJECTS() );
#					return 0;
#			    }
#			}
#		}
#	    #end recursive
#	    
#	    
#	
#		my $id_iterator = XIMS::Iterator::Object->new( \@ids, 1 );
#		while ( my $obj = $id_iterator->getNext() ) {
#			#warn "\n object : ".obj->location();
#			# store the set to the database
#			foreach(@grantees){
#				my $gid = $_->id();
#				#my $gid = $_;
#				my $boolean = $obj->grant_user_privileges(
#					grantee        => $gid,
#					privilege_mask => $bitmask,
#					grantor        => $user
#				);
#				if ($boolean) {
#					XIMS::Debug( 6, "ACL privs changed for (" . $_->name() . ")" );
#					#XIMS::Debug( 6, "ACL privs changed for user ( id: " . $_ . ")" );
#	#					#$ctxt->properties->application->style('obj_user_update');
#	##					my $granted = XIMS::User->new( id => $uid );
#	##					$ctxt->session->message(
#	##						__x("Privileges changed successfully for user/role '{name}'.",
#	##							name => $granted->name(),
#	##						)
#	##					);
#	#				}
#	#				else {
#	#					XIMS::Debug( 2, "ACL grant failure on ". $obj->document_id . " for ". $_->name() );
#	#					#XIMS::Debug( 2, "ACL grant failure on ". $obj->document_id . " for user with id ". $_ );
#	#				}
#				}
#				else {
#					XIMS::Debug( 2, "ACL grant failure on ". $obj->document_id . " for ". $_->name() );
#					#XIMS::Debug( 2, "ACL grant failure on ". $obj->document_id . " for user with id ". $_ );
#				}
#			}
#		}
#	    XIMS::Debug( 3, "all privileges granted." );
#		XIMS::Debug( 4, "redirecting to the container" );
#	    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id ) );
#	    return 0;
#	}
#	else{
#		$ctxt->properties->application->styleprefix('common');
#		$ctxt->properties->application->style('error');
#		XIMS::Debug( 2, "no grantee(s) provided" );
#		$self->sendError( $ctxt, __ "Please provide at least one grantee." );
#		return 0;
#	}
#}

=head2 event_aclrevokemultiple()

=cut

#sub event_aclrevokemultiple {
#	XIMS::Debug( 5, "called" );
#    my ( $self, $ctxt ) = @_;
#
#	if($self->param('grantees')){
#	my @grantees;
#	foreach ( split( /\s*,\s*/, $self->param('grantees') ) ) {
#	    my $grantee = XIMS::User->new( name => $_ );
##	    XIMS::Debug( 4, "Grantee '" . $_ . "' could not be found.\n")
##	        unless $grantee and $grantee->id();
##	    push @grantees, $grantee;
#		if($grantee and $grantee-id()){	
#				push @grantees, $grantee;
#			}
#			else{
#				XIMS::Debug( 4, "Grantee '" . $_ . "' could not be found.\n");
#			}
#		}
#		unless (scalar @grantees){
#			$ctxt->properties->application->styleprefix('common');
#			$ctxt->properties->application->style('error');
#			XIMS::Debug( 2, "none of provided grantees found" );
#			$self->sendError( $ctxt, __ "None of your provided grantees could befound." );
#			return 0;
#		}
#	my $recgrant = $self->param('recacl');
#	my @ids = $self->param('multiselect');
#	my $user = $ctxt->session->user();
#	
#	my $obj;
#	#recursive
#	if ( $recgrant ) {
#		my @org_ids = @ids;
#		foreach(@org_ids){
#			$obj = new XIMS::Object('id' => $_);
#		    my @descendants = $obj->descendants_granted(
#		        User           => $user,
#		        marked_deleted => 0
#		    );
#		    XIMS::Debug( 4, "Number of objects: ".(scalar @descendants + scalar @ids));
#			if((scalar @descendants + scalar @ids) < XIMS::RECMAXOBJECTS()){
#			    foreach my $desc (@descendants) {
#			    	if($user->object_privmask( $obj )& (XIMS::Privileges::GRANT() || XIMS::Privileges::GRANT_ALL())){
#						push(@ids, $desc->id());
#			    	}
#				}
#			}
#		    else{
#		    	$ctxt->properties->application->styleprefix('common');
#				$ctxt->properties->application->style('error');
#				XIMS::Debug( 2, "to many objects in recursion" );
#				$self->sendError( $ctxt, __x "Current limit is {rec_max_obj}. Please select fewer objects or disable recursion.", rec_max_obj => XIMS::RECMAXOBJECTS() );
#				return 0;
#		    }
#		}
#		#warn "\n\norg_ids: ".scalar @org_ids." -- ids: ".scalar @ids."\n";
#	}
#    #end recursive
#
#	my $id_iterator = XIMS::Iterator::Object->new( \@ids );
#	while ( my $obj = $id_iterator->getNext() ) {
#		foreach(@grantees){
#				my $gid = $_->id();
#				
#				# revoke the privs
#				my $privs_object = XIMS::ObjectPriv->new(
#					grantee_id => $gid,
#					content_id => $obj->id()
#				);
#				
#				my $boolean = ($privs_object and $privs_object->delete());
#				if ($boolean) {
#					XIMS::Debug( 5, "ACL privs changed for (" . $_->name() . ")" );
#					#$ctxt->properties->application->style('obj_user_update');
##					my $granted = XIMS::User->new( id => $uid );
##					$ctxt->session->message(
##						__x("Privileges changed successfully for user/role '{name}'.",
##							name => $granted->name(),
##						)
##					);
#				}
#				else {
#					XIMS::Debug( 2, "ACL grant failure on ". $obj->document_id . " for ". $_->name() );
#				}
#			}
#			#$ctxt->properties->application->style('obj_user_update');
#    }
#	XIMS::Debug( 4, "redirecting to the container" );
#    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id ) );
#    return 0;
#    }
#	else{
#		$ctxt->properties->application->styleprefix('common');
#		$ctxt->properties->application->style('error');
#		XIMS::Debug( 2, "no grantee(s) provided" );
#		$self->sendError( $ctxt, __ "Please provide at least one grantee." );
#		return 0;
#	}
#}

# END RUNTIME EVENTS
# #############################################################################

=head2   get_display_params()

=head3 Parameter

    $ctxt: AppContext object.

=head3 Returns

A reference to a hash:

    {
        offset => $offset,
        limit  => $limit,
        order  => $order,
        style  => $style,
    }

=head3 Description
    
    my $display_params = $self->get_display_params($ctxt);

A common method to get the values for display-styles (ordering, pagination,
custom stylesheet names) merged from defaults, container attributes, and
CGI-parameters.

=cut

sub get_display_params {
    my ( $self, $ctxt ) = @_;
    my $defaultsortby = $ctxt->object->attribute_by_key('defaultsortby');
    my $defaultsort   = $ctxt->object->attribute_by_key('defaultsort');

    # only sort by title 
    if($defaultsortby eq 'titlelocation') {
    	$defaultsortby = $ctxt->session->user->userprefs->containerview_show() || '';
    }

    # maybe put that into config values
    $defaultsortby ||= 'position';
    $defaultsort   ||= 'asc';

    unless ( $self->param('sb') and $self->param('order') ) {
        $self->param( 'sb',    $defaultsortby );
        $self->param( 'order', $defaultsort );
        $self->param( 'defsorting', 1 );    # tell stylesheets not to pass
                                            # 'sb' and 'order' params when
                                            # linking to children
    }

    # The params override attribute and default values
    else {
        $defaultsortby = $self->param('sb');
        $defaultsort   = $self->param('order');
    }

    my %sortbymap = (
        date     => 'last_modification_timestamp',
        position => 'position',
        title    => 'title',
        location    => 'location'
    );
	#XIMS::Debug(5,"defaultsortby: ".$defaultsortby.", defaultsort: ".$defaultsort);
    my $order = $sortbymap{$defaultsortby} . ' ' . $defaultsort;

    my $style = $self->param('style');

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;

    my $limit;
    if ( defined $self->param('onepage') or defined $style ) {
        $limit = undef;
    }
    else {
        $limit = $self->param('pagerowlimit');
        unless ($limit) {
            $limit ||= $ctxt->object->attribute_by_key('pagerowlimit');
            $limit ||= XIMS::SEARCHRESULTROWLIMIT();

            # set for stylesheet consumation;
            $self->param( 'searchresultrowlimit', $limit );
        }
        $offset ||= 0;
        $offset = $offset * $limit;
    }
    my $showtrashcan = $self->param('showtrashcan');
    $showtrashcan ||= 0;

	#XIMS::Debug(5,"offset: ".$offset.", limit: ".$limit.", order: ".$order.", showtrashcan: ".$showtrashcan);
    return (
        {
            offset => $offset,
            limit  => $limit,
            order  => $order,
            style  => $style,
            showtrashcan => $showtrashcan,
        }
    );
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

