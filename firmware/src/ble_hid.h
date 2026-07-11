#pragma once
#include <Arduino.h>

#ifdef ENABLE_BLE_HID

// ====================== BLE HID Module ======================
// Ported from DuckESP. Scope intentionally reduced:
//   - No BLE scanning
//   - No device-name cloning
//   - No onboard WebServer/UI — driven entirely by NRSuite's
//     existing framed bridge protocol (CMD/RESP/EVENT) over USB CDC
//
// Two run modes, matching NRSuite's `ble badble` and `ble keyboard`
// CLI subcommands:
//   - Script mode: one-shot DuckyScript payload, sent as a single
//     BLE_RUN_SCRIPT CMD, executed line-by-line on the ESP32
//   - Realtime mode: Termux streams individual keystrokes as they
//     happen (BLE_KEY_DOWN / BLE_KEY_UP or a single BLE_KEY_EVENT),
//     ESP32 just relays them — no interpreter involved

namespace BleHid {

// Lifecycle
void begin(const String& deviceName);
void end();
bool isConnected();
String peerAddress();

// Script mode (badble)
// Returns number of lines executed; runs synchronously.
int runScript(const String& payload);
void stop(); // aborts a running script / releases all keys
bool isAdvertising();

// Realtime mode (keyboard)
// keyName follows the same token vocabulary as DuckyScript
// (e.g. "A", "ENTER", "GUI"). Modifiers press/release independently
// so callers can implement proper key-up/key-down semantics.
void keyDown(const String& keyName);
void keyUp(const String& keyName);
void releaseAll();
// Shared keymap — exposed in case the transport layer wants to
// validate key names before sending (e.g. reject unknown tokens
// with an error RESP instead of silently dropping them).
uint8_t resolveKey(String keyName);

} // namespace BleHid

#endif // ENABLE_BLE_HID