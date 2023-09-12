import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';

class _Debug {
  static const bool debug = true;

  static void log(String message) {
    developer.log('StandardModel: $message');
  }
}

enum TakeMode {
  baseOnly,
  baseLeaf,
  leafOnly,
}

abstract class _StandardMethods<T extends StandardNode<T>> {
  void appendAll(Iterable<T> iterable);
  void insertAll(int index, Iterable<T> iterable);
  void removeAll(Iterable<T> iterable);

  void append(T child);
  void insert(int index, T child);
  void remove(T child);

  void clear();

  T? elementAt(dynamic index);
  T? operator [](dynamic index);

  void forEach(void Function(T node) action);
  void removeWhere(bool Function(T node) test);
  void traverseWhere(bool Function(T node) test);

  List<T> takeCheckedNodes([TakeMode takeMode = TakeMode.baseOnly]);

  bool get isEmpty;
  bool get isNotEmpty;

  int get length;
}

class StandardNode<T extends StandardNode<T>> implements _StandardMethods<T> {
  StandardNode({
    this.key,
    T? parent,
    List<T>? children,
    bool? collapsed,
    bool? checked,
  })  : _collapsed = collapsed,
        _checked = checked {
    if (children != null) {
      appendAll(children);
    }
    parent?.append(this as T);
  }

  T? _reliableParentRef() {
    return _parent is T ? _parent as T : null;
  }

  T? _reliableThisRef() {
    return this is T ? this as T : null;
  }

  T? get parent => _reliableParentRef();
  List<T> get children => _children;
  StandardModel<T>? get model => _model;

  int get index {
    if (_parent?._dirtyIndexf != null) {
      _parent!._rebuildIndexes();
    }
    return _index;
  }

  int get dirty => _index;
  int get level => _level;

  int? get dirtyIndexf => _dirtyIndexf;
  int? get dirtyIndexl => _dirtyIndexl;

  bool get collapsed => _collapsed ?? false;
  bool get checked => _checked ?? false;

  final String? key;

  StandardNode<T>? _parent;
  final List<T> _children = [];
  StandardModel<T>? _model;

  int _index = -1;
  int _level = -1;

  int? _dirtyIndexf;
  int? _dirtyIndexl;

  bool? _collapsed;
  bool? _checked;

  int _uncheckedCount = 0;
  int _checkedCount = 0;
  int _partiallyCount = 0;

  bool? _reliableCheckState() {
    return _children.isEmpty ? checked : _checked;
  }

  late final ValueNotifier<bool?> checkState = ValueNotifier<bool?>(_reliableCheckState());

  @override
  void appendAll(Iterable<T> iterable) {
    if (_Debug.debug) {
      List<String?> keys = [];
      for (final child in iterable) {
        keys.add(child.key);
      }
      _Debug.log('$key: appendAll([${keys.join(', ')}]);');
    }

    if (iterable.isEmpty) {
      return;
    }

    // 检查节点是否有效
    for (final child in iterable) {
      if (child._parent != null) {
        if (_Debug.debug) {
          _Debug.log('"${child.key}" already has a parent.');
        }
        assert(child._parent == null);
        return;
      }
    }

    // 计算无效索引范围 -->
    final index = _children.length;
    if (_dirtyIndexf != null) {
      if (_dirtyIndexl != null) {
        _dirtyIndexl = min(index - 1, _dirtyIndexl!);
      } else {
        _dirtyIndexl = index - 1;
      }
    }
    if (_Debug.debug) {
      _Debug.log('dirty index from $_dirtyIndexf to $_dirtyIndexl.');
    }
    // <-- 计算无效索引范围

    final reviseState = _children.isEmpty;
    // 插入前的通知
    _model?._beforeInsert(_model!, _reliableThisRef(), iterable, index);
    // 实际插入过程
    int childIndex = -1;
    for (final child in iterable) {
      child._parent = this;
      child._index = index + ++childIndex;
      if (_model != null) {
        child._recursiveUpdate(_model, _level + 1);
      }

      switch (child._reliableCheckState()) {
        case false:
          ++_uncheckedCount;
          break;
        case true:
          ++_checkedCount;
          break;
        case null:
          ++_partiallyCount;
          break;
      }
    }

    _children.addAll(iterable);
    // 插入后的通知
    _model?._afterInsert(_model!, _reliableThisRef(), iterable, index);

    _updateCheckState(reviseState);
    _model?._rebuildList();
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    if (_Debug.debug) {
      List<String?> keys = [];
      for (final child in iterable) {
        keys.add(child.key);
      }
      _Debug.log('$key: insertAll($index, [${keys.join(', ')}]);');
    }

    if (iterable.isEmpty) {
      return;
    }

    // 检查节点是否有效
    for (final child in iterable) {
      if (child._parent != null) {
        if (_Debug.debug) {
          _Debug.log('"${child.key}" already has a parent.');
        }
        assert(child._parent == null);
        return;
      }
    }

    // 计算无效索引范围 -->
    if (index < 0) {
      assert(index >= 0);
      return;
    } else if (index > _children.length) {
      assert(index <= _children.length);
      return;
    } else if (_children.isEmpty && (index > 0)) {
      assert(index == 0);
      return;
    }

    if (index == _children.length) {
      if (_dirtyIndexf != null) {
        if (_dirtyIndexl != null) {
          _dirtyIndexl = min(index - 1, _dirtyIndexl!);
        } else {
          _dirtyIndexl = index - 1;
        }
      }
    } else {
      final dirtyIndex = index + iterable.length;
      if (_dirtyIndexf != null) {
        if (index > _dirtyIndexf!) {
          _dirtyIndexf = min(dirtyIndex, _dirtyIndexf!);
        } else {
          _dirtyIndexf = dirtyIndex;
        }
      } else {
        _dirtyIndexf = dirtyIndex;
      }
      _dirtyIndexl = null;
    }
    if (_Debug.debug) {
      _Debug.log('dirty index from $_dirtyIndexf to $_dirtyIndexl.');
    }
    // <-- 计算无效索引范围

    final reviseState = _children.isEmpty;
    // 插入前的通知
    _model?._beforeInsert(_model!, _reliableThisRef(), iterable, index);
    // 实际插入过程
    int childIndex = -1;
    for (final child in iterable) {
      child._parent = this;
      child._index = index + ++childIndex;
      if (_model != null) {
        child._recursiveUpdate(_model, _level + 1);
      }

      switch (child._reliableCheckState()) {
        case false:
          ++_uncheckedCount;
          break;
        case true:
          ++_checkedCount;
          break;
        case null:
          ++_partiallyCount;
          break;
      }
    }
    _children.insertAll(index, iterable);
    // 插入后的通知
    _model?._afterInsert(_model!, _reliableThisRef(), iterable, index);

    _updateCheckState(reviseState);
    _model?._rebuildList();
  }

  @override
  void removeAll(Iterable<T> iterable) {
    if (_Debug.debug) {
      List<String?> keys = [];
      for (final child in iterable) {
        keys.add(child.key);
      }
      _Debug.log('$key: removeAll([${keys.join(', ')}]);');
    }

    if (iterable.isEmpty) {
      return;
    }

    // 检查节点是否有效
    for (final child in iterable) {
      if (child._parent != this) {
        if (_Debug.debug) {
          _Debug.log('${child.key} does not belong to this node.');
        }
        assert(child._parent == this);
        return;
      }
    }

    // 如果存在无效索引，需要重建索引
    if (_dirtyIndexf != null) {
      _rebuildIndexes();
    }

    // 反序将要删除的节点
    final children = iterable.toList();
    children.sort((lhs, rhs) {
      return rhs._index.compareTo(lhs._index);
    });

    // 计算无效索引范围 -->
    // 特殊情况: 如果删除的是连续的, 且在最后, 不设置 _dirtyIndexf
    if (children.first._index != (_children.length - children.length)) {
      _dirtyIndexf = children.last._index;
    }
    if (_Debug.debug) {
      _Debug.log('dirty index from $_dirtyIndexf to $_dirtyIndexl.');
    }
    // <-- 计算无效索引范围

    // ********** 开始删除 **********

    int? indexf;
    int? indexl;
    for (final child in children) {
      if (indexf != null) {
        if ((indexf - 1) != child._index) {
          if (_Debug.debug) {
            _Debug.log('remove from $indexf to $indexl.');
          }

          final temps = _children.getRange(indexf, indexl! + 1);
          // 删除前的通知
          _model?._beforeRemove(_model!, _reliableThisRef(), temps, indexf);
          // 实际删除过程
          for (final child in temps) {
            child._parent = null;
            child._index = -1;
            if (_model != null) {
              child._recursiveUpdate(null, -1);
            }

            switch (child._reliableCheckState()) {
              case false:
                --_uncheckedCount;
                break;
              case true:
                --_checkedCount;
                break;
              case null:
                --_partiallyCount;
                break;
            }
          }
          _children.removeRange(indexf, indexl + 1);
          // 删除后的通知
          _model?._afterRemove(_model!, _reliableThisRef(), temps, indexf);
        }

        indexf = child._index;
        indexl ??= child._index;
      } else {
        indexf = child._index;
        indexl = child._index;
      }
    }

    if (indexf != null) {
      if (_Debug.debug) {
        _Debug.log('remove from $indexf to $indexl.');
      }

      final temps = _children.sublist(indexf, indexl! + 1);
      // 删除前的通知
      _model?._beforeRemove(_model!, _reliableThisRef(), temps, indexf);
      // 实际删除过程
      for (final child in temps) {
        child._parent = null;
        child._index = -1;
        if (_model != null) {
          child._recursiveUpdate(null, -1);
        }

        switch (child._reliableCheckState()) {
          case false:
            --_uncheckedCount;
            break;
          case true:
            --_checkedCount;
            break;
          case null:
            --_partiallyCount;
            break;
        }
      }
      _children.removeRange(indexf, indexl + 1);
      // 删除后的通知
      _model?._afterRemove(_model!, _reliableThisRef(), temps, indexf);
    }

    if (_children.isEmpty) {
      _dirtyIndexf = null;
      _dirtyIndexl = null;
    }

    _updateCheckState(_children.isEmpty);
    _model?._rebuildList();
  }

  @override
  void append(T child) {
    appendAll([child]);
  }

  @override
  void insert(int index, T child) {
    insertAll(index, [child]);
  }

  @override
  void remove(T child) {
    removeAll([child]);
  }

  void _recursiveUpdate(StandardModel<T>? model, int level) {
    if (model != null) {
      this._model = model;
      this._level = level;
    } else {
      this._model = null;
      this._level = -1;
    }

    for (final child in _children) {
      child._recursiveUpdate(model, level + 1);
    }
  }

  void _rebuildIndexes() {
    if (_Debug.debug) {
      _Debug.log('$key: _rebuildIndexes($_dirtyIndexf, $_dirtyIndexl);');
    }

    if (_dirtyIndexf != null) {
      int childIndex = _dirtyIndexf! - 1;
      final end = _dirtyIndexl != null ? _dirtyIndexl! + 1 : _children.length;
      for (final child in _children.getRange(_dirtyIndexf!, end)) {
        child._index = ++childIndex;
      }

      _dirtyIndexf = null;
      _dirtyIndexl = null;
    }
  }

  @override
  void clear() {
    if (_Debug.debug) {
      _Debug.log('$key: clear();');
    }

    if (_children.isNotEmpty) {
      // 实际删除过程 -->
      for (final child in _children) {
        child._uncheckedCount = 0;
        child._checkedCount = 0;
        child._partiallyCount = 0;
        child._dirtyIndexf = null;
        child._dirtyIndexl = null;
        child._parent = null;
        child._model = null;
        child._index = -1;
        child._level = -1;
        child.clear();
      }
      _uncheckedCount = 0;
      _checkedCount = 0;
      _partiallyCount = 0;
      _dirtyIndexf = null;
      _dirtyIndexl = null;
      _children.clear();
      // <-- 实际删除过程
    }
  }

  @override
  T? elementAt(dynamic index) {
    if (index is int) {
      assert(index >= 0 && index < _children.length);
      return _children.elementAt(index);
    }

    return null;
  }

  @override
  T? operator [](dynamic index) => elementAt(index);

  @override
  void forEach(void Function(T node) action) {
    _children.forEach(action);
  }

  @override
  void removeWhere(bool Function(T node) test) {
    removeAll(_children.where(test));
  }

  @override
  void traverseWhere(bool Function(T node) test) {
    List<T> stack = [];
    if (this is T) {
      stack.add(this as T);
    } else if (_children.isNotEmpty) {
      stack.addAll(_children.reversed);
    }

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (test(node) && node._children.isNotEmpty) {
        stack.addAll(node._children.reversed);
      }
    }
  }

  @override
  List<T> takeCheckedNodes([TakeMode takeMode = TakeMode.baseOnly]) {
    final checkedNodes = <T>[];

    switch (takeMode) {
      case TakeMode.baseOnly:
        traverseWhere((node) {
          if (node.checked) {
            checkedNodes.add(node);
            return false;
          }
          return true;
        });
        break;
      case TakeMode.baseLeaf:
        traverseWhere((node) {
          if (node.checked) {
            checkedNodes.add(node);
          }
          return true;
        });
        break;
      case TakeMode.leafOnly:
        traverseWhere((node) {
          if (node.checked && node.isEmpty) {
            checkedNodes.add(node);
          }
          return true;
        });
        break;
    }

    return checkedNodes;
  }

  @override
  bool get isEmpty => _children.isEmpty;
  @override
  bool get isNotEmpty => _children.isNotEmpty;

  @override
  int get length => _children.length;

  void expand() {
    if (_Debug.debug) {
      _Debug.log('$key: expand();');
    }

    // 模型需要设置: collapsable = true
    if (_model != null && !_model!.collapsable) {
      assert(_model!.collapsable);
      return;
    }

    // 根节点不能执行此操作
    if (_model != null && _parent == null) {
      assert(_model == null || _parent != null);
      return;
    }

    if (collapsed != false) {
      _collapsed = false;
      _model?._rebuildList();
    }
  }

  void collapse() {
    if (_Debug.debug) {
      _Debug.log('$key: collapse();');
    }

    // 模型需要设置: collapsable = true
    if (_model != null && !_model!.collapsable) {
      assert(_model!.collapsable);
      return;
    }

    // 根节点不能执行此操作
    if (_model != null && _parent == null) {
      assert(_model == null || _parent != null);
      return;
    }

    if (collapsed != true) {
      _collapsed = true;
      _model?._rebuildList();
    }
  }

  void expandAll() {
    if (_Debug.debug) {
      _Debug.log('$key: expandAll();');
    }

    // 模型需要设置: collapsable = true
    if (_model != null && !_model!.collapsable) {
      assert(_model!.collapsable);
      return;
    }

    int changes = 0;
    traverseWhere((node) {
      if (node.collapsed != false) {
        node._collapsed = false;
        ++changes;
      }
      return true;
    });
    if (changes > 0 && _model != null) {
      _model?._rebuildList();
    }
  }

  void collapseAll() {
    if (_Debug.debug) {
      _Debug.log('$key: collapseAll();');
    }

    // 模型需要设置: collapsable = true
    if (_model != null && !_model!.collapsable) {
      assert(_model!.collapsable);
      return;
    }

    int changes = 0;
    traverseWhere((node) {
      if (node.collapsed != true) {
        node._collapsed = true;
        ++changes;
      }
      return true;
    });
    if (changes > 0 && _model != null) {
      _model?._rebuildList();
    }
  }

  void check() {
    if (_Debug.debug) {
      _Debug.log('$key: check();');
    }

    // 模型需要设置: checkable = true
    if (_model != null && !_model!.checkable) {
      assert(_model!.checkable);
      return;
    }

    if (checked != true) {
      final oldChecked = _reliableCheckState();
      traverseWhere((node) {
        final l = node._children.length;

        node._partiallyCount = 0;
        node._checkedCount = l;
        node._uncheckedCount = 0;

        node._checked = true;
        node.checkState.value = true;
        return true;
      });

      final p = parent;
      if (p != null) {
        if (oldChecked == null) {
          --p._partiallyCount;
          ++p._checkedCount;
        } else {
          assert(oldChecked == false);
          --p._uncheckedCount;
          ++p._checkedCount;
        }

        p._updateCheckState(false);
      }
    }
  }

  void uncheck() {
    if (_Debug.debug) {
      _Debug.log('$key: uncheck();');
    }

    // 模型需要设置: checkable = true
    if (_model != null && !_model!.checkable) {
      assert(_model!.checkable);
      return;
    }

    if (checked != false) {
      final oldChecked = _reliableCheckState();
      traverseWhere((node) {
        final l = node._children.length;

        node._partiallyCount = 0;
        node._checkedCount = 0;
        node._uncheckedCount = l;

        node._checked = false;
        node.checkState.value = false;
        return true;
      });

      final p = parent;
      if (p != null) {
        if (oldChecked == null) {
          --p._partiallyCount;
          ++p._uncheckedCount;
        } else {
          assert(oldChecked == true);
          --p._checkedCount;
          ++p._uncheckedCount;
        }

        p._updateCheckState(false);
      }
    }
  }

  void _updateCheckState(bool reviseState) {
    if (_Debug.debug) {
      _Debug.log('$key: _updateCheckState();');
    }

    assert((_uncheckedCount + _checkedCount + _partiallyCount) == _children.length);

    assert(_uncheckedCount >= 0);
    assert(_checkedCount >= 0);
    assert(_partiallyCount >= 0);

    bool? nextState = _checked;
    if (_children.isNotEmpty) {
      final childCount = _children.length;
      if (childCount == _uncheckedCount) {
        nextState = false;
      } else if (childCount == _checkedCount) {
        nextState = true;
      } else {
        nextState = null;
      }
    }
    if (_Debug.debug) {
      _Debug.log('$_uncheckedCount + $_checkedCount + $_partiallyCount = ${_children.length} -> $nextState');
    }

    if (_checked != nextState) {
      final p = parent;
      if (p != null) {
        bool? oldCheckState = _checked;
        if (reviseState && _children.isNotEmpty && oldCheckState == null) {
          // 如果叶结点变成了拥有子节点的节点，需要修正状态，防止计值错误
          oldCheckState = false;
        }

        switch (oldCheckState) {
          case false:
            --p._uncheckedCount;
            break;
          case true:
            --p._checkedCount;
            break;
          case null:
            --p._partiallyCount;
            break;
        }
      }

      _checked = nextState;
      checkState.value = nextState;

      if (p != null) {
        bool? newCheckState = _checked;
        if (reviseState && _children.isEmpty && newCheckState == null) {
          // 如果拥有子节点的节点变成叶结点后，需要修正状态，防止计值错误
          newCheckState = false;
        }

        switch (newCheckState) {
          case false:
            ++p._uncheckedCount;
            break;
          case true:
            ++p._checkedCount;
            break;
          case null:
            ++p._partiallyCount;
            break;
        }

        p._updateCheckState(false);
      }
    }
  }

  void detach() {
    if (_Debug.debug) {
      _Debug.log('$key: detach();');
    }

    assert(this is T);
    if (this is T) {
      _parent?.remove(this as T);
    }
  }

  void makeCurrent() {
    _model?.current = this as T;
  }

  void doneCurrent() {
    if (_model?.current == this) {
      _model!.current = null;
    }
  }

  bool get current => _current;

  bool _current = false;

  late final ValueNotifier<bool> currentNotifier = ValueNotifier<bool>(_current);

  void debugDumpTree() {
    developer.log("---------- debugDumpTree ----------");
    _recursiveDebugDumpTree("", 0, 0);
  }

  void _recursiveDebugDumpTree(String indent, int level, int indexl) {
    final key = this.key ?? hashCode.toString();

    if (level == 0) {
      developer.log("level: $_level, index: $_index, dirtyRange($_dirtyIndexf, $_dirtyIndexl), key: $key");
    } else {
      if (indexl == 0) {
        developer.log("$indent└── level: $_level, index: $_index, dirtyRange($_dirtyIndexf, $_dirtyIndexl), key: $key");
      } else {
        developer.log("$indent├── level: $_level, index: $_index, dirtyRange($_dirtyIndexf, $_dirtyIndexl), key: $key");
      }
    }

    int childIndexl = _children.length;
    for (final child in _children) {
      child._recursiveDebugDumpTree(level == 0 ? indent : "    $indent", level + 1, --childIndexl);
    }
  }
}

typedef StandardModelChanges<T extends StandardNode<T>> = void Function(
    StandardModel<T> model, T? parent, Iterable<T> children, int index);

class StandardModel<T extends StandardNode<T>> implements _StandardMethods<T> {
  StandardModel({
    List<T>? children,
    this.collapsable = false,
    this.checkable = false,
  }) {
    _root._model = this;
    if (children != null) {
      _root.appendAll(children);
    }
  }
  late final StandardNode<T> _root = StandardNode<T>();

  List<T> get children => _root.children;

  int? get dirtyIndexf => _root.dirtyIndexf;
  int? get dirtyIndexl => _root.dirtyIndexl;

  final bool collapsable;
  final bool checkable;

  @override
  void appendAll(Iterable<T> iterable) {
    _root.appendAll(iterable);
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    _root.insertAll(index, iterable);
  }

  @override
  void removeAll(Iterable<T> iterable) {
    _root.removeAll(iterable);
  }

  @override
  void append(T child) {
    _root.append(child);
  }

  @override
  void insert(int index, T child) {
    _root.insert(index, child);
  }

  @override
  void remove(T child) {
    _root.remove(child);
  }

  @override
  void clear() {
    _root.clear();
  }

  @override
  T? elementAt(dynamic index) {
    return _root.elementAt(index);
  }

  @override
  T? operator [](dynamic index) => _root.elementAt(index);

  @override
  void forEach(void Function(T node) action) {
    _root.forEach(action);
  }

  @override
  void removeWhere(bool Function(T node) test) {
    _root.removeWhere(test);
  }

  @override
  void traverseWhere(bool Function(T node) test) {
    _root.traverseWhere(test);
  }

  @override
  List<T> takeCheckedNodes([TakeMode takeMode = TakeMode.baseOnly]) {
    return _root.takeCheckedNodes(takeMode);
  }

  @override
  bool get isEmpty => _root.isEmpty;
  @override
  bool get isNotEmpty => _root.isNotEmpty;

  @override
  int get length => _root.length;

  void expandAll() {
    _root.expandAll();
  }

  void collapseAll() {
    _root.collapseAll();
  }

  void checkAll() {
    _root.check();
  }

  void uncheckAll() {
    _root.uncheck();
  }

  void dispose() {
    _beforeInsertListeners.clear();
    _afterInsertListeners.clear();
    _beforeRemoveListeners.clear();
    _afterRemoveListeners.clear();

    _root.clear();
  }

  void debugDumpTree() {
    _root.debugDumpTree();
  }

  void _rebuildList() {
    if (_Debug.debug) {
      _Debug.log('null: _rebuildList();');
    }

    final tempList = <T>[];

    traverseWhere((node) {
      tempList.add(node);
      return !(node.collapsed);
    });

    list.value = tempList;
  }

  final ValueNotifier<List<T>> list = ValueNotifier<List<T>>([]);

  set current(T? current) {
    if (_current != current) {
      if (_current != null) {
        _current!._current = false;
        _current!.currentNotifier.value = false;
      }
      _current = current;
      if (_current != null) {
        _current!._current = true;
        _current!.currentNotifier.value = true;
      }
    }
  }

  T? get current => _current;

  T? _current;

  late ValueNotifier<T?> currentNotifier = ValueNotifier<T?>(_current);

  final List<StandardModelChanges<T>> _beforeInsertListeners = [];
  final List<StandardModelChanges<T>> _afterInsertListeners = [];
  final List<StandardModelChanges<T>> _beforeRemoveListeners = [];
  final List<StandardModelChanges<T>> _afterRemoveListeners = [];

  void addBeforeInsertListener(StandardModelChanges<T> listener) {
    _beforeInsertListeners.add(listener);
  }

  void addAfterInsertListener(StandardModelChanges<T> listener) {
    _afterInsertListeners.add(listener);
  }

  void addBeforeRemoveListener(StandardModelChanges<T> listener) {
    _beforeRemoveListeners.add(listener);
  }

  void addAfterRemoveListener(StandardModelChanges<T> listener) {
    _afterRemoveListeners.add(listener);
  }

  void removeBeforeInsertListener(StandardModelChanges<T> listener) {
    _beforeInsertListeners.remove(listener);
  }

  void removeAfterInsertListener(StandardModelChanges<T> listener) {
    _afterInsertListeners.remove(listener);
  }

  void removeBeforeRemoveListener(StandardModelChanges<T> listener) {
    _beforeRemoveListeners.remove(listener);
  }

  void removeAfterRemoveListener(StandardModelChanges<T> listener) {
    _afterRemoveListeners.remove(listener);
  }

  void _beforeInsert(StandardModel<T> model, T? parent, Iterable<T> children, int index) {
    for (final listener in _beforeInsertListeners) {
      listener(model, parent, children, index);
    }
  }

  void _afterInsert(StandardModel<T> model, T? parent, Iterable<T> children, int index) {
    for (final listener in _afterInsertListeners) {
      listener(model, parent, children, index);
    }
  }

  void _beforeRemove(StandardModel<T> model, T? parent, Iterable<T> children, int index) {
    for (final listener in _beforeRemoveListeners) {
      listener(model, parent, children, index);
    }
  }

  void _afterRemove(StandardModel<T> model, T? parent, Iterable<T> children, int index) {
    for (final listener in _afterRemoveListeners) {
      listener(model, parent, children, index);
    }
  }
}