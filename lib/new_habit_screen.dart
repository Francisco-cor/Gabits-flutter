// lib/new_habit_screen.dart
import 'package:flutter/material.dart';
import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gabits/utils/custom_time_picker.dart'; // Asumo que este es tu selector de tiempo personalizado
import 'package:gabits/models/habit_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NewHabitScreen extends StatefulWidget {
  final Habit? habitToEdit;
  const NewHabitScreen({super.key, this.habitToEdit});

  @override
  State<NewHabitScreen> createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityTimeController;

  late GoalType _selectedGoalType;
  late Color _selectedColor;
  late List<bool> _selectedDaysBool;
  late TimeOfDay _selectedTime;

  final List<Color> _commonColors = [
    const Color(0xFF4FA7B3),
    const Color(0xFF3C50A0),
    const Color(0xFF7FB361),
    const Color(0xFF397A3E),
    const Color(0xFFD9A441),
    const Color(0xFFB04747),
  ];
  late List<bool> _goalTypeSelections;

  final GlobalKey _hourWidgetKey = GlobalKey();
  double _inputFieldHeight = 56.0;

  late AnimationController _entryAnimationController;

  @override
  void initState() {
    super.initState();

    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hourWidgetKey.currentContext != null) {
        final RenderBox renderBox = _hourWidgetKey.currentContext!.findRenderObject() as RenderBox;
        if (mounted) {
          setState(() {
            _inputFieldHeight = renderBox.size.height.clamp(52.0, 60.0);
          });
        }
      }
      if (mounted) {
        _entryAnimationController.forward();
      }
    });

    if (widget.habitToEdit != null) {
      final habit = widget.habitToEdit!;
      _nameController = TextEditingController(text: habit.name);
      _descriptionController = TextEditingController(text: habit.description ?? '');
      _selectedGoalType = habit.goalType;
      _quantityTimeController = TextEditingController(text: habit.goalValue?.toStringAsFixed(0) ?? '');
      _selectedColor = habit.color; // Usa el getter
      _selectedDaysBool = List.generate(7, (index) => habit.scheduleDays.contains(index));
      _selectedTime = habit.startTime; // Usa el getter
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _quantityTimeController = TextEditingController();
      _selectedGoalType = GoalType.yesNo;
      _selectedColor = _commonColors[0];
      _selectedDaysBool = List.generate(7, (_) => true); // Todos los días por defecto
      _selectedTime = const TimeOfDay(hour: 8, minute: 0);
    }
    _goalTypeSelections = GoalType.values.map((type) => type == _selectedGoalType).toList();
  }

  bool _validateAndSaveForm(AppLocalizations localizations) {
    final form = _formKey.currentState;
    if (form!.validate()) {
      if (!_selectedDaysBool.contains(true)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.habitScheduleRequired), behavior: SnackBarBehavior.floating));
        return false;
      }
      form.save(); // Esto es opcional si no usas onSaved en los TextFormField
      return true;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all required fields."), backgroundColor: Theme.of(context).colorScheme.error, behavior: SnackBarBehavior.floating));
    return false;
  }

  void _showColorPicker() {
    Color pickerColor = _selectedColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final localizations = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(localizations.selectColor),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) => pickerColor = color,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false, // Isar no guarda alpha directamente con int
              displayThumbColor: true,
              paletteType: PaletteType.hsl,
              hexInputBar: true, // Permite entrada HEX, útil
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: <Widget>[
            TextButton(child: Text(localizations.cancel), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text(localizations.done),
              onPressed: () {
                if (mounted) setState(() => _selectedColor = pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showThemedTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && picked != _selectedTime) {
      if (mounted) setState(() => _selectedTime = picked);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityTimeController.dispose();
    _entryAnimationController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
  }

  InputDecoration _inputDecoration(ThemeData theme, String hintText, Color defaultBorderColor, double defaultBorderWidth, double selectedBorderWidth) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: defaultBorderColor, width: defaultBorderWidth)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: defaultBorderColor, width: defaultBorderWidth)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: theme.colorScheme.primary, width: selectedBorderWidth)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: theme.colorScheme.error, width: defaultBorderWidth)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: theme.colorScheme.error, width: selectedBorderWidth)),
    );
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenPadding = 16.0;
    final availableWidth = MediaQuery.of(context).size.width - (screenPadding * 2);
    final double itemSpacing = 8.0;
    final double circleDiameter = ((availableWidth - (6 * itemSpacing)) / 7.0).clamp(38.0, 42.0);

    final Color defaultElementBorderColor = theme.colorScheme.outlineVariant;
    const double defaultElementBorderWidth = 1.5;
    const double selectedElementBorderWidth = 2.0;

    final List<String> dayNamesShort = [
      localizations.sundayShort, localizations.mondayShort, localizations.tuesdayShort,
      localizations.wednesdayShort, localizations.thursdayShort, localizations.fridayShort,
      localizations.saturdayShort,
    ];

    bool isAnyCommonColorSelected = _commonColors.any((c) => c.value == _selectedColor.value);
    bool isCustomColorActive = !isAnyCommonColorSelected;

    final formWidgets = <Widget>[
      // ... tus widgets del formulario sin cambios ...
      _buildSectionTitle(localizations.habitNameLabel, theme),
      const SizedBox(height: 8),
      TextFormField(controller: _nameController, decoration: _inputDecoration(theme, localizations.habitNameHint, defaultElementBorderColor, defaultElementBorderWidth, selectedElementBorderWidth), validator: (v)=>(v==null||v.trim().isEmpty)?localizations.habitNameRequired:null, textCapitalization: TextCapitalization.sentences),
      const SizedBox(height: 24),

      _buildSectionTitle(localizations.descriptionLabel, theme),
      const SizedBox(height: 8),
      TextFormField(controller: _descriptionController, maxLines: 3, decoration: _inputDecoration(theme, localizations.descriptionHint, defaultElementBorderColor, defaultElementBorderWidth, selectedElementBorderWidth), textCapitalization: TextCapitalization.sentences),
      const SizedBox(height: 24),

      _buildSectionTitle(localizations.hourLabel, theme),
      const SizedBox(height: 8),
      GestureDetector(key: _hourWidgetKey, onTap: () => _selectTime(context),
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              decoration: BoxDecoration(border: Border.all(color: defaultElementBorderColor, width: defaultElementBorderWidth), borderRadius: BorderRadius.circular(12.0), color: Colors.white),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(_selectedTime.format(context), style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)), Icon(Icons.access_time_rounded, color: theme.colorScheme.onSurfaceVariant)])
          )
      ),
      const SizedBox(height: 24),

      _buildSectionTitle(localizations.scheduleLabel, theme),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          bool isSelected = _selectedDaysBool[index];
          return GestureDetector(onTap: () => setState(() => _selectedDaysBool[index] = !_selectedDaysBool[index]),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200), curve: Curves.easeInOut,
                  width: circleDiameter, height: circleDiameter,
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? theme.colorScheme.primary : defaultElementBorderColor, width: isSelected ? selectedElementBorderWidth : defaultElementBorderWidth),
                    boxShadow: isSelected ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 4, offset: Offset(0,2))] : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(dayNamesShort[index], style: TextStyle(color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: circleDiameter * 0.38))
              )
          );
        }),
      ),
      const SizedBox(height: 24),

      _buildSectionTitle(localizations.colorLabel, theme),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_commonColors.length + 1, (index) {
          final double itemDiameter = circleDiameter;
          if (index < _commonColors.length) {
            final color = _commonColors[index];
            bool isThisOneSelected = _selectedColor.value == color.value && isAnyCommonColorSelected;
            return GestureDetector(onTap: () => setState(() { _selectedColor = color; }),
                child: AnimatedContainer(duration: const Duration(milliseconds: 200), curve: Curves.easeInOut,
                    width: itemDiameter, height: itemDiameter,
                    decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle,
                      border: Border.all(
                          color: isThisOneSelected ? color.withOpacity(0.7) : Colors.grey.shade300,
                          width: isThisOneSelected ? 2.5 : 1.0
                      ),
                      boxShadow: isThisOneSelected ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 4, offset: Offset(0,1.5))] : [],
                    ),
                    child: isThisOneSelected ? Icon(Icons.check, color: color.computeLuminance() > 0.5 ? Colors.black.withOpacity(0.7) : Colors.white, size: itemDiameter * 0.6) : null
                )
            );
          } else {
            return GestureDetector(onTap: _showColorPicker,
                child: AnimatedContainer(duration: const Duration(milliseconds: 200), curve: Curves.easeInOut,
                    width: itemDiameter, height: itemDiameter,
                    decoration: BoxDecoration(
                      color: isCustomColorActive ? _selectedColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: isCustomColorActive ? _selectedColor.withOpacity(0.7) : Colors.grey.shade300,
                          width: isCustomColorActive ? 2.5 : 1.0
                      ),
                      boxShadow: isCustomColorActive ? [BoxShadow(color: _selectedColor.withOpacity(0.35), blurRadius: 4, offset: Offset(0,1.5))] : [],
                    ),
                    child: isCustomColorActive
                        ? Icon(Icons.check, color: _selectedColor.computeLuminance() > 0.5 ? Colors.black.withOpacity(0.7) : Colors.white, size: itemDiameter * 0.6)
                        : Icon(Icons.colorize_rounded, color: theme.colorScheme.onSurfaceVariant, size: itemDiameter * 0.55)
                )
            );
          }
        }),
      ),
      const SizedBox(height: 24),

      _buildSectionTitle(localizations.goalTypeLabel, theme),
      const SizedBox(height: 10),
      SizedBox(width: availableWidth,
          child: ToggleButtons(isSelected: _goalTypeSelections,
            onPressed: (int index) => setState(() { for (int i = 0; i < _goalTypeSelections.length; i++) _goalTypeSelections[i] = i == index; _selectedGoalType = GoalType.values[index]; if (_selectedGoalType == GoalType.yesNo) _quantityTimeController.clear(); }),
            borderRadius: BorderRadius.circular(12.0),
            selectedColor: theme.colorScheme.onPrimary,
            fillColor: theme.colorScheme.primary,
            color: theme.colorScheme.primary,
            borderColor: defaultElementBorderColor,
            selectedBorderColor: theme.colorScheme.primary,
            borderWidth: defaultElementBorderWidth,
            splashColor: theme.colorScheme.primary.withOpacity(0.1),
            constraints: BoxConstraints(
              minHeight: _inputFieldHeight > 0 ? _inputFieldHeight : 52.0,
              minWidth: (availableWidth - (4 * defaultElementBorderWidth)) / 3.0,
            ),
            children: GoalType.values.map((type) {
              String label;
              if (type == GoalType.yesNo) label = localizations.goalTypeYesNo; else if (type == GoalType.time) label = localizations.goalTypeTime; else label = localizations.goalTypeQuantity;
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
              );
            }).toList(),
          )
      ),
      const SizedBox(height: 10),

      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: child,
            ),
          );
        },
        child: (_selectedGoalType == GoalType.time || _selectedGoalType == GoalType.quantity)
            ? Column(
          key: ValueKey<GoalType>(_selectedGoalType),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            _buildSectionTitle(_selectedGoalType == GoalType.time ? localizations.timeLabel : localizations.quantityLabel, theme),
            const SizedBox(height: 8),
            TextFormField(
              controller: _quantityTimeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              decoration: _inputDecoration(theme, _selectedGoalType == GoalType.time ? localizations.timeHint : localizations.quantityHint, defaultElementBorderColor, defaultElementBorderWidth, selectedElementBorderWidth),
              validator: (v) { if (v == null || v.trim().isEmpty) return localizations.habitGoalValueRequired; if (int.tryParse(v.trim()) == null || int.parse(v.trim()) <=0) return localizations.habitGoalValueInvalid; return null; },
            ),
            const SizedBox(height: 16),
          ],
        )
            : const SizedBox.shrink(key: ValueKey<String>("empty_goal_value")),
      ),
    ];


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: theme.appBarTheme.foregroundColor), onPressed: () => Navigator.pop(context)),
        title: Text(widget.habitToEdit == null ? localizations.newHabitTitle : localizations.editButtonLabel),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.tonal(
              onPressed: () {
                if (_validateAndSaveForm(localizations)) {
                  List<int> scheduledDaysIndexes = [];
                  for (int i = 0; i < _selectedDaysBool.length; i++) { if (_selectedDaysBool[i]) scheduledDaysIndexes.add(i); }

                  // Usar Habit.create para construir el objeto
                  final habitToReturn = Habit.create(
                    name: _nameController.text.trim(),
                    description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                    goalType: _selectedGoalType,
                    goalValue: (_selectedGoalType == GoalType.time || _selectedGoalType == GoalType.quantity) ? double.tryParse(_quantityTimeController.text.trim()) : null,
                    color: _selectedColor,
                    scheduleDays: scheduledDaysIndexes,
                    startTime: _selectedTime,
                    // isCompleted no se establece aquí, se maneja al completar/descompletar
                  );

                  // Si estamos editando, asignamos el ID del hábito original
                  // para que Isar sepa qué objeto actualizar.
                  if (widget.habitToEdit != null) {
                    habitToReturn.id = widget.habitToEdit!.id;
                  }
                  // Si es un hábito nuevo, Isar asignará un nuevo ID automáticamente al hacer .put()

                  Navigator.pop(context, habitToReturn);
                }
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEEEEEE), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
              child: Text(localizations.doneButtonLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenPadding),
        child: Form(
          key: _formKey,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, bottom: 32.0),
            itemCount: formWidgets.length,
            itemBuilder: (context, index) {
              return formWidgets[index];
            },
          ),
        )
            .animate(controller: _entryAnimationController)
            .slideX(begin: -0.25, end: 0, curve: Curves.easeOutCubic, duration: _entryAnimationController.duration)
            .fadeIn(duration: _entryAnimationController.duration! * 0.8),
      ),
    );
  }
}