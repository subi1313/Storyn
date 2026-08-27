import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/saved_book.dart';
import '../providers/library_provider.dart';

enum ReaderThemeMode { light, dark, sepia }

class _ThemeColors {
  final Color background;
  final Color foreground;
  final Brightness statusBarBrightness;

  const _ThemeColors(
      this.background,
      this.foreground,
      this.statusBarBrightness,
      );
}

const Map<ReaderThemeMode, _ThemeColors> _kThemeColors = {
  ReaderThemeMode.light: _ThemeColors(
    Color(0xFFFFFFFF),
    Color(0xFF1A1A1A),
    Brightness.light,
  ),
  ReaderThemeMode.sepia: _ThemeColors(
    Color(0xFFF4ECD8),
    Color(0xFF5B4636),
    Brightness.light,
  ),
  ReaderThemeMode.dark: _ThemeColors(
    Color(0xFF121212),
    Color(0xFFE6E6E6),
    Brightness.dark,
  ),
};

const List<Color> _kHighlightColors = [
  Color(0xFFFFF176),
  Color(0xFFA5D6A7),
  Color(0xFF90CAF9),
  Color(0xFFF48FB1),
];

class EpubReaderPage extends StatefulWidget {
  final SavedBook book;

  const EpubReaderPage({
    super.key,
    required this.book,
  });

  @override
  State<EpubReaderPage> createState() => _EpubReaderPageState();
}

class _EpubReaderPageState extends State<EpubReaderPage> {
  final epubController = EpubController();

  Uint8List? _epubBytes;

  bool _ready = false;

  double _progress = 0.0;
  double _fontSize = 16;

  ReaderThemeMode _themeMode = ReaderThemeMode.light;

  // Reader controls are hidden by default.
  bool _showReaderControls = false;


  String? _lastKnownCfi;
  String? _pendingSaveCfi;
  double? _pendingSaveProgress;

  Timer? _saveDebounce;


  List<EpubChapter> _chapters = [];


  late List<String> _bookmarks;

  @override
  void initState() {
    super.initState();

    _progress = widget.book.readingProgress;
    _lastKnownCfi = widget.book.lastCfi;

    _bookmarks = List<String>.of(
      widget.book.bookmarkCfis,
    );

    _loadBytes();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();

    _flushProgress();

    super.dispose();
  }

  Future<void> _loadBytes() async {
    final epubPath = widget.book.epubPath;

    if (epubPath == null || epubPath.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('EPUB file not found.'),
          ),
        );
      }

      return;
    }

    try {
      final bytes = await File(epubPath).readAsBytes();

      if (!mounted) return;

      setState(() {
        _epubBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open EPUB file.'),
        ),
      );
    }
  }

  Map<String, Map<String, String>> _cssForTheme(
      ReaderThemeMode mode,
      ) {
    final colors = _kThemeColors[mode]!;

    final bg =
        '#${colors.background.value.toRadixString(16).substring(2)}';

    final fg =
        '#${colors.foreground.value.toRadixString(16).substring(2)}';

    return {
      'body': {
        'background': bg,
        'color': fg,
      },
      'p': {
        'color': fg,
        'font-size': '${_fontSize}px',
      },
    };
  }

  void _setThemeMode(ReaderThemeMode mode) {
    setState(() {
      _themeMode = mode;
      _ready = false;
    });
  }

  void _changeFontSize(double delta) {
    final next = (_fontSize + delta).clamp(
      12.0,
      28.0,
    );

    setState(() {
      _fontSize = next;
    });

    if (_ready) {
      epubController.setFontSize(
        fontSize: _fontSize,
      );
    }
  }

  void _toggleReaderControls() {
    setState(() {
      _showReaderControls = !_showReaderControls;
    });
  }

  Future<T?> _withRetry<T>(
      Future<T> Function() action,
      ) async {
    try {
      return await action();
    } catch (_) {
      await Future.delayed(
        const Duration(milliseconds: 400),
      );

      try {
        return await action();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Reader isn\'t ready yet — try again in a moment.',
              ),
            ),
          );
        }

        return null;
      }
    }
  }

  Future<void> _onEpubLoaded() async {
    if (!mounted) return;

    setState(() {
      _ready = true;
    });

    // Restore saved position after the EPUB has loaded.
    if (_lastKnownCfi != null &&
        _lastKnownCfi!.isNotEmpty) {
      try {
        await Future.delayed(
          const Duration(milliseconds: 300),
        );

        await epubController.display(
          cfi: _lastKnownCfi!,
        );
      } catch (_) {
        // Ignore restore errors.
      }
    }
  }

  Future<void> _addBookmark() async {
    if (!_ready) return;

    final location = await _withRetry(
          () => epubController.getCurrentLocation(),
    );

    if (location == null) return;

    final cfi = location.startCfi;

    if (cfi.isEmpty) return;

    if (_bookmarks.contains(cfi)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already bookmarked'),
          duration: Duration(seconds: 1),
        ),
      );

      return;
    }

    setState(() {
      _bookmarks = [
        ..._bookmarks,
        cfi,
      ];
    });

    context.read<LibraryProvider>().saveWithOptions(
      widget.book.copyWith(
        bookmarkCfis: _bookmarks,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bookmark added'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeBookmark(String cfi) {
    setState(() {
      _bookmarks = _bookmarks
          .where(
            (bookmark) => bookmark != cfi,
      )
          .toList();
    });

    context.read<LibraryProvider>().saveWithOptions(
      widget.book.copyWith(
        bookmarkCfis: _bookmarks,
      ),
    );
  }

  void _showBookmarksSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bookmarks',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                if (_bookmarks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 24,
                    ),
                    child: Text(
                      'No bookmarks yet.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.dotActive,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _bookmarks.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final cfi = _bookmarks[index];

                        return ListTile(
                          leading: const Icon(
                            Icons.bookmark,
                            color:
                            AppColors.onboardingButton,
                            size: 20,
                          ),
                          title: Text(
                            'Bookmark ${index + 1}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(sheetContext);

                            epubController.display(
                              cfi: cfi,
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.dotActive,
                            ),
                            onPressed: () {
                              _removeBookmark(cfi);

                              Navigator.pop(sheetContext);

                              _showBookmarksSheet();
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChaptersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chapters',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                if (_chapters.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 24,
                    ),
                    child: Text(
                      'No table of contents found.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.dotActive,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _chapters.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final chapter = _chapters[index];

                        return ListTile(
                          leading: const Icon(
                            Icons.menu_book_outlined,
                            color:
                            AppColors.onboardingButton,
                            size: 20,
                          ),
                          title: Text(
                            chapter.title,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.pop(sheetContext);

                            epubController.display(
                              cfi: chapter.href,
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Called by flutter_epub_viewer when the user selects text.
  ///
  /// The selection is expected to contain a `cfiRange`.
  void _onTextSelected(dynamic selection) {
    try {
      final String cfiRange =
          selection.cfiRange?.toString() ?? '';

      if (cfiRange.trim().isEmpty) {
        return;
      }

      _showHighlightColorPicker(cfiRange);
    } catch (e) {
      debugPrint(
        'Text selection error: $e',
      );
    }
  }

  void _showHighlightColorPicker(
      String cfiRange,
      ) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    bool removed = false;

    void removeEntry() {
      if (!removed && entry.mounted) {
        removed = true;
        entry.remove();
      }
    }

    entry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          left: 24,
          right: 24,
          bottom: 40,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [

                  for (final color
                  in _kHighlightColors)
                    GestureDetector(
                      onTap: () {
                        try {
                          epubController.addHighlight(
                            cfi: cfiRange,
                            color: color,
                          );

                          removeEntry();

                          if (mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content:
                                Text('Text highlighted'),
                                duration:
                                Duration(seconds: 1),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint(
                            'Highlight error: $e',
                          );

                          removeEntry();

                          if (mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Unable to highlight selected text.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration:
                        BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black12,
                          ),
                        ),
                      ),
                    ),

                  GestureDetector(
                    onTap: removeEntry,
                    child: const Icon(
                      Icons.close,
                      size: 22,
                      color: AppColors.dotActive,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Future.delayed(
      const Duration(seconds: 6),
      removeEntry,
    );
  }

  void _onRelocated(dynamic location) {
    try {
      final cfi =
      location.startCfi as String?;

      final progress =
      location.progress as double?;

      if (cfi == null && progress == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        if (cfi != null) {
          _lastKnownCfi = cfi;
        }

        if (progress != null) {
          _progress = progress;
        }
      });

      _pendingSaveCfi =
          cfi ?? _lastKnownCfi;

      _pendingSaveProgress =
          progress ?? _progress;

      _saveDebounce?.cancel();

      _saveDebounce = Timer(
        const Duration(
          milliseconds: 900,
        ),
        _flushProgress,
      );
    } catch (e) {
      debugPrint(
        'Relocation error: $e',
      );
    }
  }

  void _flushProgress() {
    if (_pendingSaveCfi == null &&
        _pendingSaveProgress == null) {
      return;
    }

    context.read<LibraryProvider>().saveWithOptions(
      widget.book.copyWith(
        readingProgress:
        _pendingSaveProgress ?? _progress,
        lastCfi:
        _pendingSaveCfi ?? _lastKnownCfi,
      ),
    );

    _pendingSaveCfi = null;
    _pendingSaveProgress = null;
  }

  Widget _themeChip(
      String label,
      ReaderThemeMode mode,
      ) {
    final selected =
        _themeMode == mode;

    return Padding(
      padding:
      const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
          ),
        ),
        selected: selected,
        onSelected: (_) {
          _setThemeMode(mode);
        },
        selectedColor:
        AppColors.onboardingButton,
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : AppColors.textPrimary,
        ),
      ),
    );
  }

  void _showReaderSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder:
              (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reading settings',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(
                      'Text size',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.text_decrease,
                          ),
                          onPressed: () {
                            _changeFontSize(
                              -2,
                            );

                            setSheetState(
                                  () {},
                            );
                          },
                        ),

                        Expanded(
                          child: Text(
                            '${_fontSize.toInt()}px',
                            textAlign:
                            TextAlign.center,
                            style:
                            const TextStyle(
                              fontFamily:
                              'Inter',
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.text_increase,
                          ),
                          onPressed: () {
                            _changeFontSize(
                              2,
                            );

                            setSheetState(
                                  () {},
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const Text(
                      'Theme',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Row(
                      children: [
                        _themeChip(
                          'Light',
                          ReaderThemeMode.light,
                        ),
                        _themeChip(
                          'Sepia',
                          ReaderThemeMode.sepia,
                        ),
                        _themeChip(
                          'Dark',
                          ReaderThemeMode.dark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then(
          (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildReaderControls(
      _ThemeColors theme,
      ) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            decoration:
            BoxDecoration(
              color: theme.background
                  .withOpacity(0.97),
              borderRadius:
              BorderRadius.circular(18),
              border: Border.all(
                color: theme.foreground
                    .withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.18),
                  blurRadius: 16,
                  offset:
                  const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceAround,
              children: [

                _readerControlButton(
                  icon:
                  Icons.list_alt_outlined,
                  tooltip: 'Chapters',
                  foreground:
                  theme.foreground,
                  onPressed:
                  _showChaptersSheet,
                ),

                _readerControlButton(
                  icon:
                  Icons.bookmarks_outlined,
                  tooltip: 'Bookmarks',
                  foreground:
                  theme.foreground,
                  onPressed:
                  _showBookmarksSheet,
                ),

                _readerControlButton(
                  icon:
                  Icons.bookmark_add_outlined,
                  tooltip:
                  'Bookmark this page',
                  foreground:
                  theme.foreground,
                  onPressed: _ready
                      ? _addBookmark
                      : null,
                ),

                _readerControlButton(
                  icon: Icons.text_fields,
                  tooltip:
                  'Reading settings',
                  foreground:
                  theme.foreground,
                  onPressed:
                  _showReaderSettingsSheet,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _readerControlButton({
    required IconData icon,
    required String tooltip,
    required Color foreground,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(
        icon,
        color: onPressed == null
            ? foreground.withOpacity(0.35)
            : foreground,
      ),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme =
    _kThemeColors[_themeMode]!;

    return PopScope(
      onPopInvokedWithResult:
          (didPop, _) {
        if (didPop) {
          _flushProgress();
        }
      },
      child: AnnotatedRegion<
          SystemUiOverlayStyle>(
        value:
        theme.statusBarBrightness ==
            Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor:
          theme.background,

          appBar: AppBar(
            backgroundColor:
            theme.background,
            elevation: 0,

            iconTheme:
            IconThemeData(
              color: theme.foreground,
            ),

            title: Text(
              widget.book.title,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color:
                theme.foreground,
              ),
            ),

            actions: [
              Padding(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 16,
                ),
                child: Center(
                  child: Text(
                    '${(_progress * 100).round()}%',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w600,
                      color: theme
                          .foreground
                          .withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],

            bottom:
            PreferredSize(
              preferredSize:
              const Size.fromHeight(
                4,
              ),
              child:
              LinearProgressIndicator(
                value: _progress,
                backgroundColor:
                AppColors.dotInactive,
                color: AppColors
                    .onboardingButton,
                minHeight: 4,
              ),
            ),
          ),


          body: _epubBytes == null
              ? const Center(
            child:
            CircularProgressIndicator(),
          )
              : Stack(
            children: [

              EpubViewer(
                key: ValueKey(
                  _themeMode,
                ),

                epubSource:
                EpubSource.fromData(
                  _epubBytes!,
                ),

                epubController:
                epubController,

                initialCfi:
                _lastKnownCfi,

                displaySettings:
                EpubDisplaySettings(
                  flow:
                  EpubFlow.paginated,
                  snap: true,
                  theme:
                  EpubTheme.custom(
                    customCss:
                    _cssForTheme(
                      _themeMode,
                    ),
                  ),
                ),

                onEpubLoaded:
                _onEpubLoaded,

                onChaptersLoaded:
                    (chapters) {
                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    _chapters =
                        chapters;
                  });
                },

                onRelocated:
                _onRelocated,

                onTextSelected:
                _onTextSelected,
              ),


              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 56,
                child:
                GestureDetector(
                  behavior:
                  HitTestBehavior
                      .translucent,
                  onTap: _ready
                      ? () {
                    epubController
                        .prev();
                  }
                      : null,
                ),
              ),


              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 56,
                child:
                GestureDetector(
                  behavior:
                  HitTestBehavior
                      .translucent,
                  onTap: _ready
                      ? () {
                    epubController
                        .next();
                  }
                      : null,
                ),
              ),


              Positioned(
                left: 56,
                right: 56,
                top: 0,
                bottom: 0,
                child:
                GestureDetector(
                  behavior:
                  HitTestBehavior
                      .translucent,
                  onTap:
                  _toggleReaderControls,
                ),
              ),


              if (_showReaderControls)
                _buildReaderControls(
                  theme,
                ),

              if (!_ready)
                const Center(
                  child:
                  CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}