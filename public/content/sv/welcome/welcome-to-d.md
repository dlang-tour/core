# Välkommen till D

Välkommen till den interaktiva rundturen av *Programmings språket D*.

{{#dmanmobile}}

Denna rundtur ger en överblick av detta __kraftfulla__ och __målande__
språk vilket kompilerar direkt till __effektiv__, __ren__ maskin kod.

{{/dmanmobile}}

### Vad är D?

D är höjdpunkten utav __decennier av erfarenhet inom att implementera kompilatorer__
för många diverse språk och har en stort antal [unika funktioner](http://dlang.org/overview.html):

{{#dmandesktop}}

- _hög nivå_ begrepp för fantastiskt modellerings kraft
- _högt presterande_, kompilerat språk
- statisk typning
- evolutionen av C++ (utan dess misstag)
- direkt gränssnitt till operativ systemets API:n och hårdvara
- supersnabb kompilerings tid
- tillåter minnes-säker programmering (SafeD)
- _underhållbart_, _enkelt att förstå_ kod
- kort inlärningskurva (C-likt syntax, likt Java och andra språk)
- kompatibel med C applikationers binära gränssnitt
- multi-paradigm (imperative, structured, object oriented, generic, functional programming purity, and even assembly) //TODO: Translate to Swedish
- inbyggt fel hinder (kontrakt, unitttest)

... och många mer [funktioner](http://dlang.org/overview.html).

{{/dmandesktop}}

### Om rundturen

Varje sektion kommer med ett kod exempel som kan modifieras och användas med för
att experimentera med Ds språk funktioner.
Klicka på kör knappen (eller `Ctrl+enter`) för att kompilera och köra koden.

### Bidra

Denna rundtur är [öppen källkod](https://github.com/stonemaster/dlang-tour)
och vi är glada i 'pull requests' som gör denna rundtur ännu bättre.

## {SourceCode}

```d
import std.stdio;

void main()
{
    writeln("Hej Världen!");
}
```
