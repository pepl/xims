
=head1 NAME

XIMS::Middleware::AppContext -- prepares the XIMS::AppContext in PSGI's environment

=head1 VERSION

$Id: $

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

package Plack::Middleware::XIMS::AppContext;
use parent qw( Plack::Middleware );
use XIMS::AppContext;
use HTTP::Exception;

sub call {
    my($self, $env) = @_;

    # Add XIMS::AppContext in $env
    $env->{'xims.appcontext'} = XIMS::AppContext->new();
    $env->{'xims.appcontext'}->{data_provider} = XIMS::DATAPROVIDER();
    unless ($env->{'xims.appcontext'}->{data_provider}->isa('XIMS::DataProvider')) {
        HTTP::Exception::500->throw;
    }

    # $self->app is the original app
    my $res = $self->app->($env);

    return $res;
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

Copyright (c) 2002-2017 The XIMS Project.

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

