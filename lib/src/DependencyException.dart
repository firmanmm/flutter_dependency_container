class DependencyException implements Exception {
}

class DuplicateDependencyException extends DependencyException {

	final String key;
	final bool isClass;

  DuplicateDependencyException(this.key, this.isClass);

	@override
  String toString() {
    if(isClass) {
    	return "Duplicate dependency for class $key";
    }
    return "Duplicate dependency for key $key";
  }
}

class CircularDependencyException extends DependencyException {
	final List<String> _path;

	CircularDependencyException(this._path);

	List<String> getPath() {
		return _path;
	}

	@override
	String toString() {
		return "Unable to satisfy dependency due to circular dependency : " + _path.join(" -> ");
	}
}

class UnResolvableDependencyException extends DependencyException {
	final String _key;
	final bool _isClass;
	final List<String> _path;

	UnResolvableDependencyException(this._key, this._isClass, this._path);

	@override
	String toString() {
		if(_isClass) {
			return "Undefined evaluation for class $_key, ${_path.join(" -> ")}";
		}
		return "Undefined evaluation for key $_key, ${_path.join(" -> ")}";
	}
}