#!/usr/bin/perl -w
use CGI::Carp qw( fatalsToBrowser );
use Net::SMTP;
#
#
use strict;
my $NULL=0.0;
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

my $Elektrolaufzeit=0;
my $elektrostatus=0;
my $anzStatusZeilen=0;



my $Pumpelaufzeit=0;
my $Pumpestatus=0;



my %cgivars;
my @Statistik=0;

my @prefzeit=0;
my $anzPrefsZeilen;


# First, get the CGI variables into a list of strings
%cgivars= &getcgivars ;

# Print the CGI response header, required for all HTML output ****WICHTIG****
# Note the extra \n, to send the blank line
print "Content-type: text/html\n\n" ;
# Fuer reinen Text: Conten-type text/plain
# So werden newlines als Zeilenschaltung interpretiert
# print "Content-type: text/plain\n\n" ;

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
printf	"Datumstring: $Datumstring<br>";
printf	"tagsekunde: $tagsekunde<br>";

#print `pwd`;
#print `ls \`pwd/../public_html\``;
#my $PWD = `pwd`; chomp $PWD;
#print "Datenverzeichnis: \"", $PWD, "/../public_html/Data\"\n";
#print `ls $PWD/../public_html/Data`;

#printf	 "zeit[3]: $zeit[3] tag: $tag<br>";
#printf	 "zeit[2]: $zeit[2] stunde: $stunde<br>";
#printf	 "zeit[1]: $zeit[1] min: $min<br>";
#open LOGFILE, ">> $PWD/../public_html/Data/SolarLog.txt" || die "Z 80 Nicht einmal SolarLog gefunden\n";
#print LOGFILE "$Datumstring\n";
#close(LOGFILE);

#
# Prefs lesen, neues Datum einsetzen
#

# Last Time laden
open PREFS, "<../public_html/Data/SolarCentralPrefs.txt" || die "SolarCentralPrefs.txt nicht gefunden\n";
my @prefstat = stat(PREFS);
$prefsize=$prefstat[7];
my @feld=<PREFS>;
my $anzZeilen=@feld;
close(PREFS);
#print PREFS "size $prefsize\n";
# Wenn leer: neue Datei
#if ($prefsize == 0)
if($anzZeilen == 0) # leeres File
{
	open PREFS, ">../public_html/Data/SolarCentralPrefs.txt" || die "Prefs 2 nicht gefunden\n";
	#print PREFS "N $Datumstring";
	$lastDatumstring=$Datumstring;
	print PREFS "$Datumstring";
	close PREFS;
	
	open TIMEPREFS, ">../public_html/Data/SolarTimePrefs.txt" || die "TimePrefs nicht gefunden\n";
	print TIMEPREFS time();
	close TIMEPREFS;


	open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die " Auch dieses Logfile nicht gefunden\n";
	print LOGFILE "neues File: $Datumstring\n";

	close LOGFILE;
	
}
else # Prefs schon vorhanden, aktualisieren
{
	# SolarCentralPrefs oeffnen
	open PREFS, ">../public_html/Data/SolarCentralPrefs.txt" || die "Prefs 3 nicht gefunden\n";
	my $linien=0;
	my $eintrag=0;
	$lastDatumstring=$feld[0];

	#neues Datum in SolarCentralPrefs einsetzen
	print PREFS "$Datumstring\n";
	close (PREFS);
	
	# SolarTimePrefs oeffnen: Datum als Zahl
	open TIMEPREFS, "<../public_html/Data/SolarTimePrefs.txt" || die "SolarTimePrefs 4 nicht gefunden\n";
	@prefzeit = <TIMEPREFS>;
	printf "TimePrefs: $prefzeit[0]<br>";
	$anzPrefsZeilen=@prefzeit;
	if ($anzPrefsZeilen == 0)
	{
		open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "SolarLogfile nicht gefunden\n";
		#print LOGFILE "solar.pl: Keine TimePrefs gefunden $lastDatumstring\n";
		print LOGFILE "SolarTimePrefs anzPrefszeilen == 0  $Datumstring\n";
		close LOGFILE;

	}
	else
	{
		
		$laufzeit = $tagsekunde;
		my $laufzeitausprefs=time() - $prefzeit[0];
		
		# Kontrolle der Differnez, sollte konstant sein
		my $diff= $laufzeit - $laufzeitausprefs;
		
		
		open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Z 130 Logfile nicht gefunden\n";
		#print LOGFILE "laufzeitausprefs: $laufzeitausprefs laufzeit: $laufzeit Diff: $diff\n";
		#print LOGFILE "anzPrefszeilen: $anzPrefsZeilen	 prefzeit [0]: $prefzeit[0]	 laufzeit: $laufzeit  Diff: $diff\n";
		
		close LOGFILE;

	}
	close(TIMEPREFS);

	
}



#
# Wenn neues Datum nicht gleich wie altes Datum > SolarData sichern in Ordner SolarData
# mit Datum aus lastDatumstring
#
printf "LastDatumString: $lastDatumstring<br>";
my @lastDatumstringarray = split(" ",$lastDatumstring);

my @lastZeitarray= split(":",$lastDatumstringarray[2]); # Zeitangabe, drittes Objekt 

my $oldStunde = $lastZeitarray[0]; # Stunde
my $oldMinute = $lastZeitarray[1]; # Minute
my $newMinute = $min;
my $newStunde = $stunde;

my $newMonat = $ monat;
my $newJahr = $jahr;


my $oldFilename = $lastZeitarray[0]; # Stunde
my $newFilename = "$stunde";

# Daten des alten Tages sichern
my @lastDatumarray= split("", $lastDatumstringarray[1]); # Datumangabe
#
my $oldTag =$lastDatumarray[0].$lastDatumarray[1]; # Elemente 0,1: Tag des Monats
my $oldMonat=$lastDatumarray[3].$lastDatumarray[4]; # Elemente 3,4: Monat des Jahres
my $oldJahr=$lastDatumarray[6].$lastDatumarray[7]; # Elemente 6,7: Jahr

#
printf ("$Datumstring<br>");
my $jahrlong= $jahr + 2000;
#printf "$jahrlong<br>";

my $oldJahrlong = $oldJahr+2000;
#printf "oldJahrlong: $oldJahrlong<br>";

#my $testnewPfad="../public_html/Data/SolarDaten/$oldJahrlong/SolarDaten$oldJahr$oldMonat$oldTag.txt";
#printf "newPfad: $testnewPfad<br>";

#	neuer Tag
my $newTag = "$tag";

#open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "newTag: Logfile nicht gefunden\n";
#print LOGFILE "oldTag: $oldTag	 newTag: $newTag\n";
#print LOGFILE "oldFilename: $oldFilename  newFilename: $newFilename\n";
#close LOGFILE;
		
			
		
		
		
#if ($oldFilename ne $newFilename)
#if ($oldMinute ne $newMinute)
#if ($oldStunde ne $newStunde)
#if ($newMinute%5==0)
#$newTag += 1; # Test

if ($oldTag ne $newTag) # Tagzahl hat sich geaendert
{
	#printf ("neue Minute: $newMinute\n");
	open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "oldTag ne newTag: Logfile nicht gefunden\n";
	print LOGFILE "neuer Tag: Laufzeit: $laufzeit  $Datumstring\n";
	close(LOGFILE);

	my $oldPfad="../public_html/Data/SolarDaten.txt";
	#my $newFilename="SolarDaten/SolarDaten$jahr$monat$tag.txt";
	#my $newFilename="SolarDaten/SolarDaten.txt";
	#my $newPfad="SolarDaten/SolarDaten$tag$stunde.txt";
	
	#my $newPfad="SolarDaten/SolarDaten$jahr$monat$tag.txt";
	my $newPfad="../public_html/Data/SolarDaten/$oldJahrlong/SolarDaten$oldJahr$oldMonat$oldTag.txt";
		
	#copy($oldPfad, $newPfad) or die "Copy failed: $!";
	#print PREFS "\noldPfad: $oldPfad newPfad: $newPfad\n";
	#close(PREFS);
	#open OLD,"<../public_html/Data/SolarDaten.txt";
	open OLD,"<$oldPfad";
	my @Data=<OLD>;
	
	open NEW,">$newPfad" || die "NEW nicht gefunden\n";
	print NEW "@Data";
	close NEW;
	open OLD,">$oldPfad" || die "OLD nicht gefunden\n";
	print OLD "";
	close OLD;

	# Neu: JahrOrdner		
	my $newJahrOrdnerPfad="../public_html/Data/SolarDaten/$jahrlong/SolarDaten$oldJahr$oldMonat$oldTag.txt";
	#printf "$newJahrOrdnerPfad<br>";
	open NEWJAHR, ">$newJahrOrdnerPfad" || die "NEWJAHR nicht gefunden\n";
	print NEWJAHR "@Data";
	close NEWJAHR; 
	# JahrOrdner
		
	$laufzeit=0;
		
	# neu	Daten fuer Elektrozeit speichern
	 my $Elektrozeitstring;
	 my @Elektrozeitdatei=0;
	 my $anzZeilen=0;
	 my $Elektrozeit=0;
	 my $ElektrozeitMittel=0;
	
	# Daten fuer Pumpezeit speichern
	 my @Pumpezeitdatei=0;
	 my $Pumpezeitstring=0;
	 #my $anzPumpeZeilen=0;
	 my $Pumpezeit=0;

	# Daten fuer Pumpedaten speichern
	 my @Pumpedatei=0;

	
	#
	# Elektrozeit des Tages	 lesen
	#
	 open TAGELEKTROZEIT, "<../public_html/Data/ElektroDaten.txt" || die "TAGELEKTROZEIT nicht gefunden\n";
	 @Elektrozeitdatei = <TAGELEKTROZEIT>;
	 chop(@Elektrozeitdatei);
	 $anzZeilen=@Elektrozeitdatei;
	 if ($anzZeilen)
	 {
		$Elektrozeit = $Elektrozeitdatei[5];					# Darstellung: Elektro_Laufzeit: $laufzeit
	  }
	 close (TAGELEKTROZEIT);
	
	#
	# Pumpezeit des Tages lesen
	#
	{	# Namespace fuer $TagPumpezeit
		 open TAGPUMPEZEIT, "<../public_html/Data/SolarPumpeDaten.txt" || die "TAGPUMPEZEIT nicht gefunden\n";
		 @Pumpezeitdatei = <TAGPUMPEZEIT>;
		 chop(@Pumpezeitdatei);
		 my $anzTagPumpeZeilen=@Pumpezeitdatei;
		 my $TagPumpezeit=sprintf("Pumpe-Laufzeit: %d",0);
		 
		 if ($anzTagPumpeZeilen)
		 {
			# letzte Stundenlaufzeit lesen
			my @lastStundenlaufzeitArray = split(" ",$Pumpezeitdatei[5]);
			my $lastStundenlaufzeit = $lastStundenlaufzeitArray[1];
		
			# Bisherige Tageslaufzeit lesen
			my @tempTagelaufzeitArray = split(" ",$Pumpezeitdatei[14]);
			my $tempTageslaufzeit = $tempTagelaufzeitArray[1];
			
			#	Stundenlaufzeit zur Tageslaufzeit addieren
			$tempTageslaufzeit = $tempTageslaufzeit + $lastStundenlaufzeit;
	
			$TagPumpezeit = sprintf("Pumpe-Laufzeit: $tempTageslaufzeit");	# Darstellung: Pumpe-Laufzeit: $Tageslaufzeit
		  }
		 close (TAGPUMPEZEIT);
		
		$Pumpezeitstring = "\n$oldTag.$oldMonat.$oldJahr\t$TagPumpezeit"; # Datum
		
		open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Pumpezeit des Tages lesen: Logfile nicht gefunden\n";
		print LOGFILE "Pumpezeit des Tages lesen: Pumpezeitstring: $Pumpezeitstring\n";
		close(LOGFILE);
	
		open PUMPEZEIT, ">>../public_html/Data/SolarPumpeZeit.txt" || die "PumpeZEIT nicht gefunden\n";
		print PUMPEZEIT $Pumpezeitstring;
		close PUMPEZEIT;
		
		#$Elektrozeitstring = "$oldTag.$oldMonat.$oldJahr\t$Elektrozeit\t$ElektrozeitMittel\n"; # Datum
		$Elektrozeitstring = "\n$oldTag.$oldMonat.$oldJahr\t$Elektrozeit\t$TagPumpezeit"; # Datum
	}# End Namespace fuer $TagPumpezeit
	
	#
	# File fuer Elektrozeit oeffnen, Daten des alten Tages schreiben.
	#
	
	 open ELEKTROZEIT, ">>../public_html/Data/ElektroZeit.txt" || die "ELEKTROZEIT nicht gefunden\n";
	 print (ELEKTROZEIT $Elektrozeitstring);
	 close ELEKTROZEIT;
	
	#
	#	Elektrodaten: Werte zurueksetzen
	#
	
	$Elektrozeitdatei[5] = sprintf("Elektro-Laufzeit: %d",0);				#	Laufzeit des Tages
	$Elektrozeitdatei[6] = sprintf("Status: %d",0); 						#	Status
	$Elektrozeitdatei[7] = 0;									#	Anzahl Einschaltungen

	#	Elektrodaten: Daten schreiben
	
	open ELEKTRODATEI, ">../public_html/Data/ElektroDaten.txt" || die "ELEKTRODATEI nicht gefunden\n";
	foreach (@Elektrozeitdatei)
	{
		print ELEKTRODATEI "$_\n";
	}
	 close (ELEKTRODATEI);


	
	
	# Daten fuer Temperatur speichern
	 my $Temperaturstring;
	 my @Temperaturdatei=0;
	 my $anzTempZeilen=0;
	 my $Temperaturmittel=0;
	my $TagTemperaturmittel=0;
	my $NachtTemperaturmittel=0;
	

	#
	# Temperaturdaten des Tages lesen
	#
	
	open TEMPERATURDATEI, "<../public_html/Data/SolarTemperaturDaten.txt" || die "Solar TEMPERATURDATEI nicht gefunden\n";
	@Temperaturdatei = <TEMPERATURDATEI>;
	chop(@Temperaturdatei);
	my $anzSolarTempZeilen=@Temperaturdatei;
	
	if ($anzSolarTempZeilen )
	{
		my @tempMittelwertarray=split(" ",$Temperaturdatei[10]);
		my $TemperaturMittelwert = $tempMittelwertarray[1];
	
	#
	# File fuer Temperaturmittel oeffnen, letzten Mittelwert des Tages eintragen
	#
	
		# Datei fuer lesen oeffnen
		open SOLARTEMPERATURMITTEL, "<../public_html/Data/SolarTemperaturMittel.txt" || die "Solar TEMPERATURDATEI nicht gefunden\n";
		my @TemperaturMittelArray = <SOLARTEMPERATURMITTEL>;
		my $anzTemperaturMittelZeilen=@TemperaturMittelArray;
		chomp(@TemperaturMittelArray);
		my $TemperaturStundenzeile=0;
		if ($anzTemperaturMittelZeilen) # schon Zeile(n) vorhanden
		{
			$TemperaturStundenzeile = $TemperaturMittelArray[$anzTemperaturMittelZeilen-1]; # letzte Zeile lesen
			$TemperaturMittelArray[$anzTemperaturMittelZeilen-1]= "$TemperaturStundenzeile\t$TemperaturMittelwert";
			
			# Datei fuer schreiben oeffnen, Array wieder schreiben
			open SOLARTEMPERATURMITTEL, ">../public_html/Data/SolarTemperaturMittel.txt" || die "SolarTemperaturdaten nicht gefunden";
			foreach (@TemperaturMittelArray)
			{
				print SOLARTEMPERATURMITTEL "$_\n";
			}

		}	# if ($anzTemperaturMittelZeilen)
		
		open LOGFILE,  ">>../public_html/Data/SolarLog.txt" || die " TEMPERATURDATEI Logfile nicht gefunden\n";
		print LOGFILE "SolarTemperaturMittel neue Zeile anlegen: $newTag.$newMonat.$newJahr\n";
		close LOGFILE;
		
		# Solartemperaturmittel: neue Zeile anlegen
		open SOLARTEMPERATURMITTEL, ">>../public_html/Data/SolarTemperaturMittel.txt" || die "SolarTemperaturMittel nicht gefunden";
		my $neueStundenzeile= "$newTag.$newMonat.$newJahr";
		print  SOLARTEMPERATURMITTEL "\n$neueStundenzeile";
		close SOLARTEMPERATURMITTEL;
		 
	} # if anzTempZeilen
	else
	{
		open LOGFILE,  ">>../public_html/Data/SolarLog.txt" || die " TEMPERATURDATEI Logfile nicht gefunden\n";
		print LOGFILE "Temperaturdaten des Tages lesen: anzZeilen ist 0\n";
		close LOGFILE;

	}

	#
	#	SolarTemperaturdaten: Werte zurueksetzen
	#
	$Temperaturdatei[6] = sprintf("Ertrag: %.2f",0.0);							#	Ertrag (Differenz)
	$Temperaturdatei[7] = sprintf("Ertragsumme: %.2f",0.0);			#	Integration (laufende Summe)
	$Temperaturdatei[8] = 0;										#	
	$Temperaturdatei[9] = 0;										#	Anzahl Messungen
	$Temperaturdatei[10] = sprintf("Mittelwert: %.2f",0.0);			#	Mittel
	$Temperaturdatei[11] = 0.0;										#	Summe Kollektortemperatur
	$Temperaturdatei[12] = sprintf("Kollektortemperatur: %.2f",0.0);#	
	$Temperaturdatei[13] = 0.0;										#	Summe Aussentemp
	$Temperaturdatei[14] = sprintf("Aussentemperatur: %.2f",0.0);	#	Aussentemperatur
	
	#	SolarTemperaturDaten: Daten schreiben
	open TEMPERATURDATEI, ">../public_html/Data/SolarTemperaturDaten.txt" || die "Solar TEMPERATURDATEI nicht gefunden\n";
	foreach (@Temperaturdatei)
	{
		print TEMPERATURDATEI "$_\n";
	}
	 close (TEMPERATURDATEI);

	#
	# Ertragdaten des Tages lesen
	#	
	open PUMPEDATEI, "<../public_html/Data/SolarPumpeDaten.txt" || die "Solar TEMPERATURDATEI nicht gefunden\n";
	@Pumpedatei = <PUMPEDATEI>;
	chop(@Pumpedatei);
	my $anzPumpeZeilen=@Pumpedatei;
	if ($anzPumpeZeilen )
	{
		my @tempErtragarray=split(" ",$Pumpedatei[12]);			# Bisheriger Ertrag: String aufteilen
		my $oldertrag = $tempErtragarray[1];					# Daten sind an Platz 1
		#
		# File fuer TagErtragmittel oeffnen, letzten Mittelwert des Tages eintragen
		#
		
		# Datei fuer lesen oeffnen
		open TAGERTRAGDATEI, "<../public_html/Data/SolarTagErtrag.txt" || die "Solar TAGERTRAGDATEI nicht gefunden\n";
		my @ErtragArray = <TAGERTRAGDATEI>;
		my $anzErtragZeilen=@ErtragArray;
		chomp(@ErtragArray);
		my $TagErtragStundenzeile=0;
		if ($anzErtragZeilen) # schon Zeile(n) vorhanden
		{
			$TagErtragStundenzeile = $ErtragArray[$anzErtragZeilen-1]; # letzte Zeile lesen
			$ErtragArray[$anzErtragZeilen-1]= "$TagErtragStundenzeile\t$oldertrag";

			open LOGFILE,  ">>../public_html/Data/SolarLog.txt" || die " TAGERTRAGDATEI Logfile nicht gefunden\n";
			print LOGFILE "TagErtrag lesen: oldertrag: $oldertrag\n";
			close LOGFILE;
			
			# Datei fuer schreiben oeffnen, Array wieder schreiben
			open TAGERTRAGDATEI, ">../public_html/Data/SolarTagErtrag.txt" || die "TAGERTRAGDATEI nicht gefunden";
			foreach (@ErtragArray)
			{
				print TAGERTRAGDATEI "$_\n";
			}
		}
		else
		{
			open LOGFILE,  ">>../public_html/Data/SolarLog.txt" || die " TAGERTRAGDATEI Logfile nicht gefunden\n";
			print LOGFILE "TagErtrag lesen: anzZeilen ist 0\n";
			close LOGFILE;
		}
		
		open LOGFILE,  ">>../public_html/Data/SolarLog.txt" || die " TEMPERATURDATEI Logfile nicht gefunden\n";
		print LOGFILE "SolarTagErtrag neue Zeile anlegen: $newTag.$newMonat.$newJahr\n";
		close LOGFILE;
		
		# SolarTagErtrag: neue Zeile anlegen
		open TAGERTRAGDATEI, ">>../public_html/Data/SolarTagErtrag.txt" || die "SolarTagErtrag nicht gefunden";
		my $ErtragStundenzeile= "$newTag.$newMonat.$newJahr";
		print TAGERTRAGDATEI "\n$ErtragStundenzeile";
		close TAGERTRAGDATEI;

	
	}	# if anzPumpeZeilen
	else
	{
		open LOGFILE,  ">>../public_html/Data/SolarLog.txt" || die " TEMPERATURDATEI Logfile nicht gefunden\n";
		print LOGFILE "Ertragdaten des Tages lesen: anzZeilen ist 0\n";
		close LOGFILE;
	}
	
	
	#
	#	SolarPumpeDaten: Daten zuruecksetzen
	#
	$Pumpedatei[5] = sprintf("Stunden-Pumpelaufzeit: %d",0);					# Laufzeit der Stunde
	$Pumpedatei[6] = sprintf("Status: %d",0);							# aktueller Status
	$Pumpedatei[7] = 0;										# Anzahl Einschaltungen
	$Pumpedatei[8] = 0;										# Startzeit der aktuellen Einschaltung
	$Pumpedatei[11] = sprintf("Ertrag: %.1f",0.0);
	$Pumpedatei[12] = sprintf("Ertragsumme: %.2f",0.0);	
	$Pumpedatei[13] = sprintf("Mittelwert: %.2f",0.0);
	
	$Pumpedatei[14] = sprintf("Pumpe-Tageslaufzeit: %d",0);					# Laufzeit des Tages
	
	#	SolarPumpeDaten: Daten schreiben
	open PUMPEDATEI, ">../public_html/Data/SolarPumpeDaten.txt" || die "Solar TEMPERATURDATEI nicht gefunden\n";
	foreach (@Pumpedatei)
	{
		print PUMPEDATEI "$_\n";
	}
	close (PUMPEDATEI);
	#
	#	Ende neuer Tag
	#
	}																		
	else	# bestehender Tag
	{
		#open PREFS, ">>../public_htmi/Data/SolarCentralPrefs.txt" || die "Prefs nicht gefunden\n";
		#print PREFS "\nkein neues File\n";
		#close(PREFS);	
	
	}

	#	

open SOLARDATEI, ">>../public_html/Data/SolarDaten.txt" || die "SOLARDATEI nicht gefunden\n";

@Statistik=stat(SOLARDATEI);
$size=$Statistik[7];

#open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Logfile nicht gefunden\n";
#print LOGFILE "Die Datei SolarDaten.txt ist $size Bytes gross.\n";
#close(LOGFILE);
my @homedatei=0;
my $anzSolardateiZeilen=0;

#		Solardatei fuer Lesen oeffnen
open SOLARDATEI, "<../public_html/Data/SolarDaten.txt" || die "SOLARDATEI nicht gefunden\n";
@homedatei = <SOLARDATEI>;
$anzSolardateiZeilen=@homedatei;


# Variablen von Elektrodatei
my @Elektrodatei=0;
my $anzElektrodateiZeilen=0;

my $oldLaufzeit=0;					# Laufzeit beim letzten Aufruf
my $oldElektrolaufzeit=0;			# bisher aufgelaufene Elektrozeit
my $oldElektrostatus=0;				# Status beim letzten Aufruf

#Variablen von Pumpedatei
my @Pumpedatei=0;
my $anzPumpedateiZeilen=0;
my $oldPumpeLaufzeit=0;				# Laufzeit beim letzten Aufruf
my $oldPumpelaufzeit=0;				# bisher aufgelaufene Pumpezeit
my $oldPumpestatus=0;				# Status beim letzten Aufruf
my $Pumpestartzeit=0;				# Zeit beim Beginn einer neuen Aktivität

open ELEKTRODATEI, "<../public_html/Data/ElektroDaten.txt" || die "ELEKTRODATEI nicht gefunden\n";
@Elektrodatei = <ELEKTRODATEI>;
chomp(@Elektrodatei);
$anzElektrodateiZeilen=@Elektrodatei;

#open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Logfile nicht gefunden\n";
#print LOGFILE "Die Datei ElektroDaten.txt hat $anzElektrodateiZeilen Zeilen.\n";
#close(LOGFILE);

#open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Logfile nicht gefunden\n";
#print LOGFILE "Die Datei SolarDaten.txt hat $anzSolardateiZeilen Zeilen.\n";
#close(LOGFILE);

#	Solardaten fuer Schreiben am Ende oeffnen
open SOLARDATEI, ">>../public_html/Data/SolarDaten.txt" || die "SOLARDATEI nicht gefunden\n";


#
#	Elektrodatei mit bisherigen Daten lesen
#

#	ELEKTRODATEI fuer Schreiben am Anfang oeffnen
open ELEKTRODATEI, ">../public_html/Data/ElektroDaten.txt" || die "ELEKTRODATEI nicht gefunden\n";

if ($anzElektrodateiZeilen == 0)	# File ist noch leer, Titel schreiben
{
	open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Logfile Solarlog nicht gefunden\n";
	print LOGFILE "Elektrodaten: leeres File\n";
	close LOGFILE;
	
	$Elektrodatei[0] = "HomeCentral";
	$Elektrodatei[1] = "Elektrodaten";
	$Elektrodatei[2] = "$Datumstring";
	$Elektrodatei[3] = "Zeit: $stunde:$min";
	$Elektrodatei[4] = "$laufzeit";								#ktuelle Laufzeit (tagsekunden)
	$Elektrodatei[5] = sprintf("Elektro-Laufzeit: %d",0);		#akkumulierte Laufzeit, 0 am Anfang
	$Elektrodatei[6] = sprintf("Status: %d",0);					# aktueller Status, 1 fuer Start
	$Elektrodatei[7] = 0;										# Anzahl Einschaltungen
	$Elektrodatei[8] = 0;										# Startzeit der aktuuellen Einschaltphase


}
else
{
	#$oldLaufzeit = $Elektrodatei[4];					# bisherige Laufzeit

	 my @tempLaufzeitarray=split(" ",$Elektrodatei[5]);		# String aufteilen, Daten sind an Platz 5
	 my $anzLaufzeitelemente = @tempLaufzeitarray;			# Anzahl Elemente
	$oldElektrolaufzeit= $tempLaufzeitarray[1];				# bisher aufgelaufene Elektrozeit

#	open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Logfile Solarlog nicht gefunden\n";
#	print LOGFILE "\n** $Datumstring\nElektrodaten lesen: oldElektrolaufzeit: $oldElektrolaufzeit\tlaufzeit: $laufzeit\n";
#	close LOGFILE;
	
	 my @tempStatusarray=split(" ",$Elektrodatei[6]);	# String aufteilen, Daten sind an Platz 6
	 my $anzStatuselemente = @tempStatusarray;			# Anzahl Elemente
	$oldElektrostatus = $tempStatusarray[1];			# Status beim letzten Aufruf


}

my $beispielfloat=3.64159;
my $beispielfix = sprintf("%.1f",$beispielfloat);

#my $beispielint = sprintf("%d",$beispielfix);
my $beispielint = roundup($beispielfix);

open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Logfile Solarlog nicht gefunden\n";
#print LOGFILE "\n** $Datumstring\toldElektrolaufzeit: $oldElektrolaufzeit\told Elektrostatus: $oldElektrostatus\n";
#print LOGFILE "*** beispielfloat: $beispielfloat\tbeispielfix: $beispielfix\tbeispielint: $beispielint\n";

close(LOGFILE);

#
# 	Daten aktualisieren: 		Pumpedatei lesen
#

#
#	Pumpedatei mit bisherigen Daten lesen
#
open PUMPEDATEI, "<../public_html/Data/SolarPumpeDaten.txt" || die "PUMPEDATEI nicht gefunden\n";
@Pumpedatei = <PUMPEDATEI>;
chomp(@Pumpedatei);
$anzPumpedateiZeilen=@Pumpedatei;

#open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Logfile nicht gefunden\n";
#print LOGFILE "Die Datei SolarPumpeDaten.txt hat $anzPumpedateiZeilen Zeilen.\n";
#close LOGFILE;


if ($anzPumpedateiZeilen == 0)	# File ist noch leer, Titel schreiben
{
	open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Logfile Solarlog nicht gefunden\n";
	print LOGFILE "SolarPumpeDaten: leeres File\n";
	close LOGFILE;

	$Pumpedatei[0] = "HomeCentral";
	$Pumpedatei[1] = "Pumpedaten";
	$Pumpedatei[2] = "$Datumstring";
	$Pumpedatei[3] = "Zeit: $stunde:$min";
	$Pumpedatei[4] = "$laufzeit";							#	aktuelle Laufzeit (tagsekunde)	
	$Pumpedatei[5] = "Stunden-Pumpelaufzeit: $Pumpelaufzeit";
	$Pumpedatei[6] = "Status: $Pumpestatus";				# aktueller Status, 1 fuer Start
	$Pumpedatei[7] = 0;										# Anzahl Messungen
	$Pumpedatei[8] = 0;										# Startzeit der aktuellen Einschaltung
	$Pumpedatei[9] = sprintf("Kollektor-Vorlauf: %.1f",0.0);
	$Pumpedatei[10] = sprintf("Kollektor-Ruecklauf: %.1f",0.0);
	$Pumpedatei[11] = sprintf("Ertrag: %.1f",0.0);
	$Pumpedatei[12] = sprintf("Ertragsumme: %.2f",0.0);	
	$Pumpedatei[13] = sprintf("Mittelwert: %.2f",0.0);
	$Pumpedatei[14] = sprintf("Pumpe-Tageslaufzeit: %d",0);
}
else
{

	 my @tempLaufzeitarray=split(" ",$Pumpedatei[5]);		# String aufteilen, Daten sind an Platz 5
	 my $anzLaufzeitelemente = @tempLaufzeitarray;			# Anzahl Elemente
	$oldPumpelaufzeit= $tempLaufzeitarray[1];				# bisher aufgelaufene Pumpezeit der Stunde
	
	 my @tempStatusarray=split(" ",$Pumpedatei[6]);			# String aufteilen, Daten sind an Platz 6
	 my $anzStatuselemente = @tempStatusarray;				# Anzahl Elemente
	$oldPumpestatus = $tempStatusarray[1];					# Status beim letzten Aufruf
}

#	Datum aktualisieren
$Pumpedatei[2] = "$Datumstring";
$Pumpedatei[3] = "Zeit: $stunde:$min";
$Pumpedatei[4] = "$laufzeit";								#	aktuelle Laufzeit, tagsekunden

open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Logfile Solarlog nicht gefunden\n";
print LOGFILE "\n$Datumstring\n";
print LOGFILE "Pumpedaten lesen: oldPumpelaufzeit: $oldPumpelaufzeit\toldPumpestatus: $oldPumpestatus\tlastStartzeit: $Pumpedatei[8]\tlaufzeit: $laufzeit\n";
#print LOGFILE "anzPumpedateiZeilen: $anzPumpedateiZeilen\n";

close(LOGFILE);



# End Pumpedatei lesen


#
#	 Solardaten von Homecentral lesen
#

if ($anzSolardateiZeilen==0)							# File ist noch leer, Titel schreiben
{
	print SOLARDATEI "HomeCentral\nFalkenstrasse 20\n8630 Rueti\n";
	print SOLARDATEI "$Datumstring\n\n";
	$jahr +=2000;
	print SOLARDATEI "Startzeit: $jahr-$monat-$tag $stunde:$min:$sec +0100\n";
	
#	open TIMEPREFS, ">../public_html/Data/SolarTimePrefs.txt" || die "SolarTimePrefs nicht gefunden\n";
#	print TIMEPREFS time();
#	close(TIMEPREFS);
	
	$laufzeit=0;
	$Elektrolaufzeit=0;
}
else
{
	#
	# Daten von Solardaten.txt lesen
	#
	
	# zeit Vorlauf Ruecklauf BoilerU BoilerM BoilerO 
	#printf SOLARDATEI "%d\t%d\t%d\t%d\t%d\t%d\t%d\t0\n",$laufzeit,$cgivars{d2},$cgivars{d3},$cgivars{d4},$cgivars{d1},$cgivars{d0};
	
	# print SOLARDATEI "$laufzeit\t$cgivars{d2}\t$cgivars{d3}\t$cgivars{d4}\t$cgivars{d1}\t$cgivars{d0}\t0\n";
	
	my $datacontrol=0;									# 	Kontrolle, ob Daten OK: Vorlauf, Ruecklauf sind nie null
	my $h0 = hex($cgivars{d0});							# 	Kollektor Vorlauf
		$datacontrol += $h0;
	my $h1 = hex($cgivars{d1});							# 	Kollektor Ruecklauf
		$datacontrol += $h1;
	my $h2 = hex($cgivars{d2});							#	Boiler unten
		$datacontrol += $h2;
	my $h3 = hex($cgivars{d3});							#	Boiler Mitte
		$datacontrol += $h3;
	my $h4 = hex($cgivars{d4});							#	Boiler oben
		$datacontrol += $h4;
	my $h5 = hex($cgivars{d5});							#	Kollektortemperatur
	
	my $h6 = hex($cgivars{d6});							#	Solarstatus
	
	my $h7 = hex($cgivars{d7});							# 	offen
	
	open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Solarlog: Logfile nicht gefunden\n";
	print LOGFILE "Daten cgivars: $laufzeit\t*$cgivars{d0}\t*$cgivars{d1}\t*$cgivars{d2}\t*$cgivars{d3}\t*$cgivars{d4}\t*$cgivars{d5}\n";
	print LOGFILE "Daten solar: $laufzeit\td0: $h0\td1: $h1\td2: $h2\td3: $h3\td4: $h4\td5: $h5\n";
	close LOGFILE;
	
	printf "Daten solar: $laufzeit\td0: $h0\td1: $h1\td2: $h2\td3: $h3\td4: $h4\td5: $h5<br>";
	
	#	Aussentemperatur speichern
	my @TemperaturArray=0;
	my $anzTemperaturZeilen=0;
	
	#
	#	Temperaturdaten speichern. (Kopie von home.pl)
	#
		
	if ($oldMinute ne $newMinute) # neue Minute, Temperaturen speichern
	{
		
		open HOMETEMPERATURDATEN, "<../public_html/Data/TemperaturDaten.txt" || die "SolarTemperaturdaten nicht gefunden";
		my @HomeTemperaturArray = <HOMETEMPERATURDATEN>;
		my $anzHomeTemperaturZeilen=@HomeTemperaturArray;
		chomp(@HomeTemperaturArray);
		my @AussentemperaturArray=split(" ",$HomeTemperaturArray[5]);
		my $aktuelleAussentemperatur= $AussentemperaturArray[1];
		close (HOMETEMPERATURDATEN);
	
	
	#	Temperaturdaten von HomeCentral verarbeiten
	
		open TEMPERATURDATEN, "<../public_html/Data/SolarTemperaturDaten.txt" || die "SolarTemperaturdaten nicht gefunden";
		@TemperaturArray = <TEMPERATURDATEN>;
		$anzTemperaturZeilen=@TemperaturArray;
		chomp(@TemperaturArray);
		#open LOGFILE, ">>../public_html/SolarData/Log.txt" || die "TEMPERATURDATEN Logfile nicht gefunden\n";
		#print LOGFILE "anzTemperaturZeilen: $anzTemperaturZeilen\n";
		#close(LOGFILE);

		if ($anzTemperaturZeilen == 0)
		{
			$TemperaturArray[0] = "HomeCentral";
			$TemperaturArray[1] = "Solar-Temperaturdaten";
			$TemperaturArray[2] = "$Datumstring";
			$TemperaturArray[3] = "$stunde:$min";
			$TemperaturArray[4] = sprintf("Kollektor-Vorlauf: %.1f",0.0);										#	Vorlauftemperatur
			$TemperaturArray[5] = sprintf("Kollektor-Ruecklauf: %.1f",0.0);									#	Ruecklauftemperatur
			$TemperaturArray[6] = sprintf("Ertrag: %.2f",0.0);										#	Ertrag (Differenz)
			$TemperaturArray[7] = sprintf("Ertragsumme: %.2f",0.0);			#	Integration (laufende Summe)
			$TemperaturArray[8] = 0;										#	
			$TemperaturArray[9] = 0;										#	Anzahl Messungen
			$TemperaturArray[10] = sprintf("Mittelwert: %.2f",0.0);			#	Mittel
			$TemperaturArray[11] = 0.0;										#	Summe Kollektortemperatur
			$TemperaturArray[12] = sprintf("Kollektortemperatur: %.2f",0.0);#	Kollektortemperatur										#	
			$TemperaturArray[13] = 0.0;										#	Summe Aussentemp
			$TemperaturArray[14] = sprintf("Aussentemperatur: %.2f",0.0);	#	Aussentemperatur
		} # if anzTemperaturzeilen
		else
		{
			$TemperaturArray[3] = "Zeit: $stunde:$min";
			my $tempTemperaturV=($h0)/2.0;														#Kollektor Vorlauf
			$TemperaturArray[4] = sprintf("Kollektor-Vorlauf: %.1f",$tempTemperaturV);			#	Wert
			my $tempTemperaturR=($h1)/2;														#Kollektor Vorlauf
			$TemperaturArray[5] = sprintf("Kollektor-Ruecklauf: %.1f",$tempTemperaturR);		#	Wert
			
			my $ertrag=($tempTemperaturV-$tempTemperaturR);										#	Ertrag
			$TemperaturArray[6] = sprintf("Ertrag: %.1f",$ertrag);
			
			my @tempErtragarray=split(" ",$TemperaturArray[7]);		# String aufteilen, Daten sind an Platz 1
			my $oldertrag = $tempErtragarray[1];					# Daten sind an Platz 1


			my $ertragsumme=$oldertrag + $ertrag;					#	Ertrag aufaddieren
			$TemperaturArray[7] =sprintf("Ertragsumme: %.2f",$ertragsumme);		
			
			$TemperaturArray[9] ++;										#	Anzahl Messungen aufaddieren
	
			$TemperaturArray[10]= sprintf("Mittelwert: %.2f",$ertragsumme / $TemperaturArray[9]);
			
			my $tempKollektortemperatursumme = $TemperaturArray[11];
			$TemperaturArray[12] = sprintf("Kollektortemperatur: %.2f",($h5/2.0));		#	Kollektortemperatur	
			$TemperaturArray[11] = $tempKollektortemperatursumme + ($h5/2.0);			# 	Temperatur aufaddieren fuer Stundenmittel
			
			
			# Aussentemperatur
			$TemperaturArray[13] += $aktuelleAussentemperatur;	# Summe fuer Mittelwertbildung
			$TemperaturArray[14] = sprintf("Aussentemperatur: %.1f",$TemperaturArray[13]/$TemperaturArray[9]); # Mittelwert
			
			
	
		
		}
		
		#	Temperaturdaten schreiben
		
		open TEMPERATURDATEN, ">../public_html/Data/SolarTemperaturDaten.txt" || die "Temperaturdaten nicht gefunden\n";
		foreach (@TemperaturArray)
		{
			print TEMPERATURDATEN "$_\n";
		}
		close (TEMPERATURDATEN);

		#
		#	Pumpe aktualisieren
		#
		
		# Kollektor-Temperaturen aktualisieren
		my $tempTemperaturV=($h0)/2.0;												#	Kollektor Vorlauf
		$Pumpedatei[9] = sprintf("Kollektor-Vorlauf: %.1f",$tempTemperaturV);		#	Wert
		my $tempTemperaturR=($h1)/2;												#	Kollektor Vorlauf
		$Pumpedatei[10] = sprintf("Kollektor-Ruecklauf: %.1f",$tempTemperaturR);	#	Wert
		
		#$Pumpedatei[14]=sprintf("Tages-Pumpelaufzeit: %.1f",1185);
		#
		#Pumpestatus abfragen
		#
		if ($h6 & 0x08) # Pumpe ON
		{
			open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Solarlog: Logfile nicht gefunden\n";
			#print LOGFILE "Pumpe ist ON. oldPumpestatus: $oldPumpestatus\toldPumpelaufzeit: $oldPumpelaufzeit\t h6: $h6\n";
			print LOGFILE "Pumpe ist ON.\n";
			
			if ($oldPumpestatus == 1)									# Pumpe war schon ON, Ertrag aktualisieren
			{
				my $ertrag=$tempTemperaturV-$tempTemperaturR;			#	Ertrag
				$Pumpedatei[11] = sprintf("Ertrag: %.1f",$ertrag);
			
				my @tempErtragarray=split(" ",$Pumpedatei[12]);			# Bisheriger Ertrag: String aufteilen
				my $oldertrag = $tempErtragarray[1];					# Daten sind an Platz 1

				my $ertragsumme=$oldertrag + $ertrag;					#	Ertrag aufaddieren
				print LOGFILE " Pumpe war schon ON. Ertragsumme integrieren: oldertrag: $oldertrag\tnewertrag: $ertrag\tertragsumme: $ertragsumme\n";
				$Pumpedatei[12] =sprintf("Ertragsumme: %.2f",$ertragsumme);		
				$Pumpedatei[7] ++;										#	Anzahl Messungen aufaddieren
			}
			else
			{
				print LOGFILE "* Pumpe ist neu ON. oldPumpestatus ist 0. Laufzeit setzen. laufzeit: $laufzeit\n";
				my $tempStatus=1;
				$Pumpedatei[8] = "$laufzeit";							# Startzeit der neuen Etappe
								
				$Pumpedatei[6] = "Status: $tempStatus";					# Status speichern			
				#print LOGFILE "Pumpedatei[6]: $Pumpedatei[6]\n";
			}
			
			close LOGFILE;
		} # if $h6 & 0x08
		else															# Pumpe ist OFF
		{
			open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Solardatei: Logfile nicht gefunden\n";
			#print LOGFILE "Pumpe ist OFF. oldPumpestatus: $oldPumpestatus\toldPumpelaufzeit: $oldPumpelaufzeit\th6: $h6\n";
			print LOGFILE "Pumpe ist OFF\n";
			if ($oldPumpestatus == 1) 									# Pumpe war ON, Laufzeit aufaddieren, Messreihe abschliessen
			{
				print LOGFILE "\t* Pumpe ist neu OFF. oldPumpestatus ist 1. Laufzeit addieren.\n";
				my $tempStatus=0;
				my @tempLaufzeitarray=split(" ",$Pumpedatei[5]);						# String aufteilen, Daten sind auf Linie 5
				my $anzLaufzeitelemente = @tempLaufzeitarray;							# Anzahl Elemente
				my $lastPumpelaufzeit= $tempLaufzeitarray[1];							# bisher aufgelaufene Pumpelaufzeit
				$Pumpelaufzeit = $lastPumpelaufzeit + ($laufzeit - $Pumpedatei[8]); 	# Laenge der Etappe der Stunde addieren

				$Pumpedatei[5] = "Stunden-Pumpelaufzeit: $Pumpelaufzeit";				# Neue Pumpelaufzeit schreiben
				$Pumpedatei[6] = "Status: $tempStatus";									# Status speichern
				$Pumpedatei[7] ++;														# Anzahl Messungen aufaddieren
				
																						#	Letzte Temperaturwerte verarbeiten
				my $ertrag=$tempTemperaturV-$tempTemperaturR;							# neuer Ertrag
				$Pumpedatei[11] = sprintf("Ertrag: %.1f",$ertrag);
				my @tempErtragarray=split(" ",$Pumpedatei[12]);							# Bisheriger Ertrag: String aufteilen
				my $lastertrag = $tempErtragarray[1];									# Daten sind an Platz 1

				my $ertragsumme=$lastertrag + $ertrag;									# Ertrag aufaddieren
				$Pumpedatei[12] =sprintf("Ertragsumme: %.2f",$ertragsumme);				# neuen Ertrag schreiben
				
				$Pumpedatei[13]

				print LOGFILE "\tlastPumpelaufzeit: $lastPumpelaufzeit\tIntervall: $laufzeit - $Pumpedatei[8]\tneue Pumpelaufzeit: $Pumpelaufzeit\n";	   
				
			}
			else																		#	Pumpe war OFF, nichts tun
			{
				#print LOGFILE "	   Pumpe ist OFF. oldPumpestatus ist 0. Nichts tun. \n";
			}
			close LOGFILE;	
		}									# if NOT $h6 & 0x08

		
		if ($h6 & 0x80) # Wasseralarm ON
		{
			open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Solardatei: Logfile nicht gefunden\n";
			print LOGFILE "$Datumstring WASSERALARM ESTRICH\n";
			close LOGFILE;		
		}
		
		
	#	Pumpedaten schreiben (Datum und Zeit jedesmal aktualisieren)
		
		open PUMPEDATEN, ">../public_html/Data/SolarPumpeDaten.txt" || die "Pumpedaten nicht gefunden\n";
		foreach (@Pumpedatei)
		{
			print PUMPEDATEN "$_\n";
		}
		close PUMPEDATEN;





	#
	#	Mittelwerte bei voller Stunde in SolarTemperaturMittel und SolarPumpeErtrag speichern
	#

	#	if ($oldMinute % 5 == 0) # Testphase
	
		if ($oldStunde ne $newStunde) # Stunde zu Ende
		{
			open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Elektrodatei: Logfile nicht gefunden\n";
			#print LOGFILE "\n**\tNeue Stunde\n";
			#print LOGFILE "KollektorTemperaturMittel schreiben\n";
			close (LOGFILE);
			
			my $Stundenstatistikstring=0;
			
			# SolarTemperaturMittel aktualisieren
			
			my @tempAussentemperaturarray=split(" ",$TemperaturArray[14]);
			my $tempAussentemperatur = $tempAussentemperaturarray[1];
			
			my @tempMittelwertarray=split(" ",$TemperaturArray[11]);
			my $TemperaturMittelwert = $tempMittelwertarray[1];
			
			#my $Kollektortemperaturmittelwert = round($TemperaturArray[11]/$TemperaturArray[9],2);
			my $fullKollektortemperaturmittelwert = $TemperaturArray[11]/$TemperaturArray[9];
			my $Kollektortemperaturmittelwert = sprintf("%.2f",$fullKollektortemperaturmittelwert);
			#open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Elektrodatei: Logfile nicht gefunden\n";
			#print LOGFILE "fullKollektortemperaturmittelwert: $fullKollektortemperaturmittelwert\tKollektortemperaturmittelwert:  $Kollektortemperaturmittelwert\n";
			#close LOGFILE;
			
				
			open SOLARTEMPERATURMITTEL, "<../public_html/Data/SolarTemperaturMittel.txt" || die "SolarTemperaturdaten nicht gefunden";
			my @TemperaturMittelArray = <SOLARTEMPERATURMITTEL>;
			my $anzTemperaturMittelZeilen=@TemperaturMittelArray;
			chomp(@TemperaturMittelArray);
			my $Stundenzeile=0;
			if ($anzTemperaturMittelZeilen) # schon Zeile(n) vorhanden
			{
				$Stundenzeile = $TemperaturMittelArray[$anzTemperaturMittelZeilen-1]; # letzte Zeile lesen
				$TemperaturMittelArray[$anzTemperaturMittelZeilen-1]= "$TemperaturMittelArray[$anzTemperaturMittelZeilen-1]\t$Kollektortemperaturmittelwert";
								
			}
			else		# neue Zeile anlegen
			{
				# Datum tab Aussentemperatur tab Stundenmittelwerte
				$Stundenzeile= "$oldTag.$oldMonat.$oldJahr\t$Kollektortemperaturmittelwert";
				$TemperaturMittelArray[$anzTemperaturMittelZeilen] = $Stundenzeile;
			}
			
			# TemperaturMittelArray schreiben
			open SOLARTEMPERATURMITTEL, ">../public_html/Data/SolarTemperaturMittel.txt" || die "SolarTemperaturdaten nicht gefunden";
			foreach (@TemperaturMittelArray)
			{
				print SOLARTEMPERATURMITTEL "$_\n";
			}
			
			close (SOLARTEMPERATURMITTEL);
			#
			#	Werte von TemperaturArray zuruecksetzen
			#
			$TemperaturArray[6] = sprintf("Ertrag: %.2f",0.0);
			$TemperaturArray[7] = sprintf("Ertragsumme: %.2f",0.0);
			$TemperaturArray[8] = 0;										#	
			$TemperaturArray[9] = 0;
			$TemperaturArray[10]= sprintf("Mittelwert: %.2f",0.0);
			$TemperaturArray[11] = 0.0;	
			
			$TemperaturArray[13] = 0.0;
			$TemperaturArray[14] = sprintf("Aussentemperatur: %.2f",0.0);
			
			#	Leere Temperaturdaten schreiben
		
			open TEMPERATURDATEN, ">../public_html/Data/SolarTemperaturDaten.txt" || die "Temperaturdaten nicht gefunden\n";
			foreach (@TemperaturArray)
			{
				print TEMPERATURDATEN "$_\n";
			}
			close (TEMPERATURDATEN);

			
		
			#
			#	SolarTagErtrag aktualisieren
			#
			
			# Mittelwert des Ertrags lesen
			
			# Ertragsumme und Anzahl Messungen lesen
			my @tempSummenArray = split(" ",$Pumpedatei[12]);
			my $StundeErtragSumme = $tempSummenArray[1];
			
			my $AnzMessungen = $Pumpedatei[7];
			#my $ErtragMittelwert = $StundeErtragSumme / $AnzMessungen;
			
			open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "SolarTagErtrag: Logfile nicht gefunden\n";
			print LOGFILE "SolarTagErtrag schreiben\tStunde: $oldStunde\t";
			print LOGFILE "StundeErtragSumme: $StundeErtragSumme\tAnzahl Messungen: $AnzMessungen\n";	
			close LOGFILE;
			
			
			open SOLARPUMPEERTRAG, "<../public_html/Data/SolarTagErtrag.txt" || die "SolarTagErtrag nicht gefunden";
			my @PumpeErtragdatei = <SOLARPUMPEERTRAG>;
			my $anzErtragZeilen=@PumpeErtragdatei;
			chomp(@PumpeErtragdatei);
			my $ErtragStundenzeile=0;
			open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "SolarTagErtrag: Logfile nicht gefunden\n";
			#print LOGFILE "SolarTagErtrag schreiben\t";
			#print LOGFILE "anzErtragZeilen: $anzErtragZeilen\tStundeErtragSumme: $StundeErtragSumme\n";	
			close LOGFILE;
			#$StundeErtragSumme=12.7;
			if ($anzErtragZeilen) # schon Zeile(n) vorhanden
			{
				$ErtragStundenzeile = $PumpeErtragdatei[$anzErtragZeilen-1];							 	# letzte Zeile lesen
				$PumpeErtragdatei[$anzErtragZeilen-1]= "$ErtragStundenzeile\t$StundeErtragSumme"; 		# neuen Stundenwert anfuegen
			}
			else		# neue Zeile anlegen
			{
				# Datum tab Aussentemperatur tab Stundenmittelwerte
				$ErtragStundenzeile= "$oldTag.$oldMonat.$oldJahr\t$StundeErtragSumme";
				$PumpeErtragdatei[$anzErtragZeilen] = $ErtragStundenzeile;
			}
			
			# SolarTagErtrag schreiben
			
			open SOLARPUMPEERTRAG, ">../public_html/Data/SolarTagErtrag.txt" || die "SolarTagErtrag nicht gefunden";
			foreach (@PumpeErtragdatei)
			{
				print SOLARPUMPEERTRAG "$_\n";
			}
			
			close SOLARPUMPEERTRAG;
			
			#	Etappe der Pumpe abschliessen
			
			# 	Status festlegen. Wenn die Pumpe schon ON ist, wird der Status beibehalten und nur die Startzeit aktualisiert.
			my $newStatus=0;
			
			# 	Stundenlaufzeit aktualisieren. 
			
			if ($h6 & 0x08) # Pumpe ist ON. Etappe abschliessen. Status fuer neue Stunde ist in diesem Fall ON.
			{
				my @tempLaufzeitarray=split(" ",$Pumpedatei[5]);							# String aufteilen, Daten sind auf Linie 5
				my $anzLaufzeitelemente = @tempLaufzeitarray;								# Anzahl Elemente
				my $lastPumpelaufzeit= $tempLaufzeitarray[1];								# bisher aufgelaufene Pumpelaufzeit
				my $EndPumpelaufzeit = $lastPumpelaufzeit + ($laufzeit - $Pumpedatei[8]); 	# Laenge der Etappe der Stunde addieren
	
				$Pumpedatei[5] = "Stunden-Pumpelaufzeit: $EndPumpelaufzeit";				# Neue Pumpelaufzeit schreiben
				$Pumpedatei[8] = $laufzeit;													# neue Startlaufzeit einsetzen. Wird sonst erst bei Minute 1 eingesetzt.
				$newStatus=1;
			}			
			#	Stundenlaufzeit zur Tageslaufzeit addieren
			
			# Stundenlaufzeit lesen
			my @tempStundenlaufzeitArray = split(" ",$Pumpedatei[5]);
			my $lastStundenlaufzeit = $tempStundenlaufzeitArray[1];
			
			# Bisherige Tageslaufzeit lesen
			my @tempTagelaufzeitArray = split(" ",$Pumpedatei[14]);
			my $tempTageslaufzeit = $tempTagelaufzeitArray[1];
			
			
			open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "SolarTagErtrag: Logfile nicht gefunden\n";
			print LOGFILE "Stundenlaufzeit_zur_Tageslaufzeit_addieren\tStundenlaufzeit: $lastStundenlaufzeit\tbisherige_Tageslaufzeit alt: $tempTageslaufzeit\t";
			
			$tempTageslaufzeit = $tempTageslaufzeit + $lastStundenlaufzeit;
			
			print LOGFILE "Tageslaufzeit neu: $tempTageslaufzeit\tlaufzeit: $laufzeit\n";
			close LOGFILE;
			
			# Neue Tageslaufzeit schreiben
			$Pumpedatei[14] = sprintf("Tages-Pumpelaufzeit: %.1f",$tempTageslaufzeit);
			
			#
			#	Werte zuruecksetzen
			#
			$Pumpedatei[5] = sprintf("Stunden-Pumpelaufzeit: %d",0);		#	Pumpe-Laufzeit der Stunde
			$Pumpedatei[6] = sprintf("Status: $newStatus");				# 	Status nur zuruecksetzen, wenn Pumpe nicht durchlaeuft
			$Pumpedatei[7] = 0;										# 	Anzahl Messungen zuruecksetzen.	
			$Pumpedatei[11] = sprintf("Ertrag: %.1f",0.0);
			$Pumpedatei[12] = sprintf("Ertragsumme: %.2f",0.0);
			#$Pumpedatei[13] = sprintf("Mittelwert: %.2f",0.0);

			open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "SolarTagErtrag: Logfile nicht gefunden\n";
			#print LOGFILE "5: $Pumpedatei[5]\t14: $Pumpedatei[14]\n";
			close LOGFILE;
			
			
			#	Pumpedaten schreiben
		
			open PUMPEDATEN, ">../public_html/Data/SolarPumpeDaten.txt" || die "SolarPumpeDaten nicht gefunden\n";
			foreach (@Pumpedatei)
			{
				print PUMPEDATEN "$_\n";
			}
			close (PUMPEDATEN);
			
			$Stundenstatistikstring = "Stunde: $oldStunde  Ertrag\tTemperaturMittelwert: $TemperaturMittelwert\tStundeErtragSumme: $StundeErtragSumme\tbisherige Tageslaufzeit: $tempTageslaufzeit\n";
			open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "SolarTagErtrag: Logfile nicht gefunden\n";
			print LOGFILE $Stundenstatistikstring;
			close LOGFILE;
			
			#	end	Pumpemittel schreiben
		
		}	#	if ($oldStunde ne $newStunde)
			
	}		#	if ($oldMinute ne $newMinute)
	#
	#	Ende Temperaturdaten speichern
	#
	
	
	#
	#	home.pl line 550
	#
	
	#	aktuelle Zeit einsetzen
	$Elektrodatei[3] =	"Zeit: $stunde:$min";
		
	open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Elektrodatei: Logfile nicht gefunden\n";
	#print LOGFILE "$Datumstring  Daten: h0: $h0	h1: $h1 h2: $h2 h3: $h3 h4: $h4 laufzeit: $laufzeit\n";
	#print LOGFILE "\n$Datumstring	Daten: h0: $h0	h1: $h1 h2: $h2 h3: $h3 h4: $h4 h5: $h5 h6: $h6 h7: $h7		laufzeit: $laufzeit\n";
	#print LOGFILE "datacontrol: $datacontrol\n";
	#print LOGFILE "\t\tlaufzeit: $laufzeit	\toldElektrolaufzeit: $oldElektrolaufzeit	\toldLaufzeit: $oldLaufzeit\n";
	
	#	Elektrolaufzeit ggf aufaddieren
		# Elektrostatus, filtern aus h6. Elektro OFF: 0	 Elektro ON: 1

	if ($h6 & 0x10)										# Bit 4, Elektro ist ON
	{
		#print LOGFILE "Elektro ist ON. oldElektrostatus: $oldElektrostatus\toldElektrolaufzeit: $oldElektrolaufzeit\t h6: $h6\n";
		#print LOGFILE "Elektro ist ON.\n";
		if ($oldElektrostatus == 1)						# Elektro war ON, nichts tun
		{
			#print LOGFILE "   Elektro ist ON. oldElektrostatus ist 1. Nichts tun.\n";
		}
		else											#	Elektro war OFF, Laufzeit setzen
		{
			print LOGFILE "		  Elektro ist neu ON. oldElektrostatus ist 0. Laufzeit setzen. laufzeit: $laufzeit\n";
			my $tempStatus=1;
			$Elektrodatei[4] = "$laufzeit";				# aktuelle Laufzeit
								
			$Elektrodatei[6] = "Status: $tempStatus";	# Status speichern
			$Elektrodatei[8] = "$laufzeit";				# Startzeit der neuen Etappe
			#print LOGFILE "		oldElektrostatus aus neuer Elektrodatei ist $Elektrodatei[6]\n";
		}
	}
	else												#	Elektro ist OFF
	{
	#	print LOGFILE "Elektro ist OFF. oldElektrostatus: $oldElektrostatus\toldElektrolaufzeit: $oldElektrolaufzeit\th6: $h6\n";
		#print LOGFILE "Elektro ist OFF.\n";
		
		if ($oldElektrostatus == 1) # Elektro war ON, Laufzeit aufaddieren
		{
			print LOGFILE "\tElektro ist neu OFF. oldElektrostatus ist 1. Laufzeit addieren.\n";
			my $tempStatus=0;
	 		
	 		my @tempLaufzeitarray=split(" ",$Elektrodatei[5]);		# String aufteilen, Daten sind an Platz 5
	 		my $anzLaufzeitelemente = @tempLaufzeitarray;			# Anzahl Elemente
			my $prevElektrolaufzeit= $tempLaufzeitarray[1];				# bisher aufgelaufene Elektrozeit

			$Elektrolaufzeit = $prevElektrolaufzeit + ($laufzeit - $Elektrodatei[8]); # Laenge der Etappe addieren

			$Elektrodatei[5] = "Elektro-Laufzeit: $Elektrolaufzeit";
			$Elektrodatei[6] = "Status: $tempStatus";		# Status speichern
			$Elektrodatei[7] ++;							# Anzahl Einschaltungen inkrement.
			
			#$Elektrodatei[8] = sprintf("Mittlere Einschaltdauer: %.2f",$Elektrolaufzeit/$Elektrodatei[7]);
			print LOGFILE "\t\tIntervall: $laufzeit - $Elektrodatei[8]\tneue Elektrolaufzeit: $Elektrolaufzeit\n";	   
			
			
			
		}
		else		#	Elektro war OFF, nichts tun
		{
			#print LOGFILE "	   Elektro ist OFF. oldElektrostatus ist 0. Nichts tun. \n";
	
		}
	
	}
	close(LOGFILE);
	
	#$Elektrodatei[5] = "Elektro-Laufzeit: 15.0";
	
	open ELEKTRODATEI, ">../public_html/Data/ElektroDaten.txt" || die "ELEKTRODATEI nicht gefunden\n";
	foreach (@Elektrodatei)
	{
		print ELEKTRODATEI "$_\n";
	}
	
	
	#open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Logfile nicht gefunden\n";
	#print LOGFILE "**	Elektrodatei[6] nach print ist $Elektrodatei[6]\n";
	#close(LOGFILE);
	
	
	open STATUSFILE, ">../public_html/Data/SolarStatus.txt" || die "SolarStatusfile nicht gefunden\n";
	print STATUSFILE "$Datumstring \t$laufzeit\t$h0\t$h1\t$h2\t$h3\t$h4\t$h5\t$h6\t$h7\n";
	close(STATUSFILE);
	
	
	# 22.8.09
	if ($laufzeit> 0 && $datacontrol>0) # Keine Nullen in HomeData, keine Null-Temperaturen
	{
		# 22.8.09: print in if verschoben: nur drucken, wenn > last
		print SOLARDATEI "$laufzeit\t$h0\t$h1\t$h2\t$h3\t$h4\t$h5\t$h6\t$h7\n";
		
		#print ELEKTRODATEI "$laufzeit\t$h5a\n";
		#letzte Daten in last schreiben
		
		open LAST, "+>../public_html/Data/LastSolarData.txt" || die "LastSolarData nicht gefunden\n";
		my @lastdatei = <LAST>;
		
	
		
		if ($lastdatei[0] < $cgivars{d0})
		{
			#		print SOLARDATEI "$laufzeit\t$h2\t$h3\t$h4\t$h5\t$h0\t$h1\n";
			#		print LAST "**$laufzeit\t$h2\t$h3\t$h4\t$h5\t$h0\t$h1\n";
		}
		else # neue Zeit< lastTime
		{
			#		open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Logfile nicht gefunden\n";
			#		print LOGFILE "Time < als lastTime: $lastdatei[0]\n";
			#		close(LOGFILE);
		}
		
		# 22.8.09
		if ($datacontrol)
		{
			print LAST "$laufzeit\t$h0\t$h1\t$h2\t$h3\t$h4\t$h5\t$h6\t$h7\n";
		}
		
		close(LAST);
	
	}	# if $h00
	else
	{
		open LOGFILE, ">>../public_html/Data/SolarLog.txt" || die "Laufzeit ne 0: Logfile nicht gefunden\n";
		if ($laufzeit == 0)
		{
		print LOGFILE "Datumstring: $Datumstring\tlaufzeit ist 0: $laufzeit Laufzeit ist 0\n";
		}
	
		if ($datacontrol == 0)
		{
#			print LOGFILE "$Datumstring\tSolar: datacontrol ist 0\t$laufzeit\t$h2\t$h3\t$h4\t$h5\t$h0\t$h1\t$h6\t$h7\n";
		}
		
		close(LOGFILE);
	}
	
	
}




close SOLARDATEI;

close ELEKTRODATEI;

close PUMPEDATEI;



#open LOGFILE, ">>../public_html/SolarData/Log.txt" || die "Logfile nicht gefunden\n";
#print LOGFILE "$laufzeit\t$cgivars{d2}\t$cgivars{d3}\t$cgivars{d4}\t$cgivars{d1}\t$cgivars{d0}\t$cgivars{d6}\t$cgivars{d7}\t0\n";
#close(LOGFILE);

# Finally, print out the complete HTML response page
# print <<EOF druckt alles bis EOF


# Print the CGI variables sent by the user.
# Note that the order of variables is unpredictable.
# Also note this simple example assumes all input fields had unique names,
#	though the &getcgivars() routine correctly handles similarly named
#	fields-- it delimits the multiple values with the \0 character, within 
#	$cgivars{$_}.

#foreach (keys %cgivars) 
#{
#	 print "<li>[$_] = [$cgivars{$_}]\n" ;
#}




exit ;

sub roundup {
    my $n = shift;
    return(($n == int($n)) ? $n : int($n + 1))
}

sub round_to_halves {
    return 0.5 * (int(2*$_[0]));
}

# Read all CGI vars into an associative array.
# If multiple input fields have the same name, they are concatenated into
#	one array element and delimited with the \0 character (which fails if
#	the input has any \0 characters, very unlikely but conceivably possible).
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
	foreach (split(/[&;]/, $in)) 
	{
		s/\+/ /g ;
		($name, $value)= split('=', $_, 2) ;
		$name=~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/ge ;
		$value=~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/ge ;
		$in{$name}.= "\0" if defined($in{$name}) ;	# concatenate multiple vars
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
