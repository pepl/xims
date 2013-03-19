
=head1 NAME

XIMS::Entities -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Entities;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

#
# This is is a modified version of Gisle Aas' HTML::Entities module,
# It was stripped down to what we need and pulled into the XIMS namespace,
# to avoid messing up the original Module
# (and potentially rendering it useless for purposes other than ours)
#
# The "decode_entity_old" function was renamed to "decode";
# Some changes where made to avoid decoding entities
# of "'",'"',"&","<" and ">". %decodemap was introduced
# to allow decoding numeric entities known from %entity2char.
#
# Original Copyright:
#
# Id: Entities.pm,v 1.22 2001/04/11 17:22:45 gisle Exp
#
# This library is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package XIMS::Entities;

use common::sense;

# require instead of use here because we do not want Encode::decode to be
# exported and trigger a "method decode redefined" warning
require Encode;

our %decodemap;
our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 Version()

=cut

sub Version { $VERSION; }

BEGIN {
    for ( 1..33,
            35..37,
            40..59,
            61,
            63..159,
            161..255,
            338,
            339,
            352,
            353,
            376,
            402,
            710,
            732,
            913..929,
            931..937,
            945..969,
            977,
            978,
            982,
            8194,
            8195,
            8201,
            8204..8207,
            8211,
            8212,
            8216,
            8217,
            8218,
            8220,
            8221,
            8222,
            8224,
            8225,
            8226,
            8230,
            8240,
            8242,
            8243,
            8249,
            8250,
            8254,
            8260,
            8364,
            8465,
            8472,
            8476,
            8482,
            8501,
            8592,
            8593,
            8594,
            8595,
            8596,
            8629,
            8656,
            8657,
            8658,
            8659,
            8660,
            8704,
            8706,
            8707,
            8709,
            8711,
            8712,
            8713,
            8715,
            8719,
            8721,
            8722,
            8727,
            8730,
            8733,
            8734,
            8736,
            8743,
            8744,
            8745,
            8746,
            8747,
            8756,
            8764,
            8773,
            8776,
            8800,
            8801,
            8804,
            8805,
            8834,
            8835,
            8836,
            8838,
            8839,
            8853,
            8855,
            8869,
            8901,
            8968,
            8969,
            8970,
            8971,
            9001,
            9002,
            9674,
            9824,
            9827,
            9829,
            9830 ) {
        $decodemap{$_}++
    }
}

our %entity2char = (
 # PUBLIC ISO 8879-1986//ENTITIES Added Latin 1//EN//HTML
 AElig  => 'Æ',  # capital AE diphthong (ligature)
 Aacute => 'Á',  # capital A, acute accent
 Acirc  => 'Â',  # capital A, circumflex accent
 Agrave => 'À',  # capital A, grave accent
 Aring  => 'Å',  # capital A, ring
 Atilde => 'Ã',  # capital A, tilde
 Auml   => 'Ä',  # capital A, dieresis or umlaut mark
 Ccedil => 'Ç',  # capital C, cedilla
 ETH    => 'Ð',  # capital Eth, Icelandic
 Eacute => 'É',  # capital E, acute accent
 Ecirc  => 'Ê',  # capital E, circumflex accent
 Egrave => 'È',  # capital E, grave accent
 Euml   => 'Ë',  # capital E, dieresis or umlaut mark
 Iacute => 'Í',  # capital I, acute accent
 Icirc  => 'Î',  # capital I, circumflex accent
 Igrave => 'Ì',  # capital I, grave accent
 Iuml   => 'Ï',  # capital I, dieresis or umlaut mark
 Ntilde => 'Ñ',  # capital N, tilde
 Oacute => 'Ó',  # capital O, acute accent
 Ocirc  => 'Ô',  # capital O, circumflex accent
 Ograve => 'Ò',  # capital O, grave accent
 Oslash => 'Ø',  # capital O, slash
 Otilde => 'Õ',  # capital O, tilde
 Ouml   => 'Ö',  # capital O, dieresis or umlaut mark
 THORN  => 'Þ',  # capital THORN, Icelandic
 Uacute => 'Ú',  # capital U, acute accent
 Ucirc  => 'Û',  # capital U, circumflex accent
 Ugrave => 'Ù',  # capital U, grave accent
 Uuml   => 'Ü',  # capital U, dieresis or umlaut mark
 Yacute => 'Ý',  # capital Y, acute accent
 aacute => 'á',  # small a, acute accent
 acirc  => 'â',  # small a, circumflex accent
 aelig  => 'æ',  # small ae diphthong (ligature)
 agrave => 'à',  # small a, grave accent
 aring  => 'å',  # small a, ring
 atilde => 'ã',  # small a, tilde
 auml   => 'ä',  # small a, dieresis or umlaut mark
 ccedil => 'ç',  # small c, cedilla
 eacute => 'é',  # small e, acute accent
 ecirc  => 'ê',  # small e, circumflex accent
 egrave => 'è',  # small e, grave accent
 eth    => 'ð',  # small eth, Icelandic
 euml   => 'ë',  # small e, dieresis or umlaut mark
 iacute => 'í',  # small i, acute accent
 icirc  => 'î',  # small i, circumflex accent
 igrave => 'ì',  # small i, grave accent
 iuml   => 'ï',  # small i, dieresis or umlaut mark
 ntilde => 'ñ',  # small n, tilde
 oacute => 'ó',  # small o, acute accent
 ocirc  => 'ô',  # small o, circumflex accent
 ograve => 'ò',  # small o, grave accent
 oslash => 'ø',  # small o, slash
 otilde => 'õ',  # small o, tilde
 ouml   => 'ö',  # small o, dieresis or umlaut mark
 szlig  => 'ß',  # small sharp s, German (sz ligature)
 thorn  => 'þ',  # small thorn, Icelandic
 uacute => 'ú',  # small u, acute accent
 ucirc  => 'û',  # small u, circumflex accent
 ugrave => 'ù',  # small u, grave accent
 uuml   => 'ü',  # small u, dieresis or umlaut mark
 yacute => 'ý',  # small y, acute accent
 yuml   => 'ÿ',  # small y, dieresis or umlaut mark

 # Some extra Latin 1 chars that are listed in the HTML3.2 draft (21-May-96)
 copy   => '©',  # copyright sign
 reg    => '®',  # registered sign
 nbsp   => "&#160;", # non breaking space

 # Additional ISO-8859/1 entities listed in rfc1866 (section 14)
 iexcl  => '¡',
 cent   => '¢',
 pound  => '£',
 curren => '¤',
 yen    => '¥',
 brvbar => '¦',
 sect   => '§',
 uml    => '¨',
 ordf   => 'ª',
 laquo  => '«',
'not'   => '¬',    # not is a keyword in perl
 shy    => '­',
 macr   => '¯',
 deg    => '°',
 plusmn => '±',
 sup1   => '¹',
 sup2   => '²',
 sup3   => '³',
 acute  => '´',
 micro  => 'µ',
 para   => '¶',
 middot => '·',
 cedil  => '¸',
 ordm   => 'º',
 raquo  => '»',
 frac14 => '¼',
 frac12 => '½',
 frac34 => '¾',
 iquest => '¿',
'times' => '×',    # times is a keyword in perl
 divide => '÷',

 ( $] > 5.007 ? (
   OElig    => chr(338),
   oelig    => chr(339),
   Scaron   => chr(352),
   scaron   => chr(353),
   Yuml     => chr(376),
   fnof     => chr(402),
   circ     => chr(710),
   tilde    => chr(732),
   Alpha    => chr(913),
   Beta     => chr(914),
   Gamma    => chr(915),
   Delta    => chr(916),
   Epsilon  => chr(917),
   Zeta     => chr(918),
   Eta      => chr(919),
   Theta    => chr(920),
   Iota     => chr(921),
   Kappa    => chr(922),
   Lambda   => chr(923),
   Mu       => chr(924),
   Nu       => chr(925),
   Xi       => chr(926),
   Omicron  => chr(927),
   Pi       => chr(928),
   Rho      => chr(929),
   Sigma    => chr(931),
   Tau      => chr(932),
   Upsilon  => chr(933),
   Phi      => chr(934),
   Chi      => chr(935),
   Psi      => chr(936),
   Omega    => chr(937),
   alpha    => chr(945),
   beta     => chr(946),
   gamma    => chr(947),
   delta    => chr(948),
   epsilon  => chr(949),
   zeta     => chr(950),
   eta      => chr(951),
   theta    => chr(952),
   iota     => chr(953),
   kappa    => chr(954),
   lambda   => chr(955),
   mu       => chr(956),
   nu       => chr(957),
   xi       => chr(958),
   omicron  => chr(959),
   pi       => chr(960),
   rho      => chr(961),
   sigmaf   => chr(962),
   sigma    => chr(963),
   tau      => chr(964),
   upsilon  => chr(965),
   phi      => chr(966),
   chi      => chr(967),
   psi      => chr(968),
   omega    => chr(969),
   thetasym => chr(977),
   upsih    => chr(978),
   piv      => chr(982),
   ensp     => chr(8194),
   emsp     => chr(8195),
   thinsp   => chr(8201),
   zwnj     => chr(8204),
   zwj      => chr(8205),
   lrm      => chr(8206),
   rlm      => chr(8207),
   ndash    => chr(8211),
   mdash    => chr(8212),
   lsquo    => chr(8216),
   rsquo    => chr(8217),
   sbquo    => chr(8218),
   ldquo    => chr(8220),
   rdquo    => chr(8221),
   bdquo    => chr(8222),
   dagger   => chr(8224),
   Dagger   => chr(8225),
   bull     => chr(8226),
   hellip   => chr(8230),
   permil   => chr(8240),
   prime    => chr(8242),
   Prime    => chr(8243),
   lsaquo   => chr(8249),
   rsaquo   => chr(8250),
   oline    => chr(8254),
   frasl    => chr(8260),
   euro     => chr(8364),
   image    => chr(8465),
   weierp   => chr(8472),
   real     => chr(8476),
   trade    => chr(8482),
   alefsym  => chr(8501),
   larr     => chr(8592),
   uarr     => chr(8593),
   rarr     => chr(8594),
   darr     => chr(8595),
   harr     => chr(8596),
   crarr    => chr(8629),
   lArr     => chr(8656),
   uArr     => chr(8657),
   rArr     => chr(8658),
   dArr     => chr(8659),
   hArr     => chr(8660),
   forall   => chr(8704),
   part     => chr(8706),
   exist    => chr(8707),
   empty    => chr(8709),
   nabla    => chr(8711),
   isin     => chr(8712),
   notin    => chr(8713),
   ni       => chr(8715),
   prod     => chr(8719),
   sum      => chr(8721),
   minus    => chr(8722),
   lowast   => chr(8727),
   radic    => chr(8730),
   prop     => chr(8733),
   infin    => chr(8734),
   ang      => chr(8736),
  'and'     => chr(8743),
  'or'      => chr(8744),
   cap      => chr(8745),
   cup      => chr(8746),
  'int'     => chr(8747),
   there4   => chr(8756),
   sim      => chr(8764),
   cong     => chr(8773),
   asymp    => chr(8776),
  'ne'      => chr(8800),
   equiv    => chr(8801),
  'le'      => chr(8804),
  'ge'      => chr(8805),
  'sub'     => chr(8834),
   sup      => chr(8835),
   nsub     => chr(8836),
   sube     => chr(8838),
   supe     => chr(8839),
   oplus    => chr(8853),
   otimes   => chr(8855),
   perp     => chr(8869),
   sdot     => chr(8901),
   lceil    => chr(8968),
   rceil    => chr(8969),
   lfloor   => chr(8970),
   rfloor   => chr(8971),
   lang     => chr(9001),
   rang     => chr(9002),
   loz      => chr(9674),
   spades   => chr(9824),
   clubs    => chr(9827),
   hearts   => chr(9829),
   diams    => chr(9830),
 ) : ())
);

=head2 decode()

=cut

sub decode {
    my $array;
    if (defined wantarray) {
        $array = [@_]; # copy
    } else {
        $array = \@_;  # modify in-place
    }
    my $c;

    # this assumes that if XIMS::DBENCODING() is set, it refers to a one byte
    # encoding and that users who need multi-byte encodings will use utf-8
    if ( XIMS::DBENCODING() ) {
        for (@$array) {
            s/(&\#(\d+);?)/($2 < 256 and exists $decodemap{$2}) ? chr($2) : $1/eg;
            s/(&\#[xX]([0-9a-fA-F]+);?)/$c = hex($2);($c < 256 and exists $decodemap{$c}) ? chr($c) : $1/eg;
            s/(&(\w+);?)/$entity2char{$2} || $1/eg;
        }
    }
    else {
        for (@$array) {
            # if XIMS::DBENCODING is not set, the database and input/output are expected to be
            # encoded in utf-8
            #utf8::decode($_);

            # convert the octets and turn utf-8 flag on.
            # otherwise lines containing chars chr(127)+, will
            # be incorrectly utf-8 encoded :-/
            $_ = Encode::decode_utf8($_) unless Encode::is_utf8($_);

            s/(&\#(\d+);?)/exists $decodemap{$2} ? chr($2) : $1/eg;
            s/(&\#[xX]([0-9a-fA-F]+);?)/$c = hex($2);exists $decodemap{$c} ? chr($c) : $1/eg;
            s/(&(\w+);?)/$entity2char{$2} || $1/eg;

            # convert back and turn utf-8 flag off. otherwise XML::LibXML
            # will get confused and will not parse the string :-/
            $_ = Encode::encode_utf8($_);

        }
    }
    wantarray ? @$array : $array->[0];
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

