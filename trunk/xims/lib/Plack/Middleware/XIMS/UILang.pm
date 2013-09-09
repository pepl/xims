
=head1 NAME

XIMS::Middleware::XIMSUILang -- set and cleanup XIMS UI-language parameters

=head1 VERSION

$Id: $

=cut

package Plack::Middleware::XIMS::UILang;
use parent qw( Plack::Middleware );
use Plack::Request;
use HTTP::Throwable::Factory qw(http_throw);
use XIMS;
use POSIX qw(setlocale LC_ALL);


sub call {
    my ( $self, $env ) = @_;

    my $langpref = getLanguagePref($env);

    if ( $langpref eq 'de-at' ) {
        setlocale( LC_ALL, "de_AT.UTF-8" );
    }
    else {
        setlocale( LC_ALL, "en_US.UTF-8" );
    }
    if ($env->{'xims.appcontext'}->session){
        $env->{'xims.appcontext'}->session->uilanguage($langpref);
    }
    else {
        http_throw(InternalServerError =>  {message     => "\nMissing Session."});
    }

    my $res = $self->app->($env);

    setlocale( LC_ALL, 'C' );

    return $res;
}


=head2    getLanguagePref($r)

=head3 Parameter

    $env:    PGSI environment hash      (mandatory)

=head3 Returns

    $retval: interface language (string)

=head3 Description

loose implementation of what is described in:
http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4

=cut

sub getLanguagePref {
    my $env       = shift;
    my $req       = Plack::Request->new($env);
    my $langrex = qr/(\w{1,8}(?:-\w{1,8})?)(?:;q=([0|1](?:\.\d{1,3})?))?/;
    my %langprefs;
    my %havelangs = XIMS::UILANGUAGES();

    # parse Header
    foreach my $pref_field ( split( /,/, $req->header('Accept-Language') ) ) {
        my $qvalue;
        $pref_field =~ $langrex;
        $qvalue = $2 or $qvalue = '1';
        push @{ $langprefs{$qvalue} }, $1;
    }

    # compare
    foreach my $wantlang ( reverse sort keys(%langprefs) ) {
        foreach my $langpref ( keys %havelangs ) {
            map { $_ =~ $havelangs{$langpref} ? return $langpref : next; }
              @{ $langprefs{$wantlang} };
        }
    }

    return XIMS::UIFALLBACKLANG();
}


1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Look at F<ximshttpd.conf> for some well-commented examples.

=head1 BUGS AND LIMITATION

Language-preference handling does not comply to RFC 2616.

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

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

