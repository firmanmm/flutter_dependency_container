import 'DependencyException.dart';
import 'IDependencyContainer.dart';

class DependencyContainer implements IDependencyContainer{

	Map<String, dynamic> _map;
	Map<String, DependencyContainerFunc>_evalMap;

	_DependencyPath _dependencyPath;

	DependencyContainer() {
		_map = Map();
		_evalMap = Map();
		_dependencyPath = new _DependencyPath();
	}

	/*
	Try to obtain dependency by their [Type].
	Will throw error if dependency is unsatisfied
	Example:
		container.get<Calculator>();
	or:
		container.get(Calculator);
	*/
	@override
	T get<T>([Type type]) {
		if(type == null) {
			type = T;
		}
		_dependencyPath.visit("Class " + type.toString());
		final key = "C_"+type.toString();
		if(!_map.containsKey(key)) {
			final res = _resolveGet(key);
			if(res == null){
				final _path = _dependencyPath.getPath();
				_dependencyPath.clear();
				throw new UnResolvableDependencyException(type.toString(), true, _path);
			}
			_map[key] = res;
		}
		_dependencyPath.clear();
		return _map[key];
	}

	/*
	Try to obtain dependency by their name [String].
	Will throw error if dependency is unsatisfied
	Example:
		container.getByName("Calculator");
	*/
	@override
	T getByName<T>(String name) {
		_dependencyPath.visit("Key " + name);
		final key = "S_" + name;
		if(!_map.containsKey(key)) {
			final res = _resolveGet(key);
			if(res == null){
				final _path = _dependencyPath.getPath();
				_dependencyPath.clear();
				throw new UnResolvableDependencyException(name, false, _path);
			}
			_map[key] = res;
		}
		_dependencyPath.clear();
		return _map[key];
	}

	/*
	Register dependency with certain [Type]
	Example:
		iDependencyContainer.register(ADependency, (container) {
    	return ADependency(
		    container.get(BDependency), //Try to obtain BDependency from container
	    );
    });
	 */
	@override
	void register(Type type, DependencyContainerFunc func) {
		final key = "C_"+type.toString();
		if(_evalMap.containsKey(key)) {
			throw DuplicateDependencyException(type.toString(), true);
		}
		_evalMap[key] = func;
	}

	/*
	Register dependency with certain name [String]
	Example:
		iDependencyContainer.registerByName("ADependency", (container) {
    	return ADependency(
		    container.get(BDependency), //Try to obtain BDependency from container
	    );
    });
	 */
	@override
	void registerByName(String name, DependencyContainerFunc func) {
		final key = "S_" + name;
		if(_evalMap.containsKey(key)) {
			throw DuplicateDependencyException(name, false);
		}
		_evalMap[key] = func;
	}

	dynamic _resolveGet(String key) {
		if (!_evalMap.containsKey(key)) {
			final _path = _dependencyPath.getPath();
			_dependencyPath.clear();
			bool isClass = false;
			if(key[0] == 'C') {
				isClass = true;
			}
			throw new UnResolvableDependencyException(key, isClass, _path);
		}
		final func = _evalMap[key];
		return func(this);
	}
}

class _DependencyPath {
	List<String> _path;
	Set<String> _visited;

	_DependencyPath() {
		_path = [];
		_visited = Set<String>();
	}

	void visit(String key) {
		_path.add(key);
		if(_visited.contains(key)){
			var path = _path;
			clear();
			throw new CircularDependencyException(path);
		}
		_visited.add(key);
	}

	void clear() {
		_path = [];
		_visited = Set<String>();
	}

	List<String> getPath() {
		return _path;
	}
}