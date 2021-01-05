class CID {
  static bool isCID(String cid) {
    // ToDo: add the correct implementation
    if (cid == null || cid.isEmpty) return false;
    if (cid.contains('/')) return false;
    return true;
  }
}
