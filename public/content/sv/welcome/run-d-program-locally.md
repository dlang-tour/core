//# Run D program locally
# Köra D program lokalt

D kommer med kompilatorn `dmd`, ett skript-liknande verktyg `rdmd`
och en pakethanterare `dub`.

### DMD Kompilatorn

*DMD* kompilatorn kompilerar D filer och skapar en binär fil.
På kommandoraden kan *DMD* anropas med ett filnamn:

    dmd hello.d


Det finns många inställningar vilket tillåter att ändra beteendet av *DMD* kompilatorn.
Granska [online dokumentationen](https://dlang.org/dmd.html#switches) eller kör `dmd --help` för en överblick av tillgängliga flaggor.

### "On-the-fly" kompilering med `rdmd`


Hjälpverktyget `rdmd`, distruberat med DMD kompilatorn,
kommer kompilera alla beroenden och automatiskt köra applikationen.

    rdmd hello.d


På UNIX system kommer 'shebang' raden `#!/usr/bin/env rdmd` på första raden av en körbar D fil att tillåta
skript liknande användning.

Granska [online dokumentationen](https://dlang.org/rdmd.html) eller kör `rdmd --help` för en överblick av tillgängliga flaggor.

### Pakethanteraren `dub`


Ds standard pakethanterare är [`dub`](http://code.dlang.org). När `dub` är installerat
lokalt, kan ett nytt projekt `hello` skapas med kommandot:

    dub init hello

Köra `dub` i denna mapp kommer hämta alla beroenden, kompilera applikationen
och klra den.
`dub build` kommer kompilera projektet.

Browse the [online documentation](https://code.dlang.org/docs/commandline) or run `dub help` for an overview of available commands and features.
Granska [online dokumentationen](https://code.dlang.org/docs/commandline) eller kör `dub help` för en överblick av tillgängliga kommandon och funktioner.

Alla tillgängliga dub paket kan granskas via dubs [webb gränssnitt](https://code.dlang.org).
