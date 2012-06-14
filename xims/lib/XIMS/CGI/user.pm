
=head1 NAME

XIMS::CGI::user -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::user;

=head1 DESCRIPTION

It is based on XIMS::CGI.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::user;

use strict;
use base qw( XIMS::CGI );
use XIMS::User;
use XIMS::UserPrefs;
use XIMS::Bookmark;
use XIMS::UserPrefs;
use XIMS::DepartmentRoot;
use XIMS::Object;
use XIMS::ObjectPriv;
use XIMS::Document;
use XIMS::Importer::Object;
use XIMS::Term;
use Getopt::Std;
use XIMS::Exporter;
use Digest::MD5 qw( md5_hex );
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
          default
          passwd
          passwd_update
          prefs
          bookmarks
          newwebsite
          gen_website
          )
        );
}

=head2 event_init()

=cut

sub event_init {
    my $self = shift;
    my $ctxt = shift;
    $self->SUPER::event_init( $ctxt );

    # sanity check
    return $self->event_access_denied( $ctxt ) unless $ctxt->session->user();

    $ctxt->sax_generator( 'XIMS::SAX::Generator::User' );
}

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # to resolve the bookmark paths
    $self->resolve_content( $ctxt, [ qw( CONTENT_ID ) ] );

    # to resolve the role names
    $self->resolve_user( $ctxt, [ qw( OWNER_ID ) ] );

    # fill $ctxt->objectlist with the 5 last modified objects readable by the user
    # we do not want to see the auto-generated .diff_to_second_last here
    my $object = XIMS::Object->new( User => $ctxt->session->user() );
    
    #deactivated because this information mighty confuse the normal users
#    my @lmobjects = $object->find_objects_granted( criteria => "title <> '.diff_to_second_last'",
#                                                   limit => 5 );
#    $ctxt->objectlist( \@lmobjects );

    # fill $ctxt->userobjectlist with the 5 objects most recently created or modified by the user
    my $qbdriver;
    if ( XIMS::DBMS() eq 'DBI' ) {
        $qbdriver = XIMS::DBDSN();
        $qbdriver = ( split(':',$qbdriver))[1];
    }
    else {
        XIMS::Debug( 2, "search not implemented for non DBI DPs" );
        $ctxt->session->error_msg( __"Search mechanism has not yet been implemented for non DBI based datastores!" );
        return 0;
    }

    $qbdriver = 'XIMS::QueryBuilder::' . $qbdriver . XIMS::QBDRIVER();
    eval "require $qbdriver"; #
    if ( $@ ) {
        XIMS::Debug( 2, "querybuilderdriver $qbdriver not found" );
        $ctxt->session->error_msg( __"QueryBuilder-Driver could not be found!" );
        return 0;
    }

    my $search = "u:".$ctxt->session->user->name();

    # Make sure the utf8 flag is turned on, since it may not depending on the DBD driver version
    if ( not XIMS::DBENCODING() ) {
        require Encode;
        Encode::_utf8_on($search);
    }

    my $qb = $qbdriver->new( { search => $search } );
    if ( defined $qb ) {
        my ($critstring, @critvals) = @{$qb->criteria()};
        my @lmuobjects = $object->find_objects_granted( criteria => [ $critstring . " AND title <> '.diff_to_second_last'", @critvals ],
                                                        limit => 5,
                                                      );
        $ctxt->userobjectlist( \@lmuobjects );
    }
    else {
        XIMS::Debug( 3, "QueryBuilder could not find userobjectlist objects" );
    }
}

# the 'change password' data entry screen

=head2 event_passwd()

=cut

sub event_passwd {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::CHANGE_PASSWORD() ) {
        return $self->event_access_denied( $ctxt );
    }

    $ctxt->properties->application->style( 'passwd' );
}
# the 'change password' confirmation and data handling screen

=head2 event_passwd_update()

=cut

sub event_passwd_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::CHANGE_PASSWORD() ) {
        return $self->event_access_denied( $ctxt );
    }

    my $user = $ctxt->session->user();

    my $pass = $self->param('password');
    my $pass1 = $self->param('password1');
    my $pass2 = $self->param('password2');

    if ( $user->validate_password( $pass ) ) {
        if ($pass1 eq $pass2 and length ($pass1) > 0) {
            $user->password( Digest::MD5::md5_hex( $pass1 ) );

            if ( $user->update() ) {
                $ctxt->properties->application->style( 'update' );
                $ctxt->session->message( __"Password updated successfully." );
            }
            else {
                $self->sendError( $ctxt,"Password update failed. Please check with your system adminstrator.");
            }
        }
        # otherwise, entered passwds were not the same, kick
        # 'em back to the prompt.
        else {
            $ctxt->properties->application->style( 'passwd' );
            $ctxt->session->warning_msg( __"Passwords did not match." );
        }
    }
    else {
        $ctxt->properties->application->style( 'passwd' );
        $ctxt->session->warning_msg( __"Wrong Password." );
    }
}

=head2 event_bookmarks()

=cut

sub event_bookmarks {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style( 'bookmarks' );

    $self->resolve_content( $ctxt, [ qw( CONTENT_ID ) ] );
    $self->resolve_user( $ctxt, [ qw( OWNER_ID ) ] );

    return 0;
}

=head2 event_prefs()

=cut

sub event_prefs {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    $ctxt->properties->application->style( 'prefs' );
    $ctxt->session->message( __"User's preferences updated successfully." );

    $self->resolve_content( $ctxt, [ qw( CONTENT_ID ) ] );
    $self->resolve_user( $ctxt, [ qw( OWNER_ID ) ] );

    return 0;
}

=head2 event_newwebsite()

=cut

sub event_newwebsite {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

	
    $ctxt->properties->application->style( 'newwebsite' );

    $self->resolve_content( $ctxt, [ qw( CONTENT_ID ) ] );
    $self->resolve_user( $ctxt, [ qw( OWNER_ID ) ] );

    return 0;
}

=head2 event_gen_website()

=cut

sub event_gen_website {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    
    my $user = $ctxt->session->user();

#    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::ADMIN() ) {
#        return $self->event_access_denied( $ctxt );
#    }

# we don't take the system privileges (at the moment)
#    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::GEN_WEBSITE() ) {
#        return $self->event_access_denied( $ctxt );
#    }

    unless ( ($ctxt->session->user->system_privs_mask() & XIMS::Privileges::ADMIN()) || ( $user->userprefs->profile_type() eq 'webadmin' )) {
        return $self->event_access_denied( $ctxt );
    }
    
    my $message = "";
    
    #my $user = $ctxt->session->user();
    
	my $parent_folder = $self->param('path'); #$args{m};	
	my $location = $self->param('shortname'); #$args{l};	
	my $title         = $self->param('title'); #$args{t};
	my $path_deptroot = $parent_folder . $location;
	my $role;
	if($self->param('role')){
		$role = XIMS::User->new( name => $self->param('role') ); #$args{r} );
		warn "\n\nparam: ".$self->param('role')." -  role: ".$role->name;
		$self->sendError( $ctxt,"Could not find role '". $self->param('role') ."'.") 
			unless $role and $role->id();
	}
	my $owner = XIMS::User->new( name => $self->param('owner')); #$args{o} );
		$self->sendError( $ctxt,"Could not find user '". $self->param('owner') ."'.") 
			unless $owner and $owner->id();
	my $grantees_list = $self->param('grantees');
				
	# create Departmentroot with departmentlinks and speciallinks
	
	# set deptroot info text accordingly to new uniweb design
	my $abstract = "<span lang=\"de\">$title</span>";
	$abstract .= "<span lang=\"en\">Insert English title here!</span>";
	my $deptroot = XIMS::DepartmentRoot->new(
		User     => $user,
		location => $location,
		title    => $title,
		abstract => $abstract
	);
	#### set attributes of Departmentroot
	# avoid autoindexing of departmentroot contents
	$deptroot->attribute( autoindex => '0' );
	#TODO: attributes
	
	my $parent = XIMS::Object->new( path => $parent_folder );
	die "Could not find object '" . $parent_folder . "'\n"
	  unless $parent and $parent->id();

	my $importer = XIMS::Importer::Object->new( User => $user, Parent => $parent );

	unless ($importer->import($deptroot)){
		$ctxt->properties->application->style( 'newwebsite' );
		$self->sendError( $ctxt,"Could not import Departmentroot");
	}
		
		my $deptrootid = $importer->import($deptroot);
		if ($deptrootid) {
			$message .= "<p>Departmentroot created.</p>";
		
		#create Home - Document
		my $document = XIMS::Document->new(
			User     => $owner,
			location => 'index.html',
			title    => $title
		);
		$document->body( '<h1>' . $title . '</h1>' );
	
		my $deptimporter = XIMS::Importer::Object->new( User => $user, Parent => $deptroot );
		my $documentid = $deptimporter->import($document);
		unless (defined $documentid){
			$ctxt->properties->application->style( 'passwd' );
			$self->sendError( $ctxt,"Could not import index.html\n"); 
		}
		#print "Successfully created 'index.html'.\n";
	
		$document->title($title);
		$document->abstract($title);
		
		$message .= "<p>Document '".$document->title()."' created.</p>";
		#end create Home document
		
		#departmentlinks & speciallinks
		$message .= &add_link( 'department', $title, $document, $deptroot, $user, $title );
		$message .= &add_link( 'special', 'A sample Bookmark', $document, $deptroot, $user, $title );
		
		# set grants
		defaultgrants( $deptroot, $owner, $role, $user, $grantees_list );
		my $iterator = $deptroot->descendants();
		while ( my $desc = $iterator->getNext() ) {
			defaultgrants( $desc, $owner, $role, $user );
		}
		
		# only set default bookmark if -b is not given as an argument
		if ( not $self->param('nobm') ) {
			$message .= &set_default_bookmark($role, $deptroot);
		}
		$message .= &publish_deptroot_rec($deptroot, $user);
		
#		$ctxt->properties->application->style( 'newwebsite' );
		$message .= "<p><strong>New website <a href='content".$parent_folder.$location."'>".$title."</a> successfully generated!</strong></p>";
#		$ctxt->session->message($message );
		$ctxt->properties->application->style( 'newwebsite_update' );
        $ctxt->session->message($message);
		}
		else{
			$ctxt->properties->application->style( 'newwebsite' );
			$self->sendError( $ctxt,"Could not create DepartmentRoot");
		}
		return 0;
}
		
		
# add special or departmentlinks and create folder and portlet
# add_links($linktype, $object, $title)
sub add_link{
		my $type_of_link  = shift;       #department or special
		my $urllink_title = shift;
		my $document = shift;
		my $deptroot = shift;
		my $user = shift;
		my $title = shift;
		
		my $message = "";
		#my $object        = $document;
		# hardcode alarm
		my $l_location  = $type_of_link . 'links';
		my $lp_location = $l_location . '_portlet.ptlt';


		# check for portlet
#		my @portlet_ids = $deptroot->get_portlet_ids();
#		my $linksportlet;
#		$linksportlet = XIMS::Portlet->new(
#			id             => \@portlet_ids,
#			location       => $lp_location,
#			marked_deleted => undef
#		  )
#		  if $portlet_ids[0];
	my $oimporter = XIMS::Importer::Object->new(
		User   => $deptroot->User,
		Parent => $deptroot
	);	  
		my $linksfolder;
		# add folder 
			$linksfolder = XIMS::Folder->new(
				User     => $deptroot->User,
				location => $l_location
			);
			my $id = $oimporter->import($linksfolder);
			if ( not $id ) {
				XIMS::Debug( 2,"could not create ". $type_of_link. "links folder '$l_location'" );
				return;
			}
			else{
				$message .= "<p>Folder '".$l_location ."' created.</p>"
			}
		# add links
		my $urlimporter = XIMS::Importer::Object::URLLink->new(
			User   => $deptroot->User,
			Parent => $linksfolder
		);
		#return unless $urlimporter;
		
		my $location_path =
		  XIMS::RESOLVERELTOSITEROOTS() eq '1'
		  ? $document->location_path_relative()
		  : $document->location_path();
	
		my $urllink = XIMS::URLLink->new(
			User     => $user,
			location => $location_path,
			title => $urllink_title,
			abstract => $document->abstract(),
		);
		my $urlid = $urlimporter->import($urllink);
		XIMS::Debug( 3,
		    "could not create "
		  . $type_of_link
		  . "link '$location_path'. Perhaps it already exists." )
	  unless $urlid;
		if($urlid){
			$message .= "<p>URLLink '".$urllink->title()."' created in ".$linksfolder->title().".</p>"
		}
		
		# create and assign portlet
			my $lp_location_nosuffix = $lp_location;
			$lp_location_nosuffix =~ s/\.[^\.]+$//;
			my $linksportlet = XIMS::Portlet->new(
				User     => $deptroot->User,
				location => $lp_location,
				title    => $lp_location_nosuffix
			);
			$linksportlet->target($linksfolder);
	
			# *do not look at the following lines, hack-attack!*
			# see portlet::generate_body why this hack is here.
			# REWRITE!
			my $body =
	'<content><column name="abstract"/><column name="location"/><column name="title"/><object-type name="URLLink"/></content>';
			$linksportlet->body($body);
			
			my $id = $oimporter->import($linksportlet);
			$deptroot->add_portlet($linksportlet);
			$deptroot->update();	
			
			$message .= "<p>Portlet '".$linksportlet->title()."' created and assigned to DeptartmentRoot.</p>";	
		
		return $message;
}		

##############################################################################
###########         subroutines     ##########################################
##############################################################################

sub set_default_bookmark {
	XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    
	my $role = shift;
	my $deptroot = shift;
	
	my $message = "";
	
	if(defined $role){
		my $default_bookmark = $role->bookmarks( explicit_only => 1, stdhome => 1 );
		if ($default_bookmark) {
			$default_bookmark->stdhome(undef);
	
			my $bookmark = XIMS::Bookmark->new->data(
				owner_id   => $role->id(),
				stdhome    => 1,
				content_id => $deptroot->id()
			);
			unless ($bookmark->create()){
				$ctxt->properties->application->style( 'newwebsite' );
				$self->sendError( $ctxt,"Could not create default bookmark\n");
			}
			#print "Successfully set default bookmark.\n";
			$message .= "<p>Successfully set default bookmark.<p>";
		}
	}
	return $message;
}

sub defaultgrants {
	my $object = shift;
	my $owner  = shift;
	my $role   = shift;
	my $user = shift;
	my $grantees_list = shift;
	
	my $message = "";

	if (
		$object->grant_user_privileges(
			grantee  => $owner,
			grantor  => $user,
			privmask => ( XIMS::Privileges::MODIFY | XIMS::Privileges::PUBLISH )
		)
	  )
	{
		$message .= "<p>Privileges set for ".$owner."</p>"
	}
	else {
		warn "Could not grant privileges to " . $owner->name() . " .\n";
	}
	
	foreach my $grantee_str (split(',',$grantees_list)){
		my $grantee = XIMS::User->new( name => $grantee_str);
		#warn("\n grantee : ".$grantee->id()."   ".$grantee->name()."\n");
		
		if ($object->grant_user_privileges(
				grantee  => $grantee,
				grantor  => $user,
				privmask => ( XIMS::Privileges::MODIFY | XIMS::Privileges::PUBLISH )
		)
	  )
	{
		$message .= "<p>Privileges set for ".$grantee."</p>"
	}
	else {
		warn "Could not grant privileges to " . $grantee->name() . " .\n";
	}
	}
	
	if($role){
		if (
			$object->grant_user_privileges(
				grantee  => $role,
				grantor  => $user,
				privmask => XIMS::Privileges::VIEW
			)
		  )
		{
		}
		else {
			warn "Could not grant privileges to " . $role->name() . " .\n";
		}
	}
}

sub rebless {
	my $object  = shift;
	my $otclass = "XIMS::" . $object->object_type->fullname();

	# load the object class
	eval "require $otclass;" if $otclass;
	if ($@) {
		die "Could not load object class $otclass: $@\n";
	}

	# rebless the object
	bless $object, $otclass;
	return $object;
}

sub publish_deptroot_rec {

	#print "\n\t Publish\n";
	
	my $deptroot = shift;
	my $user = shift;

	my $total      = 0;
	my $successful = 0;
	my $failed     = 0;
	
	my $message = "";

	my $path;
	my $exporter =
	  XIMS::Exporter->new( Basedir => XIMS::PUBROOT(), User => $user, );
	my $iterator = $deptroot->descendants();

	while ( my $child = $iterator->getNext() ) {
		$child = rebless($child);
		$path  = $child->location_path();
		if ( $exporter->publish( Object => $child, User => $user ) ) {
			warn "Object '$path' published successfully.\n";
			$successful++;
		}
		else {
			warn "could not publish object '$path'.\n";
			$failed++;
		}
		$total++;
	}
	$path     = $deptroot->location_path();
	$deptroot = rebless($deptroot);
	if ( $exporter->publish( Object => $deptroot, User => $user ) )
	{
		warn "Object '$path' published successfully.\n";
		$successful++;
	}
	else {
		warn "could not publish object '$path'.\n";
		$failed++;
	}
	$total++;

#	print qq*
#    Publish Report:
#        Total files:                    $total
#        Successfully exported:          $successful
#        Failed exported:                $failed

#*;
	
	if (not $failed){ $message .= "<p>All Objects published successfully<p>";}
	return $message;
}

sub remove_user_privileges {
	my $grantee_name = shift;
	my $deptroot = shift;

	#print "\tRemove privileges for $grantee_name \n";

	my $grantee = XIMS::User->new( name => $grantee_name );
	die "Grantee '" . $_ . "' could not be found.\n"
	  unless $grantee
	  and $grantee->id();

	my $path = $deptroot->location_path();

	my $total      = 0;
	my $successful = 0;
	my $failed     = 0;

	my $ok = 1;

	my $privs_object = XIMS::ObjectPriv->new(
		grantee_id => $grantee->id,
		content_id => $deptroot->id()
	);
	if ( not $privs_object ) {
		#print "Grantee $grantee_name does not exist for '$path'.\n";
		$failed++;
	}
	else {

		$ok &= ( $privs_object and $privs_object->delete() );

		if ($ok) {
			#print "Revoked grantee(s)) from '$path'.\n";
			$successful++;
		}
		else {
			#print "Could not revoke grantee(s) from '$path'.\n";
			$failed++;
		}
	}
	$total++;

	my $desc_privmask;
	my $iterator = $deptroot->descendants();

	while ( my $desc = $iterator->getNext() ) {
		$path = $desc->location_path();

		my $ok           = 1;
		my $privs_object = XIMS::ObjectPriv->new(
			grantee_id => $grantee->id,
			content_id => $desc->id()
		);
		if ( not $privs_object ) {
			#print "Grantee $grantee_name does not exist for '$path'.\n";
			$failed++;
		}
		else {
			$ok &= ( $privs_object and $privs_object->delete() );

			if ($ok) {
				#print "Revoked grantee from '$path'.\n";
				$successful++;
			}
			else {
				#print "Could not revoke grantee from '$path'.\n";
				$failed++;
			}

		}
		$total++;
	}

#	print qq*
#    Privileges Report:
#        Total files:                    $total
#        Successful:                     $successful
#        Failed:                         $failed

#*;
	return 1;
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

