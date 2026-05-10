/// Base class for all Use Cases in the application.
/// [Type] is the return type, [Params] is the parameter type.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Used when a use case requires no parameters.
class NoParams {
  const NoParams();
}
