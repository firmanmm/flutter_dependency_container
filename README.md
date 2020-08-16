# Flutter Dependency Container
This is a flutter dependency container written in `Dart`. This is just a simple map with callback function used to retreive dependency. It will automatically construct dependency based on how you tell it how to build certain object. Also, this is reflect free!

# How it works
- **Register** certain object or class
- Tell them how to **build** them
- Try to **get** them
    - If **found**
        - If **constructed** return them
        - Else
            - If **need dependency** then find
                - If **circular** then throw `CircularDependencyException`
    - If **not found** then throw `UnResolvableDependencyException`
    
- Simply done

# Usage
```
IDependencyContainer container = DependencyContainer();

//Register simple object by key
container.registerByName("one", (container) {
    return 1;
});
container.registerByName("two", (container) {
    return 2;
});

//Register certain class, and try yo get object with key "one"
container.register(AClass, (container) {
    final one = container.getByName("one");
    return AClass(one);
});

//Register certain class
container.register(BClass, (container) {
    return BClass(3);
});

//Nested Dependency which require previous class
container.register(ABClass, (container) {
    final aClass = container.get<AClass>();
    final bClass = container.get<BClass>();
    return ABClass(aClass, bClass);
});

//Obtain ABClass first
//It will automatically build AClass, BClass, and key "one"
//since it is referred in the ABClass builder
final abClass = container.get<ABClass>();
