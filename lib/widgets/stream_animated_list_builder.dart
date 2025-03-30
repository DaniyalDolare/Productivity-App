import 'package:flutter/widgets.dart';

class StreamAnimatedListBuilder<T> extends StatefulWidget {
  const StreamAnimatedListBuilder(
      {super.key,
      required this.stream,
      required this.build,
      required this.listKey,
      required this.compareEquals,
      required this.onEmpty,
      required this.compareUpdated,
      required this.onError,
      this.duration = const Duration(milliseconds: 300),
      this.filterData,
      required this.searchController});

  final Stream<List<T>> stream;
  final TextEditingController searchController;
  final Widget Function(
      BuildContext context, T item, Animation<double> animation) build;
  final GlobalObjectKey<AnimatedListState> listKey;
  final List<T> Function(List<T>)? filterData;
  final bool Function(T, T) compareEquals;
  final bool Function(T, T) compareUpdated;
  final Widget onEmpty;
  final Widget onError;
  final Duration duration;

  @override
  State<StatefulWidget> createState() {
    return _StreamAnimatedListBuilderState<T>();
  }
}

class _StreamAnimatedListBuilderState<T>
    extends State<StreamAnimatedListBuilder<T>> {
  List<T> _currentList = [];
  List<T> _originalList = [];
  bool _hasData = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    widget.stream.listen(
      (event) {
        handleData(event, isUpdatedData: true);
      },
      onError: (error) {
        setState(() {
          _hasError = true;
        });
      },
    );

    widget.searchController.addListener(() {
      if (widget.searchController.text.isNotEmpty) {
        handleData(widget.filterData!(_originalList));
      } else {
        handleData(_originalList);
      }
    });
  }

  void handleData(List<T> data, {isUpdatedData = false}) {
    final List<T> newList =
        widget.filterData != null ? widget.filterData!(data) : data;

    if (_hasData && widget.listKey.currentState != null) {
      List<T> addedItems = newList
          .where((a) => !_currentList.any((b) => widget.compareEquals(a, b)))
          .toList();

      for (var update in addedItems) {
        final int updateIndex = newList.indexOf(update);
        widget.listKey.currentState!
            .insertItem(updateIndex, duration: widget.duration);
      }

      Iterable<T> removedItems = _currentList
          .where((a) => !newList.any((b) => widget.compareEquals(a, b)))
          .toList()
          .reversed;

      for (var update in removedItems) {
        final int updateIndex = _currentList.indexOf(update);
        widget.listKey.currentState!.removeItem(updateIndex,
            (context, animation) {
          return widget.build(context, update, animation);
        }, duration: widget.duration);
      }

      List<T> updatedItems = _currentList
          .where((a) => newList.any((b) => widget.compareUpdated(a, b)))
          .toList();

      for (var update in updatedItems) {
        final int oldIndex = _currentList.indexOf(update);
        final int newIndex = newList.indexOf(update);
        if (newIndex < oldIndex) {
          widget.listKey.currentState!
              .insertItem(newIndex, duration: widget.duration);
          widget.listKey.currentState!.removeItem(oldIndex,
              (context, animation) {
            return widget.build(context, update, animation);
          }, duration: Duration.zero);
        } else {
          widget.listKey.currentState!.removeItem(oldIndex,
              (context, animation) {
            return widget.build(context, update, animation);
          }, duration: widget.duration);

          Future.delayed(widget.duration, () {
            widget.listKey.currentState!
                .insertItem(newIndex, duration: widget.duration);
          });
        }
      }
    }

    _currentList = newList;
    if (isUpdatedData) {
      _originalList = data;
    }

    setState(() {
      _hasData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasData) {
      return widget.onEmpty;
    }
    if (_hasError) {
      return widget.onError;
    }
    if (_currentList.isEmpty) {
      return widget.onEmpty;
    }

    return AnimatedList(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width / 3),
      key: widget.listKey,
      initialItemCount: _currentList.length,
      itemBuilder: (context, index, animation) {
        if (_currentList.length <= index) {
          return const SizedBox.shrink();
        }

        final item = _currentList[index];
        return widget.build(context, item, animation);
      },
    );
  }
}
