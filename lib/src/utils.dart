/// Default equals comparison, uses [Object.==].
bool defaultEquals<T>(T lhs, T rhs) => lhs == rhs;

/// Default hash code. returns [Object.hashCode].
int defaultHashCode<T>(T o) => o.hashCode;
