import os

folder_path = r'c:\MySect\mobile_app\lib\mobile_app\files'
files = ['corporate_page.dart', 'accounting_page.dart', 'personal_page.dart', 'other_page.dart', 'attention_page.dart']

old_block = """            if (isExpanded) ...[
              const Divider(height: 32),
              Text(
                'Uploaded Files',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              if (uploadedFiles.isEmpty)
                Text(
                  'No files uploaded yet.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ...uploadedFiles.asMap().entries.map((entry) {
                int idx = entry.key;
                String f = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                      if (onRemoveFile != null)
                        GestureDetector(
                          onTap: () => onRemoveFile(idx),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                    ],
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
                  ),
                ),
            ],"""

new_block = """            if (isExpanded) ...[
              const Divider(height: 32),
              Text(
                'Files',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              if (uploadedFiles.isEmpty)
                Text(
                  'No files available.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ...uploadedFiles.asMap().entries.map((entry) {
                String f = entry.value;
                return InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing $f', style: GoogleFonts.poppins()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          size: 16,
                          color: Color(0xFF062AAE),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF062AAE),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.visibility,
                          size: 16,
                          color: Color(0xFF062AAE),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],"""

for filename in files:
    filepath = os.path.join(folder_path, filename)
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if old_block in content:
            new_content = content.replace(old_block, new_block)
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated {filename}")
        else:
            print(f"Old block not found in {filename}")
