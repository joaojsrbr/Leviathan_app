abstract interface class Service {
  Future<void> init();
  Future<T> load<T>(String key, T defaultValue, {dynamic Function(T data)? print, bool debug = true});
  Future<void> save<T>(String key, T value, [bool log = true]);
}
