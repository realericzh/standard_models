import 'package:flutter_test/flutter_test.dart';
import 'package:standard_models/standard_models.dart';

class StandardModelTester<T extends StandardNode<T>> {
  StandardModelTester(this._model) {
    _model.addBeforeInsertListener(_beforeInsert);
    _model.addAfterInsertListener(_afterInsert);
    _model.addBeforeRemoveListener(_beforeRemove);
    _model.addAfterRemoveListener(_afterRemove);
  }

  void dispose() {
    _model.removeBeforeInsertListener(_beforeInsert);
    _model.removeAfterInsertListener(_afterInsert);
    _model.removeBeforeRemoveListener(_beforeRemove);
    _model.removeAfterRemoveListener(_afterRemove);
  }

  final StandardModel<T> _model;

  void _beforeInsert(StandardModel<T> model, T? parent, Iterable<T> children, int index) {
    expect(model, _model);

    for (final child in children) {
      expect(child.parent, null);
      expect(child.model, null);
      expect(child.dirty, -1);
      expect(child.level, -1);
    }

    if (_beforeInsertChangesTests.isNotEmpty) {
      _beforeInsertChangesTests.removeAt(0).test(parent, children.toList(), index);
    }
  }

  void _afterInsert(StandardModel<T> model, T? parent, Iterable<T> children, int index) {
    expect(model, _model);

    int childIndex = -1;
    for (final child in children) {
      expect(child.parent, parent);
      expect(child.model, model);
      expect(child.dirty, index + ++childIndex);
      expect(child.level, parent != null ? parent.level + 1 : 0);
    }

    if (_afterInsertChangesTests.isNotEmpty) {
      _afterInsertChangesTests.removeAt(0).test(parent, children.toList(), index);
    }
  }

  void _beforeRemove(StandardModel<T> model, T? parent, Iterable<T> children, int index) {
    expect(model, _model);

    int childIndex = -1;
    for (final child in children) {
      expect(child.parent, parent);
      expect(child.model, model);
      expect(child.dirty, index + ++childIndex);
      expect(child.level, parent != null ? parent.level + 1 : 0);
    }

    if (_beforeRemoveChangesTests.isNotEmpty) {
      _beforeRemoveChangesTests.removeAt(0).test(parent, children.toList(), index);
    }
  }

  void _afterRemove(StandardModel<T> model, T? parent, Iterable<T> children, int index) {
    expect(model, _model);

    for (final child in children) {
      expect(child.parent, null);
      expect(child.model, null);
      expect(child.dirty, -1);
      expect(child.level, -1);
    }

    if (_afterRemoveChangesTests.isNotEmpty) {
      _afterRemoveChangesTests.removeAt(0).test(parent, children.toList(), index);
    }
  }

  final List<_StandardModelChangesTest<T>> _beforeInsertChangesTests = [];
  void beforeInsert(int index, List<T> children, [T? parent]) {
    _beforeInsertChangesTests.add(_StandardModelChangesTest<T>(parent, children, index));
  }

  final List<_StandardModelChangesTest<T>> _afterInsertChangesTests = [];
  void afterInsert(int index, List<T> children, [T? parent]) {
    _afterInsertChangesTests.add(_StandardModelChangesTest<T>(parent, children, index));
  }

  final List<_StandardModelChangesTest<T>> _beforeRemoveChangesTests = [];
  void beforeRemove(int index, List<T> children, [T? parent]) {
    _beforeRemoveChangesTests.add(_StandardModelChangesTest<T>(parent, children, index));
  }

  final List<_StandardModelChangesTest<T>> _afterRemoveChangesTests = [];
  void afterRemove(int index, List<T> children, [T? parent]) {
    _afterRemoveChangesTests.add(_StandardModelChangesTest<T>(parent, children, index));
  }

  void dirtyRange(int? indexf, int? indexl, [T? node]) {
    expect(indexf, node != null ? node.dirtyIndexf : _model.dirtyIndexf);
    expect(indexl, node != null ? node.dirtyIndexl : _model.dirtyIndexl);
  }
}

class _StandardModelChangesTest<T extends StandardNode<T>> {
  _StandardModelChangesTest(this.parent, this.children, this.index);

  final StandardNode<T>? parent;
  final List<T> children;
  final int index;

  void test(StandardNode<T>? parent, List<T> children, int index) {
    expect(parent, this.parent);

    expect(children.length, this.children.length);
    for (int i = 0; i < children.length; ++i) {
      expect(children[i], this.children[i]);
    }

    expect(index, this.index);
  }
}
