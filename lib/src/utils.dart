/// Default equals comparison, uses [Object.==].
bool defaultEquals(Object? lhs, Object? rhs) => lhs == rhs;

/// Default hash code. returns [Object.hashCode].
int defaultHashCode(Object? o) => o.hashCode;
