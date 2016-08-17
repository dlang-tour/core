# Benvenuto nel tour del linguaggio D

Benvenuto nel tour interattivo del *Linguaggio di Programmazione D*.

{{#dmanmobile}}

Questo tour ti fornirà le basi di questo  __potente__ ed __espressivo__
linguaggio, che compila in __efficiente__ codice __nativo__.

{{/dmanmobile}}

### Cos'è D?

D rappresenta il culmine di  _decenni di esperienza nell'implementazione di compilatori_
per molti linguaggi differenti e dispone di un gran numero di
[caratteristiche uniche](http://dlang.org/overview.html):

{{#dmandesktop}}

- costrutti _ad alto livello_ per una grande capacità di modellazione
- linguaggio compilato in codice _ad alte prestazioni_
- tipizzazione statica
- evoluzione del linguaggio C++ (senza ripeterne gli errori)
- interfacciamento diretto con le API del sistema operativo e con l'hardware
- tempi di compilazione estremamente brevi
- programmazione memory-safe (SafeD)
- codice _mantenibile_ e _facile da comprendere_
- bassa curva di apprendimento (sintassi C-like, simile a Java e molti altri linguaggi)
- compatibile con il codice C a livello di ABI
- linguaggio multi-paradigma (programmazione imperativa, strutturata, orientata agli oggetti, generica, funzionale e persino codice assembly integrato)
- costrutti di prevenzione degli errori (asserzioni, contratti, unit testing)

... e molte altre [interessanti caratteristiche](http://dlang.org/overview.html).

{{/dmandesktop}}

### Informazioni sul tour

Ogni sezione è accompagnata da un esempio di codice che può essere modificato e testato
per sperimentare le caratteristiche del linguaggio D.
Premi il pulsante esegui (o `Ctrl-Invio`) per compilarlo ed eseguirlo.

### Contribuire al tour

Questo tour è [open source](https://github.com/stonemaster/dlang-tour)
e siamo aperti a pull requests per renderlo ancora migliore.

## {SourceCode}

```d
import std.stdio;

// Iniziamo!
void main()
{
    writeln("Ciao, Mondo!");
}
```
