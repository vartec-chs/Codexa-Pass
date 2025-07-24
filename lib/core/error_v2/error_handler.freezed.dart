// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'error_handler.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppError {

 String get message; ErrorContext get context; bool get isCritical;
/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppErrorCopyWith<AppError> get copyWith => _$AppErrorCopyWithImpl<AppError>(this as AppError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppError&&(identical(other.message, message) || other.message == message)&&(identical(other.context, context) || other.context == context)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical));
}


@override
int get hashCode => Object.hash(runtimeType,message,context,isCritical);

@override
String toString() {
  return 'AppError(message: $message, context: $context, isCritical: $isCritical)';
}


}

/// @nodoc
abstract mixin class $AppErrorCopyWith<$Res>  {
  factory $AppErrorCopyWith(AppError value, $Res Function(AppError) _then) = _$AppErrorCopyWithImpl;
@useResult
$Res call({
 String message, ErrorContext context, bool isCritical
});




}
/// @nodoc
class _$AppErrorCopyWithImpl<$Res>
    implements $AppErrorCopyWith<$Res> {
  _$AppErrorCopyWithImpl(this._self, this._then);

  final AppError _self;
  final $Res Function(AppError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? context = null,Object? isCritical = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ErrorContext,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppError].
extension AppErrorPatterns on AppError {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkError value)?  network,TResult Function( TimeoutError value)?  timeout,TResult Function( HttpError value)?  http,TResult Function( AuthError value)?  authentication,TResult Function( ValidationError value)?  validation,TResult Function( UnknownError value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network(_that);case TimeoutError() when timeout != null:
return timeout(_that);case HttpError() when http != null:
return http(_that);case AuthError() when authentication != null:
return authentication(_that);case ValidationError() when validation != null:
return validation(_that);case UnknownError() when unknown != null:
return unknown(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkError value)  network,required TResult Function( TimeoutError value)  timeout,required TResult Function( HttpError value)  http,required TResult Function( AuthError value)  authentication,required TResult Function( ValidationError value)  validation,required TResult Function( UnknownError value)  unknown,}){
final _that = this;
switch (_that) {
case NetworkError():
return network(_that);case TimeoutError():
return timeout(_that);case HttpError():
return http(_that);case AuthError():
return authentication(_that);case ValidationError():
return validation(_that);case UnknownError():
return unknown(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkError value)?  network,TResult? Function( TimeoutError value)?  timeout,TResult? Function( HttpError value)?  http,TResult? Function( AuthError value)?  authentication,TResult? Function( ValidationError value)?  validation,TResult? Function( UnknownError value)?  unknown,}){
final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network(_that);case TimeoutError() when timeout != null:
return timeout(_that);case HttpError() when http != null:
return http(_that);case AuthError() when authentication != null:
return authentication(_that);case ValidationError() when validation != null:
return validation(_that);case UnknownError() when unknown != null:
return unknown(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message,  ErrorContext context,  bool isCritical)?  network,TResult Function( String message,  ErrorContext context,  bool isCritical)?  timeout,TResult Function( int statusCode,  String message,  ErrorContext context,  bool isCritical)?  http,TResult Function( String message,  ErrorContext context,  bool isCritical)?  authentication,TResult Function( String message,  ErrorContext context,  bool isCritical)?  validation,TResult Function( String message,  ErrorContext context,  bool isCritical)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network(_that.message,_that.context,_that.isCritical);case TimeoutError() when timeout != null:
return timeout(_that.message,_that.context,_that.isCritical);case HttpError() when http != null:
return http(_that.statusCode,_that.message,_that.context,_that.isCritical);case AuthError() when authentication != null:
return authentication(_that.message,_that.context,_that.isCritical);case ValidationError() when validation != null:
return validation(_that.message,_that.context,_that.isCritical);case UnknownError() when unknown != null:
return unknown(_that.message,_that.context,_that.isCritical);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message,  ErrorContext context,  bool isCritical)  network,required TResult Function( String message,  ErrorContext context,  bool isCritical)  timeout,required TResult Function( int statusCode,  String message,  ErrorContext context,  bool isCritical)  http,required TResult Function( String message,  ErrorContext context,  bool isCritical)  authentication,required TResult Function( String message,  ErrorContext context,  bool isCritical)  validation,required TResult Function( String message,  ErrorContext context,  bool isCritical)  unknown,}) {final _that = this;
switch (_that) {
case NetworkError():
return network(_that.message,_that.context,_that.isCritical);case TimeoutError():
return timeout(_that.message,_that.context,_that.isCritical);case HttpError():
return http(_that.statusCode,_that.message,_that.context,_that.isCritical);case AuthError():
return authentication(_that.message,_that.context,_that.isCritical);case ValidationError():
return validation(_that.message,_that.context,_that.isCritical);case UnknownError():
return unknown(_that.message,_that.context,_that.isCritical);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message,  ErrorContext context,  bool isCritical)?  network,TResult? Function( String message,  ErrorContext context,  bool isCritical)?  timeout,TResult? Function( int statusCode,  String message,  ErrorContext context,  bool isCritical)?  http,TResult? Function( String message,  ErrorContext context,  bool isCritical)?  authentication,TResult? Function( String message,  ErrorContext context,  bool isCritical)?  validation,TResult? Function( String message,  ErrorContext context,  bool isCritical)?  unknown,}) {final _that = this;
switch (_that) {
case NetworkError() when network != null:
return network(_that.message,_that.context,_that.isCritical);case TimeoutError() when timeout != null:
return timeout(_that.message,_that.context,_that.isCritical);case HttpError() when http != null:
return http(_that.statusCode,_that.message,_that.context,_that.isCritical);case AuthError() when authentication != null:
return authentication(_that.message,_that.context,_that.isCritical);case ValidationError() when validation != null:
return validation(_that.message,_that.context,_that.isCritical);case UnknownError() when unknown != null:
return unknown(_that.message,_that.context,_that.isCritical);case _:
  return null;

}
}

}

/// @nodoc


class NetworkError extends AppError {
  const NetworkError(this.message, this.context, {this.isCritical = false}): super._();
  

@override final  String message;
@override final  ErrorContext context;
@override@JsonKey() final  bool isCritical;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkErrorCopyWith<NetworkError> get copyWith => _$NetworkErrorCopyWithImpl<NetworkError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkError&&(identical(other.message, message) || other.message == message)&&(identical(other.context, context) || other.context == context)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical));
}


@override
int get hashCode => Object.hash(runtimeType,message,context,isCritical);

@override
String toString() {
  return 'AppError.network(message: $message, context: $context, isCritical: $isCritical)';
}


}

/// @nodoc
abstract mixin class $NetworkErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $NetworkErrorCopyWith(NetworkError value, $Res Function(NetworkError) _then) = _$NetworkErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, ErrorContext context, bool isCritical
});




}
/// @nodoc
class _$NetworkErrorCopyWithImpl<$Res>
    implements $NetworkErrorCopyWith<$Res> {
  _$NetworkErrorCopyWithImpl(this._self, this._then);

  final NetworkError _self;
  final $Res Function(NetworkError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? context = null,Object? isCritical = null,}) {
  return _then(NetworkError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ErrorContext,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class TimeoutError extends AppError {
  const TimeoutError(this.message, this.context, {this.isCritical = false}): super._();
  

@override final  String message;
@override final  ErrorContext context;
@override@JsonKey() final  bool isCritical;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeoutErrorCopyWith<TimeoutError> get copyWith => _$TimeoutErrorCopyWithImpl<TimeoutError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeoutError&&(identical(other.message, message) || other.message == message)&&(identical(other.context, context) || other.context == context)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical));
}


@override
int get hashCode => Object.hash(runtimeType,message,context,isCritical);

@override
String toString() {
  return 'AppError.timeout(message: $message, context: $context, isCritical: $isCritical)';
}


}

/// @nodoc
abstract mixin class $TimeoutErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $TimeoutErrorCopyWith(TimeoutError value, $Res Function(TimeoutError) _then) = _$TimeoutErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, ErrorContext context, bool isCritical
});




}
/// @nodoc
class _$TimeoutErrorCopyWithImpl<$Res>
    implements $TimeoutErrorCopyWith<$Res> {
  _$TimeoutErrorCopyWithImpl(this._self, this._then);

  final TimeoutError _self;
  final $Res Function(TimeoutError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? context = null,Object? isCritical = null,}) {
  return _then(TimeoutError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ErrorContext,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class HttpError extends AppError {
  const HttpError(this.statusCode, this.message, this.context, {this.isCritical = false}): super._();
  

 final  int statusCode;
@override final  String message;
@override final  ErrorContext context;
@override@JsonKey() final  bool isCritical;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HttpErrorCopyWith<HttpError> get copyWith => _$HttpErrorCopyWithImpl<HttpError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HttpError&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.context, context) || other.context == context)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical));
}


@override
int get hashCode => Object.hash(runtimeType,statusCode,message,context,isCritical);

@override
String toString() {
  return 'AppError.http(statusCode: $statusCode, message: $message, context: $context, isCritical: $isCritical)';
}


}

/// @nodoc
abstract mixin class $HttpErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $HttpErrorCopyWith(HttpError value, $Res Function(HttpError) _then) = _$HttpErrorCopyWithImpl;
@override @useResult
$Res call({
 int statusCode, String message, ErrorContext context, bool isCritical
});




}
/// @nodoc
class _$HttpErrorCopyWithImpl<$Res>
    implements $HttpErrorCopyWith<$Res> {
  _$HttpErrorCopyWithImpl(this._self, this._then);

  final HttpError _self;
  final $Res Function(HttpError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? message = null,Object? context = null,Object? isCritical = null,}) {
  return _then(HttpError(
null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ErrorContext,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class AuthError extends AppError {
  const AuthError(this.message, this.context, {this.isCritical = true}): super._();
  

@override final  String message;
@override final  ErrorContext context;
@override@JsonKey() final  bool isCritical;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthErrorCopyWith<AuthError> get copyWith => _$AuthErrorCopyWithImpl<AuthError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthError&&(identical(other.message, message) || other.message == message)&&(identical(other.context, context) || other.context == context)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical));
}


@override
int get hashCode => Object.hash(runtimeType,message,context,isCritical);

@override
String toString() {
  return 'AppError.authentication(message: $message, context: $context, isCritical: $isCritical)';
}


}

/// @nodoc
abstract mixin class $AuthErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $AuthErrorCopyWith(AuthError value, $Res Function(AuthError) _then) = _$AuthErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, ErrorContext context, bool isCritical
});




}
/// @nodoc
class _$AuthErrorCopyWithImpl<$Res>
    implements $AuthErrorCopyWith<$Res> {
  _$AuthErrorCopyWithImpl(this._self, this._then);

  final AuthError _self;
  final $Res Function(AuthError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? context = null,Object? isCritical = null,}) {
  return _then(AuthError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ErrorContext,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ValidationError extends AppError {
  const ValidationError(this.message, this.context, {this.isCritical = false}): super._();
  

@override final  String message;
@override final  ErrorContext context;
@override@JsonKey() final  bool isCritical;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationErrorCopyWith<ValidationError> get copyWith => _$ValidationErrorCopyWithImpl<ValidationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationError&&(identical(other.message, message) || other.message == message)&&(identical(other.context, context) || other.context == context)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical));
}


@override
int get hashCode => Object.hash(runtimeType,message,context,isCritical);

@override
String toString() {
  return 'AppError.validation(message: $message, context: $context, isCritical: $isCritical)';
}


}

/// @nodoc
abstract mixin class $ValidationErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $ValidationErrorCopyWith(ValidationError value, $Res Function(ValidationError) _then) = _$ValidationErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, ErrorContext context, bool isCritical
});




}
/// @nodoc
class _$ValidationErrorCopyWithImpl<$Res>
    implements $ValidationErrorCopyWith<$Res> {
  _$ValidationErrorCopyWithImpl(this._self, this._then);

  final ValidationError _self;
  final $Res Function(ValidationError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? context = null,Object? isCritical = null,}) {
  return _then(ValidationError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ErrorContext,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class UnknownError extends AppError {
  const UnknownError(this.message, this.context, {this.isCritical = true}): super._();
  

@override final  String message;
@override final  ErrorContext context;
@override@JsonKey() final  bool isCritical;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownErrorCopyWith<UnknownError> get copyWith => _$UnknownErrorCopyWithImpl<UnknownError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownError&&(identical(other.message, message) || other.message == message)&&(identical(other.context, context) || other.context == context)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical));
}


@override
int get hashCode => Object.hash(runtimeType,message,context,isCritical);

@override
String toString() {
  return 'AppError.unknown(message: $message, context: $context, isCritical: $isCritical)';
}


}

/// @nodoc
abstract mixin class $UnknownErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $UnknownErrorCopyWith(UnknownError value, $Res Function(UnknownError) _then) = _$UnknownErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, ErrorContext context, bool isCritical
});




}
/// @nodoc
class _$UnknownErrorCopyWithImpl<$Res>
    implements $UnknownErrorCopyWith<$Res> {
  _$UnknownErrorCopyWithImpl(this._self, this._then);

  final UnknownError _self;
  final $Res Function(UnknownError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? context = null,Object? isCritical = null,}) {
  return _then(UnknownError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ErrorContext,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
