
=head1 NAME

XIMS::Test

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Test;

=head1 DESCRIPTION

A helper module for the tests in t/.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Test;

use lib "../../../lib";
use strict;
no warnings 'redefine';
use XIMS;
use XIMS::DataProvider;
use LWP::UserAgent;
use HTTP::Cookies;
use XML::Schematron;

#use Data::Dumper;
use Sys::Hostname;
use Storable qw( retrieve store );

our %Conf;

BEGIN {
    my $app_config = {};
    eval { $app_config = retrieve('lib/XIMS/.ximstest.conf'); };

    warn "No config file found. Trying values from 'ximsconfig.xml'.\n" if $@;
    %Conf = %{$app_config} unless $@;
    $Conf{DBUser}     ||= XIMS::Config::DBUser();
    $Conf{DBPassword} ||= XIMS::Config::DBPassword();
    $Conf{DBdsn}      ||= XIMS::Config::DBdsn();

}

# fake the config if config file exists
sub XIMS::Config::DBdsn      { return $Conf{DBdsn} }
sub XIMS::Config::DBUser     { return $Conf{DBUser} }
sub XIMS::Config::DBPassword { return $Conf{DBPassword} }

# provide some default values if we do not have a config file
$Conf{user_name} ||= 'xgu';
$Conf{password}  ||= 'xgu';
$Conf{http_host} ||= 'http://' . hostname();

# some helpful subs

my $found_cookie;

sub new {
    my $class = shift;
    my %self  = (
        UA => LWP::UserAgent->new(
            requests_redirectable => [ 'GET', 'POST' ],
            cookie_jar            => HTTP::Cookies->new(),
        )
    );
    $self{UA}->agent("XIMSTester/0.1 ");
    return bless \%self, $class;
}

sub login {
    my $self = shift;
    my ( $user, $pass ) = @_;
    $user ||= $Conf{user_name};
    $pass ||= $Conf{password};
    my $url = $Conf{http_host} . '/goxims/user';

    # warn "using: " . $user . ' ' . $pass . ' ' . $url;
    my $req = HTTP::Request->new( POST => $url );
    $req->content_type('application/x-www-form-urlencoded');
    $req->content("dologin=1&userid=$user&password=$pass");

    # Pass request to the user agent and get a response back
    my $res = $self->{UA}->request($req);
    $res = $self->{UA}->request($req);
    my $cookie_parser = $self->{UA}->cookie_jar();
    $cookie_parser->extract_cookies();
    $cookie_parser->scan( \&cookie_scan );
    if ( length($found_cookie) > 0 ) {

        #print "user $user logged in\n";
        $self->{Cookie}     = $cookie_parser;
        $self->{session_id} = $found_cookie;
        $self->{logged_in}  = 1;
        return $res;
    }
    return;
}

sub get {
    my $self = shift;
    my $uri  = $_[0];
    $uri = $Conf{http_host} . '/goxims' . $uri;

    #warn "getting $uri \n";
    my $req = HTTP::Request->new( GET => $uri );
    $self->{Cookie}->add_cookie_header($req);
    my $res = $self->{UA}->request($req);
    return $res;
}

sub cookie_scan {
    $found_cookie = $_[2] if $_[1] eq 'session';
}

sub validate_xml {
    my $self = shift;
    my ( $xml, $schema ) = @_;
    my $tron = XML::Schematron->new_with_traits( traits => ['LibXSLT'] );
    $tron->schema($schema);
    my @messages = $tron->verify($xml);
    return @messages;
}

sub object_type_names {
    my $dp = data_provider();
    my $data =
      $dp->{Driver}->{dbh}->fetch_select(
        sql => 'select name from ci_object_types where parent_id IS NULL' );
    my @names = map { values( %{$_} ) } @{$data};
    return @names;
}

sub data_provider {
    return XIMS::DataProvider->new();
}

1;

__END__

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2013 The XIMS Project.

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

