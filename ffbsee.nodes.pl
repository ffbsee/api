#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use utf8;

#	Hier werden einige globale Parameter festgelegt
#	wie zum Beispiel der absolute Speicherpfad der Freifunk JSON.

our $json_source = "/tmp/nodes.json";
our $json_export = "/tmp/ffbsee.json";
our $json_ffbsee;
our $ffcommunity = "Freifunk Bodensee";
our $ffnodes_link = "https://vpn3.ffbsee.de/ffbsee.json";
our $currentTime = `date +%Y-%m-%dT%H:%M:%S+02:00`;
chomp $currentTime;
our $version = "0.1";

while (my $arg = shift @ARGV) {
    #Komandozeilenargumente: #print "$arg\n";
    if (($arg eq "-h") or ($arg eq "h") or ($arg eq "--help")){
        print "Dieses Script generiert ein freifunk-karte.de kompatibles JSON mit allen FFBSee Nodes\n";
        exit(0);
    }
}


open(DATEI, $json_source) or die "Datei wurde nicht gefunden\n";
    my $daten;
    while(<DATEI>){
         $daten = $daten.$_;
    }
close (DATEI);
our $json_text = $daten;
our $json = JSON->new->utf8; #force UTF8 Encoding
our $ffbsee_json = $json->decode( $json_text ); #decode nodes.json

#	Generiert das JSON:
$json_ffbsee .= "\{\n\t\"community\": \{\n\t\t\"name\": \"$ffcommunity\",\n\t\t\"href\": \"$ffnodes_link\"\n\t\},\n";
$json_ffbsee .= "\t\"nodes\": \[\n";
#	Generate FFNodes


#	EOFFNodes
$json_ffbsee .= "\t\],\n\t\"updated_at\": \"$currentTime\",\n\t\"version\": \"$version\"\n\}";
#	Öffne eine Datei und generiere das JSON

open (DATEI, "> $json_export") or die $!;
   print DATEI $json_ffbsee;
close (DATEI);