import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reading_status.dart';
import '../providers/library_provider.dart';
import '../widgets/library_folder_card.dart';
import 'collection_books_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().loadLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Library',
                style: TextStyle(fontFamily: 'Playfair', fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            Expanded(
              child: provider.status == LibraryStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.3,
                children: [
                  LibraryFolderCard(
                    title: 'All books',
                    icon: Icons.library_books_outlined,
                    count: provider.savedBooks.length,
                    onTap: () => _open(context, 'All books', LibraryFilterType.all),
                  ),
                  LibraryFolderCard(
                    title: 'Plan to read',
                    icon: Icons.bookmark_add_outlined,
                    count: provider.booksByStatus(ReadingStatus.planToRead).length,
                    onTap: () => _open(context, 'Plan to read', LibraryFilterType.status, status: ReadingStatus.planToRead),
                  ),
                  LibraryFolderCard(
                    title: 'Currently reading',
                    icon: Icons.menu_book_outlined,
                    count: provider.booksByStatus(ReadingStatus.currentlyReading).length,
                    onTap: () => _open(context, 'Currently reading', LibraryFilterType.status, status: ReadingStatus.currentlyReading),
                  ),
                  LibraryFolderCard(
                    title: 'Completed',
                    icon: Icons.check_circle_outline,
                    count: provider.booksByStatus(ReadingStatus.completed).length,
                    onTap: () => _open(context, 'Completed', LibraryFilterType.status, status: ReadingStatus.completed),
                  ),
                  for (final collection in provider.collections)
                    LibraryFolderCard(
                      title: collection.name,
                      icon: Icons.folder_outlined,
                      count: provider.booksInCollection(collection.id).length,
                      onTap: () => _open(context, collection.name, LibraryFilterType.collection, collectionId: collection.id),
                      onLongPress: () => _confirmDeleteCollection(context, collection.id, collection.name),
                    ),
                  LibraryFolderCard(
                    title: 'New collection',
                    icon: Icons.add,
                    count: null,
                    isAddCard: true,
                    onTap: () => _showCreateCollectionDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, String title, LibraryFilterType type, {ReadingStatus? status, String? collectionId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CollectionBooksPage(title: title, filterType: type, status: status, collectionId: collectionId),
      ),
    );
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('New collection', style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Collection name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<LibraryProvider>().createCollection(controller.text.trim());
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCollection(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Delete collection?', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.textPrimary)),
        content: Text('"$name" will be deleted. Books inside it stay in your library.',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<LibraryProvider>().deleteCollection(id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}