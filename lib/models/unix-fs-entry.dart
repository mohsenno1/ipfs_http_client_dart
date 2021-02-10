class UnixFSEntry {
  String name;
  String path;
  String cid;
  int size;
  int type;
  String target;
  dynamic content;
  int mode;
  int mtime;

  static UnixFSEntry fromJson(x) {
    if (x == null) return null;
    var res = new UnixFSEntry();
    res.name = x['Name'];
    res.path = x['Path'];
    res.cid = x['Hash'];
    if (x['Size'] is int)
      res.size = x['Size'] as int;
    else
      res.size = int.parse(x['Size']);
    res.type = x['Type'];
    res.target = x['Target'];
    res.content = x['Content'];
    res.mode = x['Mode'];
    res.mtime = x['Mtime'];

    return res;
  }
}
