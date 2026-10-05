import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The user's own card(s). One row in MVP; multiple cards arrive in v1.1.
@DataClassName('CardRow')
class Cards extends Table {
  TextColumn get id => text()();

  /// Supabase user id; null for cards made in the offline-only build.
  TextColumn get ownerId => text().nullable()();
  TextColumn get slug => text().unique()();
  TextColumn get name => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get company => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get website => text().withDefault(const Constant(''))();
  TextColumn get linkedin => text().withDefault(const Constant(''))();
  TextColumn get location => text().withDefault(const Constant(''))();
  TextColumn get bio => text().withDefault(const Constant(''))();

  /// JSON array of `{label, url}` objects.
  TextColumn get linksJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isPublic => boolean().withDefault(const Constant(true))();
  BoolColumn get hidePhone => boolean().withDefault(const Constant(false))();
  BoolColumn get hideEmail => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  /// True until the row has been pushed to the backend.
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Cards])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'b_card'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.addColumn(cards, cards.ownerId);
        },
      );
}
