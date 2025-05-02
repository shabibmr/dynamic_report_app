part of 'entity_search_bloc.dart';

abstract class EntitySearchState {}

class EntitySearchInitial extends EntitySearchState {}

class EntitySearchLoading extends EntitySearchState {}

class EntitySearchSuccess extends EntitySearchState {
  final List<Map<String, dynamic>> results;
  EntitySearchSuccess(this.results);
}

class EntitySearchError extends EntitySearchState {
  final String message;
  EntitySearchError(this.message);
}
