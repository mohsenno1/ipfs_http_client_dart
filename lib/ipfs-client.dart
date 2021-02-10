library ipfs_http_client_dart;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ipfs_http_client_dart/files/files-api.dart';
import 'package:archive/archive.dart';

import 'models/cid.dart';
import 'models/unix-fs-entry.dart';

class IpfsClient {
  final JsonDecoder _decoder = new JsonDecoder();
  final JsonEncoder _encoder = new JsonEncoder();
  Map<String, String> _headers = {"Content-Type": "application/json"};
  Uri _baseUri;

  IpfsClient(String address) {
    _baseUri = Uri.parse(address);
  }

  FilesApi _files;
  FilesApi get files {
    if (_files == null) _files = new FilesApi(this);
    return _files;
  }

  Future<String> version() async {
    var res = await httpPost('version');
    return res['Version'];
  }

  Future<String> id() async {
    var res = await httpPost('id');
    return res['ID'];
  }

  Future<UnixFSEntry> add(UnixFSEntry file) async {
    var data = await httpPostMultiPart('add', [file]);
    return UnixFSEntry.fromJson(data);
  }

  Stream<UnixFSEntry> get(String path) async* {
    var data = await httpGet(CID.isCID(path) ? 'get/$path' : path);
    var archive = new TarDecoder().decodeBytes(utf8.encode(data));
    for (var file in archive) {
      var res = UnixFSEntry();
      res.path = file.name;
      res.size = file.size;
      res.content = file.content;
      res.mode = file.mode;
      res.mtime = file.lastModTime;
      yield res;
    }
  }

  Future<dynamic> httpGet(String url) {
    url = _getUrl(url);

    var headers = _headers;

    return http.get(url, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400) {
        throw new Exception(
            "$statusCode: Error while fetching data; ${response.body}");
      }
      if (res == null || res.isEmpty) return null;
      if (res.startsWith("{") || res.startsWith("["))
        return _decoder.convert(res);
      else
        return res;
    });
  }

  Future<dynamic> httpPost(String url, {body, Encoding encoding}) {
    url = _getUrl(url);

    var headers = _headers;

    return http
        .post(url,
            body: _encoder.convert(body), headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400) {
        throw new Exception(
            "$statusCode: Error while fetching data; ${response.body}");
      }

      if (res == null || res.isEmpty) return null;
      if (res.startsWith("{") || res.startsWith("["))
        return _decoder.convert(res);
      else
        return res;
    });
  }

  Future<dynamic> httpPostMultiPart(String url, List<UnixFSEntry> body) {
    url = _getUrl(url);

    var headers = _headers;
    if (body == null || body.length == 0)
      throw Exception('body cannot be empty');

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    body.forEach((element) {
      if (element.content is String)
        request.files.add(
            http.MultipartFile.fromString('file', element.content as String));
    });

    return request.send().then((http.StreamedResponse response) async {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400) {
        throw new Exception(
            "$statusCode: Error while fetching data; ${response.reasonPhrase}");
      }

      final String res = await response.stream.bytesToString();

      if (res == null || res.isEmpty) return null;
      if (res.startsWith("{") || res.startsWith("["))
        return _decoder.convert(res);
      else
        return res;
    });
  }

  String _getUrl(String relativeUrl) {
    if (relativeUrl.startsWith("http")) return relativeUrl;
    String url = _baseUri.toString();
    if (!url.endsWith("/")) url += "/";

    if (relativeUrl.startsWith("/")) relativeUrl = relativeUrl.substring(1);

    return url + relativeUrl;
  }
}
