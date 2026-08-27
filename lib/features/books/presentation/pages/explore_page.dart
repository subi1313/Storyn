import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/books_provider.dart';
import '../widgets/book_cover_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _controller = TextEditingController();

  final List<String> _quickGenres = [
    'Romance', 'Mystery', 'Horror', 'Sci-fi', 'Fantasy', 'Self help',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BooksProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _controller,
                    onSubmitted: (query) => context.read<BooksProvider>().search(query),
                    decoration: InputDecoration(
                      hintText: 'search title, author, or genre...',
                      hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
                      suffixIcon: provider.searchStatus != SearchStatus.initial
                          ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.clear();
                          context.read<BooksProvider>().clearSearch();
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: AppColors.textSecondary,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickGenres.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final genre = _quickGenres[index];
                        return GestureDetector(
                          onTap: () {
                            _controller.text = genre;
                            context.read<BooksProvider>().search('$genre fiction novel');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.dotInactive),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              genre,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BooksProvider provider) {
    switch (provider.searchStatus) {
      case SearchStatus.initial:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/empty_search.json', width: 200, height: 200, repeat: true),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Search for a title, author, or tap a genre above to start exploring.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        );
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchStatus.error:
        return Center(
          child: Text(provider.searchErrorMessage, style: const TextStyle(fontFamily: 'Inter')),
        );
      case SearchStatus.loaded:
        if (provider.searchResults.isEmpty) {
          return const Center(child: Text('No books found.', style: TextStyle(fontFamily: 'Inter')));
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 18,
            crossAxisSpacing: 16,
            childAspectRatio: 0.6,
          ),
          itemCount: provider.searchResults.length,
          itemBuilder: (context, index) => BookCoverCard(
            book: provider.searchResults[index],
          ),
        );
    }
  }
}