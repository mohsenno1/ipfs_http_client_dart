class FileObject {
  String path;
  dynamic content;
  int mode;
  int mtime;

  Map<String, dynamic> toJson() {
    var res = new Map<String, dynamic>();
    res['path'] = path;
    res['content'] = content;
    res['mode'] = mode;
    res['mtime'] = mtime;
    return res;
  }
}
