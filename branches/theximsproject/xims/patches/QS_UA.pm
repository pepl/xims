package Apache::AxKit::StyleChooser::QS_UA;

use strict;
use vars qw($VERSION);

$VERSION = '0.01';

use Apache::Constants qw(OK);

sub handler {
    my $r = shift;

    my %in = $r->args();
    if ($in{style}) {
        $r->notes('preferred_style', $in{style});
    }
    else {
      my @UAMap;
      my @aoh = split /\s*,\s*/, $r->dir_config('AxUAStyleMap');
      foreach (@aoh) {
          push (@UAMap, [ split /\s*=>\s*/, $_ ]);
      }
      # warn "checking UA: $ENV{HTTP_USER_AGENT}\n";

      UA: foreach my $ua (@UAMap) {
          if ($ENV{HTTP_USER_AGENT} =~ /$ua->[1]/g) {
              # warn "found UA $ua->[1], setting 'preferred_style' to $ua->[0]\n";
              $r->notes('preferred_style', $ua->[0]);
              last UA;
          }
      }
    }

    return OK;
}

1;
__END__

=head1 NAME

Apache::AxKit::StyleChooser::QS_UA - Choose stylesheets based on QueryString and user agent.

=head1 SYNOPSIS
    In your .conf or .htaccess file(s):
    
    AxAddPlugin Apache::AxKit::StyleChooser::QS_UA

    PerlSetVar AxUAStyleMap "lynx     => Lynx,\
                             explorer => MSIE,\
                             opera    => Opera,\
                             netscape => Mozilla"

=head1 DESCRIPTION

Merge of Apache::AxKit::StyleChooser::QueryString and Apache::AxKit::StyleChooser::UserAgent;

This module sets the internal preferred style based on the user agent
string presented by the connecting client if it finds no "style=" querystring value.

See the B<AxStyleName> AxKit configuration directive
for more information on how to setup named styles.

=cut

=head1 AUTHOR

