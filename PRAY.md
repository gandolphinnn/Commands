# pray

Scorciatoia per aprire **Claude Code** (`claude --dangerously-skip-permissions`) nella
cartella giusta, senza dover navigare a mano con `cd`.

## Utilizzo

```
pray                lancia il selettore interattivo con tutte le cartelle
pray <testo>        filtra le cartelle che iniziano per <testo> e apre il selettore
pray -r             riprende l'ultimissima sessione Claude aperta (ovunque)
pray -r <testo>     filtra le cartelle, ne scegli una e riprende la sua ultima sessione
pray <testo> -r     come sopra: il flag -r può stare prima o dopo il filtro
```

> La regola: ciò che scrivi dopo `pray` **senza** trattino è un **filtro** sulle
> cartelle; il trattino (`-r`) identifica invece un parametro/flag. Il flag `-r`
> può essere indicato indifferentemente **prima o dopo** il filtro
> (`pray -r a` equivale a `pray a -r`).

### `pray` — selettore interattivo

Senza argomenti mostra un menu con tutte le cartelle presenti in `D:\Progetti` e
`D:\Personale`, più la **cartella corrente** (quella da cui hai lanciato il
comando) in cima alla lista, etichettata `[here]`.

Comandi del menu:

| Tasto              | Azione                          |
| ------------------ | ------------------------------- |
| `↑` / `↓`          | sposta la selezione             |
| `Home` / `End`     | vai al primo / ultimo elemento  |
| `Invio`            | conferma e apre Claude          |
| `Esc` / `Ctrl+C`   | annulla                         |

Alla conferma fa `cd` nella cartella scelta e lancia Claude.

### `pray <testo>` — filtro sulle cartelle

Il testo viene usato come **prefisso** (case-insensitive) sul nome delle cartelle
di `D:\Progetti` e `D:\Personale`. Il comportamento dipende da quante cartelle
corrispondono:

| Corrispondenze | Comportamento                                          |
| -------------- | ------------------------------------------------------ |
| **1**          | apre quella cartella direttamente, senza menu          |
| **più di 1**   | apre il selettore con le sole cartelle che combaciano  |
| **0**          | apre il selettore con tutte le cartelle                |

Esempi:

```
pray Naar     ->  menu con [Progetti] NaarGo e [Progetti] NaarNew
pray api      ->  apre direttamente D:\Progetti\api (unica corrispondenza)
pray zzz      ->  nessun match: menu con tutte le cartelle
```

### `pray -r` — riprendi l'ultima sessione (globale)

Riprende automaticamente **l'ultimissima sessione Claude aperta**, qualunque sia
la cartella in cui era stata avviata:

1. cerca il file di sessione più recente in `%USERPROFILE%\.claude\projects`;
2. ne ricava la cartella di lavoro originale;
3. fa `cd` in quella cartella e rilancia Claude con `--resume`.

Se non esiste nessuna sessione da riprendere, lo segnala ed esce.

### `pray -r <testo>` — riprendi nella cartella scelta

Applica lo stesso filtro di `pray <testo>` (prefisso sul nome cartella, con le
stesse regole 1 / più / 0 della tabella sopra) e, una volta individuata la
cartella, vi entra e riprende la sua sessione più recente con `claude --continue`.

Esempio:

```
pray -r a   ->  menu con [Progetti] api e [Personale] AditusBelli;
                dopo la scelta riprende l'ultima sessione di quella cartella
```

## File coinvolti

| File              | Ruolo                                                            |
| ----------------- | ---------------------------------------------------------------- |
| `Pray.bat`        | entry point: smista tra picker, filtro e resume                  |
| `PraySelect.ps1`  | filtra le cartelle e disegna il menu interattivo                 |
| `PrayResume.ps1`  | individua l'ultima sessione globale e la sua cartella (`pray -r`) |

## Note

- Claude viene sempre avviato con `--dangerously-skip-permissions`.
- Il selettore pulisce lo schermo all'avvio per evitare problemi di rendering
  quando lo si rilancia dopo un annullamento.
- Il filtro confronta solo il **nome** della cartella (non l'etichetta
  `[Progetti]` / `[Personale]`) e ignora maiuscole/minuscole.
