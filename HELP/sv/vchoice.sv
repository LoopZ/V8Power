vchoice [flaggor]

V„lj ett alternativ.

Returnerar en errorlevel f”r det val som valts baserat p† dess postnummer. Inte
bokstaven/numret f”r alternativet. Om t.ex. det andra objektet v„ljs kommer
det att returnera en errorlevel som „r 2. Oavsett vilket prefix (s† som C,
1, R, etc). Jag rekommenderar ocks† personligen att anv„nda auto f”r en
upps„ttning alternativ som du prefixar med en bokstav eller ett nummer.

    [inga]      Utf”r alla automatiska standardinst„llningar.
    /A n        S„tt textattribut till n f”r valt objekt.
    /B f„rg     S„tt textattribut f”r bakgrunden till f„rg (eller v„rde)
                f”r valt objekt.
    /F f„rg     S„tt textattribut f”r f”rgrunden till f„rg (eller v„rde)
                f”r valt objekt.
    /D n        F”rv„lj objekt nummer n som standard alternativ.
    type        Val f”r typ av direkttangent
                    off     V„lj endast med piltangenterna.
                    auto    Identifiera hopptecken. (Standard)
                    alpha   Hoppa till alternativ med A-Z.
                    digit   Hoppa till alternativ med 1-9 (+0).
    /Q          Fr†ga efter resultat. N„r alternativet g”rs kommer dess text
                att skickas till STDOUT.
    /T sekunder F”rdr”jning i sekunder innan standardobjektet v„ljs automatiskt
                (0-3600). Notera att „ven om anv„ndaren navigerar till ett annat
                objekt, kommer original standardobjektet att vara valt n„r
		tidsgr„nsen l”per ut.
    /P n        Anv„nd pollningsl„ge och f”rv„lj objekt nummer n som aktuellt
                val. Notera att „ndring av valet kommer att avsluta vchoice och
                returnera 100 + nummer f”r aktuellt alternativ.
    /K n        Anv„nd n ist„llet f”r ramtecken f”r att identifiera ramar.
    CTRL-C      N„r angivet och Control-C trycks ned kommer det att avsluta
                med errorlevel 200.

    tba         (Fortfarande under utveckling, mer kommer att annonseras)
