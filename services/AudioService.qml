import QtQuick
import Quickshell.Services.Pipewire
pragma Singleton

QtObject {
    /* keep the default sink alive and updated
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
      } */

    id: root

    // ── OUTPUT ──────────────────────────
    readonly property var _keepSinkAlive: Pipewire.defaultAudioSink
    readonly property var _keepSourceAlive: Pipewire.defaultAudioSource
    readonly property var outputNode: Pipewire.defaultAudioSink
    readonly property real outputVolume: outputNode && outputNode.audio ? outputNode.audio.volume : 0
    readonly property bool outputMuted: outputNode && outputNode.audio ? outputNode.audio.muted : false
    readonly property string outputName: outputNode ? outputNode.description : "No output"
    // ── INPUT ───────────────────────────
    readonly property var inputNode: Pipewire.defaultAudioSource
    readonly property real inputVolume: inputNode && inputNode.audio ? inputNode.audio.volume : 0
    readonly property bool inputMuted: inputNode && inputNode.audio ? inputNode.audio.muted : false
    readonly property string inputName: inputNode ? inputNode.description : "No input"
    // ── DEVICE LISTS ────────────────────
    // output devices — hardware sinks only, not app streams
    readonly property var outputDevices: {
        let nodes = Pipewire.nodes.values; // explicit reference makes it reactive
        return nodes.filter((n) => {
            return n.isSink && !n.isStream && n.audio;
        });
    }
    // input devices — hardware sources only, no monitors
    readonly property var inputDevices: {
        let nodes = Pipewire.nodes.values;
        return nodes.filter((n) => {
            return !n.isSink && !n.isStream && n.audio;
        });
    }

    // ── FUNCTIONS ───────────────────────
    function setOutputVolume(v) {
        if (outputNode && outputNode.audio)
            outputNode.audio.volume = Math.max(0, Math.min(1, v));

    }

    function setInputVolume(v) {
        if (inputNode && inputNode.audio)
            inputNode.audio.volume = Math.max(0, Math.min(1, v));

    }

    function toggleOutputMute() {
        if (outputNode && outputNode.audio)
            outputNode.audio.muted = !outputNode.audio.muted;

    }

    function toggleInputMute() {
        if (inputNode && inputNode.audio)
            inputNode.audio.muted = !inputNode.audio.muted;

    }

    function setOutputDevice(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setInputDevice(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }

    Component.onCompleted: {
        console.log("all nodes:", JSON.stringify(Pipewire.nodes));
        console.log("default sink:", Pipewire.defaultAudioSink);
        console.log("default source:", Pipewire.defaultAudioSource);
    }
}
