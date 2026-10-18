<# :
@echo off
title MusicMaster Nexus Web Client 2.2 (Windows 11 Native)
echo Pulizia vecchie sessioni e avvio su http://localhost:3001 ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ([System.IO.File]::ReadAllText('%~f0'))"
pause
exit /b
#>

$port = 3001;
$html = @'
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>MusicMaster Nexus Web Client 2.2</title>
    <style>
        * { box-sizing: border-box; font-family: 'Segoe UI', Tahoma, sans-serif; font-size: 13px; }
        body { background: #e3e7eb; margin: 0; padding: 15px; color: #222; }
        .window { max-width: 1020px; margin: auto; background: #f5f5f5; border: 1px solid #999; border-radius: 5px; padding: 14px; box-shadow: 0 5px 15px rgba(0,0,0,0.2); }
        .title-bar { font-size: 15px; font-weight: 600; color: #1e395b; margin-bottom: 12px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #ccc; padding-bottom: 8px; }
        .top-panel { display: grid; grid-template-columns: 1fr 250px 130px; gap: 15px; background: #fff; padding: 12px; border: 1px solid #ccc; margin-bottom: 12px; align-items: center; }
        .field-row { display: flex; align-items: center; margin-bottom: 6px; gap: 8px; }
        .field-row:last-child { margin-bottom: 0; }
        .field-row label { min-width: 75px; font-weight: 500; }
        input[type="text"], input[type="password"], select { width: 100%; padding: 5px 8px; border: 1px solid #aaa; border-radius: 2px; background: #fff; }
        input:disabled, select:disabled { background: #ebebe4; color: #666; }
        .btn { padding: 6px 14px; border: 1px solid #0078d7; background: #e5f1fb; color: #000; cursor: pointer; border-radius: 2px; font-weight: 600; }
        .btn:hover:not(:disabled) { background: #cce4f7; }
        .btn:disabled { border-color: #ccc; background: #eee; color: #888; cursor: not-allowed; }
        .btn-connect { height: 58px; width: 100%; font-size: 14px; }
        .mid-bar { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
        textarea { width: 100%; height: 190px; font-family: Consolas, monospace; font-size: 13px; padding: 10px; border: 1px solid #888; resize: vertical; margin-bottom: 12px; background: #fff; }
        .tabs { display: flex; border-bottom: 1px solid #888; }
        .tab { flex: 1; text-align: center; padding: 7px; background: #e1e1e1; border: 1px solid #888; border-bottom: none; cursor: pointer; font-weight: 600; }
        .tab.active { background: #fff; border-bottom: 1px solid #fff; margin-bottom: -1px; color: #005a9e; }
        .reply-box { background: #fff; border: 1px solid #888; border-top: none; height: 340px; padding: 10px; overflow: auto; }
        pre { margin: 0; font-family: Consolas, monospace; font-size: 13px; white-space: pre-wrap; }
        table { width: 100%; border-collapse: collapse; font-size: 12px; }
        th, td { border: 1px solid #ccc; padding: 5px 8px; text-align: left; }
        th { background: #eaeaea; font-weight: 600; position: sticky; top: 0; }
        .status-dot { display: inline-block; width: 10px; height: 10px; border-radius: 50%; background: #cc0000; margin-right: 6px; }
        .status-dot.connected { background: #28a745; }
        .timer { color: #444; font-family: Consolas, monospace; min-width: 80px; }
        .color-swatch { display: inline-block; padding: 2px 8px; border-radius: 3px; border: 1px solid #888; font-weight: bold; }
    </style>
</head>
<body>

<div class="window">
    <div class="title-bar">
        <span>✅ MusicMaster Nexus Test Client (Web Edition 2.2 - XML Fix)</span>
        <span id="connStatus"><span class="status-dot" id="statusDot"></span>Disconnesso</span>
    </div>

    <div class="top-panel">
        <div>
            <div class="field-row">
                <label>Server:</label>
                <input type="text" id="serverInput" value="localhost:8080">
                <label style="min-width:75px; display:flex; align-items:center; gap:4px;">
                    <input type="checkbox" id="sslCheck"> Use SSL
                </label>
            </div>
            <div class="field-row">
                <label>Client ID:</label>
                <input type="text" id="clientInput" value="NexusTest 1.5">
            </div>
        </div>

        <div>
            <div class="field-row">
                <label>Username:</label>
                <input type="text" id="userInput" placeholder="Opzionale (CS Auth)">
            </div>
            <div class="field-row">
                <label>Password:</label>
                <input type="password" id="passInput" placeholder="Opzionale">
            </div>
        </div>

        <div>
            <button class="btn btn-connect" id="connectBtn" onclick="toggleConnect()">Connect</button>
        </div>
    </div>

    <div class="mid-bar">
        <label>Request:</label>
        <select id="requestSelect" onchange="onSelectionChange()" style="max-width: 240px;" disabled>
            <optgroup label="Library & Metadata">
                <option value="getCategoryList" selected>getCategoryList</option>
                <option value="getFieldList">getFieldList</option>
                <option value="getAttributeList">getAttributeList</option>
                <option value="getSongList">getSongList</option>
                <option value="getElements">getElements (Query Brani)</option>
                <option value="publishMetadata">publishMetadata</option>
            </optgroup>
            <optgroup label="Scheduling & Clocks">
                <option value="getAssignedClocks">getAssignedClocks</option>
                <option value="getClockList">getClockList</option>
                <option value="getSchedule">getSchedule</option>
                <option value="publishSchedule">publishSchedule</option>
                <option value="getReplacementSongs">getReplacementSongs</option>
            </optgroup>
            <optgroup label="General">
                <option value="ping">ping</option>
                <option value="getSetup">getSetup</option>
            </optgroup>
        </select>

        <button class="btn" id="sendBtn" onclick="sendCurrentRequest()" disabled>Send Request</button>
        <span class="timer" id="elapsedTime"></span>

        <div style="margin-left: auto; display: flex; align-items: center; gap: 6px; min-width: 320px;">
            <label>Station:</label>
            <select id="stationSelect" onchange="onSelectionChange()" disabled>
                <option value="Enterprise">Enterprise</option>
                <option value="105 DAB">105 DAB</option>
                <option value="Mediaset_DBEmptyGSEL">Mediaset_DBEmptyGSEL</option>
                <option value="VIRGIN_651_-_CLASSIC_ROCK">VIRGIN_651_-_CLASSIC_ROCK</option>
                <option value="RMC_601_Hits">RMC_601_Hits</option>
                <option value="UM_037_-_HITS">UM_037_-_HITS</option>
                <option value="NuovoDB">NuovoDB</option>
                <option value="ZenonMedia" selected>ZenonMedia</option>
            </select>
            <button class="btn" id="addStBtn" onclick="addCustomStation()" title="Aggiungi un nuovo canale" disabled>+</button>
        </div>
    </div>

    <textarea id="xmlEditor" spellcheck="false"></textarea>

    <div class="tabs">
        <div class="tab active" id="tabXml" onclick="switchTab('xml')">Reply (XML View)</div>
        <div class="tab" id="tabGrid" onclick="switchTab('grid')">Reply (Grid View)</div>
    </div>
    <div class="reply-box">
        <pre id="xmlReply">Premi "Connect" in alto a destra per iniziare...</pre>
        <div id="gridReply" style="display:none;"></div>
    </div>
</div>

<script>
    let isConnected = false;

    function bgrIntToHex(bgrInt) {
        if (!bgrInt || isNaN(bgrInt)) return null;
        const n = parseInt(bgrInt, 10);
        const r = (n & 0xFF);
        const g = ((n >> 8) & 0xFF);
        const b = ((n >> 16) & 0xFF);
        return "#" + [r, g, b].map(x => x.toString(16).padStart(2, '0')).join('');
    }

    async function callNexus(xmlPayload) {
        const server = document.getElementById('serverInput').value.trim();
        const ssl = document.getElementById('sslCheck').checked;
        const protocol = ssl ? 'https://' : 'http://';
        const targetUrl = server.startsWith('http') ? server : protocol + server;

        const t0 = performance.now();
        const res = await fetch('/proxy', {
            method: 'POST',
            headers: { 'Content-Type': 'text/xml; charset=utf-8', 'X-Target-Url': targetUrl },
            body: xmlPayload
        });
        const text = await res.text();
        const secs = ((performance.now() - t0) / 1000).toFixed(3).replace('.', ',');
        document.getElementById('elapsedTime').textContent = `${secs} secs`;
        return { ok: res.ok, xml: text };
    }

    async function toggleConnect() {
        const btn = document.getElementById('connectBtn');
        const stationSel = document.getElementById('stationSelect');
        const reqSel = document.getElementById('requestSelect');
        const sendBtn = document.getElementById('sendBtn');
        const addStBtn = document.getElementById('addStBtn');

        if (isConnected) {
            isConnected = false;
            btn.textContent = "Connect";
            document.getElementById('serverInput').disabled = false;
            stationSel.disabled = true;
            reqSel.disabled = true;
            sendBtn.disabled = true;
            addStBtn.disabled = true;
            document.getElementById('connStatus').innerHTML = '<span class="status-dot"></span>Disconnesso';
            return;
        }

        btn.textContent = "Connecting...";
        buildXmlTemplate();

        try {
            const xmlToSend = document.getElementById('xmlEditor').value;
            const result = await callNexus(xmlToSend);
            document.getElementById('xmlReply').textContent = result.xml;
            renderGrid(result.xml);

            isConnected = true;
            btn.textContent = "Disconnect";
            document.getElementById('serverInput').disabled = true;
            stationSel.disabled = false;
            reqSel.disabled = false;
            sendBtn.disabled = false;
            addStBtn.disabled = false;
            document.getElementById('connStatus').innerHTML = '<span class="status-dot connected"></span>Connesso a ' + document.getElementById('serverInput').value;
        } catch (err) {
            btn.textContent = "Connect";
            document.getElementById('xmlReply').textContent = "Errore di connessione a Nexus:\n" + err.message;
        }
    }

    function onSelectionChange() {
        buildXmlTemplate();
        if (isConnected) {
            sendCurrentRequest();
        }
    }

    function addCustomStation() {
        const name = prompt("Inserisci il nome esatto della Station / Database (case-sensitive):");
        if (name && name.trim()) {
            const sel = document.getElementById('stationSelect');
            const opt = document.createElement('option');
            opt.value = name.trim();
            opt.textContent = name.trim();
            sel.appendChild(opt);
            sel.value = name.trim();
            onSelectionChange();
        }
    }

    function buildXmlTemplate() {
        const cmd = document.getElementById('requestSelect').value;
        const station = document.getElementById('stationSelect').value || "ZenonMedia";
        const client = document.getElementById('clientInput').value || "NexusTest 1.5";
        const today = new Date().toISOString().split('T')[0];

        let stationAttr = (cmd === "ping") ? "" : ` station="${station}"`;

        let inner = "";
        switch (cmd) {
            case "getAttributeList":
                inner = `\n    <contents>\n        <fields>\n            <field id="101"/>\n        </fields>\n    </contents>\n`;
                break;
            case "getAssignedClocks":
                inner = `\n    <contents>\n        <assignments>\n            <assignment time="${today}T00:00:00"/>\n            <assignment time="${today}T01:00:00"/>\n            <assignment time="${today}T02:00:00"/>\n        </assignments>\n    </contents>\n`;
                break;
            case "getSchedule":
                inner = `\n    <contents>\n        <startTime>${today}T00:00:00</startTime>\n        <endTime>${today}T23:59:59</endTime>\n        <fields>\n            <field name="Artist"/>\n            <field name="Title"/>\n        </fields>\n    </contents>\n`;
                break;
            case "getElements":
                inner = `\n    <contents>\n        <query>\n            <filters>\n                <filter type="field" target="Artist" operator="contains" value="a"/>\n            </filters>\n            <fields>\n                <field name="Artist"/>\n                <field name="Title"/>\n                <field name="Category"/>\n                <field name="Runtime"/>\n            </fields>\n        </query>\n    </contents>\n`;
                break;
            case "getReplacementSongs":
                inner = `\n    <contents>\n        <LogElementID>1</LogElementID>\n        <GoalList>1</GoalList>\n        <MaxElements>10</MaxElements>\n    </contents>\n`;
                break;
        }

        const xml = `<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n` +
                    `<mmRequest command="${cmd}"${stationAttr} client="${client}" userData="testing">` +
                    `${inner}</mmRequest>`;

        document.getElementById('xmlEditor').value = xml;
    }

    async function sendCurrentRequest() {
        const xml = document.getElementById('xmlEditor').value;
        document.getElementById('xmlReply').textContent = "Invio richiesta in corso...";
        try {
            const res = await callNexus(xml);
            document.getElementById('xmlReply').textContent = res.xml;
            renderGrid(res.xml);
        } catch (err) {
            document.getElementById('xmlReply').textContent = "ERRORE HTTP:\n" + err.message;
        }
    }

    function renderGrid(xmlString) {
        const container = document.getElementById('gridReply');
        const parser = new DOMParser();
        const doc = parser.parseFromString(xmlString, "text/xml");

        const parserError = doc.querySelector("parsererror");
        if (parserError) {
            container.innerHTML = `<p style="color:#c0392b; font-weight:bold;">Risposta non XML o errore di sintassi:<br></p><pre>${xmlString.replace(/</g,'&lt;')}</pre>`;
            return;
        }

        const errors = doc.querySelector("errors");
        if (errors) {
            container.innerHTML = `<p style="color:#c0392b; font-weight:bold;">Errore restituito da Nexus: ${errors.textContent.trim()}</p><pre>${xmlString.replace(/</g,'&lt;')}</pre>`;
            return;
        }

        const contents = doc.querySelector("contents");
        if (!contents || contents.children.length === 0) {
            container.innerHTML = `<p style='color:#666;'>Risposta XML ricevuta (nessuna tabella in &lt;contents&gt;):</p><pre>${xmlString.replace(/</g,'&lt;')}</pre>`;
            return;
        }

        let rows = Array.from(contents.children);
        while (rows.length === 1 && rows[0].children.length > 0 && rows[0].attributes.length === 0) {
            rows = Array.from(rows[0].children);
        }

        let cols = new Set();
        rows.forEach(r => {
            Array.from(r.attributes).forEach(a => cols.add("@" + a.name));
            Array.from(r.children).forEach(c => cols.add(c.tagName + (c.getAttribute("name") ? ":" + c.getAttribute("name") : "")));
            if (r.children.length === 0 && r.textContent.trim()) cols.add("Valore");
        });

        const colList = Array.from(cols);
        let html = "<table><thead><tr><th>Elemento</th>" + colList.map(c => `<th>${c.replace('@','')}</th>`).join("") + "</tr></thead><tbody>";

        rows.forEach(r => {
            html += `<tr><td><b>${r.tagName}</b></td>`;
            const backHex = bgrIntToHex(r.getAttribute("backcolor"));
            const foreHex = bgrIntToHex(r.getAttribute("forecolor")) || "#000";

            colList.forEach(col => {
                let val = "";
                if (col.startsWith("@")) {
                    const attrName = col.substring(1);
                    val = r.getAttribute(attrName) || "";
                    if (attrName === "code" && backHex) {
                        val = `<span class="color-swatch" style="background:${backHex}; color:${foreHex};">${val}</span>`;
                    }
                } else if (col === "Valore") {
                    val = r.textContent.trim();
                } else {
                    const [tag, attrName] = col.split(":");
                    const child = Array.from(r.children).find(c => c.tagName === tag && (!attrName || c.getAttribute("name") === attrName));
                    if (child) val = child.textContent.trim() || child.getAttribute("value") || "";
                }
                html += `<td>${val}</td>`;
            });
            html += "</tr>";
        });
        html += "</tbody></table>";
        container.innerHTML = html;
    }

    function switchTab(mode) {
        document.getElementById('tabXml').classList.toggle('active', mode === 'xml');
        document.getElementById('tabGrid').classList.toggle('active', mode === 'grid');
        document.getElementById('xmlReply').style.display = mode === 'xml' ? 'block' : 'none';
        document.getElementById('gridReply').style.display = mode === 'grid' ? 'block' : 'none';
    }

    buildXmlTemplate();
</script>
</body>
</html>
'@;

$listener = New-Object System.Net.HttpListener;
$listener.Prefixes.Add("http://localhost:$port/");
$listener.Start();
Start-Process "http://localhost:$port/";
Write-Host "Server Web 2.2 attivo su http://localhost:$port/ - Lascia aperta questa finestra." -ForegroundColor Green;

while ($listener.IsListening) {
    $ctx =$listener.GetContext();
    $req =$ctx.Request;
    $res =$ctx.Response;
    $res.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate");

    if ($req.HttpMethod -eq 'GET') {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($html);
        $res.ContentType = 'text/html; charset=utf-8';$res.OutputStream.Write($bytes, 0,$bytes.Length);
    } elseif ($req.HttpMethod -eq 'POST' -and$req.Url.LocalPath -eq '/proxy') {
        $reader = New-Object System.IO.StreamReader($req.InputStream, [System.Text.Encoding]::UTF8);
        $xmlBody =$reader.ReadToEnd();
        $target =$req.Headers['X-Target-Url'];
        if (-not $target) {$target = 'http://localhost:8080' };

        try {
            $wc = New-Object System.Net.WebClient;
            $wc.Encoding = [System.Text.Encoding]::UTF8;
            $wc.Headers.Add('Content-Type', 'text/xml; charset=utf-8');
            $reply =$wc.UploadString($target, 'POST',$xmlBody);
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($reply);
            $res.StatusCode = 200; } catch {$bytes = [System.Text.Encoding]::UTF8.GetBytes("Errore da Nexus: " + $_.Exception.Message);$res.StatusCode = 500;
        };
        $res.ContentType = 'text/xml; charset=utf-8';$res.OutputStream.Write($bytes, 0,$bytes.Length);
    };
    $res.Close();
}