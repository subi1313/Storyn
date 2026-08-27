import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../library/domain/entities/reading_status.dart';
import '../../../library/domain/entities/saved_book.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../domain/entities/book.dart';

const _statusOptions = [
  (status: ReadingStatus.planToRead, label: 'Plan to read', icon: Icons.bookmark_add_outlined),
  (status: ReadingStatus.currentlyReading, label: 'Currently reading', icon: Icons.menu_book_outlined),
  (status: ReadingStatus.completed, label: 'Completed', icon: Icons.check_circle_outline),
];

class AddToLibrarySheet extends StatefulWidget {
  final Book book;
  const AddToLibrarySheet({super.key, required this.book});

  @override
  State<AddToLibrarySheet> createState() => _AddToLibrarySheetState();
}

class _AddToLibrarySheetState extends State<AddToLibrarySheet> {
  ReadingStatus? _selectedStatus;
  final Set<String> _selectedCollectionIds = {};

  @override
  void initState() {
    super.initState();
    final provider = context.read<LibraryProvider>();
    final current = provider.statusFor(widget.book.id);
    _selectedStatus = current == ReadingStatus.none ? null : current;
    _selectedCollectionIds.addAll(provider.collectionIdsFor(widget.book.id));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.dotInactive, borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 16),
            const Text('Add to library', style: TextStyle(fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            const Text('Reading status', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dotActive)),
            const SizedBox(height: 8),
            ..._statusOptions.map((option) => _StatusTile(
              label: option.label,
              icon: option.icon,
              isSelected: _selectedStatus == option.status,
              onTap: () => setState(() => _selectedStatus = _selectedStatus == option.status ? null : option.status),
            )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Collections', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dotActive)),
                GestureDetector(
                  onTap: () => _showCreateCollectionDialog(context),
                  child: const Text('+ New', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onboardingButton)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (provider.collections.isEmpty)
              const Text('No collections yet.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textPrimary))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.collections.map((c) {
                  final isSelected = _selectedCollectionIds.contains(c.id);
                  return GestureDetector(
                    onTap: () => setState(() {
                      isSelected ? _selectedCollectionIds.remove(c.id) : _selectedCollectionIds.add(c.id);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.onboardingButton : AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(c.name, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: isSelected ? AppColors.white : AppColors.textPrimary)),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onboardingButton,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final savedBook = SavedBook(
                    id: widget.book.id,
                    title: widget.book.title,
                    authors: widget.book.authors,
                    thumbnailUrl: widget.book.thumbnailUrl,
                    description: widget.book.description,
                    savedAt: DateTime.now(),
                  );
                  print('SHEET: saving with status=$_selectedStatus, collections=$_selectedCollectionIds, bookId="${widget.book.id}"');

                  final success = await context.read<LibraryProvider>().saveWithOptions(
                    savedBook,
                    status: _selectedStatus ?? ReadingStatus.none,
                    collectionIds: _selectedCollectionIds.toList(),
                  );

                  if (context.mounted) {
                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to library'), duration: Duration(seconds: 1)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save — check your connection'), duration: Duration(seconds: 2)),
                      );
                    }
                  }
                },
                child: const Text('Save', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white)),
              ),
            ),
            if (provider.isSaved(widget.book.id)) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    context.read<LibraryProvider>().removeSavedBook(widget.book.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Remove from library', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.redAccent)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New collection'),
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
}

class _StatusTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusTile({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.onboardingButton.withOpacity(0.12) : AppColors.textSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.onboardingButton : Colors.transparent, width: 1.4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? AppColors.onboardingButton : AppColors.textPrimary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: AppColors.textPrimary))),
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, size: 20, color: isSelected ? AppColors.onboardingButton : AppColors.dotInactive),
          ],
        ),
      ),
    );
  }
}