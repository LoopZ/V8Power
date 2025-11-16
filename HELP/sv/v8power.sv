*******************************************************************************
V8Power Tools
Copyright 2015-2024 Jerome Shidel
Sl„ppt under licensen GPL v2.0.
*******************************************************************************

Som att stoppa kraften fr†n en V8 under huven p† DOS-kommandofiler.

===============================================================================

V8Power Tools-projektet har designats i samarbete med
Jim Hall f”r operativsystemet FreeDOS(TM) (http://www.freedos.org). Det „r
avsett att expandera funktionaliteten f”r skrivs skrivna med kommandofiler och
f”r att tillhandah†lla dem med ett snyggare anv„ndargr„nssnitt med ”kad
funktionalitet.

===============================================================================

Att kompilera V8Power Tools

    F”ruts„ttningar:

        8086-processor eller b„ttre.
        EGA-grafikkort eller b„ttre.
        FreeDOS(TM) 1.1 (http://www.freedos.org) eller senare
        NASM f”r DOS version 2.16.01 (http://wwww.nasm.us) eller nyare

    Kompilering:

        S„kerst„ll att NASM-katalogen finns i din s”kv„g.
        H„mta senaste k„llkoden fr†n http://github.com/LoopZ/V8Power
        K”r skriptet mkV8.bat.
        Alla k”rbara filer placeras i den nyskapade katalogen BIN.

    F”r lata personer som jag:

        F”rkompilerade versioner tillg„ngliga p† http://up.lod.bz/V8Power.

===============================================================================

V8Power Tools testad kompatibilitet

    FreeDOS 1.1+

Begr„nsad kompatibilitet f”r avancerade funktioner (inte kommandost”d f”r "set /p"):

    MS-DOS 6.2 och 6.22
    PC-DOS 7.0, 7.01 och 2000
    DR-DOS 7.03
    DOSBox (i/o-omdirigering eller f”rfr†gan via stdout kommer INTE att fungera
        via det inbyggda DOSBox-skalet. De fungerar dock bra i DOSBox n„r ett
        kompatibelt skal s† som FreeCOM anv„nds)
    Windows 3.11-skal
    Windows 98-skal och kommandotolk
    Windows XP SP3-skal (f”rutom vcursor)

===============================================================================

V8Power Tools anv„ndning

H„r lite grundl„ggande information kring alla verktyg och hur de fungerar.

    Flaggor, v„rden och hexadecimala nummer „r skiftl„gesok„nsliga /f vitt „r
    det samma som /F vITt.

    Hexadecimala nummer kan prefixas med 0x f”r att f”rhindra att de behandlas
    som bas tio. (Exempel 10 och 0x10)

    Blanksteg „r f”r det mesta valfritt. /B7/f0 „r detsamma som /B 7 /F 0.
    Men inte / B7 / F0.

    F”r att anv„nda ett / eller blanksteg i ett v„rde, placera det inom
    citationstecken, exempelvis "Jack och/eller Jill".

    Anv„nd flera citattecken f”r att anv„nda citattecken, exempelvis
    "V„lkommen till stan'" eller 'S„g "va?"'.

    Om inte †sidosatta anv„nder de flesta verktygen samma textattribut som den
    aktuella mark”rpositionen.

===============================================================================

H„r „r en f„rgtabell som anv„nds f”r alla **/A**, **/F** och **/B**-flaggor:

    Decimalt    Hex         Textetikett (Skiftl„gesok„nsligt)

    0           0x00        Black
    1           0x01        Blue
    2           0x02        Green
    3           0x03        Cyan
    4           0x04        Red
    5           0x05        Magenta
    6           0x06        Brown
    7           0x07        Gray / Grey

    (Enda f”r f”rgrund /f och /a)

    8           0x08        DarkGray / DarkGrey
    9           0x09        LightBlue
    10          0x0a        LightGreen
    11          0x0b        LightCyan
    12          0x0c        LightRed
    13          0x0d        LightMagenta
    14          0x0e        Yellow
    15          0x0f        White

De flesta av de individuella verktygen som har st”d f”r f„rg„ndring har ocks†
st”d f”r blinkning-/intensitetsinst„llningen. De flesta verktygen n„mner dock
inte det.

	/BlinkOn    Aktivera blinknings-/intenstetsbiten (B”rja blinka)
	/BlinkOff   Inaktivera blinknings-/intensitetsbiten. (Sluta blinka)

===============================================================================

DOS-kommandorad (och kommandofiler) „r begr„nsade till ungef„r 128 tecken.
Detta skulle kunna g”ra det sv†rt f”r verktyg som vecho att skriva ut flera
rader p† en g†ng. M†nga verktyg s† som vecho, vstr, etc. har st”d f”r att
l„sa in textresurser fr†n en fil med /T-flaggan. Generellt anv„nds /T-flaggan
f”r att tillhandah†lla ”versatt text f”r en kommandofil. N„r den l„ses in fr†n
fil „r V8Power Tools-verktyget begr„nsat till 10 kilobyte per rad. Ut”ver det
kommer verktyget att hoppa ”ver †terst†ende text p† den raden. 10kbyte „r
detsamma som 5 eller fler fulla sk„rmar text och det r„cker tillr„ckligt.
