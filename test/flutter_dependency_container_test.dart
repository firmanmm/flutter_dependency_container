import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_dependency_container/flutter_dependency_container.dart';


class MockContainer implements IDependencyContainer {
  @override
  T get<T>([Type type]) {
    return null;
  }

  @override
  T getByName<T>(String name) {
    return null;
  }

  @override
  void register(Type type, func) {
    //NOP
  }

  @override
  void registerByName(String name, func) {
    //NOP
  }

}
class AClass {
  final int value;

  AClass(this.value);
}

class BClass {
  final int value;

  BClass(this.value);
}

class ABClass {
  final AClass aClass;
  final BClass bClass;

  ABClass(this.aClass, this.bClass);
}

class CClass {
  final DClass dClass;

  CClass(this.dClass);
}

class DClass {
  final CClass cClass;

  DClass(this.cClass);
}

class ZClass {

}

void main() {
  group("Default Test", () {
    IDependencyContainer container = DependencyContainer();
    test("Setting dependency by key", () {
      expect(() {
        container.registerByName("one", (container) {
          return 1;
        });
        container.registerByName("two", (container) {
          return 2;
        });
      }, returnsNormally);
    });

    test("Verify key insertion", () {
      expect(1, container.getByName("one"));
      expect(2, container.getByName("two"));
    });

    test("Setting dependency by Class", () {
      expect(() {
        container.register(AClass, (container) {
          final one = container.getByName("one");
          return AClass(one);
        });
        container.register(BClass, (container) {
          return BClass(3);
        });
      }, returnsNormally);
    });

    test("Verify class insertion", () {
      expect(1, container.get<AClass>().value);
      expect(3, container.get(BClass).value);
    });

    test("Setting dependency with dependency by Class", () {
      expect(() {
        container.register(ABClass, (container) {
          final aClass = container.get<AClass>();
          final bClass = container.get<BClass>();
          return ABClass(aClass, bClass);
        });
      }, returnsNormally);
    });

    test("Verify nested dependency correctness", () {
      final abClass = container.get<ABClass>();
      expect(1, abClass.aClass.value);
      expect(3, abClass.bClass.value);

      final aClass = container.get<AClass>();
      final bClass = container.get(BClass);
      expect(abClass.aClass, aClass);
      expect(abClass.bClass, bClass);
    });

    test("Duplicate class", () {
      expect(() {
        container.register(AClass, (container) => null);
      }, throwsA(isA<DuplicateDependencyException>()));
    });

    test("Duplicate name", () {
      expect(() {
        container.registerByName("one", (container) => null);
      }, throwsA(isA<DuplicateDependencyException>()));
    });

    test("Not Found class", () {
      expect(() {
        container.get(ZClass);
      }, throwsA(isA<UnResolvableDependencyException>()));
    });

    test("Not Found key", () {
      expect(() {
        container.getByName("404");
      }, throwsA(isA<UnResolvableDependencyException>()));
    });

    test("Circular", () {
      IDependencyContainer container = DependencyContainer();
      expect(() {
        container.register(CClass, (container) {
          final dClass = container.get(DClass);
          return CClass(dClass);
        });
        container.register(DClass, (container) {
          final cClass = container.get(CClass);
          return DClass(cClass);
        });
      }, returnsNormally);

      expect(() {
        final cClass = container.get(CClass);
      }, throwsA(isA<CircularDependencyException>()));

      expect(() {
        final dClass = container.get(DClass);
      }, throwsA(isA<CircularDependencyException>()));
    });
  });
}
