import QtQuick
import Quickshell.Services.Pipewire

pragma Singleton

Item {
    id: root
    visible: false

    // Keep default audio nodes tracked and bound.
    PwObjectTracker {
        objects: [
            Pipewire.defaultAudioSink,
            Pipewire.defaultAudioSource
        ]
    }

    // ── OUTPUT ──────────────────────────
    readonly property var outputNode: Pipewire.defaultAudioSink
    readonly property real outputVolume:
        outputNode && outputNode.audio ? outputNode.audio.volume : 0
    readonly property bool outputMuted:
        outputNode && outputNode.audio ? outputNode.audio.muted : false
    readonly property string outputName:
        outputNode ? outputNode.description : "No output"

    // ── INPUT ───────────────────────────
    readonly property var inputNode: Pipewire.defaultAudioSource
    readonly property real inputVolume:
        inputNode && inputNode.audio ? inputNode.audio.volume : 0
    readonly property bool inputMuted:
        inputNode && inputNode.audio ? inputNode.audio.muted : false
    readonly property string inputName:
        inputNode ? inputNode.description : "No input"

    // ── DEVICE LISTS ────────────────────
    readonly property var outputDevices: {
        const nodes = Pipewire.nodes.values;
        return nodes.filter(n => n.isSink && !n.isStream && n.audio);
    }

    readonly property var inputDevices: {
        const nodes = Pipewire.nodes.values;
        return nodes.filter(n => !n.isSink && !n.isStream && n.audio);
    }

    // ── VOLUME ──────────────────────────
    function setOutputVolume(v) {
        if (outputNode && outputNode.audio)
            outputNode.audio.volume = Math.max(0, Math.min(1, v));
    }

    function setInputVolume(v) {
        if (inputNode && inputNode.audio)
            inputNode.audio.volume = Math.max(0, Math.min(1, v));
    }

    // ── MUTE ────────────────────────────
    function toggleOutputMute() {
        if (outputNode && outputNode.audio)
            outputNode.audio.muted = !outputNode.audio.muted;
    }

    function toggleInputMute() {
        if (inputNode && inputNode.audio)
            inputNode.audio.muted = !inputNode.audio.muted;
    }

    // ── DEFAULT DEVICES ─────────────────
    function setOutputDevice(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setInputDevice(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }

    Component.onCompleted: {
        console.log("AudioService ready");
        console.log("Output:", outputName);
        console.log("Input:", inputName);
    }
}
