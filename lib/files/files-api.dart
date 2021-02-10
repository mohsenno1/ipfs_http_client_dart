import 'package:ipfs_http_client_dart/ipfs-client.dart';
import 'package:ipfs_http_client_dart/models/cid.dart';
import 'package:ipfs_http_client_dart/models/unix-fs-entry.dart';

class FilesApi {
  IpfsClient _client;

  FilesApi(IpfsClient client) {
    _client = client;
  }

  Future<List<UnixFSEntry>> ls(String path) async {
    var data = await _client.httpPost(CID.isCID(path) ? 'ls/$path' : path);
    if (data is String) throw Exception(data);
    var res = new List<UnixFSEntry>();
    if (data != null && data['Objects'] != null) {
      var links = (data['Objects'] as List)[0]["Links"] as List;

      links.forEach((element) {
        res.add(UnixFSEntry.fromJson(element));
      });
    }

    return res;
  }
}
