part of 'entity_search_bloc.dart';

abstract class EntitySearchEvent {}

class SearchEntities extends EntitySearchEvent {
  final String query;
  SearchEntities(this.query);
}

class ClearSearch extends EntitySearchEvent {}
