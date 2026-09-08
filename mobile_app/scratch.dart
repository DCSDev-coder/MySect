// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final folderPath = r'c:\MySect\mobile_app\lib\mobile_app\files';
  final files = ['corporate_page.dart', 'accounting_page.dart', 'personal_page.dart', 'other_page.dart'];

  final oldBlock = '''                        const Icon(
                          Icons.visibility,
                          size: 16,
                          color: Color(0xFF062AAE),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],''';

  final newBlock = '''                        const Icon(
                          Icons.visibility,
                          size: 16,
                          color: Color(0xFF062AAE),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (progressColor != Colors.green)
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: onUpload,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload File'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF062AAE),
                    ),
                  ),
                ),
            ],''';

  for (final filename in files) {
    final file = File('$folderPath\\\\$filename');
    if (file.existsSync()) {
      final content = file.readAsStringSync();
      if (content.contains(oldBlock)) {
        final newContent = content.replaceAll(oldBlock, newBlock);
        file.writeAsStringSync(newContent);
        print('Updated $filename');
      } else {
        print('Old block not found in $filename');
      }
    } else {
      print('File not found: $filename');
    }
  }
}
