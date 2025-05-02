import '../data/datasources/entity_search_datasource.dart';

abstract class EntitySearchRepository {
  Future<List<Map<String, dynamic>>> searchEntities(String query);
}

class EntitySearchRepositoryImpl implements EntitySearchRepository {
  final EntitySearchDataSource _dataSource;

  EntitySearchRepositoryImpl(this._dataSource);

  @override
  Future<List<Map<String, dynamic>>> searchEntities(String query) async {
    try {
      return await _dataSource.searchEntities(query);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}
