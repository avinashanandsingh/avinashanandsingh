import 'package:app/utils/result.dart';

abstract class Query<T> {
  Future<Result<T>> list(dynamic filter);
  Future<Result<T>> get(dynamic filter);
}

abstract class Mutation<T> {
  Future<Result<T>> add(T dataIn);
  Future<Result<T>> update(String id, T dataIn);
}
