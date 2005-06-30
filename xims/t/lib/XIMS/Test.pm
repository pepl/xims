package XIMS::Test;
use lib "../../../lib";
use strict;
use XIMS;
use XIMS::DataProvider;
use XIMS::Config;
use LWP::UserAgent;
use HTTP::Cookies;
use XML::Schematron::LibXSLT;
use Data::Dumper;
use Storable qw( retrieve store );

use vars qw( %Conf );

BEGIN {
   my $app_config = {};
   eval {
       $app_config = retrieve('lib/XIMS/.ximstest.conf');
   };

   if ( $@ ) {
       die "No config file found. use the ximstest.pl tool to create one.\n"
   }
   else {
      %Conf = %{$app_config};
   }
}

# fake the config
sub XIMS::Config::DBMS() { return $Conf{DBMS} }
sub XIMS::Config::DBUser() { return $Conf{DBUser} }
sub XIMS::Config::DBName() { return $Conf{DBName} }
sub XIMS::Config::DBPassword() { return $Conf{DBPassword} }
 
##################################
# some helpful subs
##################################

my $found_cookie;

sub new {
    my $class = shift;
    my %self = ( UA => LWP::UserAgent->new() );
    $self{UA}->agent("XIMSTester/0.1 ");
    return bless \%self, $class;
}

sub login {
    my $self = shift;
    my ( $user, $pass ) = @_;
    $user ||= $Conf{user_name};
    $pass ||= $Conf{password};
    my $url = $Conf{http_host} . '/goxims/defaultbooknark';
    my $req = HTTP::Request->new(POST => $url);
    $req->content_type('application/x-www-form-urlencoded');
    $req->content("userid=$user&password=$pass");

    # Pass request to the user agent and get a response back
    my $res = $self->{UA}->request($req);
    my $cookie_parser = HTTP::Cookies->new();
    $cookie_parser->extract_cookies( $res );
    $cookie_parser->scan( \&cookie_scan );
    if ( length( $found_cookie )  > 0 ) {
        #print "user $user logged in\n";
        $self->{Cookie} = $cookie_parser;
        $self->{session_id} = $found_cookie; 
        $self->{logged_in} = 1;
        return $res;
    }
    return undef;
}

sub get {
    my $self = shift;
    my $uri = $_[0];
    $uri = $Conf{http_host} . '/goxims' . $uri;
    warn "getting $uri \n";
    my $req = HTTP::Request->new(GET => $uri);
    $self->{Cookie}->add_cookie_header( $req );
    my $res = $self->{UA}->request( $req );
    return $res;
}

sub cookie_scan {
    $found_cookie = $_[2] if $_[1] eq 'session';
}

sub validate_xml {
    my $self = shift;
    my ( $xml, $schema ) = @_;
    my $tron = XML::Schematron::LibXSLT->new();
    $tron->schema( $schema );
    my @messages = $tron->verify( $xml );
    return @messages;
}

sub object_type_names {
   my $dp = data_provider();
   my $data = $dp->{Driver}->{dbh}->fetch_select( sql => 'select name from ci_object_types' );
   my @names = map { values( %{$_} ) } @{$data};
   return @names;
}
   
sub data_provider {
   return XIMS::DataProvider->new();
}

1;
