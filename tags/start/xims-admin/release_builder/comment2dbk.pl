#!/usr/bin/perl -w
#
#  comment2xml.pl
#
#  parse our nasty code for comments and aim to generate
#  docbook-xml fragments out of them
#
#  takes a list of files as arguments, writes xml to STDOUT
#  best use from CMS/ as CWD (so the filesections contain the
#  path in their titles).
#
#  $Id$
#
use strict;
use XML::LibXML;

my $paraFoo = "";

my $dom = XML::LibXML::Document->new( '1.0', 'UTF-8' );
my $root = $dom->createElement('article'); #rootnode

my $currentNode = $root;
my $lastNode;

$dom->setDocumentElement($root);


foreach my $infile (@ARGV) {
    $currentNode = $dom->createElement('section');
    $root->appendChild($currentNode);
    $currentNode->appendTextChild('title', $infile );
    $lastNode = $currentNode;

    parse($infile);

    $currentNode = $root;
}


sub parse {

    my $infile = shift;

    my $methodTitleNode = undef;

    my $getNextAsTitle = 0;
    my $concatPara = 1;

    my $sectionFlag = 0;
    my $inCodeFlag = 0;
    my $inGroupingFlag = 0;

    open(IN, $infile) || die "nix file :(";

    while (<IN>) {
        chomp;
        #warn $infile, $methodTitleNode, $getNextAsTitle, $concatPara;
        # ignore anything without comments and exit any comment block
        unless ($_ =~ /#/) {
                $sectionFlag = 0;
                $inCodeFlag = 0;
                $inGroupingFlag = 0;
                #warn "CODE \t". $_ . "\n";

                next;
        }

        # ignore comments after code (on the same line)
        if ( $_ =~ /\w+\s*#/) {
             #warn "CODE_Comment: " . $_ ."\n";

             next;
        }

        # matches beginning of comments before method declaration
        if ($_ =~ /^##.?$/) {
            #warn "method: \t" . ":\t" . $_ . "\n" ;
            $sectionFlag = 1;

            # if this is a reference we know that we already are in a
            # methodsection, we therefore go one up to start a new one
            if (ref ($methodTitleNode)) {
                $lastNode = $lastNode->getParentNode();
            }

            $currentNode = $dom->createElement('section');
            $lastNode->appendChild($currentNode);
            $methodTitleNode = $dom->createElement('title');
            $lastNode = $currentNode;
            $currentNode = $lastNode->appendChild($methodTitleNode);

            next;
        }


        # matches hash as first letter, one space, one or more hashes following
        # set $inGroupingFlag
        if ( $_ =~ /^# [#]+/ ) {

             # this 'feature' is not fully implented and
             # therefore disabled for now:

             #warn "GROUP:\t" . $inGroupingFlag . $_ . "\n";
             #$inGroupingFlag = 1;
             #$currentNode = $dom->createElement('section');
             #$lastNode->appendChild($currentNode);

             next;
        }

        # matches single '#' with ONLY whitespace before and after,
        # set $inCodeFlag
        if ( $_ =~ /[\s]*#[\s]*$/ ) {
             #warn "HASH:\t" . $inCodeFlag . $_ . "\n";
             $inCodeFlag = 1;
             flushPara();

             next;
        }

        # matches a heading...(Hash as first letter one space,
        #                      four or more capital letters)
        if ($_ =~ /^# (SYNOPSIS|DESCRIPTION|PARAMETER|RETURNS|EXAMPLE)/) {
            #warn "heading:\t" . ":\t" . $_ . "\n";
            flushPara();
            $currentNode = $dom->createElement('section');
            $lastNode->appendChild($currentNode);

            $currentNode->appendTextChild('title', stripHashes($_) );

            # next useful line schould contain the method's name....
            if (/SYNOPSIS/) {
              $getNextAsTitle = 1;
              $concatPara = 0;
            }
            if (/DESCRIPTION/) { $concatPara = 1; }

            next;
        }
        elsif ($_ =~ /^# GENERAL/) {
            $methodTitleNode->appendText( 'General Information' );
            $currentNode = $currentNode->getParentNode();
            $concatPara = 0;
            next;
        }

        # matches an ordinary comment, special cases should have been ruled out
        # already...
        if ($_ =~ /#[\s]*[^ ]*/) {

            if ($sectionFlag == 1)    {
                #warn "Method:\t" . $_ . "\n";
                if ( $concatPara == 0 ) {
                    $currentNode->appendTextChild('para', stripHashes($_));
                }
                else {
                    appendToPara(stripHashes($_));
                }
                if ( $getNextAsTitle == 1 && ref($methodTitleNode) ) {
                    my $title = stripHashes($_);
                    $title =~ s/^.+=\s*//;
                    $title =~ s/;.?$//;
                    $methodTitleNode->appendText( $title );
                    $getNextAsTitle = 0;
                }
            }
            elsif ($inCodeFlag == 1)     {
                #warn "CODECOM:\t" . $_ . "\n";
                if ( $concatPara == 0 ) {
                    $currentNode->appendTextChild('para', stripHashes($_));
                }
                else {
                    appendToPara(stripHashes($_));
                }
                #appendToPara(stripHashes($_));

            }
            # method-groups are not supported for now, see above

            #elsif ($inGroupingFlag == 1) {
            #    #warn "Grouping:\t" . $_ . "\n";
            #    $currentNode->appendTextChild('title', stripHashes($_));
            #}
            else {
            #    warn "NoFlag: \t" . $_ . "\n";
            }

            next;
        }

            warn "NoMatch: " . $_ . "\n";
    }
    close(IN);
}


sub stripHashes {

    my $line = shift;

    $line =~ s/(\s*#\s*)(\S+)/$2/;

    return $line . "\n";
}


sub flushPara {

    if (length $paraFoo && defined $currentNode) {
    $currentNode->appendTextChild( 'para', $paraFoo );
    $paraFoo = "";
    }
}

sub appendToPara {

    my $line = shift;

    $paraFoo .= ($line . "\n");
}

print $dom->toString();



