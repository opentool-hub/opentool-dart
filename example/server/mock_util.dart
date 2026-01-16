class MockUtil {
  List<String> storage = ["Hello", "World"];

  int count() {
    return storage.length;
  }

  int create(String text) {
    storage.add(text);
    return storage.length - 1;
  }

  String read(int id) {
    return storage[id];
  }

  Future<void> sequentiallyRead(void Function(String data) onData) async {
    for (final data in storage) {
      onData(data);
      await Future<void>.delayed(const Duration(milliseconds: 2000));
    }
  }

  void update(int id, String text) {
    storage[id] = text;
  }

  void delete(int id) {
    storage.removeAt(id);
  }

  void run() {
    throw Exception("A fatal error to break this tool.");
  }
}
