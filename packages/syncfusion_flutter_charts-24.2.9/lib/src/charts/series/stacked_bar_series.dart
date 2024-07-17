import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/core.dart';

import '../base.dart';
import '../common/chart_point.dart';
import '../common/core_tooltip.dart';
import '../common/element_widget.dart';
import '../common/marker.dart';
import '../interactions/tooltip.dart';
import '../interactions/trackball.dart';
import '../utils/constants.dart';
import '../utils/enum.dart';
import '../utils/helper.dart';
import '../utils/typedef.dart';
import 'chart_series.dart';

/// Renders the stacked bar series.
///
/// Stacked bar chart consists of multiple bar series stacked horizontally one
/// after another. The length of each series is determined by the value in each
/// data point.
///
/// To render a stacked bar chart, create an instance of [StackedBarSeries],
/// and add it to the series collection property of [SfCartesianChart].
///
/// Provides options to customize properties such as [color], [opacity],
/// [borderWidth], [borderColor], [borderRadius] of the stacked bar segments.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=NCUDBD_ClHo}
@immutable
class StackedBarSeries<T, D> extends StackedSeriesBase<T, D> {
  /// Creating an argument constructor of StackedBarSeries class.
  const StackedBarSeries({
    super.key,
    super.onCreateRenderer,
    super.dataSource,
    required super.xValueMapper,
    required super.yValueMapper,
    super.sortFieldValueMapper,
    super.pointColorMapper,
    super.dataLabelMapper,
    super.sortingOrder,
    super.isTrackVisible = false,
    this.groupName = '',
    super.trackColor = Colors.grey,
    super.trackBorderColor = Colors.transparent,
    super.trackBorderWidth = 1.0,
    super.trackPadding = 0.0,
    this.borderRadius = BorderRadius.zero,
    this.spacing = 0.0,
    super.xAxisName,
    super.yAxisName,
    super.name,
    super.color,
    this.width = 0.7,
    super.markerSettings,
    super.emptyPointSettings,
    super.dataLabelSettings,
    super.initialIsVisible,
    super.gradient,
    super.borderGradient,
    super.enableTooltip = true,
    super.animationDuration,
    super.trendlines,
    this.borderColor = Colors.transparent,
    super.borderWidth,
    super.selectionBehavior,
    super.isVisibleInLegend,
    super.legendIconType,
    super.legendItemText,
    super.dashArray,
    super.opacity,
    super.animationDelay,
    super.onRendererCreated,
    super.onPointTap,
    super.onPointDoubleTap,
    super.onPointLongPress,
    super.onCreateShader,
    super.initialSelectedDataIndexes,
  });

  /// Customizes the corners of the column. Each corner can be customized with
  /// a desired value or with a single value.
  ///
  /// Defaults to `BorderRadius.zero`.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return SfCartesianChart(
  ///     series: <StackedBarSeries<SalesData, num>>[
  ///       StackedBarSeries<SalesData, num>(
  ///         borderRadius: BorderRadius.circular(5),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  final BorderRadius borderRadius;

  final double spacing;

  final double width;

  /// Specifies the group name.
  final String groupName;

  final Color borderColor;

  @override
  bool transposed() => true;

  /// Create the stacked bar series renderer.
  @override
  StackedBarSeriesRenderer<T, D> createRenderer() {
    StackedBarSeriesRenderer<T, D> stackedAreaSeriesRenderer;
    if (onCreateRenderer != null) {
      stackedAreaSeriesRenderer =
          onCreateRenderer!(this) as StackedBarSeriesRenderer<T, D>;
      return stackedAreaSeriesRenderer;
    }
    return StackedBarSeriesRenderer<T, D>();
  }

  @override
  StackedBarSeriesRenderer<T, D> createRenderObject(BuildContext context) {
    final StackedBarSeriesRenderer<T, D> renderer =
        super.createRenderObject(context) as StackedBarSeriesRenderer<T, D>;
    renderer
      ..spacing = spacing
      ..width = width
      ..groupName = groupName
      ..borderColor = borderColor
      ..borderRadius = borderRadius;
    return renderer;
  }

  @override
  void updateRenderObject(
      BuildContext context, StackedBarSeriesRenderer<T, D> renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..spacing = spacing
      ..width = width
      ..groupName = groupName
      ..borderColor = borderColor
      ..borderRadius = borderRadius;
  }
}

/// Creates series renderer for stacked bar series.
class StackedBarSeriesRenderer<T, D> extends StackedSeriesRenderer<T, D>
    with SbsSeriesMixin<T, D>, ClusterSeriesMixin, SegmentAnimationMixin<T, D> {
  Color get borderColor => _borderColor;
  Color _borderColor = Colors.transparent;
  set borderColor(Color value) {
    if (_borderColor != value) {
      _borderColor = value;
      markNeedsSegmentsPaint();
    }
  }

  BorderRadius get borderRadius => _borderRadius;
  BorderRadius _borderRadius = BorderRadius.zero;
  set borderRadius(BorderRadius value) {
    if (_borderRadius != value) {
      _borderRadius = value;
      markNeedsLayout();
    }
  }

  @override
  ChartDataLabelAlignment effectiveDataLabelAlignment(
      ChartDataLabelAlignment alignment,
      ChartDataPointType position,
      ChartElementParentData? previous,
      ChartElementParentData current,
      ChartElementParentData? next) {
    return alignment == ChartDataLabelAlignment.auto ||
            alignment == ChartDataLabelAlignment.outer
        ? ChartDataLabelAlignment.top
        : alignment;
  }

  @override
  Offset dataLabelPosition(ChartElementParentData current,
      ChartDataLabelAlignment alignment, Size size) {
    final num x = current.x! + (sbsInfo.maximum + sbsInfo.minimum) / 2;
    final num stackValue = yValues[current.dataPointIndex];
    double y = current.y!.toDouble();
    if (alignment == ChartDataLabelAlignment.bottom) {
      y = y - stackValue;
    } else if (alignment == ChartDataLabelAlignment.middle) {
      y = (y + (y - stackValue)) / 2;
    }
    return _calculateDataLabelPosition(x, y, alignment, size);
  }

  Offset _calculateDataLabelPosition(
      num x, num y, ChartDataLabelAlignment alignment, Size size) {
    final EdgeInsets margin = dataLabelSettings.margin;
    double translationX = 0.0;
    double translationY = 0.0;
    switch (alignment) {
      case ChartDataLabelAlignment.auto:
      case ChartDataLabelAlignment.outer:
      case ChartDataLabelAlignment.bottom:
        if (isTransposed) {
          translationX = dataLabelPadding;
          translationY = -margin.top;
        } else {
          translationX = -margin.left;
          translationY = -(dataLabelPadding + size.height + margin.vertical);
        }
        return translateTransform(x, y, translationX, translationY);

      case ChartDataLabelAlignment.top:
        if (isTransposed) {
          translationX = -(dataLabelPadding + size.width + margin.horizontal);
          translationY = -margin.top;
        } else {
          translationX = -margin.left;
          translationY = dataLabelPadding;
        }
        return translateTransform(x, y, translationX, translationY);

      case ChartDataLabelAlignment.middle:
        final Offset center = translateTransform(x, y);
        if (isTransposed) {
          translationX = -margin.left - size.width / 2;
          translationY = -margin.top;
        } else {
          translationX = -margin.left;
          translationY = -margin.top - size.height / 2;
        }
        return center.translate(translationX, translationY);
    }
  }

  @override
  void setData(int index, ChartSegment segment) {
    super.setData(index, segment);
    segment as StackedBarSegment<T, D>
      ..series = this
      ..x = xValues[index]
      ..top = topValues[index]
      ..bottom = bottom == 0 ? bottomValues[index] : bottom
      .._actualBottom = bottom
      ..isEmpty = isEmpty(index);
  }

  /// Creates a segment for a data point in the series.
  @override
  StackedBarSegment<T, D> createSegment() => StackedBarSegment<T, D>();

  /// Changes the series color, border color, and border width.
  @override
  void customizeSegment(ChartSegment segment) {
    final StackedBarSegment<T, D> stackedBarSegment =
        segment as StackedBarSegment<T, D>;
    updateSegmentTrackerStyle(
        stackedBarSegment, trackColor, trackBorderColor, trackBorderWidth);
    updateSegmentColor(stackedBarSegment, borderColor, borderWidth);
    updateSegmentGradient(stackedBarSegment,
        gradientBounds: stackedBarSegment.segmentRect?.outerRect,
        gradient: gradient,
        borderGradient: borderGradient);
  }

  @override
  ShapeMarkerType effectiveLegendIconType() => ShapeMarkerType.stackedBarSeries;

  @override
  List<ChartSegment> contains(Offset position) {
    if (animationController != null && animationController!.isAnimating) {
      return <ChartSegment>[];
    }
    final List<ChartSegment> segmentCollection = <ChartSegment>[];
    int index = 0;
    double delta = 0;
    num? nearPointX;
    num? nearPointY;

    for (final ChartSegment segment in segments) {
      if (segment is StackedBarSegment<T, D>) {
        nearPointX ??= segment.series.xValues[0];
        nearPointY ??= segment.series.yAxis!.visibleRange!.minimum;
        final Rect rect = segment.series.paintBounds;

        final num touchXValue =
            segment.series.xAxis!.pixelToPoint(rect, position.dx, position.dy);
        final num touchYValue =
            segment.series.yAxis!.pixelToPoint(rect, position.dx, position.dy);
        final double curX = segment.series.xValues[index].toDouble();
        final double curY = segment.series.yValues[index].toDouble();
        if (delta == touchXValue - curX) {
          if ((touchYValue - curY).abs() > (touchYValue - nearPointY).abs()) {
            segmentCollection.clear();
          }
          segmentCollection.add(segment);
        } else if ((touchXValue - curX).abs() <=
            (touchXValue - nearPointX).abs()) {
          nearPointX = curX;
          nearPointY = curY;
          delta = touchXValue - curX;
          segmentCollection.clear();
          segmentCollection.add(segment);
        }
      }
      index++;
    }
    return segmentCollection;
  }
}

/// Segment class for stacked bar series.
class StackedBarSegment<T, D> extends ChartSegment with BarSeriesTrackerMixin {
  late StackedBarSeriesRenderer<T, D> series;
  late num x;

  num top = double.nan;
  num bottom = double.nan;
  num _actualBottom = double.nan;

  RRect? _oldSegmentRect;
  RRect? segmentRect;

  @override
  void copyOldSegmentValues(
      double seriesAnimationFactor, double segmentAnimationFactor) {
    if (series.animationType == AnimationType.loading) {
      points.clear();
      _oldSegmentRect = null;
      segmentRect = null;
      return;
    }

    if (series.animationDuration > 0) {
      _oldSegmentRect =
          RRect.lerp(_oldSegmentRect, segmentRect, segmentAnimationFactor);
    } else {
      _oldSegmentRect = segmentRect;
    }
  }

  @override
  void transformValues() {
    if (x.isNaN || top.isNaN || bottom.isNaN) {
      segmentRect = null;
      _oldSegmentRect = null;
      points.clear();
      return;
    }

    points.clear();
    final PointToPixelCallback transformX = series.pointToPixelX;
    final PointToPixelCallback transformY = series.pointToPixelY;
    final num left = x + series.sbsInfo.minimum;
    final num right = x + series.sbsInfo.maximum;

    final double x1 = transformX(left, top);
    final double y1 = transformY(left, top);
    final double x2 = transformX(right, bottom);
    final double y2 = transformY(right, bottom);

    final BorderRadius borderRadius = series._borderRadius;
    segmentRect = toRRect(x1, y1, x2, y2, borderRadius);
    _oldSegmentRect ??= toRRect(
      transformX(left, _actualBottom),
      transformY(left, _actualBottom),
      transformX(right, _actualBottom),
      transformY(right, _actualBottom),
      borderRadius,
    );

    if (series.isTrackVisible) {
      calculateTrackerBounds(left, right, borderRadius, series.trackPadding,
          series.trackBorderWidth, series);
    }
  }

  @override
  bool contains(Offset position) {
    return segmentRect != null && segmentRect!.contains(position);
  }

  CartesianChartPoint<D> _chartPoint() {
    return CartesianChartPoint<D>(
      x: series.xRawValues[currentSegmentIndex],
      xValue: series.xValues[currentSegmentIndex],
      y: series.yValues[currentSegmentIndex],
      cumulative: series.topValues[currentSegmentIndex],
    );
  }

  @override
  TooltipInfo? tooltipInfo({Offset? position, int? pointIndex}) {
    if (segmentRect != null) {
      pointIndex ??= currentSegmentIndex;
      final CartesianChartPoint<D> chartPoint = _chartPoint();
      final TooltipPosition? tooltipPosition =
          series.parent?.tooltipBehavior?.tooltipPosition;
      final ChartMarker marker = series.markerAt(pointIndex);
      final double markerHeight =
          series.markerSettings.isVisible ? marker.height / 2 : 0;
      final Offset preferredPos = tooltipPosition == TooltipPosition.pointer
          ? position ?? segmentRect!.outerRect.topCenter
          : segmentRect!.outerRect.topCenter;
      return ChartTooltipInfo<T, D>(
        primaryPosition:
            series.localToGlobal(preferredPos.translate(0, -markerHeight)),
        secondaryPosition:
            series.localToGlobal(preferredPos.translate(0, markerHeight)),
        text: series.tooltipText(chartPoint),
        header: series.parent!.tooltipBehavior!.shared
            ? series.tooltipHeaderText(chartPoint)
            : series.name,
        data: series.dataSource![pointIndex],
        point: chartPoint,
        series: series.widget,
        renderer: series,
        seriesIndex: series.index,
        segmentIndex: currentSegmentIndex,
        pointIndex: pointIndex,
        markerColors: <Color?>[fillPaint.color],
        markerType: marker.type,
      );
    }
    return null;
  }

  @override
  TrackballInfo? trackballInfo(Offset position) {
    if (segmentRect != null) {
      final CartesianChartPoint<D> chartPoint = _chartPoint();
      return ChartTrackballInfo<T, D>(
        position: series.isTransposed
            ? series.yAxis!.isInversed
                ? segmentRect!.outerRect.centerLeft
                : segmentRect!.outerRect.centerRight
            : series.yAxis!.isInversed
                ? segmentRect!.outerRect.bottomCenter
                : segmentRect!.outerRect.topCenter,
        point: chartPoint,
        series: series,
        pointIndex: currentSegmentIndex,
        seriesIndex: series.index,
      );
    }
    return null;
  }

  /// Gets the color of the series.
  @override
  Paint getFillPaint() => fillPaint;

  /// Gets the border color of the series.
  @override
  Paint getStrokePaint() => strokePaint;

  /// Calculates the rendering bounds of a segment.
  @override
  void calculateSegmentPoints() {}

  /// Draws segment in series bounds.
  @override
  void onPaint(Canvas canvas) {
    if (series.isTrackVisible) {
      // Draws the tracker bounds.
      super.onPaint(canvas);
    }

    if (segmentRect == null) {
      return;
    }

    final RRect? paintRRect =
        RRect.lerp(_oldSegmentRect, segmentRect, animationFactor);
    if (paintRRect == null || paintRRect.isEmpty) {
      return;
    }

    Paint paint = getFillPaint();
    if (paint.color != Colors.transparent) {
      canvas.drawRRect(paintRRect, paint);
    }

    paint = getStrokePaint();
    final double strokeWidth = paint.strokeWidth;
    if (paint.color != Colors.transparent && strokeWidth > 0) {
      final Path strokePath = strokePathFromRRect(paintRRect, strokeWidth);
      drawDashes(canvas, series.dashArray, paint, path: strokePath);
    }
  }

  @override
  void dispose() {
    segmentRect = null;
    super.dispose();
  }
}
