# Commands

A collection of Windows batch utilities for local development.

## Scripts

### `RunTask.bat`
Launches development servers in new Windows Terminal tabs.

```
runtask [tasks] [root]
```

| Command | Task             |
|---------|------------------|
| `i`     | Intranet         |
| `b`     | B2B              |
| `c`     | B2C              |
| `s`     | NaarGo (Support) |
| `d`     | Print (Docs)     |
| `u`     | Update API       |
| `a`     | NaarApi          |
| `g`     | Naar.NaarGo      |
| `z`     | NaarAzureAgent   |
| `f`     | NaarFunctions    |
| `p`     | NaarAzurePricer  |
| `l`     | NaarLRT          |

Pass multiple letters to open several tabs at once: `runtask iab`

Optionally pass a custom root folder as the second argument (default: `D:\Progetti`).

---

### `FreePort.bat`
Inspect and kill processes listening on local ports.

```
freeport l              # list all listening ports
freeport [port]         # find process on a port
freeport [port] k       # find and kill process on a port
```

---

### `GitUndo.bat`
Soft-reset the last N commits (unstages changes, keeps files).

```
gitundo [n]   # default: 1
```

---

### `Pray.bat`
Launches Claude Code with `--dangerously-skip-permissions`.

```
pray
```

---

### `hs.bat`
Power control for the home server machines (NAS `glnas` + NUC `glnuc`) via Wake-on-LAN and SSH.

```
hs                  # status of both machines
hs on  [nas|nuc]    # wake up (default: both, NAS then NUC)
hs off [nas|nuc]    # clean shutdown via SSH (default: both, NUC then NAS)
```

`hs on nuc` requires the NAS to be up, `hs off nas` requires the NUC to be down; add `-f` to override. The underlying scripts live in `D:\Personale\HomeServer` (one-time SSH key setup: see `GESTIONE-ENERGIA.md` there).

## Setup

Add this folder to your `PATH` so the commands are available system-wide.
