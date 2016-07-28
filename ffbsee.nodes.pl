#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use utf8;

#	Hier werden einige globale Parameter festgelegt
#	wie zum Beispiel der absolute Speicherpfad der Freifunk JSON.

our $json_source = "/var/www/meshviewer/nodes.json";
our $json_export = "/var/www/ffbsee.json";
our $json_ffbsee;
our $ffcommunity = "Freifunk Bodensee";
our $ffnodes_link = "https://vpn3.ffbsee.de/ffbsee.json";
our $currentTime = `date +%Y-%m-%dT%H:%M:%S+02:00`;
our $debug;
chomp $currentTime;
our $version = "0.1";

while (my $arg = shift @ARGV) {
    #Komandozeilenargumente: #print "$arg\n";
    if (($arg eq "-h") or ($arg eq "h") or ($arg eq "--help")){
        print "Dieses Script generiert ein freifunk-karte.de kompatibles JSON mit allen FFBSee Nodes\n";
        print "\n\n\t--debug\t Debuging\n";
		print "\n";
		exit(0);
    }
	if ($arg eq "--debug"){
	    $debug = "True";
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
$version = $ffbsee_json->{"version"};
#	Generiert das JSON:
$json_ffbsee .= "\{\n\t\"comunity\": \{\n\t\t\"name\": \"$ffcommunity\",\n\t\t\"href\": \"$ffnodes_link\"\n\t\},\n";
$json_ffbsee .= "\t\"nodes\": \[\n";
#
#	Generate FFNodes
#
my $hashref_ffbsee = $ffbsee_json->{"nodes"};
for my $ffkey (keys %{$hashref_ffbsee}) {
    if ($debug) { print "$ffkey\n"; }
    $json_ffbsee .= "\t\t\{\n";
    $json_ffbsee .= "\t\t\t\"id\": \"$ffkey\",\n";
    my $ffNodeName = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"hostname"};
    $json_ffbsee .= "\t\t\t\"name\": \"$ffNodeName\",\n";
    my $ffNodeType;
    if (( $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"software"}->{"firmware"}->{"release"} eq "server" )){
    $ffNodeType = "Gateway";
    } else {$ffNodeType = "AccessPoint";}
    $json_ffbsee .= "\t\t\t\"node_type\": \"$ffNodeType\",\n";
    $json_ffbsee .= "\t\t\t\"position\": \{\n";
    my $ff_lat = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"location"}->{"latitude"};   
    my $ff_long = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"location"}->{"longitude"};   
    $json_ffbsee .= "\t\t\t\t\"lat\": \"$ff_lat\",\n";
    $json_ffbsee .= "\t\t\t\t\"long\": \"$ff_long\"\n";
    $json_ffbsee .= "\t\t\t\},\n\t\t\t\"status\": \{\n";
    my $ffclients = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"statistics"}->{"clients"};
    $json_ffbsee .= "\t\t\t\t\"clients\": \"$ffclients\",\n";
    my $ffNodeOnline;
    if ($debug) { print $ffbsee_json->{"nodes"}->{"$ffkey"}->{"flags"}->{"online"}; }
    if (($ffbsee_json->{"nodes"}->{"$ffkey"}->{"flags"}->{"online"} eq "true") or($ffbsee_json->{"nodes"}->{"$ffkey"}->{"flags"}->{"online"} eq 1) or  ($ffbsee_json->{"nodes"}->{"$ffkey"}->{"flags"}->{"online"} eq "True")){
        $ffNodeOnline = "true";
    } else {$ffNodeOnline = "false";}
    $json_ffbsee .= "\t\t\t\t\"online\": \"$ffNodeOnline\"\n\t\t\t\}\n";
    $json_ffbsee .= "\t\t\},\n";
}

#
#	EOFFNodes
#
$json_ffbsee .= "\t\],\n\t\"updated_at\": \"$currentTime\",\n\t\"version\": \"$version\"\n\}";
#	Öffne eine Datei und generiere das JSON

open (DATEI, "> $json_export") or die $!;
    print DATEI $json_ffbsee;
   
close (DATEI);
