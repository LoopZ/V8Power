vecho [flaggor] [text]

Mata ut text till sk„rmen.

    [inga]      Skriver ut vagnretur (CR) och radmatning (LF) till sk„rmen.
    text        Skriver ut texten till sk„rmen.
    /A n        S„tt textattribut till n.
    /B f„rg     S„tt textattribut f”r bakgrunden till f„rg (eller v„rde).
    /F f„rg     S„tt textattribut f”r f”rgrunden till f„rg (eller v„rde).
	/BlinkOn    Aktivera blinknings-/intensitetbiten. (B”rja blinka)
	/BlinkOff   Inaktivera blinknings-/intensitetbiten. (Sluta blinka)
    /N          Skriv inte ut CRLF av avslut.
    /P          Skriv ut CRLF nu.
    /S +        Infoga ett blanksteg mellan parametrar. (STANDARD)
    /S -        Mata inte ut blanksteg mellan flera parametrar.
    /C kod      Skriv ut en ASCII-teckenkod.
    /R g†nger   Repeterar n„sta skrivning g†nger antal g†nger. (1-65535)
    /I          Skriv ut text som v„ntar p† STDIN-enheten.
    /G          Skriv ut text globalt och ignorera alla ramar.
    /L          Skriv ut text lokalt med h„nsyn tagen till ramar. (STANDARD)
    /K n        Anv„nd n ist„llet f”r ramtecken f”r att identifiera ramar.
    /X kod      Rensa resten av raden med asciikod, men flytta inte mark”ren.
    /E          Samma som att anv„nda "/X 0x20" eller "/X32".
    /T fil ID   Sl† upp ID i fil och behandla det som en kommandoradsparameter.
                Resterande parametrar som f”ljer denna flagga anv„nds f”r att
		populera variablerna %1-%9 i textstr„ngen.

    tba         (Fortfarande under utveckling, mer kommer att annonseras)
