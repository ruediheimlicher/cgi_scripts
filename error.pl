#!/usr/bin/perl -w
use CGI::Carp qw( fatalsToBrowser );
#
#
use strict;
my @prefdok=();
my (@dok)=();
my ($size)=0;
my ($prefsize)=0;
my @DatenzeilenArray=();
my $Datenwert = 0;
my $Datumstring=0;
my $lastDatumstring=0;
my @zeit=0;
my $jahr=0;
my $monat=0;
my $tag =0; 
my $stunde=0;
my $min =0;
my $sec =0;
my $tagsekunde=0;
my $laufzeit=0;

my $Brennerlaufzeit=0;
my $brennerstatus=0;
my $anzStatusZeilen=0;

my %cgivars;
my @Statistik=0;

my @prefzeit=0;
my $anzPrefsZeilen;


# First, get the CGI variables into a list of strings
%cgivars= &getcgivars ;
#
# Daten von Err.txt lesen
#

# zeit Vorlauf Ruecklauf BoilerU BoilerM BoilerO 
#printf SOLARDATEI "%d\t%d\t%d\t%d\t%d\t%d\t%d\t0\n",$laufzeit,$cgivars{d2},$cgivars{d3},$cgivars{d4},$cgivars{d1},$cgivars{d0};

# print SOLARDATEI "$laufzeit\t$cgivars{d2}\t$cgivars{d3}\t$cgivars{d4}\t$cgivars{d1}\t$cgivars{d0}\t0\n";

my $raum = hex($cgivars{d0});							# 	Raum
my $err1 = hex($cgivars{d1});							# 	
my $err2 = hex($cgivars{d2});							#	
my $err3 = hex($cgivars{d3});							#	
my $err4 = hex($cgivars{d4});							#	
my $err5 = hex($cgivars{d5});							#	
my $err6 = hex($cgivars{d6});							#	
my $err7 = hex($cgivars{d7});							# 	


printf "Err: Raum: $raum\tErr1: $err1\tErr2: $err2\tErr3: $err3\tErr4: $err4\tErr5: $err5\tErr6: $err6\tErr7: $err7<br>";

# Print the CGI response header, required for all HTML output ****WICHTIG****
# Note the extra \n, to send the blank line
print "Content-type: text/html\n\n" ;

# cgivars in Textfile sichern
@zeit=localtime();

$jahr=$zeit[5]-100;
if (length($jahr) == 1)
{
    $jahr="0$jahr";
}

$monat = $zeit[4]+1;
if (length($monat) == 1)
{
    $monat="0$monat";
}
$tag= $zeit[3];
if(length($tag) == 1)
{
   $tag="0$tag";
}
$stunde = $zeit[2];
if(length($stunde) == 1)
{
   $stunde="0$stunde";
}
$min = $zeit[1];
if(length($min) == 1)
{
   $min="0$min";
}
$sec = $zeit[0];
if(length($sec) == 1)
{
   $sec="0$sec";
}
$tagsekunde = ((($zeit[2] * 60) + $zeit[1]) * 60) + $zeit[0];

$Datumstring = "Datum: $tag.$monat.$jahr $stunde:$min";
	open ERRFILE, ">>../public_html/Data/Err.txt" || die "ERRFILE A nicht gefunden\n";
	print ERRFILE "Start Datumstring: $Datumstring\n";
	close(ERRFILE);





open ERRFILE, ">>../public_html/Data/Err.txt" || die "ERRFILE nicht gefunden I\n";
print ERRFILE "** $Datumstring\t\n";
close(ERRFILE);



#open ERRFILE, ">>../public_html/Data/Err.txt" || die "ERRFILE nicht gefunden N\n";
#print ERRFILE "$laufzeit\t$cgivars{d2}\t$cgivars{d3}\t$cgivars{d4}\t$cgivars{d1}\t$cgivars{d0}\t$cgivars{d6}\t$cgivars{d7}\t0\n";
#close(ERRFILE);

# Finally, print out the complete HTML response page
# print <<EOF druckt alles bis EOF


# Print the CGI variables sent by the user.
# Note that the order of variables is unpredictable.
# Also note this simple example assumes all input fields had unique names,
#   though the &getcgivars() routine correctly handles similarly named
#   fields-- it delimits the multiple values with the \0 character, within 
#   $cgivars{$_}.
open ERRFILE, ">>../public_html/Data/Err.txt" || die "ERRFILE nicht gefunden I\n";

foreach (keys %cgivars) 
{
    print "<li>[$_] = [$cgivars{$_}]\n" ;
}
close(ERRFILE);



exit ;


# Read all CGI vars into an associative array.
# If multiple input fields have the same name, they are concatenated into
#   one array element and delimited with the \0 character (which fails if
#   the input has any \0 characters, very unlikely but conceivably possible).
# Currently only supports Content-Type of application/x-www-form-urlencoded.
sub getcgivars {
    my ($in, %in) ;
    my ($name, $value) ;

    # First, read entire string of CGI vars into $in
    if ( ($ENV{'REQUEST_METHOD'} eq 'GET') ||
         ($ENV{'REQUEST_METHOD'} eq 'HEAD') ) {
        $in= $ENV{'QUERY_STRING'} ;

    } 
    elsif ($ENV{'REQUEST_METHOD'} eq 'POST') 
    {
        if ($ENV{'CONTENT_TYPE'}=~ m#^application/x-www-form-urlencoded$#i) 
        {
            length($ENV{'CONTENT_LENGTH'})
                || &HTMLdie("No Content-Length sent with the POST request.") ;
            read(STDIN, $in, $ENV{'CONTENT_LENGTH'}) ;

        } 
        else 
        { 
            &HTMLdie("Unsupported Content-Type: $ENV{'CONTENT_TYPE'}") ;
        }

    } else {
        &HTMLdie("Script was called with unsupported REQUEST_METHOD.") ;
    }
    
    # Resolve and unencode name/value pairs into %in
    foreach (split(/[&;]/, $in)) {
        s/\+/ /g ;
        ($name, $value)= split('=', $_, 2) ;
        $name=~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/ge ;
        $value=~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/ge ;
        $in{$name}.= "\0" if defined($in{$name}) ;  # concatenate multiple vars
        $in{$name}.= $value ;
    }

    return %in ;

}


# Die, outputting HTML error page
# If no $title, use a default title
sub HTMLdie {
    my ($msg,$title)= @_ ;
    $title= "CGI Error" if $title eq '' ;
    print <<EOF ;
Content-type: text/html

<html>
<head>
<title>$title</title>
</head>
<body>
<h1>$title</h1>
<h3>$msg</h3>
</body>
</html>
EOF

    exit ;
}
