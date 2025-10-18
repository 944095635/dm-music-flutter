import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Gradient;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';

/// 滑动条类型
enum SliderType { line, curve }

/// 定制滑动条组件
class DMSlider extends StatefulWidget {
  const DMSlider({
    super.key,
    required this.value,
    this.secondaryTrackValue,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.secondaryActiveColor,
    this.thumbColor,
    this.overlayColor,
    this.mouseCursor,
    this.semanticFormatterCallback,
    this.focusNode,
    this.autofocus = false,
    this.allowedInteraction,
    this.thumbRadius = 2,
    this.thumbActiveRadius = 4,
    this.sliderType = SliderType.line,
  }) : assert(min <= max),
       assert(
         value >= min && value <= max,
         'Value $value is not between minimum $min and maximum $max',
       ),
       assert(
         secondaryTrackValue == null ||
             (secondaryTrackValue >= min && secondaryTrackValue <= max),
         'SecondaryValue $secondaryTrackValue is not between $min and $max',
       ),
       assert(divisions == null || divisions > 0);

  /// 当前值
  final double value;

  /// 缓冲值
  final double? secondaryTrackValue;

  /// 滑动改变
  final ValueChanged<double>? onChanged;

  /// 开始滑动
  final ValueChanged<double>? onChangeStart;

  /// 滑动结束
  final ValueChanged<double>? onChangeEnd;

  /// 最小值 0 ~ 1
  final double min;

  /// 最大值 0 ~ 1
  final double max;

  final int? divisions;

  /// 文本信息
  final String? label;

  /// 激活的轨道颜色
  final Color? activeColor;

  /// 未激活的轨道颜色
  final Color? inactiveColor;

  /// 缓冲颜色
  final Color? secondaryActiveColor;

  /// 滑块的轨道类型
  final SliderType sliderType;

  /// 滑块颜色
  final Color? thumbColor;

  /// 滑块大小
  final double thumbRadius;

  /// 激活的滑块大小
  final double thumbActiveRadius;

  /// 浮动颜色
  final WidgetStateProperty<Color?>? overlayColor;

  /// 鼠标指针
  final MouseCursor? mouseCursor;

  /// 文字格式化回调
  final SemanticFormatterCallback? semanticFormatterCallback;

  /// 焦点组件
  final FocusNode? focusNode;

  /// 自动获取焦点
  final bool autofocus;

  /// 操作模式
  final SliderInteraction? allowedInteraction;

  @override
  State<DMSlider> createState() => _SliderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('value', value));
    properties.add(DoubleProperty('secondaryTrackValue', secondaryTrackValue));
    properties.add(
      ObjectFlagProperty<ValueChanged<double>>(
        'onChanged',
        onChanged,
        ifNull: 'disabled',
      ),
    );
    properties.add(
      ObjectFlagProperty<ValueChanged<double>>.has(
        'onChangeStart',
        onChangeStart,
      ),
    );
    properties.add(
      ObjectFlagProperty<ValueChanged<double>>.has('onChangeEnd', onChangeEnd),
    );
    properties.add(DoubleProperty('min', min));
    properties.add(DoubleProperty('max', max));
    properties.add(IntProperty('divisions', divisions));
    properties.add(StringProperty('label', label));
    properties.add(ColorProperty('activeColor', activeColor));
    properties.add(ColorProperty('inactiveColor', inactiveColor));
    properties.add(ColorProperty('secondaryActiveColor', secondaryActiveColor));
    properties.add(
      ObjectFlagProperty<ValueChanged<double>>.has(
        'semanticFormatterCallback',
        semanticFormatterCallback,
      ),
    );
    properties.add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode));
    properties.add(
      FlagProperty('autofocus', value: autofocus, ifTrue: 'autofocus'),
    );
  }
}

class _SliderState extends State<DMSlider> with TickerProviderStateMixin {
  static const Duration enableAnimationDuration = Duration(milliseconds: 75);
  static const Duration valueIndicatorAnimationDuration = Duration(
    milliseconds: 100,
  );

  late AnimationController overlayController;
  late AnimationController valueIndicatorController;
  late AnimationController enableController;
  late AnimationController positionController;
  Timer? interactionTimer;
  final GlobalKey _renderObjectKey = GlobalKey();
  static const Map<ShortcutActivator, Intent>
  _traditionalNavShortcutMap = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowUp): _AdjustSliderIntent.up(),
    SingleActivator(LogicalKeyboardKey.arrowDown): _AdjustSliderIntent.down(),
    SingleActivator(LogicalKeyboardKey.arrowLeft): _AdjustSliderIntent.left(),
    SingleActivator(LogicalKeyboardKey.arrowRight): _AdjustSliderIntent.right(),
  };

  // Keyboard mapping for a focused slider when using directional navigation.
  // The vertical inputs are not handled to allow navigating out of the slider.
  static const Map<ShortcutActivator, Intent>
  _directionalNavShortcutMap = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowLeft): _AdjustSliderIntent.left(),
    SingleActivator(LogicalKeyboardKey.arrowRight): _AdjustSliderIntent.right(),
  };

  // Action mapping for a focused slider.
  late Map<Type, Action<Intent>> _actionMap;

  bool get _enabled => widget.onChanged != null;

  // Value Indicator Animation that appears on the Overlay.
  PaintValueIndicator? paintValueIndicator;

  /// 正在拖动
  bool _dragging = false;

  /// 当前修改的值
  double? _currentChangedValue;

  FocusNode? _focusNode;
  FocusNode get focusNode => widget.focusNode ?? _focusNode!;

  @override
  void initState() {
    super.initState();
    overlayController = AnimationController(
      duration: kRadialReactionDuration,
      vsync: this,
    );
    valueIndicatorController = AnimationController(
      duration: valueIndicatorAnimationDuration,
      vsync: this,
    );
    enableController = AnimationController(
      duration: enableAnimationDuration,
      vsync: this,
    );
    positionController = AnimationController(
      duration: Duration.zero,
      vsync: this,
    );
    enableController.value = widget.onChanged != null ? 1.0 : 0.0;
    positionController.value = _convert(widget.value);
    _actionMap = <Type, Action<Intent>>{
      _AdjustSliderIntent: CallbackAction<_AdjustSliderIntent>(
        onInvoke: _actionHandler,
      ),
    };
    if (widget.focusNode == null) {
      // Only create a new node if the widget doesn't have one.
      _focusNode ??= FocusNode();
    }
  }

  @override
  void dispose() {
    interactionTimer?.cancel();
    overlayController.dispose();
    valueIndicatorController.dispose();
    enableController.dispose();
    positionController.dispose();
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
    _focusNode?.dispose();
    super.dispose();
  }

  void _handleChanged(double value) {
    assert(widget.onChanged != null);
    final double lerpValue = _lerp(value);
    if (_currentChangedValue != lerpValue) {
      _currentChangedValue = lerpValue;
      if (_currentChangedValue != widget.value) {
        widget.onChanged!(_currentChangedValue!);
      }
    }
  }

  void _handleDragStart(double value) {
    _dragging = true;
    widget.onChangeStart?.call(_lerp(value));
  }

  void _handleDragEnd(double value) {
    _dragging = false;
    _currentChangedValue = null;
    widget.onChangeEnd?.call(_lerp(value));
  }

  void _actionHandler(_AdjustSliderIntent intent) {
    final TextDirection directionality = Directionality.of(
      _renderObjectKey.currentContext!,
    );
    final bool shouldIncrease = switch (intent.type) {
      _SliderAdjustmentType.up => true,
      _SliderAdjustmentType.down => false,
      _SliderAdjustmentType.left => directionality == TextDirection.rtl,
      _SliderAdjustmentType.right => directionality == TextDirection.ltr,
    };

    final _RenderSlider slider =
        _renderObjectKey.currentContext!.findRenderObject()! as _RenderSlider;
    return shouldIncrease ? slider.increaseAction() : slider.decreaseAction();
  }

  bool _focused = false;
  void _handleFocusHighlightChanged(bool focused) {
    if (focused != _focused) {
      setState(() {
        _focused = focused;
      });
    }
  }

  bool _hovering = false;
  void _handleHoverChanged(bool hovering) {
    if (hovering != _hovering) {
      setState(() {
        _hovering = hovering;
      });
    }
  }

  // Returns a number between min and max, proportional to value, which must
  // be between 0.0 and 1.0.
  double _lerp(double value) {
    assert(value >= 0.0);
    assert(value <= 1.0);
    return value * (widget.max - widget.min) + widget.min;
  }

  double _discretize(double value) {
    assert(widget.divisions != null);
    assert(value >= 0.0 && value <= 1.0);

    final int divisions = widget.divisions!;
    return (value * divisions).round() / divisions;
  }

  double _convert(double value) {
    double ret = _unlerp(value);
    if (widget.divisions != null) {
      ret = _discretize(ret);
    }
    return ret;
  }

  double _unlerp(double value) {
    assert(value <= widget.max);
    assert(value >= widget.min);
    return widget.max > widget.min
        ? (value - widget.min) / (widget.max - widget.min)
        : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMediaQuery(context));
    return _buildMaterialSlider(context);
  }

  /// 构建滑动条
  Widget _buildMaterialSlider(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    SliderThemeData sliderTheme = SliderTheme.of(context);
    final SliderThemeData defaults = theme.useMaterial3
        ? _SliderDefaultsM3(context)
        : _SliderDefaultsM2(context);

    const SliderTrackShape defaultTrackShape = RoundedRectSliderTrackShape();
    const SliderTickMarkShape defaultTickMarkShape = RoundSliderTickMarkShape();
    const SliderComponentShape defaultOverlayShape = RoundSliderOverlayShape();
    const SliderComponentShape defaultThumbShape = RoundSliderThumbShape();
    final SliderComponentShape defaultValueIndicatorShape =
        defaults.valueIndicatorShape!;
    const ShowValueIndicator defaultShowValueIndicator =
        ShowValueIndicator.onlyForDiscrete;
    const SliderInteraction defaultAllowedInteraction =
        SliderInteraction.tapAndSlide;

    final Set<WidgetState> states = <WidgetState>{
      if (!_enabled) WidgetState.disabled,
      if (_hovering) WidgetState.hovered,
      if (_focused) WidgetState.focused,
      if (_dragging) WidgetState.dragged,
    };

    // The value indicator's color is not the same as the thumb and active track
    // (which can be defined by activeColor) if the
    // RectangularSliderValueIndicatorShape is used. In all other cases, the
    // value indicator is assumed to be the same as the active color.
    final SliderComponentShape valueIndicatorShape =
        sliderTheme.valueIndicatorShape ?? defaultValueIndicatorShape;
    final Color valueIndicatorColor;
    if (valueIndicatorShape is RectangularSliderValueIndicatorShape) {
      valueIndicatorColor =
          sliderTheme.valueIndicatorColor ??
          Color.alphaBlend(
            theme.colorScheme.onSurface.withOpacity(0.60),
            theme.colorScheme.surface.withOpacity(0.90),
          );
    } else {
      valueIndicatorColor =
          widget.activeColor ??
          sliderTheme.valueIndicatorColor ??
          theme.colorScheme.primary;
    }

    Color? effectiveOverlayColor() {
      return widget.overlayColor?.resolve(states) ??
          widget.activeColor?.withOpacity(0.12) ??
          WidgetStateProperty.resolveAs<Color?>(
            sliderTheme.overlayColor,
            states,
          ) ??
          WidgetStateProperty.resolveAs<Color?>(defaults.overlayColor, states);
    }

    TextStyle valueIndicatorTextStyle =
        sliderTheme.valueIndicatorTextStyle ??
        defaults.valueIndicatorTextStyle!;
    if (MediaQuery.boldTextOf(context)) {
      valueIndicatorTextStyle = valueIndicatorTextStyle.merge(
        const TextStyle(fontWeight: FontWeight.bold),
      );
    }

    sliderTheme = sliderTheme.copyWith(
      trackHeight: sliderTheme.trackHeight ?? defaults.trackHeight,
      activeTrackColor:
          widget.activeColor ??
          sliderTheme.activeTrackColor ??
          defaults.activeTrackColor,
      inactiveTrackColor:
          widget.inactiveColor ??
          sliderTheme.inactiveTrackColor ??
          defaults.inactiveTrackColor,
      secondaryActiveTrackColor:
          widget.secondaryActiveColor ??
          sliderTheme.secondaryActiveTrackColor ??
          defaults.secondaryActiveTrackColor,
      disabledActiveTrackColor:
          sliderTheme.disabledActiveTrackColor ??
          defaults.disabledActiveTrackColor,
      disabledInactiveTrackColor:
          sliderTheme.disabledInactiveTrackColor ??
          defaults.disabledInactiveTrackColor,
      disabledSecondaryActiveTrackColor:
          sliderTheme.disabledSecondaryActiveTrackColor ??
          defaults.disabledSecondaryActiveTrackColor,
      activeTickMarkColor:
          widget.inactiveColor ??
          sliderTheme.activeTickMarkColor ??
          defaults.activeTickMarkColor,
      inactiveTickMarkColor:
          widget.activeColor ??
          sliderTheme.inactiveTickMarkColor ??
          defaults.inactiveTickMarkColor,
      disabledActiveTickMarkColor:
          sliderTheme.disabledActiveTickMarkColor ??
          defaults.disabledActiveTickMarkColor,
      disabledInactiveTickMarkColor:
          sliderTheme.disabledInactiveTickMarkColor ??
          defaults.disabledInactiveTickMarkColor,
      thumbColor:
          widget.thumbColor ??
          widget.activeColor ??
          sliderTheme.thumbColor ??
          defaults.thumbColor,
      disabledThumbColor:
          sliderTheme.disabledThumbColor ?? defaults.disabledThumbColor,
      overlayColor: effectiveOverlayColor(),
      valueIndicatorColor: valueIndicatorColor,
      trackShape: sliderTheme.trackShape ?? defaultTrackShape,
      tickMarkShape: sliderTheme.tickMarkShape ?? defaultTickMarkShape,
      thumbShape: sliderTheme.thumbShape ?? defaultThumbShape,
      overlayShape: sliderTheme.overlayShape ?? defaultOverlayShape,
      valueIndicatorShape: valueIndicatorShape,
      showValueIndicator:
          sliderTheme.showValueIndicator ?? defaultShowValueIndicator,
      valueIndicatorTextStyle: valueIndicatorTextStyle,
    );
    final MouseCursor effectiveMouseCursor =
        WidgetStateProperty.resolveAs<MouseCursor?>(
          widget.mouseCursor,
          states,
        ) ??
        sliderTheme.mouseCursor?.resolve(states) ??
        WidgetStateMouseCursor.clickable.resolve(states);
    final SliderInteraction effectiveAllowedInteraction =
        widget.allowedInteraction ??
        sliderTheme.allowedInteraction ??
        defaultAllowedInteraction;

    // This size is used as the max bounds for the painting of the value
    // indicators It must be kept in sync with the function with the same name
    // in range_slider.dart.
    Size screenSize() => MediaQuery.sizeOf(context);

    VoidCallback? handleDidGainAccessibilityFocus;
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        break;
      case TargetPlatform.windows:
        handleDidGainAccessibilityFocus = () {
          // Automatically activate the slider when it receives a11y focus.
          if (!focusNode.hasFocus && focusNode.canRequestFocus) {
            focusNode.requestFocus();
          }
        };
    }

    final Map<ShortcutActivator, Intent> shortcutMap =
        switch (MediaQuery.navigationModeOf(context)) {
          NavigationMode.directional => _directionalNavShortcutMap,
          NavigationMode.traditional => _traditionalNavShortcutMap,
        };

    final double fontSize =
        sliderTheme.valueIndicatorTextStyle?.fontSize ?? kDefaultFontSize;
    final double fontSizeToScale = fontSize == 0.0
        ? kDefaultFontSize
        : fontSize;
    final TextScaler textScaler = theme.useMaterial3
        // This needs to be updated when accessibility
        // guidelines are available on the material specs page
        // https://m3.material.io/components/sliders/accessibility.
        ? MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3)
        : MediaQuery.textScalerOf(context);
    final double effectiveTextScale =
        textScaler.scale(fontSizeToScale) / fontSizeToScale;

    return Semantics(
      container: true,
      slider: true,
      onDidGainAccessibilityFocus: handleDidGainAccessibilityFocus,
      child: FocusableActionDetector(
        actions: _actionMap,
        shortcuts: shortcutMap,
        focusNode: focusNode,
        autofocus: widget.autofocus,
        enabled: _enabled,
        onShowFocusHighlight: _handleFocusHighlightChanged,
        onShowHoverHighlight: _handleHoverChanged,
        mouseCursor: effectiveMouseCursor,
        child: CompositedTransformTarget(
          link: _layerLink,
          child: _SliderRenderObjectWidget(
            key: _renderObjectKey,
            value: _convert(widget.value),
            secondaryTrackValue: (widget.secondaryTrackValue != null)
                ? _convert(widget.secondaryTrackValue!)
                : null,
            divisions: widget.divisions,
            label: widget.label,
            sliderTheme: sliderTheme,
            textScaleFactor: effectiveTextScale,
            screenSize: screenSize(),
            onChanged: (widget.onChanged != null) && (widget.max > widget.min)
                ? _handleChanged
                : null,
            onChangeStart: _handleDragStart,
            onChangeEnd: _handleDragEnd,
            state: this,
            semanticFormatterCallback: widget.semanticFormatterCallback,
            hasFocus: _focused,
            hovering: _hovering,
            allowedInteraction: effectiveAllowedInteraction,
            sliderType: widget.sliderType,
            thumbRadius: widget.thumbRadius,
            thumbActiveRadius: widget.thumbActiveRadius,
          ),
        ),
      ),
    );
  }

  final LayerLink _layerLink = LayerLink();

  OverlayEntry? overlayEntry;

  void showValueIndicator() {
    if (overlayEntry == null) {
      overlayEntry = OverlayEntry(
        builder: (BuildContext context) {
          return CompositedTransformFollower(
            link: _layerLink,
            child: _ValueIndicatorRenderObjectWidget(state: this),
          );
        },
      );
      Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
    }
  }
}

class _SliderRenderObjectWidget extends LeafRenderObjectWidget {
  const _SliderRenderObjectWidget({
    super.key,
    required this.value,
    required this.secondaryTrackValue,
    required this.divisions,
    required this.label,
    required this.sliderTheme,
    required this.textScaleFactor,
    required this.screenSize,
    required this.onChanged,
    required this.onChangeStart,
    required this.onChangeEnd,
    required this.state,
    required this.semanticFormatterCallback,
    required this.hasFocus,
    required this.hovering,
    required this.allowedInteraction,
    required this.sliderType,
    required this.thumbRadius,
    required this.thumbActiveRadius,
  });

  final double value;
  final double? secondaryTrackValue;
  final int? divisions;
  final String? label;
  final SliderThemeData sliderTheme;
  final double textScaleFactor;
  final Size screenSize;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final SemanticFormatterCallback? semanticFormatterCallback;
  final _SliderState state;
  final bool hasFocus;
  final bool hovering;
  final SliderInteraction allowedInteraction;

  /// 滑动轨道类型
  final SliderType sliderType;

  /// 滑块大小
  final double thumbRadius;

  /// 激活的滑块大小
  final double thumbActiveRadius;

  @override
  _RenderSlider createRenderObject(BuildContext context) {
    return _RenderSlider(
      value: value,
      secondaryTrackValue: secondaryTrackValue,
      divisions: divisions,
      label: label,
      sliderTheme: sliderTheme,
      textScaleFactor: textScaleFactor,
      screenSize: screenSize,
      onChanged: onChanged,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      state: state,
      textDirection: Directionality.of(context),
      semanticFormatterCallback: semanticFormatterCallback,
      platform: Theme.of(context).platform,
      hasFocus: hasFocus,
      hovering: hovering,
      gestureSettings: MediaQuery.gestureSettingsOf(context),
      allowedInteraction: allowedInteraction,
      sliderType: sliderType,
      thumbRadius: thumbRadius,
      thumbActiveRadius: thumbActiveRadius,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSlider renderObject) {
    renderObject
      // We should update the `divisions` ahead of `value`, because the `value`
      // setter dependent on the `divisions`.
      ..divisions = divisions
      ..value = value
      ..secondaryTrackValue = secondaryTrackValue
      ..label = label
      ..sliderTheme = sliderTheme
      ..textScaleFactor = textScaleFactor
      ..screenSize = screenSize
      ..onChanged = onChanged
      ..onChangeStart = onChangeStart
      ..onChangeEnd = onChangeEnd
      ..textDirection = Directionality.of(context)
      ..semanticFormatterCallback = semanticFormatterCallback
      ..platform = Theme.of(context).platform
      ..hasFocus = hasFocus
      ..hovering = hovering
      ..gestureSettings = MediaQuery.gestureSettingsOf(context)
      ..allowedInteraction = allowedInteraction;
    // Ticker provider cannot change since there's a 1:1 relationship between
    // the _SliderRenderObjectWidget object and the _SliderState object.
  }
}

class _RenderSlider extends RenderBox with RelayoutWhenSystemFontsChangeMixin {
  _RenderSlider({
    required double value,
    required double? secondaryTrackValue,
    required int? divisions,
    required String? label,
    required SliderThemeData sliderTheme,
    required double textScaleFactor,
    required Size screenSize,
    required TargetPlatform platform,
    required ValueChanged<double>? onChanged,
    required SemanticFormatterCallback? semanticFormatterCallback,
    required this.onChangeStart,
    required this.onChangeEnd,
    required _SliderState state,
    required TextDirection textDirection,
    required bool hasFocus,
    required bool hovering,
    required DeviceGestureSettings gestureSettings,
    required SliderInteraction allowedInteraction,
    required SliderType sliderType,
    required double thumbRadius,
    required double thumbActiveRadius,
  }) : assert(value >= 0.0 && value <= 1.0),
       assert(
         secondaryTrackValue == null ||
             (secondaryTrackValue >= 0.0 && secondaryTrackValue <= 1.0),
       ),
       _platform = platform,
       _semanticFormatterCallback = semanticFormatterCallback,
       _label = label,
       _value = value,
       _secondaryTrackValue = secondaryTrackValue,
       _divisions = divisions,
       _sliderTheme = sliderTheme,
       _textScaleFactor = textScaleFactor,
       _screenSize = screenSize,
       _onChanged = onChanged,
       _state = state,
       _textDirection = textDirection,
       _hasFocus = hasFocus,
       _hovering = hovering,
       _allowedInteraction = allowedInteraction,
       _sliderType = sliderType,
       _thumbRadius = thumbRadius,
       _thumbActiveRadius = thumbActiveRadius {
    _updateLabelPainter();
    final GestureArenaTeam team = GestureArenaTeam();
    _drag = HorizontalDragGestureRecognizer()
      ..team = team
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _endInteraction
      ..gestureSettings = gestureSettings;
    _tap = TapGestureRecognizer()
      ..team = team
      ..onTapDown = _handleTapDown
      ..onTapUp = _handleTapUp
      ..gestureSettings = gestureSettings;
    _overlayAnimation = CurvedAnimation(
      parent: _state.overlayController,
      curve: Curves.fastOutSlowIn,
    );
    _valueIndicatorAnimation =
        CurvedAnimation(
          parent: _state.valueIndicatorController,
          curve: Curves.fastOutSlowIn,
        )..addStatusListener((AnimationStatus status) {
          if (status.isDismissed) {
            _state.overlayEntry?.remove();
            _state.overlayEntry?.dispose();
            _state.overlayEntry = null;
          }
        });
    _enableAnimation = CurvedAnimation(
      parent: _state.enableController,
      curve: Curves.easeInOut,
    );
  }
  static const Duration _positionAnimationDuration = Duration(milliseconds: 75);
  static const Duration _minimumInteractionTime = Duration(milliseconds: 500);

  // This value is the touch target, 48, multiplied by 3.
  static const double _minPreferredTrackWidth = 144.0;

  // Compute the largest width and height needed to paint the slider shapes,
  // other than the track shape. It is assumed that these shapes are vertically
  // centered on the track.
  double get _maxSliderPartWidth =>
      _sliderPartSizes.map((Size size) => size.width).reduce(math.max);
  double get _maxSliderPartHeight =>
      _sliderPartSizes.map((Size size) => size.height).reduce(math.max);
  List<Size> get _sliderPartSizes => <Size>[
    _sliderTheme.overlayShape!.getPreferredSize(isInteractive, isDiscrete),
    _sliderTheme.thumbShape!.getPreferredSize(isInteractive, isDiscrete),
    _sliderTheme.tickMarkShape!.getPreferredSize(
      isEnabled: isInteractive,
      sliderTheme: sliderTheme,
    ),
  ];
  double get _minPreferredTrackHeight => _sliderTheme.trackHeight!;

  final _SliderState _state;
  late CurvedAnimation _overlayAnimation;
  late CurvedAnimation _valueIndicatorAnimation;
  late CurvedAnimation _enableAnimation;
  final TextPainter _labelPainter = TextPainter();
  late HorizontalDragGestureRecognizer _drag;
  late TapGestureRecognizer _tap;
  bool _active = false;
  double _currentDragValue = 0.0;
  Rect? overlayRect;

  /// 滑块轨道类型
  final SliderType? _sliderType;

  /// 滑块大小
  final double? _thumbRadius;

  /// 激活的滑块大小
  final double? _thumbActiveRadius;

  // This rect is used in gesture calculations, where the gesture coordinates
  // are relative to the sliders origin. Therefore, the offset is passed as
  // (0,0).
  Rect get _trackRect => _sliderTheme.trackShape!.getPreferredRect(
    parentBox: this,
    sliderTheme: _sliderTheme,
    isDiscrete: false,
  );

  bool get isInteractive => onChanged != null;

  bool get isDiscrete => divisions != null && divisions! > 0;

  double get value => _value;
  double _value;
  set value(double newValue) {
    assert(newValue >= 0.0 && newValue <= 1.0);
    final double convertedValue = isDiscrete ? _discretize(newValue) : newValue;
    if (convertedValue == _value) {
      return;
    }
    _value = convertedValue;
    if (isDiscrete) {
      // Reset the duration to match the distance that we're traveling, so that
      // whatever the distance, we still do it in _positionAnimationDuration,
      // and if we get re-targeted in the middle, it still takes that long to
      // get to the new location.
      final double distance = (_value - _state.positionController.value).abs();
      _state.positionController.duration = distance != 0.0
          ? _positionAnimationDuration * (1.0 / distance)
          : Duration.zero;
      _state.positionController.animateTo(
        convertedValue,
        curve: Curves.easeInOut,
      );
    } else {
      _state.positionController.value = convertedValue;
    }
    markNeedsSemanticsUpdate();
  }

  double? get secondaryTrackValue => _secondaryTrackValue;
  double? _secondaryTrackValue;
  set secondaryTrackValue(double? newValue) {
    assert(newValue == null || (newValue >= 0.0 && newValue <= 1.0));
    if (newValue == _secondaryTrackValue) {
      return;
    }
    _secondaryTrackValue = newValue;
    markNeedsSemanticsUpdate();
  }

  DeviceGestureSettings? get gestureSettings => _drag.gestureSettings;
  set gestureSettings(DeviceGestureSettings? gestureSettings) {
    _drag.gestureSettings = gestureSettings;
    _tap.gestureSettings = gestureSettings;
  }

  TargetPlatform _platform;
  TargetPlatform get platform => _platform;
  set platform(TargetPlatform value) {
    if (_platform == value) {
      return;
    }
    _platform = value;
    markNeedsSemanticsUpdate();
  }

  SemanticFormatterCallback? _semanticFormatterCallback;
  SemanticFormatterCallback? get semanticFormatterCallback =>
      _semanticFormatterCallback;
  set semanticFormatterCallback(SemanticFormatterCallback? value) {
    if (_semanticFormatterCallback == value) {
      return;
    }
    _semanticFormatterCallback = value;
    markNeedsSemanticsUpdate();
  }

  int? get divisions => _divisions;
  int? _divisions;
  set divisions(int? value) {
    if (value == _divisions) {
      return;
    }
    _divisions = value;
    markNeedsPaint();
  }

  String? get label => _label;
  String? _label;
  set label(String? value) {
    if (value == _label) {
      return;
    }
    _label = value;
    _updateLabelPainter();
  }

  SliderThemeData get sliderTheme => _sliderTheme;
  SliderThemeData _sliderTheme;
  set sliderTheme(SliderThemeData value) {
    if (value == _sliderTheme) {
      return;
    }
    _sliderTheme = value;
    _updateLabelPainter();
  }

  double get textScaleFactor => _textScaleFactor;
  double _textScaleFactor;
  set textScaleFactor(double value) {
    if (value == _textScaleFactor) {
      return;
    }
    _textScaleFactor = value;
    _updateLabelPainter();
  }

  Size get screenSize => _screenSize;
  Size _screenSize;
  set screenSize(Size value) {
    if (value == _screenSize) {
      return;
    }
    _screenSize = value;
    markNeedsPaint();
  }

  ValueChanged<double>? get onChanged => _onChanged;
  ValueChanged<double>? _onChanged;
  set onChanged(ValueChanged<double>? value) {
    if (value == _onChanged) {
      return;
    }
    final bool wasInteractive = isInteractive;
    _onChanged = value;
    if (wasInteractive != isInteractive) {
      if (isInteractive) {
        _state.enableController.forward();
      } else {
        _state.enableController.reverse();
      }
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  ValueChanged<double>? onChangeStart;
  ValueChanged<double>? onChangeEnd;

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) {
      return;
    }
    _textDirection = value;
    _updateLabelPainter();
  }

  /// True if this slider has the input focus.
  bool get hasFocus => _hasFocus;
  bool _hasFocus;
  set hasFocus(bool value) {
    if (value == _hasFocus) {
      return;
    }
    _hasFocus = value;
    _updateForFocus(_hasFocus);
    markNeedsSemanticsUpdate();
  }

  /// True if this slider is being hovered over by a pointer.
  bool get hovering => _hovering;
  bool _hovering;
  set hovering(bool value) {
    if (value == _hovering) {
      return;
    }
    _hovering = value;
    _updateForHover(_hovering);
  }

  /// True if the slider is interactive and the slider thumb is being
  /// hovered over by a pointer.
  bool _hoveringThumb = false;
  bool get hoveringThumb => _hoveringThumb;
  set hoveringThumb(bool value) {
    if (value == _hoveringThumb) {
      return;
    }
    _hoveringThumb = value;
    _updateForHover(_hovering);
  }

  SliderInteraction _allowedInteraction;
  SliderInteraction get allowedInteraction => _allowedInteraction;
  set allowedInteraction(SliderInteraction value) {
    if (value == _allowedInteraction) {
      return;
    }
    _allowedInteraction = value;
    markNeedsSemanticsUpdate();
  }

  void _updateForFocus(bool focused) {
    if (focused) {
      _state.overlayController.forward();
      if (showValueIndicator) {
        _state.valueIndicatorController.forward();
      }
    } else {
      _state.overlayController.reverse();
      if (showValueIndicator) {
        _state.valueIndicatorController.reverse();
      }
    }
  }

  void _updateForHover(bool hovered) {
    // Only show overlay when pointer is hovering the thumb.
    if (hovered && hoveringThumb) {
      _state.overlayController.forward();
    } else {
      // Only remove overlay when Slider is inactive and unfocused.
      if (!_active && !hasFocus) {
        _state.overlayController.reverse();
      }
    }
  }

  bool get showValueIndicator {
    return switch (_sliderTheme.showValueIndicator!) {
      ShowValueIndicator.onlyForDiscrete => isDiscrete,
      ShowValueIndicator.onlyForContinuous => !isDiscrete,
      ShowValueIndicator.never => false,
      ShowValueIndicator.onDrag => true,
      ShowValueIndicator.alwaysVisible => true,
      ShowValueIndicator.always => true,
    };
  }

  double get _adjustmentUnit {
    switch (_platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // Matches iOS implementation of material slider.
        return 0.1;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        // Matches Android implementation of material slider.
        return 0.05;
    }
  }

  void _updateLabelPainter() {
    if (label != null) {
      _labelPainter
        ..text = TextSpan(
          style: _sliderTheme.valueIndicatorTextStyle,
          text: label,
        )
        ..textDirection = textDirection
        ..layout();
    } else {
      _labelPainter.text = null;
    }
    markNeedsLayout();
  }

  @override
  void systemFontsDidChange() {
    super.systemFontsDidChange();
    _labelPainter.markNeedsLayout();
    _updateLabelPainter();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _overlayAnimation.addListener(markNeedsPaint);
    _valueIndicatorAnimation.addListener(markNeedsPaint);
    _enableAnimation.addListener(markNeedsPaint);
    _state.positionController.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _overlayAnimation.removeListener(markNeedsPaint);
    _valueIndicatorAnimation.removeListener(markNeedsPaint);
    _enableAnimation.removeListener(markNeedsPaint);
    _state.positionController.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _drag.dispose();
    _tap.dispose();
    _labelPainter.dispose();
    _enableAnimation.dispose();
    _valueIndicatorAnimation.dispose();
    _overlayAnimation.dispose();
    super.dispose();
  }

  double _getValueFromVisualPosition(double visualPosition) {
    return switch (textDirection) {
      TextDirection.rtl => 1.0 - visualPosition,
      TextDirection.ltr => visualPosition,
    };
  }

  double _getValueFromGlobalPosition(Offset globalPosition) {
    final double visualPosition =
        (globalToLocal(globalPosition).dx - _trackRect.left) / _trackRect.width;
    return _getValueFromVisualPosition(visualPosition);
  }

  double _discretize(double value) {
    double result = clampDouble(value, 0.0, 1.0);
    if (isDiscrete) {
      result = (result * divisions!).round() / divisions!;
    }
    return result;
  }

  void _startInteraction(Offset globalPosition) {
    if (!_state.mounted) {
      return;
    }
    _state.showValueIndicator();
    if (!_active && isInteractive) {
      switch (allowedInteraction) {
        case SliderInteraction.tapAndSlide:
        case SliderInteraction.tapOnly:
          _active = true;
          _currentDragValue = _getValueFromGlobalPosition(globalPosition);
        case SliderInteraction.slideThumb:
          if (_isPointerOnOverlay(globalPosition)) {
            _active = true;
            _currentDragValue = value;
          }
        case SliderInteraction.slideOnly:
          onChangeStart?.call(_discretize(value));
      }

      if (_active) {
        // We supply the *current* value as the start location, so that if we have
        // a tap, it consists of a call to onChangeStart with the previous value and
        // a call to onChangeEnd with the new value.
        onChangeStart?.call(_discretize(value));
        onChanged!(_discretize(_currentDragValue));
        _state.overlayController.forward();
        if (showValueIndicator) {
          _state.valueIndicatorController.forward();
          _state.interactionTimer?.cancel();
          _state.interactionTimer = Timer(
            _minimumInteractionTime * timeDilation,
            () {
              _state.interactionTimer = null;
              if (!_active && _state.valueIndicatorController.isCompleted) {
                _state.valueIndicatorController.reverse();
              }
            },
          );
        }
      }
    }
  }

  void _endInteraction() {
    if (!_state.mounted) {
      return;
    }

    if (_active && _state.mounted) {
      onChangeEnd?.call(_discretize(_currentDragValue));
      _active = false;
      _currentDragValue = 0.0;
      _state.overlayController.reverse();
      if (showValueIndicator && _state.interactionTimer == null) {
        _state.valueIndicatorController.reverse();
      }
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _startInteraction(details.globalPosition);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_state.mounted) {
      return;
    }

    // for slide only, there is no start interaction trigger, so _active
    // will be false and needs to be made true.
    if (!_active && allowedInteraction == SliderInteraction.slideOnly) {
      _active = true;
      _currentDragValue = value;
    }

    switch (allowedInteraction) {
      case SliderInteraction.tapAndSlide:
      case SliderInteraction.slideOnly:
      case SliderInteraction.slideThumb:
        if (_active && isInteractive) {
          final double valueDelta = details.primaryDelta! / _trackRect.width;
          _currentDragValue += switch (textDirection) {
            TextDirection.rtl => -valueDelta,
            TextDirection.ltr => valueDelta,
          };
          onChanged!(_discretize(_currentDragValue));
        }
      case SliderInteraction.tapOnly:
        // cannot slide (drag) as its tapOnly.
        break;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _endInteraction();
  }

  void _handleTapDown(TapDownDetails details) {
    _startInteraction(details.globalPosition);
  }

  void _handleTapUp(TapUpDetails details) {
    _endInteraction();
  }

  bool _isPointerOnOverlay(Offset globalPosition) {
    return overlayRect!.contains(globalToLocal(globalPosition));
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (!_state.mounted) {
      return;
    }
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent && isInteractive) {
      // We need to add the drag first so that it has priority.
      _drag.addPointer(event);
      _tap.addPointer(event);
    }
    if (isInteractive && overlayRect != null) {
      hoveringThumb = overlayRect!.contains(event.localPosition);
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _minPreferredTrackWidth + _maxSliderPartWidth;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _minPreferredTrackWidth + _maxSliderPartWidth;

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(_minPreferredTrackHeight, _maxSliderPartHeight);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.max(_minPreferredTrackHeight, _maxSliderPartHeight);

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(
      constraints.hasBoundedWidth
          ? constraints.maxWidth
          : _minPreferredTrackWidth + _maxSliderPartWidth,
      constraints.hasBoundedHeight
          ? constraints.maxHeight
          : math.max(_minPreferredTrackHeight, _maxSliderPartHeight),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final double controllerValue = _state.positionController.value;

    // The visual position is the position of the thumb from 0 to 1 from left
    // to right. In left to right, this is the same as the value, but it is
    // reversed for right to left text.
    final (
      double visualPosition,
      double? secondaryVisualPosition,
    ) = switch (textDirection) {
      TextDirection.rtl when _secondaryTrackValue == null => (
        1.0 - controllerValue,
        null,
      ),
      TextDirection.rtl => (1.0 - controllerValue, 1.0 - _secondaryTrackValue!),
      TextDirection.ltr => (controllerValue, _secondaryTrackValue),
    };

    final Rect trackRect = _sliderTheme.trackShape!.getPreferredRect(
      parentBox: this,
      offset: offset,
      sliderTheme: _sliderTheme,
      isDiscrete: isDiscrete,
    );

    /// 定义颜色画刷
    final ColorTween activeTrackColorTween = ColorTween(
      begin: sliderTheme.disabledActiveTrackColor,
      end: sliderTheme.activeTrackColor,
    );
    final ColorTween inactiveTrackColorTween = ColorTween(
      begin: sliderTheme.disabledInactiveTrackColor,
      end: sliderTheme.inactiveTrackColor,
    );

    // 缓冲进度
    final Offset? secondaryOffset = (secondaryVisualPosition != null)
        ? Offset(
            trackRect.left + secondaryVisualPosition * trackRect.width,
            trackRect.center.dy,
          )
        : null;

    /// 计算滑块的位置
    final Offset thumbCenter;

    // 激活的时候 容器高度
    final Tween<double> elevationTween = Tween<double>(
      begin: _thumbRadius,
      end: _thumbActiveRadius,
    );
    double additionalActiveTrackHeight = elevationTween.evaluate(
      _overlayAnimation,
    );

    /// 绘制轨道区域
    // A 模式弧线模式
    // B 模式直线模式
    if (_sliderType == SliderType.curve) {
      // 定义画刷
      var gradient = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, 0),
        [
          const Color(0xFFB7EAFF),
          const Color(0xFF7ED9FF),
          const Color(0xFF0F7BAA),
          // Colors.red, Colors.blue, Colors.yellow,
        ],
        [0, 0.6, 1],
      );

      final Paint activePaint = Paint()
        ..strokeWidth = additionalActiveTrackHeight
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // final Paint inactivePaint = Paint()
      //   ..color = inactiveTrackColorTween.evaluate(_enableAnimation)!
      //   ..strokeWidth = additionalActiveTrackHeight
      //   ..style = PaintingStyle.stroke
      //   ..strokeCap = StrokeCap.round;

      Path line = Path()
        ..moveTo(0, size.height)
        ..quadraticBezierTo(
          size.width / 2,
          -size.height,
          size.width,
          size.height,
        );

      //计算百分比进度条
      ui.PathMetrics pathMetrics = line.computeMetrics();
      // 获取第一小节信息(猜测可能有多个Path叠加？)
      ui.PathMetric pathMetric = pathMetrics.first;
      // 整个Path的长度
      double length = pathMetric.length;
      // 当前进度
      double value = length * controllerValue;

      // 左侧路径
      Path extractLeftPath = pathMetric.extractPath(
        0,
        value,
        startWithMoveTo: true,
      );

      //绘制第1段颜色
      context.canvas.drawPath(extractLeftPath, activePaint);

      //右侧路径
      //Path extractRightPath =  pathMetric.extractPath(value, length, startWithMoveTo: true);

      //绘制第2段颜色
      //context.canvas.drawPath(extractRightPath, inactivePaint);

      // 获取滑块绘制的位置
      ui.Tangent? tangent = pathMetric.getTangentForOffset(value);

      /// 滑块在路径上
      thumbCenter = tangent!.position;
    } else {
      final Paint activePaint = Paint()
        ..color = activeTrackColorTween.evaluate(_enableAnimation)!;
      final Paint inactivePaint = Paint()
        ..color = inactiveTrackColorTween.evaluate(_enableAnimation)!;

      /// 计算滑块位置
      thumbCenter = Offset(
        trackRect.left + visualPosition * trackRect.width,
        trackRect.center.dy,
      );
      // 绘制轨道
      drawTrack(
        context,
        trackRect,
        progress: thumbCenter.dx / trackRect.width,
        thumbCenter: thumbCenter,
        secondaryOffset: secondaryOffset,
        additionalActiveTrackHeight: additionalActiveTrackHeight,
        leftTrackPaint: activePaint,
        rightTrackPaint: inactivePaint,
      );
    }

    // 正在交互 - 绘制 浮层
    if (isInteractive) {
      final Size overlaySize = sliderTheme.overlayShape!.getPreferredSize(
        isInteractive,
        false,
      );
      overlayRect = Rect.fromCircle(
        center: thumbCenter,
        radius: overlaySize.width / 2.0,
      );
    }

    if (!_overlayAnimation.isDismissed) {
      _sliderTheme.overlayShape!.paint(
        context,
        thumbCenter,
        activationAnimation: _overlayAnimation,
        enableAnimation: _enableAnimation,
        isDiscrete: isDiscrete,
        labelPainter: _labelPainter,
        parentBox: this,
        sliderTheme: _sliderTheme,
        textDirection: _textDirection,
        value: _value,
        textScaleFactor: _textScaleFactor,
        sizeWithOverflow: screenSize.isEmpty ? size : screenSize,
      );
    }

    if (isDiscrete) {
      final double tickMarkWidth = _sliderTheme.tickMarkShape!
          .getPreferredSize(isEnabled: isInteractive, sliderTheme: _sliderTheme)
          .width;
      final double padding = trackRect.height;
      final double adjustedTrackWidth = trackRect.width - padding;
      // If the tick marks would be too dense, don't bother painting them.
      if (adjustedTrackWidth / divisions! >= 3.0 * tickMarkWidth) {
        final double dy = trackRect.center.dy;
        for (int i = 0; i <= divisions!; i++) {
          final double value = i / divisions!;
          // The ticks are mapped to be within the track, so the tick mark width
          // must be subtracted from the track width.
          final double dx =
              trackRect.left + value * adjustedTrackWidth + padding / 2;
          final Offset tickMarkOffset = Offset(dx, dy);
          _sliderTheme.tickMarkShape!.paint(
            context,
            tickMarkOffset,
            parentBox: this,
            sliderTheme: _sliderTheme,
            enableAnimation: _enableAnimation,
            textDirection: _textDirection,
            thumbCenter: thumbCenter,
            isEnabled: isInteractive,
          );
        }
      }
    }

    if (isInteractive &&
        label != null &&
        !_valueIndicatorAnimation.isDismissed) {
      if (showValueIndicator) {
        _state.paintValueIndicator = (PaintingContext context, Offset offset) {
          if (attached && _labelPainter.text != null) {
            _sliderTheme.valueIndicatorShape!.paint(
              context,
              offset + thumbCenter,
              activationAnimation: _valueIndicatorAnimation,
              enableAnimation: _enableAnimation,
              isDiscrete: isDiscrete,
              labelPainter: _labelPainter,
              parentBox: this,
              sliderTheme: _sliderTheme,
              textDirection: _textDirection,
              value: _value,
              textScaleFactor: textScaleFactor,
              sizeWithOverflow: screenSize.isEmpty ? size : screenSize,
            );
          }
        };
      }
    }

    // 绘制滑块
    drawThumb(context, thumbCenter);
    // _sliderTheme.thumbShape!.paint(
    //   context,
    //   thumbCenter,
    //   activationAnimation: _overlayAnimation,
    //   enableAnimation: _enableAnimation,
    //   isDiscrete: isDiscrete,
    //   labelPainter: _labelPainter,
    //   parentBox: this,
    //   sliderTheme: _sliderTheme,
    //   textDirection: _textDirection,
    //   value: _value,
    //   textScaleFactor: textScaleFactor,
    //   sizeWithOverflow: screenSize.isEmpty ? size : screenSize,
    // );
  }

  /// 绘制轨道
  void drawTrack(
    PaintingContext context,
    Rect trackRect, {
    required double progress,
    required Offset thumbCenter,
    required Offset? secondaryOffset,
    required double additionalActiveTrackHeight,
    required Paint leftTrackPaint,
    required Paint rightTrackPaint,
  }) {
    // 默认的圆角值
    final Radius trackRadius = Radius.circular(trackRect.height / 2);

    /// 激活的时候 圆角值
    final Radius activeTrackRadius = Radius.circular(
      (trackRect.height + additionalActiveTrackHeight) / 2,
    );

    // 左侧轨道
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        (textDirection == TextDirection.ltr)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
        bottomLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
      ),
      leftTrackPaint,
    );

    // 右侧轨道
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        trackRect.top - (additionalActiveTrackHeight / 2),
        trackRect.right,
        trackRect.bottom + (additionalActiveTrackHeight / 2),
        topRight: activeTrackRadius,
        bottomRight: activeTrackRadius,
      ),
      rightTrackPaint,
    );
    // 绘制缓冲进度
    final bool showSecondaryTrack =
        (secondaryOffset != null) &&
        ((textDirection == TextDirection.ltr)
            ? (secondaryOffset.dx > thumbCenter.dx)
            : (secondaryOffset.dx < thumbCenter.dx));

    if (showSecondaryTrack) {
      final ColorTween secondaryTrackColorTween = ColorTween(
        begin: sliderTheme.disabledSecondaryActiveTrackColor,
        end: sliderTheme.secondaryActiveTrackColor,
      );
      final Paint secondaryTrackPaint = Paint()
        ..color = secondaryTrackColorTween.evaluate(_enableAnimation)!;
      if (textDirection == TextDirection.ltr) {
        context.canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            thumbCenter.dx,
            trackRect.top,
            secondaryOffset.dx,
            trackRect.bottom,
            topRight: trackRadius,
            bottomRight: trackRadius,
          ),
          secondaryTrackPaint,
        );
      } else {
        context.canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            secondaryOffset.dx,
            trackRect.top,
            thumbCenter.dx,
            trackRect.bottom,
            topLeft: trackRadius,
            bottomLeft: trackRadius,
          ),
          secondaryTrackPaint,
        );
      }
    }
  }

  /// 绘制滑块
  void drawThumb(
    PaintingContext context,
    Offset center, {
    double elevation = 1.0,
    double pressedElevation = 6.0,
  }) {
    final Canvas canvas = context.canvas;

    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );

    final Color color = colorTween.evaluate(_enableAnimation)!;

    // 滑块激活动画
    final Tween<double> radiusTween = Tween<double>(
      begin: _thumbRadius,
      end: _thumbActiveRadius,
    );

    final double radius = radiusTween.evaluate(_overlayAnimation);

    final Tween<double> elevationTween = Tween<double>(
      begin: elevation,
      end: pressedElevation,
    );

    final double evaluatedElevation = elevationTween.evaluate(
      _overlayAnimation,
    );
    final Path path = Path()
      ..addArc(
        Rect.fromCenter(center: center, width: 2 * radius, height: 2 * radius),
        0,
        math.pi * 2,
      );

    bool paintShadows = true;
    assert(() {
      if (debugDisableShadows) {
        _debugDrawShadow(canvas, path, evaluatedElevation);
        paintShadows = false;
      }
      return true;
    }());

    if (paintShadows) {
      canvas.drawShadow(path, Colors.black, evaluatedElevation, true);
    }

    canvas.drawCircle(center, radius, Paint()..color = color);
  }

  /// 绘制阴影
  void _debugDrawShadow(Canvas canvas, Path path, double elevation) {
    if (elevation > 0.0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = elevation * 2.0,
      );
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    // The Slider widget has its own Focus widget with semantics information,
    // and we want that semantics node to collect the semantics information here
    // so that it's all in the same node: otherwise Talkback sees that the node
    // has focusable children, and it won't focus the Slider's Focus widget
    // because it thinks the Focus widget's node doesn't have anything to say
    // (which it doesn't, but this child does). Aggregating the semantic
    // information into one node means that Talkback will recognize that it has
    // something to say and focus it when it receives keyboard focus.
    // (See https://github.com/flutter/flutter/issues/57038 for context).
    config.isSemanticBoundary = false;

    config.isEnabled = isInteractive;
    config.textDirection = textDirection;
    if (isInteractive) {
      config.onIncrease = increaseAction;
      config.onDecrease = decreaseAction;
    }

    if (semanticFormatterCallback != null) {
      config.value = semanticFormatterCallback!(_state._lerp(value));
      config.increasedValue = semanticFormatterCallback!(
        _state._lerp(clampDouble(value + _semanticActionUnit, 0.0, 1.0)),
      );
      config.decreasedValue = semanticFormatterCallback!(
        _state._lerp(clampDouble(value - _semanticActionUnit, 0.0, 1.0)),
      );
    } else {
      config.value = '${(value * 100).round()}%';
      config.increasedValue =
          '${(clampDouble(value + _semanticActionUnit, 0.0, 1.0) * 100).round()}%';
      config.decreasedValue =
          '${(clampDouble(value - _semanticActionUnit, 0.0, 1.0) * 100).round()}%';
    }
  }

  double get _semanticActionUnit =>
      divisions != null ? 1.0 / divisions! : _adjustmentUnit;

  void increaseAction() {
    if (isInteractive) {
      onChangeStart!(currentValue);
      final double increase = increaseValue();
      onChanged!(increase);
      onChangeEnd!(increase);
    }
  }

  void decreaseAction() {
    if (isInteractive) {
      onChangeStart!(currentValue);
      final double decrease = decreaseValue();
      onChanged!(decrease);
      onChangeEnd!(decrease);
    }
  }

  double get currentValue {
    return clampDouble(value, 0.0, 1.0);
  }

  double increaseValue() {
    return clampDouble(value + _semanticActionUnit, 0.0, 1.0);
  }

  double decreaseValue() {
    return clampDouble(value - _semanticActionUnit, 0.0, 1.0);
  }
}

class _AdjustSliderIntent extends Intent {
  const _AdjustSliderIntent({required this.type});

  const _AdjustSliderIntent.right() : type = _SliderAdjustmentType.right;

  const _AdjustSliderIntent.left() : type = _SliderAdjustmentType.left;

  const _AdjustSliderIntent.up() : type = _SliderAdjustmentType.up;

  const _AdjustSliderIntent.down() : type = _SliderAdjustmentType.down;

  final _SliderAdjustmentType type;
}

enum _SliderAdjustmentType { right, left, up, down }

class _ValueIndicatorRenderObjectWidget extends LeafRenderObjectWidget {
  const _ValueIndicatorRenderObjectWidget({required this.state});

  final _SliderState state;

  @override
  _RenderValueIndicator createRenderObject(BuildContext context) {
    return _RenderValueIndicator(state: state);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderValueIndicator renderObject,
  ) {
    renderObject._state = state;
  }
}

class _RenderValueIndicator extends RenderBox
    with RelayoutWhenSystemFontsChangeMixin {
  _RenderValueIndicator({required _SliderState state}) : _state = state {
    _valueIndicatorAnimation = CurvedAnimation(
      parent: _state.valueIndicatorController,
      curve: Curves.fastOutSlowIn,
    );
  }
  late CurvedAnimation _valueIndicatorAnimation;
  _SliderState _state;

  @override
  bool get sizedByParent => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _valueIndicatorAnimation.addListener(markNeedsPaint);
    _state.positionController.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _valueIndicatorAnimation.removeListener(markNeedsPaint);
    _state.positionController.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _state.paintValueIndicator?.call(context, offset);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.smallest;
  }

  @override
  void dispose() {
    _valueIndicatorAnimation.dispose();
    super.dispose();
  }
}

class _SliderDefaultsM2 extends SliderThemeData {
  _SliderDefaultsM2(this.context)
    : _colors = Theme.of(context).colorScheme,
      super(trackHeight: 4.0);

  final BuildContext context;
  final ColorScheme _colors;

  @override
  Color? get activeTrackColor => _colors.primary;

  @override
  Color? get inactiveTrackColor => _colors.primary.withOpacity(0.24);

  @override
  Color? get secondaryActiveTrackColor => _colors.primary.withOpacity(0.54);

  @override
  Color? get disabledActiveTrackColor => _colors.onSurface.withOpacity(0.32);

  @override
  Color? get disabledInactiveTrackColor => _colors.onSurface.withOpacity(0.12);

  @override
  Color? get disabledSecondaryActiveTrackColor =>
      _colors.onSurface.withOpacity(0.12);

  @override
  Color? get activeTickMarkColor => _colors.onPrimary.withOpacity(0.54);

  @override
  Color? get inactiveTickMarkColor => _colors.primary.withOpacity(0.54);

  @override
  Color? get disabledActiveTickMarkColor => _colors.onPrimary.withOpacity(0.12);

  @override
  Color? get disabledInactiveTickMarkColor =>
      _colors.onSurface.withOpacity(0.12);

  @override
  Color? get thumbColor => _colors.primary;

  @override
  Color? get disabledThumbColor =>
      Color.alphaBlend(_colors.onSurface.withOpacity(.38), _colors.surface);

  @override
  Color? get overlayColor => _colors.primary.withOpacity(0.12);

  @override
  TextStyle? get valueIndicatorTextStyle =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(color: _colors.onPrimary);

  @override
  SliderComponentShape? get valueIndicatorShape =>
      const RectangularSliderValueIndicatorShape();
}

// BEGIN GENERATED TOKEN PROPERTIES - Slider

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class _SliderDefaultsM3 extends SliderThemeData {
  _SliderDefaultsM3(this.context) : super(trackHeight: 4.0);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get activeTrackColor => _colors.primary;

  @override
  Color? get inactiveTrackColor => _colors.surfaceContainerHighest;

  @override
  Color? get secondaryActiveTrackColor => _colors.primary.withOpacity(0.54);

  @override
  Color? get disabledActiveTrackColor => _colors.onSurface.withOpacity(0.38);

  @override
  Color? get disabledInactiveTrackColor => _colors.onSurface.withOpacity(0.12);

  @override
  Color? get disabledSecondaryActiveTrackColor =>
      _colors.onSurface.withOpacity(0.12);

  @override
  Color? get activeTickMarkColor => _colors.onPrimary.withOpacity(0.38);

  @override
  Color? get inactiveTickMarkColor =>
      _colors.onSurfaceVariant.withOpacity(0.38);

  @override
  Color? get disabledActiveTickMarkColor => _colors.onSurface.withOpacity(0.38);

  @override
  Color? get disabledInactiveTickMarkColor =>
      _colors.onSurface.withOpacity(0.38);

  @override
  Color? get thumbColor => _colors.primary;

  @override
  Color? get disabledThumbColor =>
      Color.alphaBlend(_colors.onSurface.withOpacity(0.38), _colors.surface);

  @override
  Color? get overlayColor =>
      WidgetStateColor.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.dragged)) {
          return _colors.primary.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.primary.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.primary.withOpacity(0.1);
        }

        return Colors.transparent;
      });

  @override
  TextStyle? get valueIndicatorTextStyle => Theme.of(
    context,
  ).textTheme.labelMedium!.copyWith(color: _colors.onPrimary);

  @override
  SliderComponentShape? get valueIndicatorShape =>
      const DropSliderValueIndicatorShape();
}
