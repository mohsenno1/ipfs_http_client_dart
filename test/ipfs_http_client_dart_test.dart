import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:ipfs_http_client_dart/ipfs-client.dart';
import 'package:ipfs_http_client_dart/models/unix-fs-entry.dart';

final ipfs = IpfsClient('http://localhost:5001/api/v0');
//final ipfs = IpfsClient('https://ipfs.infura.io:5001/api/v0');

void main() {
  test('Check the status of ipfs by checking its version', () async {
    var v = await ipfs.version();
    expect(v, isNotNull);
  });

  test('The result of ls function', () async {
    var res =
        await ipfs.files.ls('QmSnuWmxptJZdLJpKRarxBMS2Ju2oANVrgbr2xWbie9b2D');
    expect(res, isNotNull);
    expect(res.length, 6);
  });

  test('Add a file to root and read it back', () async {
    var file = new UnixFSEntry();
    file.content = "ABC";
    var res = await ipfs.add(file);
    expect(res, isNotNull);
    expect(res.cid, isNotNull);

    var fileGetter = ipfs.get(res.cid);
    var gFile = await fileGetter.first;
    var getFileContent = utf8.decode(gFile.content);
    expect(getFileContent, file.content);
  });
}
