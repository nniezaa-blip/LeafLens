// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
DashboardUpdate _$DashboardUpdateFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'telemetry':
          return TelemetryUpdate.fromJson(
            json
          );
                case 'ghs':
          return GHSUpdate.fromJson(
            json
          );
                case 'waterSystem':
          return WaterSystemUpdate.fromJson(
            json
          );
        
          default:
            return AckUpdate.fromJson(
  json
);
        }
      
}

/// @nodoc
mixin _$DashboardUpdate {



  /// Serializes this DashboardUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardUpdate);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DashboardUpdate()';
}


}

/// @nodoc
class $DashboardUpdateCopyWith<$Res>  {
$DashboardUpdateCopyWith(DashboardUpdate _, $Res Function(DashboardUpdate) __);
}


/// Adds pattern-matching-related methods to [DashboardUpdate].
extension DashboardUpdatePatterns on DashboardUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TelemetryUpdate value)?  telemetry,TResult Function( GHSUpdate value)?  ghs,TResult Function( WaterSystemUpdate value)?  waterSystem,TResult Function( AckUpdate value)?  ack,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TelemetryUpdate() when telemetry != null:
return telemetry(_that);case GHSUpdate() when ghs != null:
return ghs(_that);case WaterSystemUpdate() when waterSystem != null:
return waterSystem(_that);case AckUpdate() when ack != null:
return ack(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TelemetryUpdate value)  telemetry,required TResult Function( GHSUpdate value)  ghs,required TResult Function( WaterSystemUpdate value)  waterSystem,required TResult Function( AckUpdate value)  ack,}){
final _that = this;
switch (_that) {
case TelemetryUpdate():
return telemetry(_that);case GHSUpdate():
return ghs(_that);case WaterSystemUpdate():
return waterSystem(_that);case AckUpdate():
return ack(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TelemetryUpdate value)?  telemetry,TResult? Function( GHSUpdate value)?  ghs,TResult? Function( WaterSystemUpdate value)?  waterSystem,TResult? Function( AckUpdate value)?  ack,}){
final _that = this;
switch (_that) {
case TelemetryUpdate() when telemetry != null:
return telemetry(_that);case GHSUpdate() when ghs != null:
return ghs(_that);case WaterSystemUpdate() when waterSystem != null:
return waterSystem(_that);case AckUpdate() when ack != null:
return ack(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( double? soilMoisture,  double? temperature,  double? humidity,  double? waterLevel,  Map<String, int>? recordedAt,  Map<String, String>? source)?  telemetry,TResult Function( double score,  String status,  bool stale)?  ghs,TResult Function(@JsonKey(name: 'water_level')  double tankLevelPercent, @JsonKey(name: 'refill_active')  bool refillActive, @JsonKey(name: 'safety_lockout')  bool safetyLockout)?  waterSystem,TResult Function( String type,  bool success)?  ack,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TelemetryUpdate() when telemetry != null:
return telemetry(_that.soilMoisture,_that.temperature,_that.humidity,_that.waterLevel,_that.recordedAt,_that.source);case GHSUpdate() when ghs != null:
return ghs(_that.score,_that.status,_that.stale);case WaterSystemUpdate() when waterSystem != null:
return waterSystem(_that.tankLevelPercent,_that.refillActive,_that.safetyLockout);case AckUpdate() when ack != null:
return ack(_that.type,_that.success);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( double? soilMoisture,  double? temperature,  double? humidity,  double? waterLevel,  Map<String, int>? recordedAt,  Map<String, String>? source)  telemetry,required TResult Function( double score,  String status,  bool stale)  ghs,required TResult Function(@JsonKey(name: 'water_level')  double tankLevelPercent, @JsonKey(name: 'refill_active')  bool refillActive, @JsonKey(name: 'safety_lockout')  bool safetyLockout)  waterSystem,required TResult Function( String type,  bool success)  ack,}) {final _that = this;
switch (_that) {
case TelemetryUpdate():
return telemetry(_that.soilMoisture,_that.temperature,_that.humidity,_that.waterLevel,_that.recordedAt,_that.source);case GHSUpdate():
return ghs(_that.score,_that.status,_that.stale);case WaterSystemUpdate():
return waterSystem(_that.tankLevelPercent,_that.refillActive,_that.safetyLockout);case AckUpdate():
return ack(_that.type,_that.success);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( double? soilMoisture,  double? temperature,  double? humidity,  double? waterLevel,  Map<String, int>? recordedAt,  Map<String, String>? source)?  telemetry,TResult? Function( double score,  String status,  bool stale)?  ghs,TResult? Function(@JsonKey(name: 'water_level')  double tankLevelPercent, @JsonKey(name: 'refill_active')  bool refillActive, @JsonKey(name: 'safety_lockout')  bool safetyLockout)?  waterSystem,TResult? Function( String type,  bool success)?  ack,}) {final _that = this;
switch (_that) {
case TelemetryUpdate() when telemetry != null:
return telemetry(_that.soilMoisture,_that.temperature,_that.humidity,_that.waterLevel,_that.recordedAt,_that.source);case GHSUpdate() when ghs != null:
return ghs(_that.score,_that.status,_that.stale);case WaterSystemUpdate() when waterSystem != null:
return waterSystem(_that.tankLevelPercent,_that.refillActive,_that.safetyLockout);case AckUpdate() when ack != null:
return ack(_that.type,_that.success);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class TelemetryUpdate implements DashboardUpdate {
  const TelemetryUpdate({this.soilMoisture, this.temperature, this.humidity, this.waterLevel,  Map<String, int>? recordedAt,  Map<String, String>? source,  String? $type}): _recordedAt = recordedAt,_source = source,$type = $type ?? 'telemetry';
  factory TelemetryUpdate.fromJson(Map<String, dynamic> json) => _$TelemetryUpdateFromJson(json);

 final  double? soilMoisture;
 final  double? temperature;
 final  double? humidity;
 final  double? waterLevel;
 final  Map<String, int>? _recordedAt;
 Map<String, int>? get recordedAt {
  final value = _recordedAt;
  if (value == null) return null;
  if (_recordedAt is EqualUnmodifiableMapView) return _recordedAt;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, String>? _source;
 Map<String, String>? get source {
  final value = _source;
  if (value == null) return null;
  if (_source is EqualUnmodifiableMapView) return _source;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of DashboardUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelemetryUpdateCopyWith<TelemetryUpdate> get copyWith => _$TelemetryUpdateCopyWithImpl<TelemetryUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TelemetryUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetryUpdate&&(identical(other.soilMoisture, soilMoisture) || other.soilMoisture == soilMoisture)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.humidity, humidity) || other.humidity == humidity)&&(identical(other.waterLevel, waterLevel) || other.waterLevel == waterLevel)&&const DeepCollectionEquality().equals(other.recordedAt, _recordedAt)&&const DeepCollectionEquality().equals(other.source, _source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,soilMoisture,temperature,humidity,waterLevel,const DeepCollectionEquality().hash(_recordedAt),const DeepCollectionEquality().hash(_source));
}

@override
String toString() {
    return 'DashboardUpdate.telemetry(soilMoisture: $soilMoisture, temperature: $temperature, humidity: $humidity, waterLevel: $waterLevel, recordedAt: $recordedAt, source: $source)';
}


}

/// @nodoc
abstract mixin class $TelemetryUpdateCopyWith<$Res> implements $DashboardUpdateCopyWith<$Res> {
  factory $TelemetryUpdateCopyWith(TelemetryUpdate value, $Res Function(TelemetryUpdate) _then) = _$TelemetryUpdateCopyWithImpl;
@useResult
$Res call({
 double? soilMoisture, double? temperature, double? humidity, double? waterLevel, Map<String, int>? recordedAt, Map<String, String>? source
});




}
/// @nodoc
class _$TelemetryUpdateCopyWithImpl<$Res>
    implements $TelemetryUpdateCopyWith<$Res> {
  _$TelemetryUpdateCopyWithImpl(this._self, this._then);

  final TelemetryUpdate _self;
  final $Res Function(TelemetryUpdate) _then;

/// Create a copy of DashboardUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? soilMoisture = freezed,Object? temperature = freezed,Object? humidity = freezed,Object? waterLevel = freezed,Object? recordedAt = freezed,Object? source = freezed,}) {
  return _then(TelemetryUpdate(
soilMoisture: freezed == soilMoisture ? _self.soilMoisture : soilMoisture // ignore: cast_nullable_to_non_nullable
as double?,temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double?,humidity: freezed == humidity ? _self.humidity : humidity // ignore: cast_nullable_to_non_nullable
as double?,waterLevel: freezed == waterLevel ? _self.waterLevel : waterLevel // ignore: cast_nullable_to_non_nullable
as double?,recordedAt: freezed == recordedAt ? _self._recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,source: freezed == source ? _self._source : source // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class GHSUpdate implements DashboardUpdate {
  const GHSUpdate({required this.score, required this.status, this.stale = false,  String? $type}): $type = $type ?? 'ghs';
  factory GHSUpdate.fromJson(Map<String, dynamic> json) => _$GHSUpdateFromJson(json);

 final  double score;
 final  String status;
@JsonKey() final  bool stale;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of DashboardUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GHSUpdateCopyWith<GHSUpdate> get copyWith => _$GHSUpdateCopyWithImpl<GHSUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GHSUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is GHSUpdate&&(identical(other.score, score) || other.score == score)&&(identical(other.status, status) || other.status == status)&&(identical(other.stale, stale) || other.stale == stale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,score,status,stale);
}

@override
String toString() {
    return 'DashboardUpdate.ghs(score: $score, status: $status, stale: $stale)';
}


}

/// @nodoc
abstract mixin class $GHSUpdateCopyWith<$Res> implements $DashboardUpdateCopyWith<$Res> {
  factory $GHSUpdateCopyWith(GHSUpdate value, $Res Function(GHSUpdate) _then) = _$GHSUpdateCopyWithImpl;
@useResult
$Res call({
 double score, String status, bool stale
});




}
/// @nodoc
class _$GHSUpdateCopyWithImpl<$Res>
    implements $GHSUpdateCopyWith<$Res> {
  _$GHSUpdateCopyWithImpl(this._self, this._then);

  final GHSUpdate _self;
  final $Res Function(GHSUpdate) _then;

/// Create a copy of DashboardUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? score = null,Object? status = null,Object? stale = null,}) {
  return _then(GHSUpdate(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class WaterSystemUpdate implements DashboardUpdate {
  const WaterSystemUpdate({@JsonKey(name: 'water_level') required this.tankLevelPercent, @JsonKey(name: 'refill_active') required this.refillActive, @JsonKey(name: 'safety_lockout') required this.safetyLockout,  String? $type}): $type = $type ?? 'waterSystem';
  factory WaterSystemUpdate.fromJson(Map<String, dynamic> json) => _$WaterSystemUpdateFromJson(json);

@JsonKey(name: 'water_level') final  double tankLevelPercent;
@JsonKey(name: 'refill_active') final  bool refillActive;
@JsonKey(name: 'safety_lockout') final  bool safetyLockout;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of DashboardUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaterSystemUpdateCopyWith<WaterSystemUpdate> get copyWith => _$WaterSystemUpdateCopyWithImpl<WaterSystemUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WaterSystemUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WaterSystemUpdate&&(identical(other.tankLevelPercent, tankLevelPercent) || other.tankLevelPercent == tankLevelPercent)&&(identical(other.refillActive, refillActive) || other.refillActive == refillActive)&&(identical(other.safetyLockout, safetyLockout) || other.safetyLockout == safetyLockout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tankLevelPercent,refillActive,safetyLockout);
}

@override
String toString() {
    return 'DashboardUpdate.waterSystem(tankLevelPercent: $tankLevelPercent, refillActive: $refillActive, safetyLockout: $safetyLockout)';
}


}

/// @nodoc
abstract mixin class $WaterSystemUpdateCopyWith<$Res> implements $DashboardUpdateCopyWith<$Res> {
  factory $WaterSystemUpdateCopyWith(WaterSystemUpdate value, $Res Function(WaterSystemUpdate) _then) = _$WaterSystemUpdateCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'water_level') double tankLevelPercent,@JsonKey(name: 'refill_active') bool refillActive,@JsonKey(name: 'safety_lockout') bool safetyLockout
});




}
/// @nodoc
class _$WaterSystemUpdateCopyWithImpl<$Res>
    implements $WaterSystemUpdateCopyWith<$Res> {
  _$WaterSystemUpdateCopyWithImpl(this._self, this._then);

  final WaterSystemUpdate _self;
  final $Res Function(WaterSystemUpdate) _then;

/// Create a copy of DashboardUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tankLevelPercent = null,Object? refillActive = null,Object? safetyLockout = null,}) {
  return _then(WaterSystemUpdate(
tankLevelPercent: null == tankLevelPercent ? _self.tankLevelPercent : tankLevelPercent // ignore: cast_nullable_to_non_nullable
as double,refillActive: null == refillActive ? _self.refillActive : refillActive // ignore: cast_nullable_to_non_nullable
as bool,safetyLockout: null == safetyLockout ? _self.safetyLockout : safetyLockout // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AckUpdate implements DashboardUpdate {
  const AckUpdate({required this.type, required this.success});
  factory AckUpdate.fromJson(Map<String, dynamic> json) => _$AckUpdateFromJson(json);

 final  String type;
 final  bool success;

/// Create a copy of DashboardUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AckUpdateCopyWith<AckUpdate> get copyWith => _$AckUpdateCopyWithImpl<AckUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AckUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AckUpdate&&(identical(other.type, type) || other.type == type)&&(identical(other.success, success) || other.success == success));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,success);
}

@override
String toString() {
    return 'DashboardUpdate.ack(type: $type, success: $success)';
}


}

/// @nodoc
abstract mixin class $AckUpdateCopyWith<$Res> implements $DashboardUpdateCopyWith<$Res> {
  factory $AckUpdateCopyWith(AckUpdate value, $Res Function(AckUpdate) _then) = _$AckUpdateCopyWithImpl;
@useResult
$Res call({
 String type, bool success
});




}
/// @nodoc
class _$AckUpdateCopyWithImpl<$Res>
    implements $AckUpdateCopyWith<$Res> {
  _$AckUpdateCopyWithImpl(this._self, this._then);

  final AckUpdate _self;
  final $Res Function(AckUpdate) _then;

/// Create a copy of DashboardUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? success = null,}) {
  return _then(AckUpdate(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
