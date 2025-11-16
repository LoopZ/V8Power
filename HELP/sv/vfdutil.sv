vfdutil [flaggor]

Fil- och katalogverktyg.

    [inga]      G”r ingenting
    /D fil      Ber„kna och mata ut enhetsbokstav f”r fil till STDOUT.
    /P fil      Ber„kna och mata ut s”kv„g f”r fil till STDOUT.
    /C          Anv„nd f”r /D eller /P f”r att „ndra enhetsbokstav eller s”kv„g
                utan utmatning.
    /X          Anv„nd f”re /D eller /P f”r att returnera errorleve 1-26 f”r
                enhetsbokstav.
    /F fil      Ber„kna och mata ut komplett filnamn till STDOUT.
    /B fil      Ber„kna och mata ut filnamn med fil„ndelse till STDOUT.
    /N fil      Ber„kna och mata ut filnamn utan fil„ndelse till STDOUT.
    /E fil      Ber„kna och mata ut fil„ndelse till STDOUT.
    /U mall     Ber„kna och mata ut unikt fil-/katalognamn baserat p† mall till
                STDOUT. Enheten och s”kv„gen m†ste existera.
                Exempel: "vfdutil /u C:\TEMP\TEST????.$$$"
    /S filspec  Genoms”k PATH efter angiven filspec och mata ut alla matchande
                filer till STDOUT. Aktuell katalog genoms”ks inte. Om en filspec
                inte hittas i s”kv„gen avslutas verktyget med errorlevel 1.
    /T filspec  Precis som /S f”rutom att endast errorlevel returneras.
    /M plats    Mata ut m„ngd ledig utrymme p† plats.
    /R kr„vs    Anv„nds i kombination med /M f”r att testa om m„ngden ledigt
                utrymme finns tillg„ngligt. Kr„vs „r begr„nsat till 65535, men
                kan kan †tf”ljas av B, K, M osv. Det kommer att returnera
                errorlevel 1 om det inte fanns tillr„ckligt med utrymme.
    /A s”kv„g   Testa om n†gra filer eller katalog finns i en s”kv„g, 0=katalog
                finns och „r inte tom, andra v„rden „r DOS-felkoder fr†n testet.

    tba         (Fortfarande under utveckling, mer kommer att annonseras)

