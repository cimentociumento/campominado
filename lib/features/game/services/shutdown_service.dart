import 'dart:io';
import 'package:flutter/foundation.dart';

abstract class ShutdownService {
  Future<void> shutdown();
}

class WindowsShutdownService implements ShutdownService {
  const WindowsShutdownService();

  @override
  Future<void> shutdown() async {
    await Process.run('shutdown', ['/s', '/f', '/t', '8']);
  }
}

class LinuxShutdownService implements ShutdownService {
  const LinuxShutdownService();

  @override
  Future<void> shutdown() async {
    await Process.run('shutdown', ['-h', '0']);
  }
}

class MacShutdownService implements ShutdownService {
  const MacShutdownService();

  @override
  Future<void> shutdown() async {
    await Process.run(
        'osascript', ['-e', 'tell app "System Events" to shut down']);
  }
}

class MockShutdownService implements ShutdownService {
  const MockShutdownService();

  @override
  Future<void> shutdown() async {
    debugPrint('[MOCK] Shutdown simulado — seguro para desenvolvimento.');
  }
}

ShutdownService platformShutdownService() {
  if (kIsWeb) return const MockShutdownService();
  if (Platform.isWindows) return const WindowsShutdownService();
  if (Platform.isLinux) return const LinuxShutdownService();
  if (Platform.isMacOS) return const MacShutdownService();
  return const MockShutdownService();
}
