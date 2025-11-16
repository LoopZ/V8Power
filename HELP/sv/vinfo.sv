vinfo [flaggor]

Allm„nt systeminformationsverktyg.

    [inga]      G”r ingenting
    /V          Utf”rligt l„ge
    /D a        Testa enhetsstatus.
                Returnerar dessa avslutningskoder:
                   15 - Saknas
                    5 - Inte formatterad (f”r DOS)
                    4 - N„tverksenhet (otestad)
                    3 - CD/DVD-ROM (endast MSCDEX, de flesta rapporterar 15)
                    2 - Borttagningsbar media (s† som diskett)
                    1 - (Reserverat)
                    0 - Ingen speciell status
    /M          Returnera maskintyp (Kan g† s”nder f”r framtida plattformar)
                Returnerar dessa avslutningskoder:
                    0 - Ok„nd, normal eller inbyggd 8086-h†rdvara.
                    1 - 80186
                    2 - 80286
                    3 - 80386
                    4 - 80486
                    5 - 80586
                    6 - 80686 eller senare
                  101 - DOSBox.
                  102 - QEMU.
                  103 - VirtualBox.
                  104 - VMware.
                  105 - Bochs.
                  200 - Annan emulator identifierad.
    /P          Samma som /M, men exkluderar tester f”r virtuella maskiner.
    /E n        Genoms”k fysisk h†rddisk #n (1, 2, etc) efter MBR-status
                    0 - MBR helt tom
                    5 - MBR inneh†ller endast partitionsinformation
                   10 - MBR inneh†ll startkod
                  101 - Ett fel intr„ffade

Fler flaggor som mest „r anv„ndbara f”r programmerare och utveckling. De
har funnits ett tag, men „r inte (enligt mig) officiellt en del av
V8Power Tools API och kan „ndras eller tas bort n„r som helst. Men eftersom
jag anv„nder dem kanske de flyttas till egna verktyg.

    ASCII       Visa hela ASCII-tabellen
    RAM         Dumpa allt konventionellt minne till Stdout.
    /C *        skriv ut ascii-v„rden f”r resten av kommandoraden
    /R str„ng   S”k genom allt konventionellt minne efter en str„ng
    /U str„ng   Genoms”k minne (a000:0000 och upp) efter skiftl„gesok„nslig
                str„ng
    /J pos *    Returnera ascii-v„rdet f”r tecknet p† position i resten av
                kommandoraden som en ERRORLEVEL. 0 returneras om positionen
                inte hittades.
    /K pos *	Samma som /J, men konverteras f”rst till versal.
    tba         (Fortfarande under utveckling, mer kommer att annonseras)
