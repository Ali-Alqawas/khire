class AppDateUtils {
  static DateTime now() => DateTime.now();

  static int timestamp() => DateTime.now().millisecondsSinceEpoch;

  static DateTime fromTimestamp(int timestamp) =>
      DateTime.fromMillisecondsSinceEpoch(timestamp);

  static String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
