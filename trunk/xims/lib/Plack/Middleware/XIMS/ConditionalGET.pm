package Plack::Middleware::XIMS::ConditionalGET;
use common::sense;
use parent qw( Plack::Middleware );
use Time::Piece;
use XIMS;
use POSIX qw(setlocale LC_TIME);

=head1 NAME

   Plack::Middleware::XIMS::ConditionalGET

=head1 VERSION

$Id: $

=head1 DESCRIPTION

This L<Plack::Middleware> implements conditional HTTP requests for
gopublic-published objects based on timestamps of the requested object and its
dependencies. It allows therefore to deliver read-only gopublic-published
objects very efficiently -- and even more so, when combined with a standard HTTP
cache of your choice (e. g. Apache’s mod_cache).

This aims to replace the gone C<Apache::AxKit::Provider::XIMSGoPublic>

Some code was taken and modified from L<Plack::Middleware::ConditionalGET>.


=head1 SUBROUTINES/METHODS

=head2 call()

=cut

sub call {
    my $self = shift;
    my $env  = shift;
    my $req = Plack::Request->new($env);

    if ( $env->{REQUEST_METHOD} ne 'GET' ) {
        return [405, ['Content-Type', 'text/plain; charset=UTF-8'], ['Method Not Allowed']];
    }

    unless ( $env->{'xims.appcontext'}->object( get_public_object($req) ) ) {
        return [404, ['Content-Type', 'text/plain; charset=UTF-8'], ['Not Found']];
    }

    $env->{'xims.appcontext'}->{mtime} = find_mtime( $env->{'xims.appcontext'}->object() );

    # NotModified? 304, over and out.
    if ( not_modified_since( $env ) ) {
        return [304, ['Last-Modified', $env->{'xims.appcontext'}->{mtime},
                      'Cache-Control', 'public, s-maxage=300'], [] ];
    }
    else {
        return $self->app->($env);
    }
}


=head2 get_public_object()

=cut

sub get_public_object {
    my $req = shift;
    my (%args, $id, $object);

    if ($id = $req->param('id') and $id > 0 ) {
        $args{id} = $id;
    }
    else {
        # we don’t deal with interfaces, better mount it right in the first
        # place.
        $args{path} = $req->path();
    }

    if ($object = XIMS::Object->new(
            %args,
            User     => XIMS::User->new( id => XIMS::PUBLICUSERID() ),
            language => 2
        )
        and $object->published()
        )
    {
        return $object;
    }
    return;
}


=head2 find_mtime()

=cut

sub find_mtime {

    my $object = shift or return;
    my ( $last_published_desc, $last_published_style, $stylesheet );

    # Get the most recent publication timestamp of the object, its
    # descendants, or of the descendants of an assigned stylesheet directory
    ( undef, undef, $last_published_desc )
        = $object->data_provider->get_descendant_infos(
        parent_id => $object->document_id() );

    $stylesheet = $object->stylesheet();
    if ( defined $stylesheet ) {
        ( undef, undef, $last_published_style )
            = $object->data_provider->get_descendant_infos(
            parent_id => $stylesheet->document_id() );
    }

    my @times = (
        Time::Piece->strptime(
            $object->last_publication_timestamp(),
            "%Y-%m-%d %H:%M:%S"
        )
    );
    if ( defined $last_published_desc ) {
        push(
            @times,
            Time::Piece->strptime(
                $last_published_desc, "%Y-%m-%d %H:%M:%S"
            )
        );
    }
    if ( defined $last_published_style ) {
        push(
            @times,
            Time::Piece->strptime(
                $last_published_style, "%Y-%m-%d %H:%M:%S"
            )
        );
    }

    my @sorted_times = sort { $a <=> $b } @times;
    my $latest = $sorted_times[-1];

    # TZ correction
    $latest -= localtime->tzoffset;

    # Locale-fu :-/
    my $olc = setlocale( LC_TIME );
    setlocale( LC_TIME, 'C' );

    my $rv = $latest->strftime("%a, %d %b %Y %H:%M:%S GMT");

    setlocale( LC_TIME, $olc );

    return $rv;

}


# Ahead: Code taken and modified from Plack::Middleware::ConditionalGET.

=head2 not_modified_since()

=cut

sub not_modified_since {
    my($env) = @_;
    $env->{'xims.appcontext'}->{mtime} eq _value($env->{HTTP_IF_MODIFIED_SINCE});
}

sub _value {
    my $str = shift;
    # IE sends wrong formatted value(i.e. "Thu, 03 Dec 2009 01:46:32 GMT; length=17936")
    $str =~ s/;.*$//;
    return $str;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2013 The XIMS Project.

See the file F<LICENSE> for information and conditions for use,
reproduction, and distribution of this work, and for a DISCLAIMER OF ALL
WARRANTIES.

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
