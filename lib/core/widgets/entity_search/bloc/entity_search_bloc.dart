import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/entity_search_repository.dart';
part 'entity_search_event.dart';
part 'entity_search_state.dart';

class EntitySearchBloc extends Bloc<EntitySearchEvent, EntitySearchState> {
  final EntitySearchRepository _repository;
  Timer? _debounceTimer;

  EntitySearchBloc(this._repository) : super(EntitySearchInitial()) {
    on<SearchEntities>(_onSearchEntities);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchEntities(
      SearchEntities event, Emitter<EntitySearchState> emit) async {
    if (event.query.isEmpty) {
      emit(EntitySearchInitial());
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      emit(EntitySearchLoading());
      try {
        final results = await _repository.searchEntities(event.query);
        emit(EntitySearchSuccess(results));
      } catch (e) {
        emit(EntitySearchError(e.toString()));
      }
    });
  }

  void _onClearSearch(ClearSearch event, Emitter<EntitySearchState> emit) {
    emit(EntitySearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
