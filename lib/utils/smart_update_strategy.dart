import 'package:geolocator/geolocator.dart';

/// Smart Update Strategy - Intelligent AR pin update management
/// 
/// This class prevents unnecessary AR pin updates to improve stability
/// and reduce jitter. It implements two key strategies:
/// 
/// 1. Distance threshold: Only update if user moved significantly (>0.5m)
/// 2. Time threshold: Force update after time period (>2s) to prevent staleness
/// 
/// Benefits:
/// - Eliminates drift when standing still
/// - Reduces CPU/GPU load by limiting updates
/// - Maintains responsiveness when moving
/// - Prevents "nervous" pin behavior
/// - Improves battery life
class SmartUpdateStrategy {
  // Minimum distance in meters before triggering an update
  // 0.5m is chosen as it's larger than typical GPS jitter (±3-5m)
  // but small enough to feel responsive when walking
  static const double _minDistanceThreshold = 0.5;

  // Maximum time in seconds before forcing an update
  // Even if user hasn't moved, update after 2 seconds
  // to ensure we don't miss genuine position changes
  static const Duration _maxTimeBetweenUpdates = Duration(seconds: 2);

  // Last position that triggered an update
  Position? _lastUpdatedPosition;

  // Timestamp of last update
  DateTime? _lastUpdateTime;

  // Total updates performed (for metrics)
  int _updateCount = 0;

  // Total updates skipped (for metrics)
  int _skippedCount = 0;

  /// Determines if AR pins should be updated based on new position
  /// 
  /// [newPosition] - Latest GPS position from location service
  /// Returns: true if pins should update, false if update should be skipped
  bool shouldUpdate(Position newPosition) {
    // First position always triggers update
    if (_lastUpdatedPosition == null || _lastUpdateTime == null) {
      _recordUpdate(newPosition);
      return true;
    }

    // Check time threshold - force update if too much time passed
    final timeSinceLastUpdate = DateTime.now().difference(_lastUpdateTime!);
    if (timeSinceLastUpdate > _maxTimeBetweenUpdates) {
      _recordUpdate(newPosition);
      return true;
    }

    // Check distance threshold - update if moved significantly
    final distance = _calculateDistance(
      _lastUpdatedPosition!,
      newPosition,
    );

    if (distance >= _minDistanceThreshold) {
      _recordUpdate(newPosition);
      return true;
    }

    // Skip this update - not enough movement
    _skippedCount++;
    return false;
  }

  /// Calculates distance between two positions using Haversine formula
  /// 
  /// This accounts for Earth's curvature for accurate results
  /// even over longer distances
  /// 
  /// Returns: Distance in meters
  double _calculateDistance(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }

  /// Records an update for tracking purposes
  void _recordUpdate(Position position) {
    _lastUpdatedPosition = position;
    _lastUpdateTime = DateTime.now();
    _updateCount++;
  }

  /// Gets the efficiency ratio of this strategy
  /// 
  /// Returns value between 0.0 and 1.0
  /// Higher = more updates skipped = better efficiency
  /// 
  /// Example: 0.75 means 75% of potential updates were skipped
  double get efficiencyRatio {
    final total = _updateCount + _skippedCount;
    if (total == 0) return 0.0;
    return _skippedCount / total;
  }

  /// Gets total number of updates performed
  int get updateCount => _updateCount;

  /// Gets total number of updates skipped
  int get skippedCount => _skippedCount;

  /// Gets time since last update
  /// Returns null if no updates performed yet
  Duration? get timeSinceLastUpdate {
    if (_lastUpdateTime == null) return null;
    return DateTime.now().difference(_lastUpdateTime!);
  }

  /// Gets the last position that triggered an update
  Position? get lastUpdatedPosition => _lastUpdatedPosition;

  /// Resets the strategy state
  /// 
  /// Call this when:
  /// - Starting a new AR session
  /// - User manually refreshes position
  /// - Switching to a different location
  void reset() {
    _lastUpdatedPosition = null;
    _lastUpdateTime = null;
    _updateCount = 0;
    _skippedCount = 0;
  }

  /// Adjusts thresholds dynamically based on movement pattern
  /// 
  /// This is an advanced feature that could be implemented to:
  /// - Tighten thresholds when user is stationary
  /// - Loosen thresholds when user is walking/moving
  /// - Adapt to GPS accuracy conditions
  /// 
  /// Currently returns default thresholds but can be extended
  UpdateThresholds getAdaptiveThresholds(Position currentPosition) {
    // Future enhancement: analyze speed, acceleration, accuracy
    // to dynamically adjust thresholds
    
    // For now, return static thresholds
    return UpdateThresholds(
      distanceMeters: _minDistanceThreshold,
      timeSeconds: _maxTimeBetweenUpdates.inSeconds,
    );
  }

  /// Provides debug information about update strategy performance
  Map<String, dynamic> getDebugInfo() {
    return {
      'updateCount': _updateCount,
      'skippedCount': _skippedCount,
      'efficiencyRatio': efficiencyRatio.toStringAsFixed(2),
      'timeSinceLastUpdate': timeSinceLastUpdate?.inSeconds ?? 0,
      'lastPosition': _lastUpdatedPosition != null
          ? '${_lastUpdatedPosition!.latitude.toStringAsFixed(6)}, ${_lastUpdatedPosition!.longitude.toStringAsFixed(6)}'
          : 'none',
    };
  }
}

/// Data class holding update threshold values
class UpdateThresholds {
  final double distanceMeters;
  final int timeSeconds;

  UpdateThresholds({
    required this.distanceMeters,
    required this.timeSeconds,
  });
}

