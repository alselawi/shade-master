import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadesmaster/analysis/analyze.dart';
import 'package:shadesmaster/drawings.dart';
import 'package:shadesmaster/l10n/app_localizations.dart';
import 'package:shadesmaster/orders/annotated_photo.dart';
import 'package:shadesmaster/utils/image_fit.dart';
import 'package:shadesmaster/utils/int_to_letter.dart';
import 'package:shadesmaster/utils/unit_8_img.dart';
import 'package:shadesmaster/widget_pill.dart';
import 'package:shadesmaster/widget_results_dialog.dart';
import 'package:shadesmaster/widget_selection_painter.dart';
import 'package:shadesmaster/widget_shade_name_picker.dart';
import 'package:shadesmaster/widget_toolbar_button.dart';

export 'package:shadesmaster/widget_selection_painter.dart' show SelectionType, teethColor, shadesColor;

/// Called with the analysis and the photo annotated with the analysed areas
/// (JPEG) when the dentist asks for a lab order from the results.
typedef CreateOrderCallback = Future<void> Function(AnalysisResult result, Uint8List annotatedJpeg);

class ShadeMaster extends StatefulWidget {
  final XFile img;
  final VoidCallback onClose;
  final CreateOrderCallback? onCreateOrder;
  @override
  ShadeMasterState createState() => ShadeMasterState();
  const ShadeMaster({super.key, required this.img, required this.onClose, this.onCreateOrder});
}

class ShadeMasterState extends State<ShadeMaster> {
  Stroke _currentStroke = Stroke([]);
  final List<List<Region>> _allRegions = [[], []];
  final TransformationController _transformation = TransformationController();
  SelectionType _activeSelecting = SelectionType.none;
  bool _isAnalyzing = false;
  bool _showAreas = true;

  /// The decoded photo. Regions are stored in its pixel coordinates.
  Unit8Img? _pixels;

  /// Size of the box the photo is shown in, before zooming.
  Size _boxSize = Size.zero;

  List<Region> get _regions => _allRegions[currentRegionIndex];
  int get currentRegionIndex => _activeSelecting == SelectionType.teeth ? 0 : 1;

  @override
  void initState() {
    super.initState();
    loadUnit8Img(widget.img.path).then((pixels) {
      if (mounted) setState(() => _pixels = pixels);
    });
  }

  @override
  void dispose() {
    _transformation.dispose();
    super.dispose();
  }

  ImageFit? get _fit => _pixels == null ? null : ImageFit(_pixels!.size, _boxSize);

  void _onPanStart(DragStartDetails details) {
    final fit = _fit;
    if (_activeSelecting == SelectionType.none || fit == null) return;
    setState(() => _currentStroke = Stroke([fit.boxToImage(details.localPosition)]));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final fit = _fit;
    if (_activeSelecting == SelectionType.none || fit == null) return;
    setState(() {
      _currentStroke.points.add(fit.boxToImage(details.localPosition));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final fit = _fit;
    if (_activeSelecting == SelectionType.none || fit == null) return;
    final stroke = _currentStroke;

    // Strokes touch when they come within 2 screen pixels of each other.
    final zoom = _transformation.value.getMaxScaleOnAxis();
    final threshold = 2 * fit.imagePixelsPerBoxPixel / zoom;
    final touchingRegionIndex = _regions.indexWhere((region) => region.isTouching(stroke, threshold));

    setState(() {
      if (touchingRegionIndex != -1) {
        _regions[touchingRegionIndex] = _regions[touchingRegionIndex].mergedWith(stroke);
      } else if (stroke.enclosesArea) {
        _regions.add(Region(stroke.points));
      }
      _currentStroke = Stroke([]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformation,
              maxScale: 200,
              minScale: 0.5,
              panEnabled: _activeSelecting == SelectionType.none,
              scaleEnabled: _activeSelecting == SelectionType.none,
              child: Stack(
                children: [
                  Positioned.fill(child: Image.file(File(widget.img.path), fit: BoxFit.contain)),
                  Positioned.fill(
                    child: _showAreas && _pixels != null
                        ? LayoutBuilder(builder: (context, box) {
                            _boxSize = box.biggest;
                            return GestureDetector(
                              onPanStart: _onPanStart,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: _onPanEnd,
                              child: IgnorePointer(
                                ignoring: _activeSelecting == SelectionType.none,
                                child: CustomPaint(
                                  size: box.biggest,
                                  painter: SelectionPainter(
                                    teethRegions: _allRegions[0],
                                    shadesRegions: _allRegions[1],
                                    currentStroke: _currentStroke,
                                    activeType: _activeSelecting,
                                    imageSize: _pixels!.size,
                                  ),
                                ),
                              ),
                            );
                          })
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            buildToolbar(constraints),
            if (_isAnalyzing || _pixels == null)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  Positioned buildToolbar(BoxConstraints constraints) {
    final l10n = AppLocalizations.of(context);
    return Positioned(
      bottom: 20,
      width: constraints.maxWidth,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  if (_regions.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          tooltip: _showAreas ? l10n.hideAreas : l10n.showAreas,
                          isSelected: !_showAreas,
                          color: Colors.black87,
                          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white24)),
                          onPressed: () {
                            setState(() {
                              _showAreas = !_showAreas;
                              if (_showAreas == false) {
                                _activeSelecting = SelectionType.none;
                              }
                            });
                          },
                          selectedIcon: Icon(HugeIcons.strokeRoundedView),
                          icon: Icon(HugeIcons.strokeRoundedViewOffSlash),
                        ),
                        SizedBox(width: 15),
                        Flexible(
                          child: Wrap(
                            spacing: 2,
                            runSpacing: 2,
                            children: _regions.map((e) {
                              final int i = _regions.indexOf(e);
                              return Pill(
                                label: _activeSelecting == SelectionType.teeth
                                    ? l10n.toothLabel(i + 1)
                                    : l10n.shadeLabel(e.shadeName ?? intToLetter(i + 1)),
                                onTap: _activeSelecting == SelectionType.teeth ? null : () => _nameShade(e, i),
                                color: _activeSelecting == SelectionType.teeth
                                    ? teethColor.shade100
                                    : shadesColor.shade100,
                                onClose: () {
                                  setState(() {
                                    _regions.removeAt(i);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  if (_regions.isNotEmpty && _activeSelecting == SelectionType.shades)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(l10n.nameShadeHint, style: TextStyle(fontSize: 12, color: Colors.black87)),
                    ),
                  if (_regions.isNotEmpty) SizedBox(height: 10),
                  // Scales the buttons down on narrow screens or with long labels.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ToolbarButton(
                          icon: HugeIcons.strokeRoundedDentalTooth,
                          label: l10n.drawTeeth,
                          isActive: _activeSelecting == SelectionType.teeth,
                          onPress: () {
                            setState(() {
                              _activeSelecting =
                                  _activeSelecting == SelectionType.teeth ? SelectionType.none : SelectionType.teeth;
                              _showAreas = true;
                            });
                          },
                          activeColor: teethColor,
                        ),
                        ToolbarButton(
                          icon: HugeIcons.strokeRoundedPinLocation02,
                          label: l10n.drawShades,
                          isActive: _activeSelecting == SelectionType.shades,
                          onPress: () {
                            setState(() {
                              _activeSelecting =
                                  _activeSelecting == SelectionType.shades ? SelectionType.none : SelectionType.shades;
                              _showAreas = true;
                            });
                          },
                          activeColor: shadesColor,
                        ),
                        if (_allRegions[0].isNotEmpty && _allRegions[1].isNotEmpty)
                          ToolbarButton(
                            icon: HugeIcons.strokeRoundedMarketAnalysis,
                            label: l10n.startAnalyze,
                            isActive: false,
                            onPress: _analyze,
                            activeColor: Colors.orange,
                          ),
                        ToolbarButton(
                          icon: HugeIcons.strokeRoundedLogout02,
                          label: l10n.closeImage,
                          isActive: false,
                          onPress: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _analyze() async {
    final pixels = _pixels;
    if (pixels == null || _isAnalyzing) return;
    setState(() => _isAnalyzing = true);
    try {
      final results = await analyzeInBackground(
        pixels,
        [for (final region in _allRegions[0]) region.points],
        [for (final region in _allRegions[1]) region.points],
        shadeNames: [for (final region in _allRegions[1]) region.shadeName],
      );
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      final createOrder = await showResultsDialog(context, results, canCreateOrder: widget.onCreateOrder != null);
      if (createOrder == true && mounted) await _createOrder(pixels, results);
    } on AnalysisException catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      final message = analysisProblemMessage(AppLocalizations.of(context), e.problem);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _nameShade(Region region, int index) async {
    final choice = await showShadeNamePicker(context, letter: intToLetter(index + 1), current: region.shadeName);
    if (choice == null || !mounted) return;
    setState(() => region.shadeName = choice.name);
  }

  Future<void> _createOrder(Unit8Img pixels, AnalysisResult results) async {
    setState(() => _isAnalyzing = true);
    try {
      final jpeg = await renderAnnotatedJpeg(pixels, _allRegions[0], _allRegions[1]);
      await widget.onCreateOrder!(results, jpeg);
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }
}
