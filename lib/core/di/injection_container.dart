import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../features/books/data/datasources/book_remote_data_source.dart';
import '../../features/books/data/datasources/openlibrary_remote_data_source.dart';
import '../../features/books/data/repositories/book_repository_impl.dart';
import '../../features/books/domain/repositories/book_repository.dart';
import '../../features/books/domain/usecases/search_books.dart';
import '../../features/books/presentation/providers/books_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/library/data/datasources/library_local_data_source.dart';
import '../../features/library/data/datasources/library_remote_data_source.dart';
import '../../features/library/data/repositories/library_repository_impl.dart';
import '../../features/library/domain/repositories/library_repository.dart';
import '../../features/library/domain/usecases/get_saved_books.dart';
import '../../features/library/domain/usecases/save_book.dart';
import '../../features/library/domain/usecases/remove_book.dart';
import '../../features/library/domain/usecases/is_book_saved.dart';
import '../../features/library/presentation/providers/library_provider.dart';
import '../../features/library/domain/usecases/create_collection.dart';
import '../../features/library/domain/usecases/delete_collection.dart';
import '../../features/library/domain/usecases/get_collections.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/profile/presentation/providers/profile_refresh_provider.dart';
import '../../features/auth/presentation/providers/auth_session_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerFactory(() => BooksProvider(searchBooksUseCase: sl()));
  sl.registerLazySingleton(() => SearchBooks(sl()));
  sl.registerLazySingleton(() => GetCollections(sl()));
  sl.registerLazySingleton(() => CreateCollection(sl()));
  sl.registerLazySingleton(() => DeleteCollection(sl()));
  sl.registerLazySingleton(() => ProfileRefreshProvider());
  sl.registerLazySingleton(() => AuthSessionProvider(prefs: sharedPreferences)); // now valid

  sl.registerLazySingleton<BookRepository>(
        () => BookRepositoryImpl(
      googleDataSource: sl(),
      openLibraryDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<BookRemoteDataSource>(
        () => BookRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<OpenLibraryRemoteDataSource>(
        () => OpenLibraryRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton(() => http.Client());

  // Library feature
  sl.registerLazySingleton(() => LibraryProvider(
    getSavedBooksUseCase: sl(),
    saveBookUseCase: sl(),
    removeBookUseCase: sl(),
    isBookSavedUseCase: sl(),
    getCollectionsUseCase: sl(),
    createCollectionUseCase: sl(),
    deleteCollectionUseCase: sl(),
  ));
  sl.registerLazySingleton(() => GetSavedBooks(sl()));
  sl.registerLazySingleton(() => SaveBook(sl()));
  sl.registerLazySingleton(() => RemoveBook(sl()));
  sl.registerLazySingleton(() => IsBookSaved(sl()));
  sl.registerLazySingleton<LibraryRepository>(() => LibraryRepositoryImpl(localDataSource: sl()));
  sl.registerLazySingleton<LibraryLocalDataSource>(
        () => LibraryRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  sl.registerLazySingleton(() => SettingsProvider(prefs: sharedPreferences)); // moved up, now valid
}