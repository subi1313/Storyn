import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../features/books/data/datasources/book_remote_data_source.dart';
import '../../features/books/data/repositories/book_repository_impl.dart';
import '../../features/books/domain/repositories/book_repository.dart';
import '../../features/books/domain/usecases/search_books.dart';
import '../../features/books/presentation/providers/books_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Presentation
  sl.registerFactory(() => BooksProvider(searchBooksUseCase: sl()));

  // Domain
  sl.registerLazySingleton(() => SearchBooks(sl()));

  // Data
  sl.registerLazySingleton<BookRepository>(
        () => BookRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<BookRemoteDataSource>(
        () => BookRemoteDataSourceImpl(client: sl()),
  );

  // External
  sl.registerLazySingleton(() => http.Client());
}