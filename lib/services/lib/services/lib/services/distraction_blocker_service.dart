abstract class DistractionBlockerService {
  Future<bool> hasBlockingPermission();
  Future<void> requestBlockingPermission();
  Future<void> startBlocking(List<String> blockedAppPackageIds);
  Future<void> stopBlocking();
  Future<bool> isCurrentlyBlocking();
}

class StubDistractionBlockerService implements DistractionBlockerService {
  bool _blocking = false;

  @override
  Future<bool> hasBlockingPermission() async => false;

  @override
  Future<void> requestBlockingPermission() async {}

  @override
  Future<void> startBlocking(List<String> blockedAppPackageIds) async {
    _blocking = true;
  }

  @override
  Future<void> stopBlocking() async {
    _blocking = false;
  }

  @override
  Future<bool> isCurrentlyBlocking() async => _blocking;
}
