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

my $Alarmstatus=0;
my $Resetstatus=1;
my @alarmdatei=0;
my $writeTask=0;
my $anzAlarmdateiZeilen=0;

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
	open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile A nicht gefunden\n";
	print LOGFILE "Start Datumstring: $Datumstring\n";
	close(LOGFILE);

#
# HomeAlarmDaten lesen
#

#	HomeAlarmDaten anlegen/laden

open ALARMDATEI, "<../public_html/Data/HomeAlarmDaten.txt" || die "HOMEDATEI nicht gefunden\n";
@alarmdatei = <ALARMDATEI>;
chomp(@alarmdatei);
$anzAlarmdateiZeilen=@alarmdatei;

printf "Die Datei HomeAlarmDaten.txt hat $anzAlarmdateiZeilen Zeilen.<br>$alarmdatei[0]<br>";

# open LOGFILE, ">>../public_html/Data/AlarmLog.txt" || die "Logfile nicht gefunden H\n";
# print LOGFILE "Die Datei AlarmDaten.txt hat $anzAlarmdateiZeilen Zeilen: \n";
# close(LOGFILE);

#	open ALARMDATEI, ">>../public_html/Data/AlarmDaten.txt" || die "ALARMDATEI nicht gefunden\n";



#if ($size <= 10)
# File ist noch leer, Titel schreiben

if ($anzAlarmdateiZeilen==0) 
{
open LOGFILE, ">>../public_html/Data/AlarmLog.txt" || die "Logfile nicht gefunden H\n";
print LOGFILE "HomeAlarmDaten: anzAlarmdateiZeilen ist NULL\n";
close(LOGFILE);

	printf "anzHomedateiZeilen ist NULL<br>";
	$alarmdatei[0] = "HomeCentral";
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
#	print LOGFILE "home: anzAlarmdateiZeilen ist OK\n";
	
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
		#print LOGFILE "home: alte Werte: Statuszeilearray[1]: $Statuszeilearray[1]	Resetzeilearray[1]: $Resetzeilearray[1]\n";
		
		if ($anzResetZeilen > 1)
		{
			$Resetstatus = $Resetzeilearray[1]; 	# reset an zweiter Stelle auf der Zeile
			
		}
	close(LOGFILE);
	}
	
	printf "home Alarmstatus: $Alarmstatus <br>Resetstatus: $Resetstatus<br>";

}

#	End HomeAlarmDaten




#
# Prefs lesen, neues Datum einsetzen
#


open PREFS, "<../public_html/Data/HomeCentralPrefs.txt" || die "Prefs 1 nicht gefunden\n";
my @prefstat = stat(PREFS);
$prefsize=$prefstat[7];
my @feld=<PREFS>;
my $anzZeilen=@feld;
close(PREFS);
#print PREFS "size $prefsize\n";
# Wenn leer: neue Datei
#if ($prefsize == 0)
if($anzZeilen == 0)
{
	open PREFS, ">../public_html/Data/HomeCentralPrefs.txt" || die "Prefs 2 nicht gefunden\n";
	#print PREFS "N $Datumstring";
	$lastDatumstring=$Datumstring;
	print PREFS "$Datumstring*";
	close (PREFS);
	
	open TIMEPREFS, ">../public_html/Data/TimePrefs.txt" || die "TimePrefs nicht gefunden\n";
	print TIMEPREFS time();
	close(TIMEPREFS);
	
	open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden A\n";
	print LOGFILE "neues File: $Datumstring\n";
	close(LOGFILE);
	
}
else
{
#	print PREFS "feld: @feld\n";
	open PREFS, ">../public_html/Data/HomeCentralPrefs.txt" || die "Prefs 3 nicht gefunden\n";
	#print PREFS "Anz Zeilen:";
	#print PREFS "$anzZeilen\n";
	my $linien=0;
	my $eintrag=0;
	#seek(PREFS,0,0);
	#@prefdok=<PREFS>;
	#foreach $eintrag (@feld)
	#{
	#	push(@prefdok,$eintrag);
	#	$linien++;
	#} 
#	print PREFS "size $prefsize\n";
#	print PREFS "prefdoc linien: $linien Daten: \n@prefdok";
	
	$lastDatumstring=$feld[0];
	
	print PREFS "$Datumstring\n";
	#  lastDatumstring: $lastDatumstring\n";
	close (PREFS);
	
	open TIMEPREFS, "<../public_html/Data/TimePrefs.txt" || die "TimePrefs 4 nicht gefunden\n";
	@prefzeit = <TIMEPREFS>;
	$anzPrefsZeilen=@prefzeit;
	if ($anzPrefsZeilen == 0)
	{
		open  TIMEPREFS, ">../public_html/Data/TimePrefs.txt" || die "TimePrefs nicht gefunden\n";
		print TIMEPREFS time();
		
		# 22.08.09
#		$laufzeit = 0;
		#
		open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden B\n";
		print LOGFILE "TimePrefs anzPrefszeilen == 0  $Datumstring Tagsekunde: $tagsekunde\n";
		close(LOGFILE);

	}
	else
	{
		
		$laufzeit = $tagsekunde;
		my $laufzeitausprefs=time() - $prefzeit[0];
		my $diff= $laufzeit - $laufzeitausprefs;
		
		open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden C\n";
		#print LOGFILE "laufzeitausprefs: $laufzeitausprefs laufzeit: $laufzeit Diff: $diff\n";
		#print LOGFILE "anzPrefszeilen: $anzPrefsZeilen  prefzeit [0]: $prefzeit[0]  laufzeit: $laufzeit  Diff: $diff\n";
		
		close(LOGFILE);

	}
	close(TIMEPREFS);

	
}



#
# Wenn neues Datum nicht gleich wie altes Datum > HomeData sichern in Ordner HomeData
# mit Datum aus lastDatumstring
#

my @lastDatumstringarray = split(" ",$lastDatumstring);

my @lastZeitarray= split(":",$lastDatumstringarray[2]); # Zeitangabe 

my $oldStunde = $lastZeitarray[0]; # Stunde
my $oldMinute = $lastZeitarray[1]; # Minute
my $newMinute = $min;
my $newStunde = $stunde;


my $oldFilename = $lastZeitarray[0]; # Stunde
my $newFilename = "$stunde";

my @lastDatumarray= split("", $lastDatumstringarray[1]); # Datumangabe
#
my $oldTag =$lastDatumarray[0].$lastDatumarray[1]; # Elemente 0,1: Tag des Monats
my $oldMonat=$lastDatumarray[3].$lastDatumarray[4]; # Elemente 3,4: Monat des Jahres
my $oldJahr=$lastDatumarray[6].$lastDatumarray[7]; # Elemente 6,7: Jahr

#
printf ("home Datumstring: $Datumstring<br>");
my $jahrlong= $jahr + 2000;
printf "$jahrlong<br>";

my $oldJahrlong = $oldJahr+2000;
printf "oldJahrlong: $oldJahrlong<br>";

my $testnewPfad="../public_html/Data/HomeDaten/$oldJahrlong/HomeDaten$oldJahr$oldMonat$oldTag.txt";
	
printf "newPfad: $testnewPfad<br>";

my $newTag = "$tag";

#open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden D\n";
#print LOGFILE " Log: oldTag: $oldTag  newTag: $newTag\n";
#print LOGFILE "oldFilename: $oldFilename  newFilename: $newFilename\n";
#close(LOGFILE);
	
		
	
	
	
#if ($oldFilename ne $newFilename)
#if ($oldMinute ne $newMinute)
#if ($oldStunde ne $newStunde)
if ($oldTag ne $newTag) # Tagzahl hat sich geaendert
{
	printf ("neue Minute: $newMinute\n");
	open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden E\n";
	print LOGFILE "neuer Tag: laufzeit\n";
	close(LOGFILE);

	open PREFS, ">../public_html/Data/HomeCentralPrefs.txt" || die "Prefs 226 nicht gefunden\n";
	print PREFS "";
	close (PREFS);
	
	open TIMEPREFS, ">../public_html/Data/TimePrefs.txt" || die "TimePrefs nicht gefunden\n";
	print TIMEPREFS "";
	close (TIMEPREFS);
	
	my $oldPfad="../public_html/Data/HomeDaten.txt";
	#my $newFilename="HomeDaten/HomeDaten$jahr$monat$tag.txt";
	#my $newFilename="HomeDaten/HomeDaten.txt";
	#my $newPfad="HomeDaten/HomeDaten$tag$stunde.txt";
	
	#my $newPfad="HomeDaten/HomeDaten$jahr$monat$tag.txt";
	my $newPfad="../public_html/Data/HomeDaten/$oldJahrlong/HomeDaten$oldJahr$oldMonat$oldTag.txt";
	
	
	#copy($oldPfad, $newPfad) or die "Copy failed: $!";
	#print PREFS "\noldPfad: $oldPfad newPfad: $newPfad\n";
	#close(PREFS);
	#open OLD,"<../public_html/Data/HomeDaten.txt" ;
	open OLD,"<$oldPfad" ;
	my @Data=<OLD>;
	
	open NEW,">$newPfad" || die "NEW nicht gefunden\n";
	print NEW "@Data";
	close(NEW);
	open OLD,">$oldPfad" || die "OLD nicht gefunden\n";
	print OLD "";
	close(OLD);

	# Neu: JahrOrdner		
	my $newJahrOrdnerPfad="../public_html/Data/HomeDaten/$jahrlong/HomeDaten$oldJahr$oldMonat$oldTag.txt";
	printf "$newJahrOrdnerPfad<br>";
	open NEWJAHR, ">$newJahrOrdnerPfad" || die "NEWJAHR nicht gefunden\n";
	print NEWJAHR "@Data";
	close(NEWJAHR);	
	# JahrOrdner
		
	$laufzeit=0;
	
	# neu	Daten fuer Brennerzeit speichern
	 my $Brennerzeitstring;
	 my @Brennerzeitdatei=0;
	 my $anzZeilen=0;
	 my $Brennerzeit=0;
	 my $BrennerzeitMittel=0;
	
	# Brennerzeit des Tages  lesen
	 open TAGBRENNERZEIT, "<../public_html/Data/BrennerDaten.txt" || die "TAGBRENNERZEIT nicht gefunden\n";
	 @Brennerzeitdatei = <TAGBRENNERZEIT>;
	 chop(@Brennerzeitdatei);
	 $anzZeilen=@Brennerzeitdatei;
	 if ($anzZeilen)
	 {
	 	$Brennerzeit = $Brennerzeitdatei[5];
	 	$BrennerzeitMittel = $Brennerzeitdatei[8];
	 }
	 close (TAGBRENNERZEIT);
	
	 $Brennerzeitstring = "$oldTag.$oldMonat.$oldJahr\t$Brennerzeit\t$BrennerzeitMittel\n"; # Datum
	
	# File fuer Brennerzeit oeffnen
	
	 open BRENNERZEIT, ">>../public_html/Data/Brennerzeit.txt" || die "BRENNERZEIT nicht gefunden\n";
	 print(BRENNERZEIT $Brennerzeitstring);
	 close (BRENNERZEIT);
	
	# File loeschen
	unlink("../public_html/Data/BrennerDaten.txt");
	
	# leeres File fuer Brennerdaten erzeugen
	open LEERESFILE,">../public_html/Data/BrennerDaten.txt" ;
	close(LEERESFILE);
	chmod(0755,"../public_html/Data/BrennerDaten.txt");
	
	# neu
	
	# neu	Daten fuer Temperatur speichern
	 my $Temperaturstring;
	 my @Temperaturdatei=0;
	 my $anzTempZeilen=0;
	 my $Temperaturmittel=0;
	my $TagTemperaturmittel=0;
	my $NachtTemperaturmittel=0;
	# Temperaturdaten des Tages  lesen
	 open TEMPERATURDATEI, "<../public_html/Data/TemperaturDaten.txt" || die "TEMPERATURDATEI nicht gefunden\n";
	 @Temperaturdatei = <TEMPERATURDATEI>;
	 chop(@Temperaturdatei);
	 $anzTempZeilen=@Temperaturdatei;
	 if ($anzTempZeilen )
	 {
	 	$Temperaturmittel = $Temperaturdatei[7];
	 	my @tempTagarray=split(" ",$Temperaturdatei[10]);
	 	$TagTemperaturmittel = $tempTagarray[2];		 	
	 	my @tempNachtarray=split(" ",$Temperaturdatei[13]);
	 	$NachtTemperaturmittel = $tempNachtarray[2];
	 }
	 close (TAGBRENNERZEIT);
	
	 $Temperaturstring = "$oldTag.$oldMonat.$oldJahr\tTemperaturmittel: $Temperaturmittel\tTagTemperaturmittel: $TagTemperaturmittel\tNachtTemperaturmittel: $NachtTemperaturmittel\n"; # Datum
		
	# File fuer Temperaturmittel oeffnen, Mittelwert eintragen
	
	 open TEMPERATURDATEI, ">>../public_html/Data/TemperaturMittel.txt" || die "TEMPERATURDATEI nicht gefunden\n";
	 print(TEMPERATURDATEI $Temperaturstring);
	 close (TEMPERATURDATEI);
	
	# File loeschen
	unlink("../public_html/Data/TemperaturDaten.txt");
	
	# leeres File fuer Temperaturdaten erzeugen
	open LEERESFILE,">../public_html/Data/TemperaturDaten.txt" ;
	close(LEERESFILE);
	chmod(0755,"../public_html/Data/TemperaturDaten.txt");
	
	# neu

}
	else
{
	#open PREFS, ">>../public_htmi/Data/HomeCentralPrefs.txt" || die "Prefs nicht gefunden\n";
	#print PREFS "\nkein neues File\n";
	#close(PREFS);


}


open HOMEDATEI, ">>../public_html/Data/HomeDaten.txt" || die "HOMEDATEI nicht gefunden\n";

@Statistik=stat(HOMEDATEI);
$size=$Statistik[7];

#open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden F\n";
#print LOGFILE "Die Datei HomeDaten.txt ist $size Bytes gross.\n";
#close(LOGFILE);
my @homedatei=0;
my $anzHomedateiZeilen=0;

open HOMEDATEI, "<../public_html/Data/HomeDaten.txt" || die "HOMEDATEI nicht gefunden\n";
@homedatei = <HOMEDATEI>;
$anzHomedateiZeilen=@homedatei;



my @Brennerdatei=0;
my $anzBrennerdateiZeilen=0;
my $oldLaufzeit=0;
my $oldBrennerlaufzeit=0;
my $oldBrennerstatus=0;


open BRENNERDATEI, "<../public_html/Data/BrennerDaten.txt" || die "BRENNERDATEI nicht gefunden\n";
@Brennerdatei = <BRENNERDATEI>;
chomp(@Brennerdatei);
$anzBrennerdateiZeilen=@Brennerdatei;

#open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden G\n";
#print LOGFILE "Die Datei BrennerDaten.txt hat $anzBrennerdateiZeilen Zeilen.\n";
#close(LOGFILE);


#open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden H\n";
#print LOGFILE "Die Datei HomeDaten.txt hat $anzHomedateiZeilen Zeilen.\n";
#close(LOGFILE);

open HOMEDATEI, ">>../public_html/Data/HomeDaten.txt" || die "HOMEDATEI nicht gefunden\n";

open BRENNERDATEI, ">../public_html/Data/BrennerDaten.txt" || die "BRENNERDATEI nicht gefunden\n";

if ($anzBrennerdateiZeilen==0)	# File ist noch leer, Titel schreiben
{
	$Brennerdatei[0] = "HomeCentral";
	$Brennerdatei[1] = "Brennerdaten";
	$Brennerdatei[2] = "$Datumstring";
	$Brennerdatei[3] = "Zeit: $stunde:$min";
	$Brennerdatei[4] = "$laufzeit";
	$Brennerdatei[5] = "$Brennerlaufzeit";
	$Brennerdatei[6] = "$brennerstatus";
	$Brennerdatei[7] = 0; 					# Anzahl Einschaltungen
}
else
{
	$oldLaufzeit = $Brennerdatei[4];
	my @Laufzeitarray=split(" ",$Brennerdatei[5]);
	$oldBrennerlaufzeit = $Laufzeitarray[1];
	my @Statusarray=split(" ",$Brennerdatei[6]);
	$oldBrennerstatus = $Statusarray[1];
	
}

open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden I\n";
print LOGFILE "** $Datumstring\tBrennerstatus: $oldBrennerstatus\n";
close(LOGFILE);

#if ($size <= 10)
# File ist noch leer, Titel schreiben

if ($anzHomedateiZeilen==0) 
{
	printf "anzHomedateiZeilen = 0\n";
	print HOMEDATEI "HomeCentral\nFalkenstrasse 20\n8630 Rueti\n";
 	print HOMEDATEI "$Datumstring\n\n";
 	$jahr +=2000;
 	print HOMEDATEI "Startzeit: $jahr-$monat-$tag $stunde:$min:$sec +0100\n";
 	
 	open  TIMEPREFS, ">../public_html/Data/TimePrefs.txt" || die "TimePrefs nicht gefunden\n";
	print TIMEPREFS time();
	close(TIMEPREFS);
	$laufzeit=0;
	$Brennerlaufzeit=0;
	
}
else
{
	#printf "Daten klone: %d\t%d\t%d\t%d\t%d\t%d\t%d\t0\n",$laufzeit,$cgivars{d2},$cgivars{d3},$cgivars{d4},$cgivars{d1},$cgivars{d0};
	
	# zeit Vorlauf Ruecklauf Aussen ... Innen
	#print HOMEDATEI "Daten klone: %d\t%d\t%d\t%d\t%d\t%d\t%d\t0\n",$laufzeit,$cgivars{d2},$cgivars{d3},$cgivars{d4},$cgivars{d1},$cgivars{d0};
	
	# print HOMEDATEI "$laufzeit\t$cgivars{d2}\t$cgivars{d3}\t$cgivars{d4}\t$cgivars{d1}\t$cgivars{d0}\t0\n";
	
	my $datacontrol=0; # Vorlauf, Ruecklauf und Aussen sind nie null
	my $h0 = hex($cgivars{d0});
	my $h1 = hex($cgivars{d1});
	my $h2 = hex($cgivars{d2});	#	Vorlauf
		$datacontrol += $h2;
	my $h3 = hex($cgivars{d3});	#	Ruecklauf
		$datacontrol += $h3;
	my $h4 = hex($cgivars{d4});	#	Aussen
		$datacontrol += $h4;
	my $h5 = hex($cgivars{d5});
		$datacontrol += $h5;
	my $h6 = hex($cgivars{d6});
		$datacontrol += $h6;
	my $h7 = hex($cgivars{d7});
		$datacontrol += $h7;
	
	
	#
	#	Mail bei falschen Eingangsdaten
	#
		printf "datacontrol: $datacontrol.<br>";
	if ($datacontrol == 0) # Fehler: Vorlauf, Ruecklauf und Aussen sind nie null
	{
	
		print LOGFILE "datacontrol NULL.\n";
		printf "datacontrol NULL.<br>";
		
		
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
			
			if ($anzMaildateiZeilen>4)
			{
				$mailzeile = $Maildatei[5];
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
			
			# Ein Mail genügt
			$Resetstatus=1;
			
		} # Resetstatus == 0	
	
	
	}
	else #	Bus ist OK
	{
		print LOGFILE "HomeBus ist OK. ";
		printf "HomeBus ist OK.<br>";
		
		if ($Alarmstatus == 1)
		{
			$writeTask=1;
			$Alarmstatus = 0;
			$alarmdatei[3] = "Status: $Alarmstatus";	# Zeile 3 zuruecksetzen

			$Resetstatus = 1;
			$alarmdatei[4] = "Reset: $Resetstatus";	# Zeile 4 setzen
		
		}
		
	}
	
	
	
	# end Mail
	
	
	
	
	
	
	
	#	Aussentemperatur speichern
	my @TemperaturArray=0;
	my $anzTemperaturZeilen=0;
	
	if ($oldMinute ne $newMinute) # neue Minute, Aussenemperatur speichern
	{
		open TEMPERATURDATEN, "<../public_html/Data/TemperaturDaten.txt" || die "Temperaturdaten nicht gefunden";
		@TemperaturArray = <TEMPERATURDATEN>;
		
		$anzTemperaturZeilen=@TemperaturArray;
		chomp(@TemperaturArray);
		
		if ($anzTemperaturZeilen == 0)
		{
			$TemperaturArray[0] = "HomeCentral";
			$TemperaturArray[1] = "Temperaturdaten";
			$TemperaturArray[2] = "$Datumstring";
			$TemperaturArray[3] = "$stunde:$min";
			$TemperaturArray[4] = 0.0;	#	Summe
			$TemperaturArray[5] = 0.0;	#	Wert
			$TemperaturArray[6] = 0;	#	Anzahl
			$TemperaturArray[7] = 0.0;	#	Mittel
			
			$TemperaturArray[8] = 0.0;	#	TagSumme
			$TemperaturArray[9] = 0;	#	TagAnzahl
			$TemperaturArray[10] = 0;	#	TagMittel
			
			$TemperaturArray[11] = 0.0;	#	NachtSumme
			$TemperaturArray[12] = 0;	#	NachtAnzahl
			$TemperaturArray[13] = 0;	#	NachtMittel
		} # if anzTemperaturzeilen
		
		if ($h4) # Data fuer Aussentemperatur ist nie Null
		{
			$TemperaturArray[3] = "Zeit: $stunde:$min";
			my $tempTemperatur=($h4 - 40)/2;
			
			$TemperaturArray[5] = sprintf("Aussentemperatur: %.1f",$tempTemperatur); 			#	Wert
			
			$TemperaturArray[4] += $tempTemperatur;		# Temperatur aufaddieren
			$TemperaturArray[6] ++; 						#	Anzahl inkrement.
			$TemperaturArray[7] = sprintf("Mittelwert: %.2f",$TemperaturArray[4] / $TemperaturArray[6]);
			
			# 12.12.09
			# Tagmittel
			if (($stunde >=6) && ($stunde <=18)) # Stunden des Tages
			{
				$TemperaturArray[8] += $tempTemperatur;
				$TemperaturArray[9] ++;
				$TemperaturArray[10] = sprintf("Mittelwert Tag: %.2f",$TemperaturArray[8] / $TemperaturArray[9]);
			}
			
			if (($stunde < 6) || ($stunde > 18))
			{
				$TemperaturArray[11] += $tempTemperatur;
				$TemperaturArray[12] ++;
				$TemperaturArray[13] = sprintf("Mittelwert Nacht: %.2f",$TemperaturArray[11] / $TemperaturArray[12]);
			}
			#
			
			
			
			open TEMPERATURDATEN, ">../public_html/Data/TemperaturDaten.txt" || die "Temperaturdaten nicht gefunden\n";
			foreach (@TemperaturArray)
			{
				print TEMPERATURDATEN "$_\n";
			}
			
		} # if $h4
		
		close (TEMPERATURDATEN);
	
	}
	
	
	
	
	
	
	#	Brennerlaufzeit aufaddieren
	my $h5a= 1; 	# Brennerstatus, filter aus h5. Brenner ON: 0  Brenner OFF: 1
	
		#	aktuelle Zeit einsetzen
		$Brennerdatei[3] =  "Zeit: $stunde:$min";
		
	open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden J\n";
	
	
	if ($h5 & 0x04) # Brenner ist OFF
	{
		#print LOGFILE "Brenner ist OFF. oldBrennerstatus: $oldBrennerstatus\toldBrennerlaufzeit: $oldBrennerlaufzeit\t h5: $h5\n";
		
		if ($oldBrennerstatus == 1) # Brenner war ON, Laufzeit addieren
		{
			#print LOGFILE "       Brenner ist OFF. oldBrennerstatus ist 1\n";
			my $tempStatus=0;
			$Brennerlaufzeit = $oldBrennerlaufzeit + ($laufzeit - $oldLaufzeit); # Laenge der Etappe addieren
			#$Brennerdatei[4] = "$oldLaufzeit\n";
			$Brennerdatei[5] = "Brenner-Laufzeit: $Brennerlaufzeit";
			$Brennerdatei[6] = "Status: $tempStatus";		# Status speichern
			$Brennerdatei[7] ++;					# Anzahl Einschaltungen inkrement.
			$Brennerdatei[8] = sprintf("Mittlere Einschaltdauer: %.2f",$Brennerlaufzeit/$Brennerdatei[7]);
		}
		else
		{
			#print LOGFILE "       Brenner ist OFF. oldBrennerstatus ist 0\n";
		}
	
		$h5a= 0;
	
	}
	else #	Brenner ist ON
	{
		#print LOGFILE "Brenner ist ON. oldBrennerstatus: $oldBrennerstatus\toldBrennerlaufzeit: $oldBrennerlaufzeit\th5: $h5\n";
		
		if ($oldBrennerstatus == 0) # Brenner war OFF, Laufzeit setzen
		{
			my $tempStatus=1;
			#print LOGFILE "       Brenner ist ON. oldBrennerstatus ist 0\n";
			$Brennerdatei[4] = "$laufzeit";					# Startzeit der neuen Etappe
			$Brennerdatei[6] = "Status: $tempStatus";				# Status speichern
			#print LOGFILE "        oldBrennerstatus aus neuer Brennerdatei ist $Brennerdatei[6]\n";
	
	
		}
		else
		{
			#print LOGFILE "       Brenner ist ON. oldBrennerstatus ist 1\n";
		}
	
	$h5a= 1;
	}
	close(LOGFILE);
	
	
	my $i=0;
	
	foreach (@Brennerdatei)
	{
		print BRENNERDATEI "$_\n";
	}
	
	
	#open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden K\n";
	#print LOGFILE "***  Brennerdatei[6] nach print ist $Brennerdatei[6]\n";
	#close(LOGFILE);
	
#	my $h6 = hex($cgivars{d6});
#	my $h7 = hex($cgivars{d7});
	
	open STATUSFILE, ">../public_html/Data/Status.txt" || die "Statusfile nicht gefunden\n";
	print STATUSFILE "$Datumstring \t$laufzeit\t$h2\t$h3\t$h4\t$h5\t$h0\t$h1\t$h6\t$h7\n";
	close(STATUSFILE);
	
	
	# 22.8.09
	if ($laufzeit> 0 && $datacontrol>0) # Keine Nullen in HomeData, keine Null-Temperaturen
	{
		# 22.8.09: print in if verschoben: nur drucken, wenn > last
		print HOMEDATEI "$laufzeit\t$h2\t$h3\t$h4\t$h5\t$h0\t$h1\t$h6\t$h7\n";
		
		#print BRENNERDATEI "$laufzeit\t$h5a\n";
		#letzte Daten in last schreiben
		
		open LAST, "+>../public_html/Data/LastData.txt" || die "LastData nicht gefunden\n";
		my @lastdatei = <LAST>;
		
	
		
		if ($lastdatei[0] < $cgivars{d0})
		{
	#		print HOMEDATEI "$laufzeit\t$h2\t$h3\t$h4\t$h5\t$h0\t$h1\n";
	#		print LAST "**$laufzeit\t$h2\t$h3\t$h4\t$h5\t$h0\t$h1\t$h6\t$h7\n";
		}
		else # neue Zeit< lastTime
		{
	#		open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden L\n";
	#		print LOGFILE "Time < als lastTime: $lastdatei[0]\n";
	#		close(LOGFILE);
		}
		
		# 22.8.09
		if ($datacontrol)
		{
		print LAST "$laufzeit\t$h2\t$h3\t$h4\t$h5\t$h0\t$h1\t$h6\t$h7\n";
		}
		
		close(LAST);
	
	}	# if $h00
	else
	{
		open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden M\n";
		if ($laufzeit == 0)
		{
		print LOGFILE "Datumstring: $Datumstring\tlaufzeit ist 0: $laufzeit\n";
		}
	
		if ($datacontrol == 0)
		{
		print LOGFILE "$Datumstring\tHome datacontrol ist 0\t$laufzeit\t$h2\t$h3\t$h4\t$h5\t$h0\t$h1\t$h6\t$h7\n";
		}
		
		
		
		close(LOGFILE);
		
	
	
	}
	
	
	}




close(HOMEDATEI);

close(BRENNERDATEI);

# AlarmDaten neu schreiben
{
	open ALARMDATEI, ">../public_html/Data/HomeAlarmDaten.txt" || die "Alarmdaten nicht gefunden\n";
	foreach (@alarmdatei)
	{
		print ALARMDATEI "$_\n";
	}

	close(ALARMDATEI);
}



#open LOGFILE, ">>../public_html/Data/Log.txt" || die "Logfile nicht gefunden N\n";
#print LOGFILE "$laufzeit\t$cgivars{d2}\t$cgivars{d3}\t$cgivars{d4}\t$cgivars{d1}\t$cgivars{d0}\t$cgivars{d6}\t$cgivars{d7}\t0\n";
#close(LOGFILE);

# Finally, print out the complete HTML response page
# print <<EOF druckt alles bis EOF


# Print the CGI variables sent by the user.
# Note that the order of variables is unpredictable.
# Also note this simple example assumes all input fields had unique names,
#   though the &getcgivars() routine correctly handles similarly named
#   fields-- it delimits the multiple values with the \0 character, within 
#   $cgivars{$_}.

#foreach (keys %cgivars) 
#{
#    print "<li>[$_] = [$cgivars{$_}]\n" ;
#}




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
