import 'dart:developer' as developer;

import 'package:flutter_test/flutter_test.dart';
import 'package:standard_models/standard_models.dart';

import 'standard_model_tester.dart';

class TestNode extends StandardNode<TestNode> {
  TestNode({super.key, super.parent, super.children});
}

void main() {
  test('testCase1', () {
    StandardModel<TestNode> model = StandardModel<TestNode>();
    StandardModelTester<TestNode> modelTester = StandardModelTester<TestNode>(model);

    TestNode node0 = TestNode(key: "node0");
    TestNode node1 = TestNode(key: "node1");
    TestNode node2 = TestNode(key: "node2");
    TestNode node3 = TestNode(key: "node3");
    TestNode node4 = TestNode(key: "node4");
    TestNode node5 = TestNode(key: "node5");
    TestNode node6 = TestNode(key: "node6");
    TestNode node7 = TestNode(key: "node7");
    TestNode node8 = TestNode(key: "node8");

    // 追加一个
    print("*** case: model.appendAll([node0]);");
    modelTester.beforeInsert(0, [node0]);
    modelTester.afterInsert(0, [node0]);
    model.appendAll([node0]);
    modelTester.dirtyRange(null, null);
    model.debugDumpTree();

    // 追加两个
    print("*** case: model.appendAll([node1, node2]);");
    modelTester.beforeInsert(1, [node1, node2]);
    modelTester.afterInsert(1, [node1, node2]);
    model.appendAll([node1, node2]);
    modelTester.dirtyRange(null, null);
    model.debugDumpTree();

    // 在最后面插入一个
    print("*** case: model.insertAll(3, [node3]);");
    modelTester.beforeInsert(3, [node3]);
    modelTester.afterInsert(3, [node3]);
    model.insertAll(3, [node3]);
    modelTester.dirtyRange(null, null);
    model.debugDumpTree();

    // 在最后面插入两个
    print("*** case: model.insertAll(4, [node4, node5]);");
    modelTester.beforeInsert(4, [node4, node5]);
    modelTester.afterInsert(4, [node4, node5]);
    model.insertAll(4, [node4, node5]);
    modelTester.dirtyRange(null, null);
    model.debugDumpTree();

    // 在最前面插入一个
    print("*** case: model.insertAll(0, [node6]);");
    modelTester.beforeInsert(0, [node6]);
    modelTester.afterInsert(0, [node6]);
    model.insertAll(0, [node6]);
    modelTester.dirtyRange(1, null);
    model.debugDumpTree();

    // 在最前面插入两个
    print("*** case: model.insertAll(0, [node7, node8]);");
    modelTester.beforeInsert(0, [node7, node8]);
    modelTester.afterInsert(0, [node7, node8]);
    model.insertAll(0, [node7, node8]);
    modelTester.dirtyRange(2, null);
    model.debugDumpTree();

    // 在最前面删除两个
    print("*** case: model.removeAll([node7, node8]);");
    modelTester.beforeRemove(0, [node7, node8]);
    modelTester.afterRemove(0, [node7, node8]);
    model.removeAll([node7, node8]);
    modelTester.dirtyRange(0, null);
    model.debugDumpTree();

    // 在最前面删除一个
    print("*** case: model.removeAll([node6]);");
    modelTester.beforeRemove(0, [node6]);
    modelTester.afterRemove(0, [node6]);
    model.removeAll([node6]);
    modelTester.dirtyRange(0, null);
    model.debugDumpTree();

    // 在最后面删除两个
    print("*** case: model.removeAll([node4, node5]);");
    modelTester.beforeRemove(4, [node4, node5]);
    modelTester.afterRemove(4, [node4, node5]);
    model.removeAll([node4, node5]);
    modelTester.dirtyRange(4, null);
    model.debugDumpTree();

    // 在最后面删除一个
    print("*** case: model.removeAll([node3]);");
    modelTester.beforeRemove(3, [node3]);
    modelTester.afterRemove(3, [node3]);
    model.removeAll([node3]);
    modelTester.dirtyRange(null, null);
    model.debugDumpTree();

    // 追加一个
    print("*** case: model.appendAll([node3]);");
    modelTester.beforeInsert(3, [node3]);
    modelTester.afterInsert(3, [node3]);
    model.appendAll([node3]);
    modelTester.dirtyRange(null, null);
    model.debugDumpTree();

    TestNode node3_0 = TestNode(key: "node3_0");
    TestNode node3_1 = TestNode(key: "node3_1");
    TestNode node3_2 = TestNode(key: "node3_2");
    TestNode node3_3 = TestNode(key: "node3_3");
    TestNode node3_4 = TestNode(key: "node3_4");
    TestNode node3_5 = TestNode(key: "node3_5");
    TestNode node3_6 = TestNode(key: "node3_6");
    TestNode node3_7 = TestNode(key: "node3_7");
    TestNode node3_8 = TestNode(key: "node3_8");

    // 追加一个
    print("*** case: node3.appendAll([node3_0]);");
    modelTester.beforeInsert(0, [node3_0], node3);
    modelTester.afterInsert(0, [node3_0], node3);
    node3.appendAll([node3_0]);
    modelTester.dirtyRange(null, null, node3);
    model.debugDumpTree();

    // 追加两个
    print("*** case: node3.appendAll([node3_1, node3_2]);");
    modelTester.beforeInsert(1, [node3_1, node3_2], node3);
    modelTester.afterInsert(1, [node3_1, node3_2], node3);
    node3.appendAll([node3_1, node3_2]);
    modelTester.dirtyRange(null, null, node3);
    model.debugDumpTree();

    // 在最后面插入一个
    print("*** case: node3.insertAll(3, [node3_3]);");
    modelTester.beforeInsert(3, [node3_3], node3);
    modelTester.afterInsert(3, [node3_3], node3);
    node3.insertAll(3, [node3_3]);
    modelTester.dirtyRange(null, null, node3);
    model.debugDumpTree();

    // 在最后面插入两个
    print("*** case: node3.insertAll(4, [node3_4, node3_5]);");
    modelTester.beforeInsert(4, [node3_4, node3_5], node3);
    modelTester.afterInsert(4, [node3_4, node3_5], node3);
    node3.insertAll(4, [node3_4, node3_5]);
    modelTester.dirtyRange(null, null, node3);
    model.debugDumpTree();

    // 在最前面插入一个
    print("*** case: node3.insertAll(0, [node3_6]);");
    modelTester.beforeInsert(0, [node3_6], node3);
    modelTester.afterInsert(0, [node3_6], node3);
    node3.insertAll(0, [node3_6]);
    modelTester.dirtyRange(1, null, node3);
    model.debugDumpTree();

    // 在最前面插入两个
    print("*** case: node3.insertAll(0, [node3_7, node3_8]);");
    modelTester.beforeInsert(0, [node3_7, node3_8], node3);
    modelTester.afterInsert(0, [node3_7, node3_8], node3);
    node3.insertAll(0, [node3_7, node3_8]);
    modelTester.dirtyRange(2, null, node3);
    model.debugDumpTree();

    // 在最前面删除两个
    print("*** case: node3.removeAll([node3_7, node3_8]);");
    modelTester.beforeRemove(0, [node3_7, node3_8], node3);
    modelTester.afterRemove(0, [node3_7, node3_8], node3);
    node3.removeAll([node3_7, node3_8]);
    modelTester.dirtyRange(0, null, node3);
    model.debugDumpTree();

    // 在最前面删除一个
    print("*** case: node3.removeAll([node3_6]);");
    modelTester.beforeRemove(0, [node3_6], node3);
    modelTester.afterRemove(0, [node3_6], node3);
    node3.removeAll([node3_6]);
    modelTester.dirtyRange(0, null, node3);
    model.debugDumpTree();

    // 在最后面删除两个
    print("*** case: node3.removeAll([node3_4, node3_5]);");
    modelTester.beforeRemove(4, [node3_4, node3_5], node3);
    modelTester.afterRemove(4, [node3_4, node3_5], node3);
    node3.removeAll([node3_4, node3_5]);
    modelTester.dirtyRange(4, null, node3);
    model.debugDumpTree();

    // 在最后面删除一个
    print("*** case: node3.removeAll([node3_3]);");
    modelTester.beforeRemove(3, [node3_3], node3);
    modelTester.afterRemove(3, [node3_3], node3);
    node3.removeAll([node3_3]);
    modelTester.dirtyRange(null, null, node3);
    model.debugDumpTree();

    // 追加一个
    print("*** case: node3.appendAll([node3_3]);");
    modelTester.beforeInsert(3, [node3_3], node3);
    modelTester.afterInsert(3, [node3_3], node3);
    node3.appendAll([node3_3]);
    modelTester.dirtyRange(null, null, node3);
    model.debugDumpTree();

    // 在最后面追加两个
    print("*** case: model.appendAll([node7, node8]);");
    modelTester.beforeInsert(4, [node7, node8]);
    modelTester.afterInsert(4, [node7, node8]);
    model.appendAll([node7, node8]);
    modelTester.dirtyRange(null, null);
    model.debugDumpTree();

    // 删除父节点 node3
    print("*** case: model.removeAll([node3]);");
    modelTester.beforeRemove(3, [node3]);
    modelTester.afterRemove(3, [node3]);
    model.removeAll([node3]);
    modelTester.dirtyRange(3, null);
    model.debugDumpTree();
    node3.debugDumpTree();

    modelTester.dispose();
    model.dispose();
  });

  test('testCase2', () {
    StandardModel<TestNode> model = StandardModel<TestNode>();
    StandardModelTester<TestNode> modelTester = StandardModelTester<TestNode>(model);

    TestNode node0 = TestNode(key: "node0");
    TestNode node1 = TestNode(key: "node1");
    TestNode node2 = TestNode(key: "node2");
    TestNode node3 = TestNode(key: "node3");
    TestNode node4 = TestNode(key: "node4");

    TestNode node1_0 = TestNode(key: "node1_0", parent: node1);
    TestNode node1_1 = TestNode(key: "node1_1", parent: node1);
    TestNode node1_2 = TestNode(key: "node1_2", parent: node1);
    TestNode node1_3 = TestNode(key: "node1_3", parent: node1);
    TestNode node1_4 = TestNode(key: "node1_4", parent: node1);

    TestNode node2_0 = TestNode(key: "node2_0", parent: node2);
    TestNode node2_1 = TestNode(key: "node2_1", parent: node2);
    TestNode node2_2 = TestNode(key: "node2_2", parent: node2);
    TestNode node2_3 = TestNode(key: "node2_3", parent: node2);
    TestNode node2_4 = TestNode(key: "node2_4", parent: node2);

    TestNode node1_1_0 = TestNode(key: "node1_1_0", parent: node1_1);
    TestNode node1_1_1 = TestNode(key: "node1_1_1", parent: node1_1);
    TestNode node1_1_2 = TestNode(key: "node1_1_2", parent: node1_1);
    TestNode node1_1_3 = TestNode(key: "node1_1_3", parent: node1_1);
    TestNode node1_1_4 = TestNode(key: "node1_1_4", parent: node1_1);

    model.appendAll([node0, node1, node2, node3, node4]);

    model.debugDumpTree();

    model.traverseWhere((node) {
      developer.log("traverse: ${node.key ?? ""}");
      return true;
    });

    modelTester.dispose();
    model.dispose();
  });
}
