extension CapitalizeExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return split(" ")
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(" ");
  }
}
