# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Installer;

use strict;

use CPAN;

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my $self = bless {}, $class;

    my @required_mods = (
                [ "Digest::MD5", '' ],
                [ "Storable", '' ],
                [ "XML::LibXML", '1.52' ],
                [ "XML::LibXSLT", '1.49' ],
                [ "DBI", '' ],
                [ "AxKit", '1.51' ],
                [ "AxKit::XSP::Param", '' ],
                [ "AxKit::XSP::IfParam", '' ],
                [ "AxKit::XSP::WebUtils", '1.6' ],
                [ "Apache::AxKit::Plugin::AddXSLParams::Request", '' ],
                [ "XML::Parser::PerlSAX", '' ],
                [ "XML::SAX::Machines", '' ],
                [ "XML::Generator::PerlData", '' ],
                [ "XML::Filter::GenericChunk", '' ],
                [ "CGI::XMLApplication", '1.1.2' ],
                [ "Class::MethodMaker", '' ],
                [ "DBIx::SQLEngine", '0.0.8' ],
                [ "Time::Piece", '' ],
                [ "XML::Schematron", '' ],
                [ "Apache::DBI", '' ],
                [ "CSS::Tiny", '' ],
                [ "Term::ReadKey", '' ],
              );

    my @optional_mods = ();

    $self->{RequiredMods} = \@required_mods;
    $self->{OptionalMods} = \@optional_mods;

    return $self;
}

sub required_mods { return shift->{RequiredMods} }
sub optional_mods { return shift->{OptionalMods} }

sub check_required_mods {
    my $self = shift;
    my @retval = ();

    my @required = @{$self->required_mods()};

    foreach my $mod ( @required ) {
        my $modname = $mod->[0];
        my $modversion = $mod->[1];
        my $module = CPAN::Shell->expand('Module',$modname);
        warn $modname . " could not be found on CPAN!\n" unless $module;
        if ( not $module->inst_version() or CPAN::Version->vgt($modversion, $module->inst_version()) ) {
            push (@retval, $module);
        }
    }
    return @retval;
}

sub expand_mods {
    my $self = shift;
    my @mods = @_;
    my @retval = ();

    foreach my $mod ( @mods ) {
        my $module = CPAN::Shell->expand('Module',$mod);
        if ( not $module->inst_version() ) {
            push (@retval, $module);
        }
    }
    return @retval;
}

sub prompt {
    my $self= shift;
    my $def = shift;
    print $def->{text} . "\n";
    if ( $def->{default} ) {
        print '[' . $def->{default} . ']';
    }
    print ': ';

    while (<>) {
      chomp;
      if ( $_ =~ /$def->{re}/ ) {
          ${$def->{var}} = $_;
          last;
      }
      elsif ( length($_) == 0 and defined( $def->{default} ) ) {
          ${$def->{var}} = $def->{default};
          last;
      }
      else {
          print $def->{error} . "\n";
          $self->prompt( $def ) && last;
      }
   }
}

sub httpd_conf {
    my $self = shift;
    my $conf = shift;

    if ( defined $conf ) {
        $self->{ApacheHttpdConf} = $conf;
        return $self->{ApacheHttpdConf};
    }
    elsif ( defined $self->{ApacheHttpdConf} ) {
        return $self->{ApacheHttpdConf};
    }

    eval { require Apache::MyConfig; };
    if ( $@ ) {
      die "Could not load Apache::MyConfig. Make sure mod_perl is installed and working!\n";
    }

    if ( defined $Apache::MyConfig::Setup{APACHE_PREFIX} and length $Apache::MyConfig::Setup{APACHE_PREFIX} ) {
        $self->{ApacheHttpdConf} = $Apache::MyConfig::Setup{APACHE_PREFIX} . '/conf/httpd.conf';
    }
    elsif ( -f '/usr/local/apache/conf/httpd.conf' ) {
        $self->{ApacheHttpdConf} = '/usr/local/apache/conf/httpd.conf';
    }
    elsif ( -f '/etc/httpd.conf' ) {
        $self->{ApacheHttpdConf} = '/etc/httpd.conf';
    }
    elsif ( -f '/etc/apache/httpd.conf' ) {                            # Debian
        $self->{ApacheHttpdConf} = '/etc/apache/httpd.conf';
    }
    elsif ( -f '/usr/local/etc/apache/httpd.conf' ) {                  # FreeBSD-Port www/apache
        $self->{ApacheHttpdConf} = '/usr/local/etc/apache/httpd.conf';
    }
    return $self->{ApacheHttpdConf};
}

sub parse_httpd_conf {
    my $self = shift;
    open(CONF, $self->httpd_conf()) || die "Can't open " . $self->httpd_conf() . ": $!";
    while (<CONF>) {
        if ( /^\s*DocumentRoot\s+["|']?([\w\/.-_]+)["|']?/) {
            $self->{ApacheDocumentRoot} = $1;
        }
        if ( /^\s*User\s+["|']?([\w.!@#$%^&*()+=-]+)["|']?/) {
            $self->{ApacheUser} = $1;
        }
        if ( /^\s*Group\s+["|']?([\w.!@#$%^&*()+=-]+)["|']?/) {
            $self->{ApacheGroup} = $1;
        }

        # ZEYA: room for improvement here:
        #       if the XIMS_PREFIX changes, the installer wont update these two...
        if ( /^\s*Include\s+["|']?\/\S+\/xims\/conf\/ximshttpd.conf["|']?/) {
            $self->{ximshttpdconf} = 1;
        }
        if ( /^\s*PerlRequire\s+["|']?\/\S+\/xims\/conf\/ximsstartup.pl["|']?/) {
            $self->{ximsstartuppl} = 1;
        }

        last if ( $self->{ApacheDocumentRoot}
                  and $self->{ApacheUser}
                  and $self->{Group}
                  and $self->{ximshttpdconf}
                  and $self->{ximsstartuppl} );
    }
    close(CONF);
    $self->{parsedhttpdconf} = 1;

}

sub parsed_httpd_conf { return shift->{parsedhttpdconf} };

sub apache_document_root {
    my $self = shift;
    if ( $self->parsed_httpd_conf() ) {
        return $self->{ApacheDocumentRoot};
    }
    else {
        $self->parse_httpd_conf() and return $self->apache_document_root();
    }
}

sub apache_user {
    my $self = shift;
    if ( $self->parsed_httpd_conf() ) {
        return $self->{ApacheUser};
    }
    else {
        $self->parse_httpd_conf() and return $self->apache_user();
    }
}

sub apache_group {
    my $self = shift;
    if ( $self->parsed_httpd_conf() ) {
        return $self->{ApacheGroup};
    }
    else {
        $self->parse_httpd_conf() and return $self->apache_group();
    }
}

sub xims_httpd_conf {
    my $self = shift;
    if ( $self->parsed_httpd_conf() ) {
        return $self->{ximshttpdconf};
    }
    else {
        $self->parse_httpd_conf() and return $self->xims_httpd_conf();
    }
}

sub xims_startup_pl {
    my $self = shift;
    if ( $self->parsed_httpd_conf() ) {
        return $self->{ximsstartuppl};
    }
    else {
        $self->parse_httpd_conf() and return $self->xims_startup_pl();
    }
}

sub inplace_edit {
    my $self = shift;
    my $file = shift;
    system ($^X, "-pi", "-e", "@_", $file) == 0
         or die "inplace_edit() failed: $?";
}

1;
