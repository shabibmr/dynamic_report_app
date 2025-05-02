import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'entity_search/bloc/entity_search_bloc.dart';

class EntitySearchWidget extends StatelessWidget {
  final String hintText;
  final void Function(Map<String, dynamic>) onSelected;
  final Widget Function(BuildContext, Map<String, dynamic>)? optionBuilder;

  const EntitySearchWidget({
    Key? key,
    required this.hintText,
    required this.onSelected,
    this.optionBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EntitySearchBloc, EntitySearchState>(
      builder: (context, state) {
        return Autocomplete<Map<String, dynamic>>(
            optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              context.read<EntitySearchBloc>().add(ClearSearch());
              return const Iterable<Map<String, dynamic>>.empty();
            }

            context
                .read<EntitySearchBloc>()
                .add(SearchEntities(textEditingValue.text));

            if (state is EntitySearchSuccess) {
              return state.results;
            }
            return const Iterable<Map<String, dynamic>>.empty();
          },
          onSelected: onSelected,
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: optionBuilder?.call(context, option) ??
                            ListTile(
                              title: Text(option['name']?.toString() ?? ''),
                            ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state is EntitySearchLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : textEditingController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              textEditingController.clear();
                              context
                                  .read<EntitySearchBloc>()
                                  .add(ClearSearch());
                            },
                          )
                        : null,
                border: const OutlineInputBorder(),
              ),
              onFieldSubmitted: (String value) {
                onFieldSubmitted();
              },
            );
          },
        );
      },
    );
  }
}
