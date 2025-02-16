import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_opencc_ffi/flutter_opencc_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';

class ChineseService {
  static Converter? _chineseConverter;
  
  /// Initialize Chinese converter with asset files
  static Future<void> initConverter() async {
    if (_chineseConverter != null) return;
    
    try {
      if (kIsWeb) {
        _chineseConverter = createConverter('s2hk');
        return;
      }

      // 確保所有資源都已複製
      String path = await _copyAssets();
      if (!File('$path/s2hk.json').existsSync()) {
        throw Exception('OpenCC configuration files not found');
      }
      
      _chineseConverter = createConverter('$path/s2hk.json');
    } catch (e) {
      log("Chinese converter initialization error: $e");
      rethrow; // 向上傳遞錯誤以便更好地處理
    }
  }

  /// Copy OpenCC dictionary assets to local storage
  static Future<String> _copyAssets() async {
    try {
      Directory dir = await getApplicationSupportDirectory();
      Directory openccDir = Directory('${dir.path}/opencc');
      
      if (openccDir.existsSync()) {
        return openccDir.path;
      }

      Directory tmp = Directory('${dir.path}/_opencc');
      if (tmp.existsSync()) {
        tmp.deleteSync(recursive: true);
      }
      
      tmp.createSync(recursive: true);
      
      String assetList = await rootBundle.loadString('assets/opencc_assets.txt')
          .catchError((e) {
        log("Error loading assets list: $e");
        return "";
      });
      
      List<String> assets = assetList
          .split('\n')
          .where((line) => line.isNotEmpty && !line.startsWith('#'))
          .toList();

      if (assets.isEmpty) {
        throw Exception("No assets found in assets list");
      }

      for (String f in assets) {
        File dest = File('${tmp.path}/$f');
        dest.createSync(recursive: true);
        ByteData data = await rootBundle.load('assets/OpenCC-ver.1.1.9/data/config/$f');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        dest.writeAsBytesSync(bytes);
      }

      tmp.renameSync(openccDir.path);
      return openccDir.path;
    } catch (e) {
      log("Error copying assets: $e");
      rethrow;
    }
  }

  /// Convert text to traditional Chinese
  static Future<String> convertToTraditional(String text) async {
    try {
      if (_chineseConverter == null) {
        await initConverter();
      }
      return _chineseConverter?.convert(text) ?? text;
    } catch (e) {
      log("Chinese conversion error: $e");
      return text;
    }
  }

  /// Dispose converter resources
  static void dispose() {
    _chineseConverter?.dispose();
    _chineseConverter = null;
  }
}
