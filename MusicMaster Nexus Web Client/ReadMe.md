# MusicMaster Nexus Web Client

Una Web App leggera e pronta all'uso (Zero-Install) per interagire con il server locale **MusicMaster Nexus** (`localhost:8080`)[cite: 1, 2], progettata per Windows 11. Questa interfaccia replica la comodità del client di test ufficiale, permettendo di inviare comandi XML, gestire stazioni/database multipli e visualizzare le risposte sia in formato XML grezzo che in tabelle formattate.

## 🚀 Caratteristiche Principali

* **Zero-Install su Windows 11 Pro:** Sfrutta il motore HTTP nativo di PowerShell e un micro-proxy integrato per aggirare completamente i blocchi di sicurezza CORS del browser.
* **Supporto Multi-Stazione / Database:** Compatibile con la gestione delle stazioni di MusicMaster PRO e CS (`Enterprise`, `ZenonMedia`, `105 DAB`, `RMC`, `Virgin`, ecc.)[cite: 6, 9].
* **Libreria di Comandi Rapidi:** Preset integrati per i comandi principali della Nexus API (es. `getCategoryList`, `getSchedule`, `getAssignedClocks`, `getElements`, `ping`)[cite: 2, 8].
* **Doppia Vista (XML & Grid View):** Analisi immediata delle risposte sia come codice XML strutturato che in tabelle interattive (con supporto automatico ai colori delle categorie)[cite: 2, 8].

---

## 🛠️ Requisiti di Sistema

* **Windows 11 Pro** (con PowerShell nativo).
* **MusicMaster Nexus Server** attivo e in esecuzione sulla macchina locale (default: `http://localhost:8080`)[cite: 1, 2].
* Un qualsiasi browser moderno (Edge, Chrome, Firefox).

---

## 📦 Installazione e Avvio Rapido

Dato che i browser bloccano le chiamate dirette da file locali (`file://`) verso `localhost` (criteri CORS), l'applicazione utilizza un server proxy locale in PowerShell. Non è richiesto l'installazione di Python o Node.js.

1. Clona o scarica questo repository nella cartella del tuo computer.
2. Crea un file denominato **`Avvia_Nexus.bat`** nella stessa cartella del progetto.
3. Incolla il codice dello script di avvio all'interno del file `.bat`.
4. Fai un **doppio clic su `Avvia_Nexus.bat`**: si aprirà automaticamente il browser all'indirizzo **`http://localhost:3001`** con l'interfaccia pronta all'uso.

---

## 💻 Struttura del Codice Batch/PowerShell (`Avvia_Nexus.bat`)

Se preferisci avviare il server incorporato tramite script batch di Windows, puoi utilizzare la seguente struttura combinata:

```bat
<# :
@echo off
title MusicMaster Nexus Web Client
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ([System.IO.File]::ReadAllText('%~f0'))"
pause
exit /b
#>

$port = 3001;
# Il codice HTML/JS dell'interfaccia web è integrato direttamente qui dentro