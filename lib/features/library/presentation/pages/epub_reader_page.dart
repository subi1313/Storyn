import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import '../../../../core/theme/app_colors.dart';

class EpubReaderPage extends StatefulWidget {
  final String title;
  final String epubPath;
  const EpubReaderPage({super.key, required this.title, required this.epubPath});

  @override
  State<EpubReaderPage> createState() => _EpubReaderPageState();
}

class _EpubReaderPageState extends State<EpubReaderPage> {
  final epubController = EpubController();
  bool _loading = true;
  Uint8List? _epubBytes;

  @override
  void initState() {
    super.initState();
    _loadBytes();
  }

  Future<void> _loadBytes() async {
    final bytes = await File(widget.epubPath).readAsBytes();
    if (mounted) setState(() => _epubBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(widget.title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.textPrimary)),
      ),
      body: _epubBytes == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          EpubViewer(
            epubSource: EpubSource.fromData(_epubBytes!),
            epubController: epubController,
            displaySettings: EpubDisplaySettings(flow: EpubFlow.paginated, snap: true),
            onEpubLoaded: () async {
              setState(() => _loading = false);
            },
            onChaptersLoaded: (chapters) {},
            onRelocated: (location) {},
          ),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}