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

my $anzStatusZeilen=0;

my %cgivars=();
my @Statistik=0;

my @prefzeit=0;
my $anzPrefsZeilen;

my $h0=0;
my $h1=0;
my $h2=0;
my $h3=0;
my $h4=0;
my $h5=0;
my $h6=0;
my $h7=0;
my $h8=0;
my $h9=0;
my $h10=0;


my $Alarmstatus=0;
my $Resetstatus=1;
my @alarmdatei=0;
my $anzAlarmdateiZeilen=0;

open ALARMDATEI, "<../public_html/Data/HomeAlarmDaten.txt" || die "HOMEALARMDATEI nicht gefunden\n";
@alarmdatei = <ALARMDATEI>;
chomp(@alarmdatei);
$anzAlarmdateiZeilen=@alarmdatei;


# First, get the CGI variables into a list of strings
%cgivars= &getcgivars ;

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
open LOGFILE, ">>../public_html/Data/AlarmLog.txt" || die "AlarmLogfile A nicht gefunden\n";
print LOGFILE "* Alarm $Datumstring\t";
close(LOGFILE);

#
printf ("Alarm Datumstring: $Datumstring<br>");
my $jahrlong= $jahr + 2000;
#printf "$jahrlong<br>";

my $newTag = "$tag";


my $writeTask=0; # Aufforderung, AlarmDaten neu zu schreiben

my @alarmdatei=0;
my $anzAlarmdateiZeilen=0;

open ALARMDATEI, "<../public_html/Data/AlarmDaten.txt" || die "HOMEDATEI nicht gefunden\n";
@alarmdatei = <ALARMDATEI>;
chomp(@alarmdatei);
$anzAlarmdateiZeilen=@alarmdatei;

printf "Die Datei AlarmDaten.txt hat $anzAlarmdateiZeilen Zeilen.<br>$alarmdatei[0]<br>";

# open LOGFILE, ">>../public_html/Data/AlarmLog.txt" || die "Logfile nicht gefunden H\n";
# print LOGFILE "Die Datei AlarmDaten.txt hat $anzAlarmdateiZeilen Zeilen: \n";
# close(LOGFILE);

#	open ALARMDATEI, ">>../public_html/Data/AlarmDaten.txt" || die "ALARMDATEI nicht gefunden\n";



#if ($size <= 10)
# File ist noch leer, Titel schreiben

if ($anzAlarmdateiZeilen==0) 
{
open LOGFILE, ">>../public_html/Data/AlarmLog.txt" || die "Logfile nicht gefunden H\n";
print LOGFILE "anzAlarmdateiZeilen ist NULL\n";
close(LOGFILE);

	printf "anzHomedateiZeilen ist NULL\n";
	$alarmdatei[0] = "HomeCentral";
 	$jahr +=2000;
 	$alarmdatei[1] = "Startzeit: $jahr-$monat-$tag $stunde:$min:$sec";
 	$alarmdatei[2] = "$Datumstring";
 	$alarmdatei[3] = "Status: $Alarmstatus"; # Zeile 3
 	$alarmdatei[4] = "Reset: $Resetstatus";	# Zeile 4
	
}
else
{
# 	open LOGFILE, ">>../public_html/Data/AlarmLog.txt" || die "Logfile nicht gefunden H\n";
# 	print LOGFILE "anzAlarmdateiZeilen ist nicht NULL, sondern $anzAlarmdateiZeilen\n";
# 	close(LOGFILE);

	# Alarmstatus lesen
	if ($anzAlarmdateiZeilen>=4) # Zeile Alarmstatus und Resetstatus vorhanden
	{
 	open LOGFILE, ">>../public_html/Data/AlarmLog.txt" || die "Logfile nicht gefunden H\n";
#	print LOGFILE "anzAlarmdateiZeilen ist OK\n";
	
		$alarmdatei[2] = "$Datumstring";
		my $Statuszeile = $alarmdatei[3];
		my @Statuszeilearray= split(" ",$alarmdatei[3]); # 
		
		$anzStatusZeilen=@Statuszeilearray; 	# Anzahl Items in Statuszeile
		#print LOGFILE "Statuszeilearray[1]: $Statuszeilearray[1]\n";
		if ($anzStatusZeilen > 1)
		{
			$Alarmstatus = $Statuszeilearray[1]; 	# status an zweiter Stelle auf der Zeile
		}

		my $Resetzeile = $alarmdatei[4];
		my @Resetzeilearray= split(" ",$alarmdatei[4]); # 
		
		my $anzResetZeilen=@Resetzeilearray; 	# Anzahl Items in Resetzeile
		#print LOGFILE "alte Werte: Statuszeilearray[1]: $Statuszeilearray[1]	Resetzeilearray[1]: $Resetzeilearray[1]\n";
		
		if ($anzResetZeilen > 1)
		{
			$Resetstatus = $Resetzeilearray[1]; 	# reset an zweiter Stelle auf der Zeile
			
		}
	close(LOGFILE);
	}
	
	printf "Alarmstatus: $Alarmstatus <br>Resetstatus: $Resetstatus<br>";
	
	# print ALARMDATEI "*$laufzeit*\t$cgivars{d2}\t$cgivars{d3}\t$cgivars{d4}\t$cgivars{d1}\t$cgivars{d0}\t0\n";
	
	# Alarm.Byte lesen
	$h0 = hex($cgivars{d0});	#  	Alarm von Tiefkuehltruhe und Wasser
	$h1 = hex($cgivars{d1});	# 	twierrcount 	Lampe-code von EEPROM 
	#$h2 = hex($cgivars{d2});	#	Echo Heizung // auskomm 7.4.11
	$h2 = hex($cgivars{d2});	#	29 Lampe (syncfehler)
	
	$h3 = hex($cgivars{d3});	#	Brenner Stundencode
	$h4 = hex($cgivars{d4});	#	Heizung Stundencode von EEPROM
	$h5 = hex($cgivars{d5}); 	# 	26: EEPROM_Err
	$h6 = hex($cgivars{d6}); 	# 	25: Write_Err 
	$h7 = hex($cgivars{d7});	#	24: Read_Err
	$h8 = hex($cgivars{d8});	#	23: Zeit.minute vom Master (DCF77)
	$h9 = hex($cgivars{d9});	#	Differenz errCounter von Webserver
	$h10 = hex($cgivars{d10});	#	SPI_Err
	
	open LOGFILE, ">>../public_html/Data/AlarmLog.txt" || die "Logfile nicht gefunden J\n";
		# print LOGFILE "$laufzeit\t$cgivars{d2}\t$cgivars{d3}\t$cgivars{d4}\t$cgivars{d1}\t$cgivars{d0}\t0\n";
	print LOGFILE "Status: $Alarmstatus Reset: $Resetstatus\t";
	#$h0 |= 0x04;
	
	print LOGFILE "h0: $h0\t";
	
	if ($h0 & 0x08) # Kuehltruhe ist hops
	{
	
		print LOGFILE "Kuehltruhe ist hops.\n";
		printf "Kuehltruhe ist hops.<br>";
		
		
		if ($Alarmstatus == 0) # 	Alarm geht erst los. Alarmstatus ist noch nicht gesetzt
		{
			$writeTask=1;
			$Resetstatus = 0; # Erste Meldung von Alarm: Resetstatus zuruecksetzen
			$Alarmstatus = 1; # Alarmstatus setzen
			$alarmdatei[4] = "Reset: $Resetstatus";	# Zeile 4
			$alarmdatei[3] = "Status: $Alarmstatus";	# Zeile 3
		}
		
		if ($Resetstatus == 0) # Reset ist noch nicht gesetzt
		{
			# Mail-Stuff
			my $title='HomeCentralAlarm';
			my $to='r.heimlicher@bluewin.ch';
			my $from= 'ruediheimlicher@ruediheimlicher.ch';
			my $subject='homecentralalarm';

			my $pushto='ruediheimlicher@dopushmail.com';

			
			my $mailzeile=0;
			open MAILDATEI, "<../public_html/Data/alarm_mail.txt" || die "MAILDATEI nicht gefunden\n";
			my @Maildatei = <MAILDATEI>;
			chomp(@Maildatei);
			my $anzMaildateiZeilen=@Maildatei;
			
			if ($anzMaildateiZeilen>1)
			{
				$mailzeile = $Maildatei[0];
			}
			
			
			close MAILDATEI;
			
			
			open(MAIL, "|/usr/sbin/sendmail -t");

			## Mail Header
			print MAIL "To: $to\n";
			print MAIL "From: $from\n";
			print MAIL "Subject: $subject\n\n";
			## Mail Body
			print MAIL "Etwas ist nicht mehr in Ordnung:\n $mailzeile";
			close(MAIL);

# 			open(MAIL, "|/usr/sbin/sendmail -t");
# 
# 			## Mail Header
# 			print MAIL "To: $pushto\n";
# 			print MAIL "From: $from\n";
# 			print MAIL "Subject: $subject\n\n";
# 			## Mail Body
# 			print MAIL "Etwas ist nicht mehr in Ordnung:\n $mailzeile";
# 			
# 			close(MAIL);
			
			print "<html><head><title>$title</title>
			</head>\n<body>\n\n";
			
			## HTML content let use know we sent an email
			print "<h1>$title</h1>\n";
			print "<p>Eine Meldung wurde von $from an $to geschickt: $mailzeile <br>cgivars: $h0";
			print "\n\n</body></html>";
			
			
		} # Resetstatus == 0	
	
	
	}
	else #	Kuehltruhe ist OK
	{
		print LOGFILE "Kuehltruhe ist OK. ";
		printf "Kuehltruhe ist OK.<br>";
		
		if ($Alarmstatus == 1)
		{
			$writeTask=1;
			$Alarmstatus = 0;
			$alarmdatei[3] = "Status: $Alarmstatus";	# Zeile 3 zuruecksetzen

			$Resetstatus = 1;
			$alarmdatei[4] = "Reset: $Resetstatus";	# Zeile 4 setzen
		
		}
		
	}
	
	if ($h0 & 0x10) # Wasser im Keller laeuft aus
	{
	
		print LOGFILE "Wasser im Keller.\n";
		printf "Wasser im Keller laeuft aus.<br>";
		
		if ($Alarmstatus == 0) # 	Alarm geht erst los. Alarmstatus ist noch nicht gesetzt
		{

			$writeTask=1;
			$Resetstatus = 0; # Erste Meldung von Alarm: Resetstatus zuruecksetzen
			$Alarmstatus = 1; # Alarmstatus setzen
			$alarmdatei[4] = "Reset: $Resetstatus";	# Zeile 4
			$alarmdatei[3] = "Status: $Alarmstatus";	# Zeile 3
		}
		
		if ($Resetstatus == 0) # Reset ist noch nicht gesetzt
		{
			# Mail-Stuff
			my $title='HomeCentralAlarm';
			my $to='r.heimlicher@bluewin.ch';
			my $from= 'ruediheimlicher@ruediheimlicher.ch';
			my $subject='homecentralalarm';

			my $pushto='ruediheimlicher@dopushmail.com';

			
			my $mailzeile=0;
			open MAILDATEI, "<../public_html/Data/alarm_mail.txt" || die "MAILDATEI nicht gefunden\n";
			my @Maildatei = <MAILDATEI>;
			chomp(@Maildatei);
			my $anzMaildateiZeilen=@Maildatei;
			
			if ($anzMaildateiZeilen>1)
			{
				$mailzeile = $Maildatei[1];
			}
			
			
			close MAILDATEI;
			
			
			open(MAIL, "|/usr/sbin/sendmail -t");

			## Mail Header
			print MAIL "To: $to\n";
			print MAIL "From: $from\n";
			print MAIL "Subject: $subject\n\n";
			## Mail Body
			print MAIL "Etwas ist nicht mehr in Ordnung:\n $mailzeile";
			close(MAIL);

# 			open(MAIL, "|/usr/sbin/sendmail -t");
# 
# 			## Mail Header
# 			print MAIL "To: $pushto\n";
# 			print MAIL "From: $from\n";
# 			print MAIL "Subject: $subject\n\n";
# 			## Mail Body
# 			print MAIL "Etwas ist nicht mehr in Ordnung:\n $mailzeile";
# 			
# 			close(MAIL);
			
			print "<html><head><title>$title</title>
			</head>\n<body>\n\n";
			
			## HTML content let use know we sent an email
			print "<h1>$title</h1>\n";
			print "<p>Eine Meldung wurde von $from an $to geschickt: $mailzeile <br>cgivars: $h0";
			print "\n\n</body></html>";
			
			
		} # Resetstatus == 0	

	}
		else #	Keller ist OK
	{
		print LOGFILE "Keller ist OK.";
		printf "Keller ist OK.<br>";
		
		if ($Alarmstatus == 1)
		{
			$writeTask=1;
			$Alarmstatus = 0;
			$alarmdatei[3] = "Status: $Alarmstatus";	# Zeile 3 zuruecksetzen

			$Resetstatus = 1;
			$alarmdatei[4] = "Reset: $Resetstatus";	# Zeile 4 setzen
		
		}
	}
	
	open TWIERRDATEI, ">>../public_html/Data/twierr.txt" || die "TWIERRFILE nicht gefunden\n";
	print TWIERRDATEI "$Datumstring\ttwierr Byte d1: $h1\tLampe: $h2\n";
	close TWIERRDATEI;

	print LOGFILE "\n";
	close(LOGFILE);
	
}	

#if ($writeTask) 
# AlarmDaten neu schreiben
{
	open ALARMDATEI, ">../public_html/Data/AlarmDaten.txt" || die "Alarmdaten nicht gefunden\n";
	foreach (@alarmdatei)
	{
		print ALARMDATEI "$_\n";
	}

	close(ALARMDATEI);
}

my $k=0;
my $v=0;
my $u=0;
my $lastErrcounter=0;
my @ErrLogDatei=0;
my $anzErrlogzeilen=0;

# ErrLog lesen, letzte Zeile lesen
open ERRLOGFILE, "<../public_html/Data/ErrLog.txt" || die "ErrLogfile nicht gefunden J\n";
@ErrLogDatei = <ERRLOGFILE>;
chomp(@ErrLogDatei);
$anzErrlogzeilen=@ErrLogDatei;

my @lastErrzeilearray= split("\t",$ErrLogDatei[$anzErrlogzeilen-1]); #
my $anzElemente = @lastErrzeilearray;
my @lastElementArray = split(" ",$lastErrzeilearray[$anzElemente-1]);
$lastErrcounter = $lastElementArray[1];

$u=keys %cgivars;
	open ERRLOGFILE, ">>../public_html/Data/ErrLog.txt" || die "ErrLogfile nicht gefunden J\n";
	#print ERRLOGFILE "start\n";
	#print ERRLOGFILE "anz:  $u\n";
	#print ERRLOGFILE "end\n";
#	print ERRLOGFILE "$Datumstring\tMinuten: $h6\tEcho Heizung: $h2\tHeizung Code: $h3\tMode Code: $h4\tRinne Code: $h5\n";
	
	print ERRLOGFILE "$Datumstring ";
#	print ERRLOGFILE "min:$h8 ";
	my $diff=$h8-$min; # Differenz Systemzeit - DCF77-Zeit vom Master
	#print ERRLOGFILE "DCF77_diff:$diff\t";
	#print ERRLOGFILE "sync_err:$h2  \t";
	if ($h7)
	{
		print ERRLOGFILE "read_err:$h7 ";
	}
	if ($h6)
	{
		print ERRLOGFILE "write_err:$h6 ";
	}
#	if ($h5)
	{
		print ERRLOGFILE "EE_err:$h5 ";
	}
	#if (!($h3 == $h2))
	{
#		print ERRLOGFILE "Heizung_code:$h4 ";
#		print ERRLOGFILE "Brenner_code:$h3 ";
		print ERRLOGFILE "Lampe_ON:$h2 ";
#		print ERRLOGFILE "twierr:$h1 ";
#		print ERRLOGFILE "B_echo:$h2 ";
#		if ($h2 == $h3) #alles OK, Code an Heizung ist gleich wie Echo von Heizung
#		{
#		print ERRLOGFILE "TRUE ";
#		}
#		else
#		{
#		print ERRLOGFILE "FALSE ";
#		}
#		print ERRLOGFILE "H_rinne:$h1 ";
	}
#	print ERRLOGFILE "SPI_Err:$h10 ";
	#print ERRLOGFILE "lastErrcounter: $lastErrcounter\t";
	my $ErrDiff = $h9 - $lastErrcounter;
#	print ERRLOGFILE "errCounter_Diff: $ErrDiff\t: $h9\n";
	#print ERRLOGFILE ": $h9\n";
	print ERRLOGFILE "\n";
	close ERRLOGFILE;


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
sub HTMLdie 
{
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
