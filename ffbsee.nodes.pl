#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use utf8;

#	Hier werden einige globale Parameter festgelegt
#	wie zum Beispiel der absolute Speicherpfad der Freifunk JSON.

our $json_source = "/var/www/meshviewer/nodes.json";
#Variablen Markdorf:
our @json_export = ("/var/www/ffbsee.json");
our @json_ffbsee;
our $ff_json;
our @ffcommunity = ("Freifunk Markdorf");
our @ffnodes_link = ("https://vpn3.ffbsee.de/ffbsee.json");
our @runFirstTime = (1);
our @community_name = ("markdorf");
our $currentTime = `date +%Y-%m-%dT%H:%M:%S`;
our $debug;
chomp $currentTime;
our $version = "0.2";
our $subcommunity = "true";
# Friedrichshafen
push (@json_export, "/var/www/fffn.json");
push (@ffcommunity, "Freifunk Friedrichshafen");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://vpn3.ffbsee.de/fffn.json");
push (@runFirstTime, 1);
push (@community_name, "friedrichshafen");
#Konstanz
push (@json_export, "/var/www/ffkn.json");
push (@ffcommunity, "Freifunk Konstanz");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://vpn3.ffbsee.de/ffkn.json");
push (@runFirstTime, 1);
push (@community_name, "konstanz");
# Kressbronn
push (@json_export, "/var/www/ffkrb.json");
push (@ffcommunity, "Freifunk Kressbronn");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://vpn3.ffbsee.de/ffkrb.json");
push (@runFirstTime, 1);
push (@community_name, "kressbronn");
# Lindau
push (@json_export, "/var/www/ffli.json");
push (@ffcommunity, "Freifunk Lindau");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://vpn3.ffbsee.de/ffli.json");
push (@runFirstTime, 1);
push (@community_name, "lindau");
# Ravensburg
push (@json_export, "/var/www/ffrv.json");
push (@ffcommunity, "Freifunk Ravensburg");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://vpn3.ffbsee.de/ffrv.json");
push (@runFirstTime, 1);
push (@community_name, "ravensburg");
# Ueberlingen
push (@json_export, "/var/www/ffueb.json");
push (@ffcommunity, "Freifunk Ueberlingen");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://vpn3.ffbsee.de/ffueb.json");
push (@runFirstTime, 1);
push (@community_name, "ueberlingen");
# Weingarten
push (@json_export, "/var/www/ffwg.json");
push (@ffcommunity, "Freifunk Weingarten");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://vpn3.ffbsee.de/ffwg.json");
push (@runFirstTime, 1);
push (@community_name, "weingarten");


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
for(my $i = 0; $i < @ffcommunity; $i++) {
    $json_ffbsee[$i] .= "\{\n    \"community\": \{\n        \"name\": \"$ffcommunity[$i]\",\n        \"href\": \"$ffnodes_link[$i]\"\n    \},\n";
    $json_ffbsee[$i] .= "    \"nodes\": \[\n";
}
#
#	Generate FFNodes
#
my $runFirstTime = 1;
my $runFirstTimeFN = 1;
my $runFirstTimeFFTettnang = 1;
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
            my $community =  $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"system"}->{"site_code"}; 
            for (my $i = 0; $i < @ffcommunity; $i++) {
                if ($community eq $community_name[$i]){
                    if ($runFirstTime[$i] eq 1){
                        $runFirstTime[$i] = 0;
                    } else { $json_ffbsee[$i] .= ",\n"; }
                    $json_ffbsee[$i] .= $ff_json;
                    $ff_json = "";
                }
            }
        }
        if ($ff_json ne ""){
            if ($runFirstTime[0] eq 1){
                $runFirstTime[0] = 0;
            } else { $json_ffbsee[0] .= ",\n"; }
                $json_ffbsee[0] .= $ff_json;
            $ff_json = "";
        }
    }
}

#
#	EOFFNodes
#
for(my $i = 0; $i < @ffcommunity; $i++) {
    $json_ffbsee[$i] .= "\n    \],\n    \"updated_at\": \"$currentTime\",\n    \"version\": \"$version\"\n\}";

#	Öffne eine Datei und generiere das JSON

open (DATEI, "> $json_export[$i]") or die $!;
    print DATEI $json_ffbsee[$i];
   
close (DATEI);
}
print "JSON Files wurden erzeugt\n";
