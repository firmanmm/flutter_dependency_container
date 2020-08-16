abstract class ISetterContainer {
	void register(Type type, DependencyContainerFunc func);
	void registerByName(String name, DependencyContainerFunc func);
}

abstract class IGetterContainer {
	T get<T>([Type type]);
	T getByName<T>(String name);
}

typedef dynamic DependencyContainerFunc(IGetterContainer container);

abstract class IDependencyContainer implements IGetterContainer, ISetterContainer {}
