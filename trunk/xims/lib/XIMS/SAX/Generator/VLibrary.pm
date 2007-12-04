=head1 NAME

XIMS::SAX::Generator::VLibrary

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Generator::VLibrary;

=head1 DESCRIPTION

SAX::Generator for Vlibrary objects.

Some structures are inserted conditionally for certain XIMS::CGI events.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Generator::VLibrary;

use strict;
use base qw(XIMS::SAX::Generator::Content);

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 prepare

=head3 Parameter

    $ctxt : the appcontext object

=head3 Returns

    $doc_data : hash ref to be given to be mangled by
                XML::Generator::PerlData

=head3 Description

    $generator->prepare( $ctxt );

=cut

sub prepare {
    XIMS::Debug( 5, "called" );
    my $self         = shift;
    my $ctxt         = shift;
    my %object_types = ();
    my %data_formats = ();

    $self->{FilterList} = [];

    my $doc_data = { context => {} };
    $doc_data->{context}->{session} = { $ctxt->session->data() };
    $doc_data->{context}->{session}->{user} = { $ctxt->session->user->data() };

    $doc_data->{context}->{object} = { $ctxt->object->data() };

    $self->_set_parents( $ctxt, $doc_data, \%object_types, \%data_formats );

    # add the user's privs.
    my %userprivs = $ctxt->session->user->object_privileges( $ctxt->object() );
    $doc_data->{context}->{object}->{user_privileges} = {%userprivs}
      if ( grep { defined $_ } values %userprivs );

    if ( not $ctxt->parent() ) {

        # Left here for amusement.
        # if ( $ctxt->properties->application->style() eq "edit_subject" ) {
        #     $doc_data->{context}->{vlsubjectinfo} =
        #       { subject => $ctxt->object->vlsubjectinfo_granted() };
        # }
        # else {
        #     $doc_data->{context}->{vlsubjectinfo} =
        #       { subject => $ctxt->object->vlsubjectinfo_granted() };
        # }

        if (
            !$ctxt->properties->application->style()    # event_default
            || $ctxt->properties->application->style() eq "subjects"
            || $ctxt->properties->application->style() eq "subject_edit"
        ) {
            $doc_data->{context}->{vlsubjectinfo} =
              { subject => $ctxt->object->vlsubjectinfo_granted() };
        }
        elsif ( $ctxt->properties->application->style() eq "authors" ) {
            $doc_data->{context}->{vlauthorinfo} =
              { author => $ctxt->object->vlauthorinfo_granted() };
        }
        elsif ( $ctxt->properties->application->style() eq "publications" ) {
            $doc_data->{context}->{vlpublicationinfo} =
              { publication => $ctxt->object->vlpublicationinfo_granted() };
        }
        elsif ( $ctxt->properties->application->style() eq "keywords" ) {
            $doc_data->{context}->{vlkeywordinfo} =
              { keyword => $ctxt->object->vlkeywordinfo_granted() };
        }
        elsif ( $ctxt->properties->application->style() eq "filter_create" ) {
            $doc_data->{context}->{vlsubjectinfo} =
              { subject => $ctxt->object->vlsubjectinfo_granted() };
            $doc_data->{context}->{vlmediatypeinfo} =
              { mediatype => $ctxt->object->vlmediatypeinfo_granted() };
            $doc_data->{context}->{vlkeywordinfo} =
              { keyword => $ctxt->object->vlkeywordinfo_granted() };
        }

    }

    if ( $ctxt->objectlist() ) {
        if ( scalar( @{ $ctxt->objectlist() } ) > 0 ) {
            if ( $ctxt->properties->content->objectlistpassthru() != 1 ) {
                foreach my $child ( @{ $ctxt->objectlist() } ) {
                    bless $child, "XIMS::VLibraryItem";

                    # added the users object privileges if he got one
                    my %uprivs =
                      $ctxt->session->user->object_privileges($child);
                    $child->{user_privileges} = {%uprivs}
                      if ( grep { defined $_ } values %uprivs );

                    # TODO
                    # yet another superfluos db hit! this has to be changed!!!
                    $child->{content_length} = $child->content_length();
                    $child->{authorgroup} =
                      { author => [ $child->vleauthors() ] };
                    $child->{meta} = [ $child->vlemeta() ];
                }
            }
            $doc_data->{context}->{object}->{children} =
              { object => $ctxt->objectlist() };
        }
    }

    # for ACL management
    if ( $ctxt->userlist() ) {

        # my @user_list = map{ $_->data() ) } @{$ctxt->userlist()};
        $doc_data->{userlist} = { user => $ctxt->userlist() };
    }

    # for ACL management
    if ( $ctxt->user() ) {
        $doc_data->{context}->{user} = $ctxt->user();
    }

    # Repositioning
    if ( defined $ctxt->properties->content->siblingscount() ) {
        $doc_data->{context}->{object}->{siblingscount} =
          $ctxt->properties->content->siblingscount();
    }

    my %object_types = ();
    my %data_formats = ();
    $object_types{ $ctxt->object->object_type_id() } = 1;
    $data_formats{ $ctxt->object->data_format_id() } = 1;

    $self->_set_formats_and_types( $ctxt, $doc_data, \%object_types,
        \%data_formats );

    return $doc_data;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2007 The XIMS Project.

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
