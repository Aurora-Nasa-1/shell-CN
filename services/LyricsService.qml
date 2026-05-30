pragma Singleton

import "../utils/scripts/lrcparser.js" as Lrc
import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import Caelestia.Config
import qs.utils

Singleton {
    id: root

    property var player: Players.active
    property int currentIndex: -1
    property bool loading: false
    property bool isManualSeeking: false
    property bool lyricsVisible: GlobalConfig.services.showLyrics
    property string backend: "Local"
    property string preferredBackend: GlobalConfig.services.lyricsBackend
    property bool showTranslation: GlobalConfig.services.lyricsShowTranslation ?? false
    property real currentSongId: 0
    property string loadedLocalFile: ""
    property real offset
    property int currentRequestId: 0
    property var lyricsMap: ({})
    // Stores parsed translation lyrics for NetEase source (used when showTranslation is enabled)
    property var _translationLyrics: []

    property real fontSize: 12.0
    property int updateInterval: 500
    property string fontFamily: ""
    property string animType: "fade"
    property int animDuration: 300
    property string animExitType: "fade"
    property int animExitDuration: 200

    readonly property string lyricsDir: Paths.absolutePath(GlobalConfig.paths.lyricsDir)
    readonly property string settingsFile: lyricsDir + "/settings.json"

    function saveSettings() {
        let obj = {
            fontSize: root.fontSize,
            updateInterval: root.updateInterval,
            fontFamily: root.fontFamily,
            animType: root.animType,
            animDuration: root.animDuration,
            animExitType: root.animExitType,
            animExitDuration: root.animExitDuration,
            showTranslation: root.showTranslation
        };
        saveSettingsProc.command = ["sh", "-c", `mkdir -p "${root.lyricsDir}" && echo '${JSON.stringify(obj)}' > "${root.settingsFile}"`];
        saveSettingsProc.running = true;
    }
    readonly property string lyricsMapFile: lyricsDir + "/lyrics_map.json"
    readonly property alias model: lyricsModel
    readonly property alias candidatesModel: fetchedCandidatesModel
    readonly property var _netEaseHeaders: ({
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0",
            "Referer": "https://music.163.com/"
        })

    function _refreshTranslationDisplay() {
        // When showTranslation toggles and we have cached translation data,
        // swap the model content without re-fetching
        if (root.backend !== "NetEase" || lyricsModel.count === 0)
            return;

        const meta = getMetadata();
        if (!meta) return;

        if (root.showTranslation && root._translationLyrics.length > 0) {
            // Switch to translation
            updateModel(root._translationLyrics);
        } else if (!root.showTranslation) {
            // Switch back to original - re-fetch to get original lyrics
            let key = _metaKey(meta);
            let saved = root.lyricsMap[key];
            if (saved?.neteaseId) {
                fetchNetEaseLyrics(saved.neteaseId, root.currentRequestId);
            } else {
                loadLyrics();
            }
        }
    }

    function getMetadata() {
        if (!player || !player.metadata)
            return null;
        let artist = player.metadata["xesam:artist"];
        const title = player.metadata["xesam:title"];
        if (Array.isArray(artist))
            artist = artist.join(", ");
        return {
            artist: artist || "Unknown",
            title: title || "Unknown"
        };
    }

    function _metaKey(meta) {
        return `${meta.artist} - ${meta.title}`;
    }

    function savePrefs() {
        let meta = getMetadata();
        if (!meta)
            return;
        let key = _metaKey(meta);
        let existing = root.lyricsMap[key] ?? {};
        root.lyricsMap[key] = {
            offset: root.offset,
            backend: root.backend,
            neteaseId: existing.neteaseId ?? null
        };
        // reassign to notify QML bindings of the map change
        root.lyricsMap = root.lyricsMap;
        saveLyricsMap.command = ["sh", "-c", `mkdir -p "${root.lyricsDir}" && echo '${JSON.stringify(root.lyricsMap).replace(/'/g, "'\\''")}' > "${root.lyricsMapFile}"`];
        saveLyricsMap.running = true;
    }

    function toggleVisibility() {
        GlobalConfig.services.showLyrics = !GlobalConfig.services.showLyrics;
    }

    function loadLyrics() {
        loadDebounce.restart();
    }

    function _doLoadLyrics() {
        const meta = getMetadata();
        if (!meta) {
            lyricsModel.clear();
            root.currentIndex = -1;
            return;
        }

        loading = true;
        lyricsModel.clear();
        currentIndex = -1;
        root.currentSongId = 0;

        root.currentRequestId++;
        let requestId = root.currentRequestId;

        let key = _metaKey(meta);
        let saved = root.lyricsMap[key];
        root.offset = saved?.offset ?? 0.0;

        // Try to get lyrics directly from MPRIS metadata if supported by the player
        if (player && player.metadata) {
            let mprisLyrics = player.metadata["xesam:lyrics"] || player.metadata["lyric"] || player.metadata["lyrics"];
            if (mprisLyrics && typeof mprisLyrics === "string" && mprisLyrics.trim().length > 0) {
                root.backend = "MPRIS";
                let parsed = Lrc.parseLrc(mprisLyrics);
                if (parsed.length > 0) {
                    updateModel(parsed);
                    loading = false;
                    return;
                }
            }
        }

        if (root.preferredBackend === "NetEase") {
            root.backend = "NetEase";
            fetchNetEase(meta.title, meta.artist, requestId);
            return;
        }

        if (root.preferredBackend === "Local") {
            root.backend = "Local";
            let cleanDir = lyricsDir.replace(/\/$/, "");
            let flatPath = `${cleanDir}/${meta.artist} - ${meta.title}.lrc`;

            // Search for files matching "Artist - Title.lrc" pattern
            const artistStr = Array.isArray(meta.artist) ? meta.artist.join(", ") : String(meta.artist || "");
            const titleStr = Array.isArray(meta.title) ? meta.title.join(", ") : String(meta.title || "");
            const escapedTitle = titleStr.replace(/'/g, "'\\''");
            const escapedArtist = artistStr.replace(/'/g, "'\\''");
            findLyricsInSubdirs.command = ["sh", "-c", `find "${cleanDir}" -type f -iname "*${escapedArtist}*${escapedTitle}*.lrc" | head -n 1`];
            findLyricsInSubdirs.requestId = requestId;
            findLyricsInSubdirs.running = true;

            lrcFile.path = "";
            lrcFile.path = flatPath;
            return;
        }

        // Auto mode: try local first
        root.backend = "Local";
        let cleanDir = lyricsDir.replace(/\/$/, "");
        let flatPath = `${cleanDir}/${meta.artist} - ${meta.title}.lrc`;

        const artistStr = Array.isArray(meta.artist) ? meta.artist.join(", ") : String(meta.artist || "");
        const titleStr = Array.isArray(meta.title) ? meta.title.join(", ") : String(meta.title || "");
        const escapedTitle = titleStr.replace(/'/g, "'\\''");
        const escapedArtist = artistStr.replace(/'/g, "'\\''");
        findLyricsInSubdirs.command = ["sh", "-c", `find "${cleanDir}" -type f -iname "*${escapedArtist}*${escapedTitle}*.lrc" | head -n 1`];
        findLyricsInSubdirs.requestId = requestId;
        findLyricsInSubdirs.running = true;

        lrcFile.path = "";
        lrcFile.path = flatPath;
        fetchNetEaseCandidates(meta.title, meta.artist, requestId);
    }

    function updateModel(parsedArray) {
        root.currentIndex = -1;
        lyricsModel.clear();
        for (let line of parsedArray) {
            lyricsModel.append({
                time: line.time,
                lyricLine: line.text
            });
        }
    }

    function fallbackToOnline() {
        let meta = getMetadata();
        if (!meta)
            return;
        fetchNetEase(meta.title, meta.artist, root.currentRequestId);
    }

    // NetEase

    // searches NetEase and populates the candidates model. returns the result array via the onResults callback
    function _searchNetEase(title, artist, reqId, onResults) {
        Requests.resetCookies();
        const query = encodeURIComponent(`${title} ${artist}`);
        const url = `https://music.163.com/api/search/get?s=${query}&type=1&limit=5`;

        Requests.get(url, text => {
            if (reqId !== root.currentRequestId)
                return;
            const res = JSON.parse(text);
            const songs = res.result?.songs || [];

            fetchedCandidatesModel.clear();
            for (let s of songs) {
                fetchedCandidatesModel.append({
                    id: s.id,
                    title: s.name || "Unknown Title",
                    artist: s.artists?.map(a => a.name).join(", ") || "Unknown Artist"
                });
            }

            onResults(songs);
        }, err => {}, root._netEaseHeaders);
    }

    // populates the candidates model only. used when a saved NetEase ID already exists and we just want to refresh the picker list.
    function fetchNetEaseCandidates(title, artist, reqId) {
        _searchNetEase(title, artist, reqId, _songs => {});
    }

    // searches NetEase, populates candidates, then auto-selects the best match and fetches its lyrics.
    function fetchNetEase(title, artist, reqId) {
        _searchNetEase(title, artist, reqId, songs => {
            const bestMatch = songs.find(s => {
                const inputArtist = String(artist || "").toLowerCase();
                const sArtist = String(s.artists?.[0]?.name || "").toLowerCase();
                return inputArtist.includes(sArtist) || sArtist.includes(inputArtist);
            });

            if (!bestMatch) {
                return; // No reliable lyrics found
            }

            let key = `${artist} - ${title}`;
            root.lyricsMap[key] = {
                offset: root.lyricsMap[key]?.offset ?? 0.0,
                backend: "NetEase",
                neteaseId: bestMatch.id
            };
            root.currentSongId = bestMatch.id;
            savePrefs();
            fetchNetEaseLyrics(bestMatch.id, reqId);
        });
    }

    function fetchNetEaseLyrics(id, reqId) {
        // Always fetch translation (tv=1) so we have it available when toggled
        const url = `https://music.163.com/api/song/lyric?id=${id}&lv=1&kv=1&tv=1`;
        Requests.get(url, text => {
            if (reqId !== root.currentRequestId)
                return;
            const res = JSON.parse(text);

            // Parse original lyrics
            const originalLyrics = res.lrc?.lyric ? Lrc.parseLrc(res.lrc.lyric) : [];

            // Parse translated lyrics if available
            root._translationLyrics = res.tlyric?.lyric ? Lrc.parseLrc(res.tlyric.lyric) : [];

            if (originalLyrics.length > 0) {
                if (root.showTranslation && root._translationLyrics.length > 0) {
                    // Show translation only
                    updateModel(root._translationLyrics);
                } else {
                    // Show original lyrics
                    updateModel(originalLyrics);
                }
                loading = false;
            } else if (root._translationLyrics.length > 0) {
                // No original but has translation - use translation
                updateModel(root._translationLyrics);
                loading = false;
            } else {
                loading = false;
            }
        });
    }

    function selectCandidate(songId) {
        let meta = getMetadata();
        if (!meta)
            return;
        root.backend = "NetEase";
        root.currentSongId = songId;
        let key = _metaKey(meta);
        root.lyricsMap[key] = {
            offset: root.lyricsMap[key]?.offset ?? 0.0,
            neteaseId: songId
        };
        savePrefs();
        fetchNetEaseLyrics(songId, currentRequestId);
    }

    function updatePosition() {
        if (isManualSeeking || loading || !player || lyricsModel.count === 0)
            return;

        let pos = player.position - root.offset;
        let newIdx = -1;
        for (let i = lyricsModel.count - 1; i >= 0; i--) {
            if (pos >= lyricsModel.get(i).time - 0.1) { // 100ms fudge factor
                newIdx = i;
                break;
            }
        }

        if (newIdx !== currentIndex) {
            root.currentIndex = newIdx;
        }
    }

    function jumpTo(index, time) {
        root.isManualSeeking = true;
        root.currentIndex = index;

        if (player) {
            player.position = time + root.offset + 0.01; // compensate for rounding
        }

        seekTimer.restart();
    }

    onPreferredBackendChanged: {
        if (GlobalConfig.services.lyricsBackend !== preferredBackend) {
            GlobalConfig.services.lyricsBackend = preferredBackend;
        }
    }

    onShowTranslationChanged: {
        _refreshTranslationDisplay();
    }

    ListModel {
        id: lyricsModel
    }

    ListModel {
        id: fetchedCandidatesModel
    }

    Timer {
        id: seekTimer

        interval: 500
        onTriggered: root.isManualSeeking = false
    }

    // If no local lyrics were loaded within the interval, fall back to NetEase
    Timer {
        id: fallbackTimer

        interval: 200
        onTriggered: {
            if (lyricsModel.count === 0) {
                root.backend = "NetEase";
                fallbackToOnline();
            }
        }
    }

    Timer {
        id: loadDebounce

        interval: 50
        onTriggered: root._doLoadLyrics()
    }

    FileView {
        id: settingsFileView

        path: root.settingsFile
        printErrors: false
        onLoaded: {
            try {
                let obj = JSON.parse(text());
                if (obj.fontSize !== undefined) root.fontSize = obj.fontSize;
                if (obj.updateInterval !== undefined) root.updateInterval = obj.updateInterval;
                if (obj.fontFamily !== undefined) root.fontFamily = obj.fontFamily;
                if (obj.animType !== undefined) root.animType = obj.animType;
                if (obj.animDuration !== undefined) root.animDuration = obj.animDuration;
                if (obj.animExitType !== undefined) root.animExitType = obj.animExitType;
                if (obj.animExitDuration !== undefined) root.animExitDuration = obj.animExitDuration;
                if (obj.showTranslation !== undefined) root.showTranslation = obj.showTranslation;
            } catch (e) {}
        }
    }



    FileView {
        id: lyricsMapFileView

        path: root.lyricsMapFile
        printErrors: false
        onLoaded: {
            try {
                root.lyricsMap = JSON.parse(text());
            } catch (e) {
                root.lyricsMap = {};
            }
        }
    }

    FileView {
        id: lrcFile

        printErrors: false
        onLoaded: {
            fallbackTimer.stop();
            let parsed = Lrc.parseLrc(text());
            if (parsed.length > 0) {
                root.backend = "Local";
                root.loadedLocalFile = path;
                updateModel(parsed);
                loading = false;
            } else if (root.preferredBackend === "Local") {
                // Local mode only - fail immediately
                root.backend = "NetEase";
                fallbackToOnline();
            }
            // In Auto mode, let the Process onExited handle fallback
        }
    }

    Connections {
        function onActiveChanged() {
            root.player = Players.active;
            loadLyrics();
        }

        target: Players
    }

    Connections {
        function onMetadataChanged() {
            loadLyrics();
        }

        target: root.player
        ignoreUnknownSignals: true
    }

    Process {
        id: saveLyricsMap
        command: ["sh", "-c", `mkdir -p "${root.lyricsDir}" && echo '${JSON.stringify(root.lyricsMap)}' > "${root.lyricsMapFile}"`]
    }

    Process {
        id: saveSettingsProc
    }

    Process {
        id: findLyricsInSubdirs

        property int requestId: -1
        property bool foundFile: false

        stdout: SplitParser {
            onRead: data => {
                if (findLyricsInSubdirs.requestId === root.currentRequestId) {
                    const foundPath = data.trim();
                    if (foundPath && foundPath.length > 0) {
                        findLyricsInSubdirs.foundFile = true;
                        fallbackTimer.stop();
                        root.loadedLocalFile = foundPath;
                        lrcFile.path = "";
                        lrcFile.path = foundPath;
                    }
                }
            }
        }

        onExited: (exitCode, exitStatus) => { // qmllint disable signal-handler-parameters
            if (requestId === root.currentRequestId && !foundFile && root.preferredBackend === "Auto") {
                if (lyricsModel.count === 0) {
                    fallbackTimer.restart();
                }
            }
            foundFile = false;
        }
    }
}
