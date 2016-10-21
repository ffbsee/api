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
our $ff_json;
our $ffcommunity = "Freifunk Markdorf";
our $ffnodes_link = "https://vpn3.ffbsee.de/ffbsee.json";
our $currentTime = `date +%Y-%m-%dT%H:%M:%S`;
our $debug;
chomp $currentTime;
our $version = "0.2";
our $subcommunity = "true";
our $sub_json_export = "/var/www/fffn.json";
our $sub_ffcommunity = "Freifunk Friedrichshafen";
our $sub_ffnodes_link = "https://vpn3.ffbsee.de/fffn.json";
our $json_fffn;

while (my $arg = shift @ARGV) {
    #Komandozeilenargumente: #print "$arg\n";
    if (($arg eq "-h") or ($arg eq "h") or ($arg eq "--help")){
        print "Dieses Script generiert ein freifunk-karte.de kompatibles JSON mit allen FFBSee Nodes\n";
        print "\n\n --debug\t Debuging\n";
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
$json_ffbsee .= "\{\n    \"comunity\": \{\n        \"name\": \"$ffcommunity\",\n        \"href\": \"$ffnodes_link\"\n    \},\n";
$json_ffbsee .= "    \"nodes\": \[\n";
if ($subcommunity){
    $json_fffn .=  "\{\n    \"comunity\": \{\n        \"name\": \"$sub_ffcommunity\",\n        \"href\": \"$sub_ffnodes_link\"\n    \},\n";
    $json_fffn .= "    \"nodes\": \[\n";
}
#
#	Generate FFNodes
#
my $runFirstTime = 1;
my $runFirstTimeFN = 1;
my $hashref_ffbsee = $ffbsee_json->{"nodes"};
for my $ffkey (keys %{$hashref_ffbsee}) {
    my $keinGeo = 0;
    if ($debug) { print "$ffkey\n"; }
    $ff_json .= "        \{\n";
    $ff_json .= "            \"id\": \"$ffkey\",\n";
    my $ffNodeName = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"hostname"};
    $ffNodeName =~ s/ä/ae/g;
    $ffNodeName =~ s/ö/oe/g;
    $ffNodeName =~ s/ü/ue/g;
    $ffNodeName =~ s/Ä/Ae/g;
    $ffNodeName =~ s/Ö/Oe/g;
    $ffNodeName =~ s/Ü/Ue/g;
    $ffNodeName =~ s/ß/sz/g;
    $ff_json .= "            \"name\": \"$ffNodeName\",\n";
    my $ffNodeType;
    if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"software"}->{"firmware"}->{"release"})){
        if (( $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"software"}->{"firmware"}->{"release"} eq "server" )){
            $ffNodeType = "AccessPoint";
        } else {$ffNodeType = "AccessPoint";}
    } else {$ffNodeType = "AccessPoint";}
    $ff_json .= "            \"node_type\": \"$ffNodeType\",\n";
    $ff_json .= "            \"position\": \{\n";
    my $ff_lat;
    my $ff_long;
    if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"location"}->{"latitude"})){
        $ff_lat = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"location"}->{"latitude"};   
        $ff_long = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"location"}->{"longitude"}; 
    }
    else {
        $keinGeo = 1; #Node wird nicht generiert weil kein Geo! 
        $ff_lat = "";   
        $ff_long = "";
        if ($debug){print "No Geocoordinaten\n";}
    }
    $ff_json .= "                \"lat\": $ff_lat,\n";
    $ff_json .= "                \"long\": $ff_long\n";
    $ff_json .= "            \},\n            \"status\": \{\n";
    my $ffclients = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"statistics"}->{"clients"};
    $ff_json .= "                \"clients\": \"$ffclients\",\n";
    my $ffNodeOnline;
    if ($debug) { print $ffbsee_json->{"nodes"}->{"$ffkey"}->{"flags"}->{"online"}; }
    if (($ffbsee_json->{"nodes"}->{"$ffkey"}->{"flags"}->{"online"} eq "true") or($ffbsee_json->{"nodes"}->{"$ffkey"}->{"flags"}->{"online"} eq 1) or  ($ffbsee_json->{"nodes"}->{"$ffkey"}->{"flags"}->{"online"} eq "True")){
        $ffNodeOnline = "true";
    } else {$ffNodeOnline = "false";}
    $ff_json .= "                \"online\": \"$ffNodeOnline\"\n            \}\n";
    $ff_json .= "        \}";

    if ($keinGeo eq 1){
        if ($debug) {print "Ueberspringen";}
    } else {
        if ($subcommunity){
            if ($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"system"}->{"site_code"} eq "friedrichshafen"){
                if ($runFirstTimeFN == 1){
                     $runFirstTimeFN = 0;
                } else { $json_fffn .= ",\n"; }
                $json_fffn .= $ff_json;

            } else {
                if ($runFirstTime == 1){
                     $runFirstTime = 0;
                } else { $json_ffbsee .= ",\n"; }
                $json_ffbsee .= $ff_json;
            }
        } else {    
            if ($runFirstTime == 1){
                $runFirstTime = 0;
            } else { $json_ffbsee .= ",\n"; }
        $json_ffbsee .= $ff_json;
        }
    }
    $ff_json = "";

}

#
#	EOFFNodes
#
$json_ffbsee .= "\n    \],\n    \"updated_at\": \"$currentTime\",\n    \"version\": \"$version\"\n\}";
if ($subcommunity){
    $json_fffn .= "\n    \],\n    \"updated_at\": \"$currentTime\",\n    \"version\": \"$version\"\n\}";
}
#	Öffne eine Datei und generiere das JSON

open (DATEI, "> $json_export") or die $!;
    print DATEI $json_ffbsee;
   
close (DATEI);
if  ($subcommunity){
    open (DATEI, "> $sub_json_export") or die $!;
        print DATEI $json_fffn;

    close (DATEI);
}
print "JSON Files wurden erzeugt\n";
