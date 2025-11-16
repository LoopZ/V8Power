vstr [flaggor]

Enkelt verktyg f”r str„ngbehandling. Matar ut resultat till STDOUT.

    /N          Skriv inte ut CRLF n„r f„rdigt.
    /U          Indatafilter: Konvertera till versaler.
    /D          Indatafilter: Konvertera till gemener.
    /B          Indatafilter: Hoppa ”ver tomma rader.
    /I          Indatafilter: Hoppa ”ver indentering.
    /C kod      Skriv ut en ASCII-teckenkod.
    /R g†nger   Repetera n„sta skrivning g†nger antal g†nger. (1-65535)
    /L rad      Returnera endast denna rad fr†n standard in. (0-65535)
                (Notera: vline /L TOTAL returnerar totalt antal rader.)
                Ocks†, om du l„gger till :kommer n rader att matas ut.
    /S s1 s2    S”k efter och ers„tt alla f”rekomster av s1 med s2.
    /F s1 s2    S„tt avgr„nsare till s1 och returnera endast f„ltposition eller
                intervall s2.
    /A kod s2   Returnera kod begr„nsad f„ltposition eller intervall s2.
                (tab=0x09)
    /P s1       Skriv ut text s1.
    /T fil ID   Sl† upp ID i fil och behandla det som en kommandoradsparameter.
                Ytterligare parametrar som f”ljer p† denna flagga anv„nds f”r
		att populera variablerna %1-%9 i textstr„ngen.

    tba         (Fortfarande under utveckling, mer kommer att annonseras)

