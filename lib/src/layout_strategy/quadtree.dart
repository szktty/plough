import 'dart:ui';

/// Lightweight representation of a body (node) in the quadtree.
class QuadtreeBody {
  const QuadtreeBody({
    required this.id,
    required this.x,
    required this.y,
    this.mass = 1.0,
  });

  final Object id;
  final double x;
  final double y;
  final double mass;
}

/// A quadtree node used for Barnes-Hut force approximation.
///
/// Each internal node stores the center-of-mass and total mass of all bodies
/// in its region. Leaf nodes store a single body directly.
///
/// Usage:
/// ```dart
/// final tree = QuadtreeNode.build(bodies, bounds);
/// for (final body in bodies) {
///   final force = tree.computeRepulsion(body, coulombConstant, theta);
/// }
/// ```
class QuadtreeNode {
  QuadtreeNode._(this.bounds);

  /// The spatial region covered by this node.
  final Rect bounds;

  // Body stored at this leaf (null if internal or empty).
  QuadtreeBody? _body;

  // Whether this node is a leaf with exactly one body.
  bool _isLeaf = true;

  // Accumulated center-of-mass position.
  double _cx = 0;
  double _cy = 0;

  // Total mass of bodies in this subtree.
  double _totalMass = 0;

  // Four children: NW, NE, SW, SE.
  QuadtreeNode? _nw;
  QuadtreeNode? _ne;
  QuadtreeNode? _sw;
  QuadtreeNode? _se;

  // ---------------------------------------------------------------------------
  // Construction
  // ---------------------------------------------------------------------------

  /// Builds a quadtree from [bodies] spanning [bounds].
  static QuadtreeNode build(List<QuadtreeBody> bodies, Rect bounds) {
    final root = QuadtreeNode._(bounds);
    for (final body in bodies) {
      root._insert(body);
    }
    return root;
  }

  void _insert(QuadtreeBody body) {
    if (_totalMass == 0) {
      // Empty node — become a leaf.
      _body = body;
      _cx = body.x;
      _cy = body.y;
      _totalMass = body.mass;
      return;
    }

    // Update center-of-mass incrementally.
    _cx = (_cx * _totalMass + body.x * body.mass) / (_totalMass + body.mass);
    _cy = (_cy * _totalMass + body.y * body.mass) / (_totalMass + body.mass);
    _totalMass += body.mass;

    if (_isLeaf) {
      // Subdivide: push the existing body into a child.
      _isLeaf = false;
      if (_body != null) {
        _childFor(_body!)._insert(_body!);
        _body = null;
      }
    }

    _childFor(body)._insert(body);
  }

  QuadtreeNode _childFor(QuadtreeBody body) {
    final midX = (bounds.left + bounds.right) / 2;
    final midY = (bounds.top + bounds.bottom) / 2;

    if (body.x < midX) {
      if (body.y < midY) {
        return _nw ??= QuadtreeNode._(
          Rect.fromLTRB(bounds.left, bounds.top, midX, midY),
        );
      } else {
        return _sw ??= QuadtreeNode._(
          Rect.fromLTRB(bounds.left, midY, midX, bounds.bottom),
        );
      }
    } else {
      if (body.y < midY) {
        return _ne ??= QuadtreeNode._(
          Rect.fromLTRB(midX, bounds.top, bounds.right, midY),
        );
      } else {
        return _se ??= QuadtreeNode._(
          Rect.fromLTRB(midX, midY, bounds.right, bounds.bottom),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Force computation
  // ---------------------------------------------------------------------------

  /// Computes the net Coulomb repulsion force on [body] using the Barnes-Hut
  /// approximation with threshold [theta] (typically 0.5).
  ///
  /// Returns the force as an [Offset].
  Offset computeRepulsion(
    QuadtreeBody body,
    double coulombConstant,
    double theta,
  ) {
    if (_totalMass == 0) return Offset.zero;

    final dx = _cx - body.x;
    final dy = _cy - body.y;
    final distSq = dx * dx + dy * dy;

    if (distSq == 0) return Offset.zero;

    // If this is a leaf containing the same body, skip.
    if (_isLeaf && _body?.id == body.id) return Offset.zero;

    final regionWidth = bounds.width;

    // Barnes-Hut criterion: use approximation when region is small enough.
    if (_isLeaf || (regionWidth * regionWidth) / distSq < theta * theta) {
      final dist = _fastSqrt(distSq);
      final force = coulombConstant * _totalMass / distSq;
      // Repulsion: push body away from center-of-mass.
      final scale = -force / dist;
      return Offset(dx * scale, dy * scale);
    }

    // Recurse into children.
    var fx = 0.0;
    var fy = 0.0;
    for (final child in [_nw, _ne, _sw, _se]) {
      if (child == null) continue;
      final f = child.computeRepulsion(body, coulombConstant, theta);
      fx += f.dx;
      fy += f.dy;
    }
    return Offset(fx, fy);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Fast approximate square root using Newton's method (2 iterations).
  static double _fastSqrt(double x) {
    if (x <= 0) return 0.00001;
    var r = x;
    r = (r + x / r) * 0.5;
    r = (r + x / r) * 0.5;
    return r;
  }
}
