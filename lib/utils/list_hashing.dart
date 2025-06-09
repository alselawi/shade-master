int listHash(List list) {
  int hash = 17; // Prime number seed

  for (int i = 0; i < list.length; i++) {
    var element = list[i];
    int elementHash;

    if (element is List) {
      elementHash = listHash(element); // Recursive call for nested lists
    } else {
      elementHash = element.hashCode;
    }

    // Combine element hash with position
    hash = 31 * hash + elementHash;
    hash = 31 * hash + i; // Position matters
  }

  return hash;
}
