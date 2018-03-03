#!/usr/bin/perl
# This File is managed by ansible. Please change it there: 
# https://github.com/ffbsee/ansible and/or there:
# https://github.com/ffbsee/api
use strict;
use warnings;
use JSON;
use utf8;
#
#	Hier werden einige globale Parameter festgelegt
#	wie zum Beispiel der absolute Speicherpfad der Freifunk JSON.
#   Diese kommen aus Parametern wie den group_vars oder den host_vars in ansible
#

#   Noch anzulegende variabeln:
#   {{ maps_webserver }}
#   {{ json_api_path }}
our $nodes = 0;
our $json_source = "/var/www/{{ hostname }}/nodes.json";
#
#   Es folgen Communityspezifische variabeln
#
#   Variablen Markdorf:
#
our @json_export = ("{{ json_api_path }}/ffbsee.json");
our @json_ffbsee;
our $ff_json;
our @ffcommunity = ("Freifunk Markdorf");
our @ffnodes_link = ("https://{{ maps_webserver }}/ffbsee.json");
our @runFirstTime = (1);
our @community_name = ("markdorf");
our $currentTime = `date +%Y-%m-%dT%H:%M:%S`;
our $debug;
our $git_root = "{{ api_gitroot }}";
chomp $currentTime;
our $version = "0.3";
our $subcommunity = "true";
our @ff_nodes = (0);
our @api = ("https://raw.githubusercontent.com/ffbsee/api/master/ffmarkdorf.json");
our @allnodes = (0);
# Friedrichshafen
push (@json_export, "{{ json_api_path }}/fffn.json");
push (@ffcommunity, "Freifunk Friedrichshafen");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://{{ maps_webserver }}/fffn.json");
push (@runFirstTime, 1);
push (@community_name, "friedrichshafen");
push (@ff_nodes, 0);
push (@api, "https://raw.githubusercontent.com/ffbsee/api/master/fffriedrichshafen.json");
push (@allnodes, 0);
# Konstanz
push (@json_export, "{{ json_api_path }}/ffkn.json");
push (@ffcommunity, "Freifunk Konstanz");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://{{ maps_webserver }}/ffkn.json");
push (@runFirstTime, 1);
push (@community_name, "konstanz");
push (@ff_nodes, 0);
push (@api, "https://raw.githubusercontent.com/ffbsee/api/master/ffkonstanz.json");
push (@allnodes, 0);
# Kressbronn
push (@json_export, "{{ json_api_path }}/ffkrb.json");
push (@ffcommunity, "Freifunk Kressbronn");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://{{ maps_webserver }}/ffkrb.json");
push (@runFirstTime, 1);
push (@community_name, "kressbronn");
push (@ff_nodes, 0);
push (@api, "https://raw.githubusercontent.com/ffbsee/api/master/ffkressbronn.json");
push (@allnodes, 0);
# Lindau
push (@json_export, "{{ json_api_path }}/ffli.json");
push (@ffcommunity, "Freifunk Lindau");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://{{ maps_webserver }}/ffli.json");
push (@runFirstTime, 1);
push (@community_name, "lindau");
push (@ff_nodes, 0);
push (@api, "https://raw.githubusercontent.com/ffbsee/api/master/fflindau.json");
push (@allnodes, 0);
# Ravensburg
push (@json_export, "{{ json_api_path }}/ffrv.json");
push (@ffcommunity, "Freifunk Ravensburg");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://{{ maps_webserver }}/ffrv.json");
push (@runFirstTime, 1);
push (@community_name, "ravensburg");
push (@ff_nodes, 0);
push (@api, "https://raw.githubusercontent.com/ffbsee/api/master/ffravensburg.json");
push (@allnodes, 0);
# Ueberlingen
push (@json_export, "{{ json_api_path }}/ffueb.json");
push (@ffcommunity, "Freifunk Ueberlingen");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://{{ maps_webserver }}/ffueb.json");
push (@runFirstTime, 1);
push (@community_name, "ueberlingen");
push (@ff_nodes, 0);
push (@api, "https://raw.githubusercontent.com/ffbsee/api/master/ffueberlingen.json");
push (@allnodes, 0);
# Tettnangen
push (@json_export, "{{ json_api_path }}/fftettnang.json");
push (@ffcommunity, "Freifunk Tettnang");
print @ffcommunity if ($debug);
push (@ffnodes_link, "https://{{ maps_webserver }}/fftettnang.json");
push (@runFirstTime, 1);
push (@community_name, "tettnang");
push (@ff_nodes, 0);
push (@api, "http://www.freifunk-tettnang.de/FreifunkTettnang-api.json");

while (my $arg = shift @ARGV) {
    # Komandozeilenargumente: #print "$arg\n";
    if (($arg eq "-h") or ($arg eq "h") or ($arg eq "--help")){
        print "Dieses Script generiert ein freifunk-karte.de kompatibles JSON mit allen FFBSee Nodes\n";
        print "Seit neusten nun auch mit automagischer communityannaeherung anhand der geokoordinaten\n";
        print "\n\n --debug\t Debuging\n";
        print " --nodes\t Welche Community hat wie viele Nodes\n";
        print "\n";
        exit(0);
    }
    if ($arg eq "--debug"){
        $debug = "True";
    }
    if ($arg eq "--nodes"){
       $nodes = "True"; 
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
    $json_ffbsee[$i] .= "\{\n    \"comunity\": \{\n        \"name\": \"$ffcommunity[$i]\",\n        \"href\": \"$ffnodes_link[$i]\"\n    \},\n";
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

    #
    # Geo Koordinaten auswerten und JSON Files Communityspezifisch zusammen stellen
    #

    if ($keinGeo eq 1){
        if ($debug) {print "Ueberspringen\n";}
        $ff_json = "";
        if ($ffNodeOnline){
            if ($debug) {print "Node wird trotzdem gezaehlt\n";}
            if ($ffNodeOnline){
                $allnodes[0]++;
            }
        }
    } else {
        if ($subcommunity){ # Wenn es Subcommunitys gibt, dann...
            # $community des aktuell auszuwertenden FF Node...
            my $community =  $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"system"}->{"site_code"}; 
            if ($community eq "bodensee"){
                # Wenn noch die Standard community ("bodensee") eingetragen ist:
                if ($debug){print "\nStandard community entdeckt.\nErmittlung von Standort anhand der GEO Position...\n";}
                #
                # Ermittlung des ungefaehren Standorts
#                --- Standortkonzept: ---
#               |          |                 | Ravensburg
#  Ueberlingen  |          |                 |_____________
#               | Markdorf |                 |
#  _____________|          | Friedrichshafen | Tettnang
#               |          |                 |______________
#     Konstanz  |          |                 |
#               |          |                 | Kressbronn
#               |          |                 |______________
#               |          |                 |
#               |          |                 |    Lindau

                #$ff_lat
                if ($ff_long < 9.2625){
                    #ueberlingen oder konstanz
                    if ($ff_lat < 47.7247){
                        if ($debug){print "! Konstanz\n";}
                        $community = "konstanz";
                    } else {
                        if ($debug){print "! ueberlingen";}
                        $community = "ueberlingen";
                    }
                } elsif (($ff_long > 9.2625) and ($ff_long < 9.4065)){
                    if ($debug){print "! markdorf";}
                    $community = "markdorf";
                } elsif (($ff_long > 9.4065 ) and ($ff_long < 9.5760)){
                    if ($debug){print "! friedrichshafen"}
                    $community = "friedrichshafen";
                } else {
                    #rv, tettnang, krb, lindau
                    if ($ff_lat > 47.6932){
                        if ($debug){print "! ravensburg";}
                        $community = "ravensburg";
                    } elsif (($ff_lat > 47.6323) and ($ff_lat < 47.6932)){
                        if ($debug){print "! tettnang";}
                        $community = "tettnang";
                    } elsif (($ff_lat > 47.5753) and ($ff_lat < 47.6323)){
                        if ($debug){print "! kressbronn";}
                        $community = "kressbronn";
                    } else {
                        if ($debug){print "! lindau";}
                        $community = "lindau";
                    }
                }
            }
            for (my $i = 0; $i < @ffcommunity; $i++) {
                if ($community eq $community_name[$i]){
                    if ($runFirstTime[$i] eq 1){
                        $runFirstTime[$i] = 0;
                    } else { $json_ffbsee[$i] .= ",\n"; }
                    $json_ffbsee[$i] .= $ff_json;
                    $ff_json = "";
                    $ff_nodes[$i]++;
                    if ($ffNodeOnline){
                        $allnodes[$i]++;
                    }
                    if ($debug){print "\nNode zur Community "; print $community_name[$i]; print " hinzugefuegt!\n\n";}
                }
            }
        }
        # Falls keine Subcommunitys gefunden wurde die default community...
        if ($ff_json ne ""){
            if ($runFirstTime[0] eq 1){
                $runFirstTime[0] = 0;
            } else { $json_ffbsee[0] .= ",\n"; }
                $json_ffbsee[0] .= $ff_json;
            $ff_json = "";
            $ff_nodes[0]++;
            if ($ffNodeOnline){
                $allnodes[0]++;
            }
            if ($debug){print "\nNode ist Teil von "; print $community_name[0];print"\n\n";}
        }
    }
}

#
#	EOFFNodes
#

for(my $i = 0; $i < @ffcommunity; $i++) {
    $json_ffbsee[$i] .= "\n    \],\n    \"updated_at\": \"$currentTime\",\n    \"version\": \"$version\"\n\}";

#	Öffne eine Datei und generiere das JSON

    open (DATEI,  '>:encoding(UTF-8)',  $json_export[$i]) or die $!;
        print DATEI $json_ffbsee[$i];
   
    close (DATEI);
}
print "JSON Files wurden erzeugt\n";
if ($nodes){
    print "\nAuswertung der Freifunk Communities:\n";
    for (my $i = 0; $i < @ffcommunity; $i++) {
        print "\nCommunity: "; 
        print $community_name[$i];
        print "\n -> Nodes: ";
        print $ff_nodes[$i];
        if ($allnodes[$i] ne $ff_nodes[$i]){
            print "\n ---> Alternative Nodes:";
            print $allnodes[$i];
        }
        print "\n -> Nodes Laut API File:";
        system "curl $api[$i] 2>/dev/null | grep \"nodes\" | cut -d: -f2 | cut -d, -f1";
        }

    print "\nJSON Files Updaten? (J/n):";
    my $update = <STDIN>;
    chomp $update;
    if (($update eq "n") or ($update eq "N") or ($update eq "^C")){
        print "\n\n";
        exit;
    }else {
        print "\nUpdate der JSON Files\n";
        for (my $i = 0; $i < @ffcommunity; $i++) {
        my $api_nodes;
            if (($community_name[$i] ne $community_name[0]) and ($i ne 7)){
                print "Nodes $community_name[$i]: $allnodes[$i] ";
                my $a = <STDIN>;
                chomp $a;
                if ($a eq ""){
                    $a =  $allnodes[$i];
                }
                $api_nodes = $a;
            } elsif ($i eq 7){
                print "\n";
            }else{
                print "\nNodes $community_name[$i]: ";
                my $tmp_nodes = $allnodes[0] + $allnodes[7] - int(`curl $api[7] 2>/dev/null | grep \"nodes\" | cut -d: -f2 | cut -d, -f1`);
                print $tmp_nodes;
                my $a = <STDIN>;
                chomp $a;
                if ($a eq ""){
                    $a =  $tmp_nodes;
                }
                $api_nodes = $a;    
            }
            if ($i ne 7){
                my @file = split(/\//,$api[$i]);
                my $apijson;
                open (DATEI, "$git_root$file[6]") or die $!;
                    while(<DATEI>){
                        $apijson = $apijson.$_;
                    }
                    $apijson =~ s/nodes\"\:\ [0-9]{1,5}/nodes\": $api_nodes/;
                    my $d = `date +%Y-%d-%mT%R:%S.%NZ`;
                    chomp $d;
                    $apijson =~ s/lastchange"\:\ \"[0-9]{1,4}-[0-9]{2}-[0-9]{2}T[0-9]{2}\:[0-9]{2}\:[0-9]{2}\.[0-9]{1,9}Z/lastchange\"\:\ \"$d/;
                close (DATEI);
                open (DATEI, ">$file[6]") or die $!;
                    print DATEI $apijson;
                close (DATEI);
            }print "\n";
        }
    }
}


