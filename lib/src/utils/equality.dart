/// Determine equality.
///
/// This is used to compare two elements for being equal.
/// This should be a proper equality relation.
typedef Equality<T> = bool Function(T previous, T next);
