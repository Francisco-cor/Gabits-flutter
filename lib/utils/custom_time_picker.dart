import 'package:flutter/material.dart';
import 'package:gabits/generated/l10n/app_localizations.dart';

/// Muestra un TimePicker con el tema personalizado de la aplicación.
Future<TimeOfDay?> showThemedTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  final localizations = AppLocalizations.of(context)!;
  final theme = Theme.of(context); // Obtener el tema actual de la aplicación

  final Color timePickerEmphasisColor = const Color(0xFF000000);

  return showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: localizations.selectTime,
    cancelText: localizations.cancel,
    confirmText: localizations.ok,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        // Aquí creamos un nuevo tema específico para el diálogo del TimePicker.
        data: theme.copyWith(
          // Modificamos el colorScheme para que coincida con tu diseño.
          colorScheme: theme.colorScheme.copyWith(
            // 'primary': Color principal de elementos interactivos (número seleccionado, manecilla, botones OK/Cancel)
            primary: timePickerEmphasisColor,
            // 'onPrimary': Color del texto/íconos sobre el primary
            onPrimary: Colors.white, // Blanco para contrastar con el negro de énfasis

            // 'surface': Color de fondo del diálogo completo
            surface: theme.scaffoldBackgroundColor, // Usa el color de fondo de tu app (debe ser claro)
            // 'onSurface': Color del texto/íconos sobre el surface (números no seleccionados)
            onSurface: theme.textTheme.bodyMedium?.color,

            // 'primaryContainer': Fondo de las cajas de entrada (hora/minuto) y el círculo principal del reloj.
            primaryContainer: Colors.grey.shade200, // Un gris muy claro para eliminar el rosa.
            // Si tu tema es oscuro, podrías necesitar un gris más oscuro.
            // 'onPrimaryContainer': Color del texto/íconos sobre primaryContainer (los números dentro de las cajas).
            onPrimaryContainer: timePickerEmphasisColor, // Negro para contraste

            // 'secondary': Afecta elementos secundarios como el selector AM/PM.
            secondary: timePickerEmphasisColor, // También puede ser el color de énfasis.
            // 'onSecondary': Color del texto/íconos sobre secondary.
            onSecondary: Colors.white, // Blanco para contrastar con el negro.

            // 'background': Aunque no siempre se usa directamente en TimePicker, mejor ser consistente.
            background: theme.scaffoldBackgroundColor,
            onBackground: theme.textTheme.bodyMedium?.color,

            // Puedes añadir o ajustar otros colores si aún ves elementos rosados inesperados:
            // Por ejemplo, si el `error` o `onError` se estuvieran aplicando por alguna razón.
            // error: theme.colorScheme.error,
            // onError: theme.colorScheme.onError,
          ),
          // Personalizamos el estilo de los botones de texto (Cancelar/OK)
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: timePickerEmphasisColor, // Color del texto de los botones
            ),
          ),
          // Puedes añadir más personalizaciones aquí si fuera necesario para otros elementos del diálogo:
          // dialogTheme: DialogTheme(
          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          //   backgroundColor: theme.scaffoldBackgroundColor, // Para el fondo general del diálogo
          // ),
          // clockPickerTheme: ClockPickerThemeData(
          //   backgroundColor: Colors.white, // Fondo del reloj circular
          //   // Otros colores para el reloj...
          // ),
          // timePickerTheme: TimePickerThemeData(
          //   backgroundColor: Colors.white, // Fondo general del picker
          //   // Otras propiedades específicas del TimePicker
          // ),
        ),
        child: child!, // Asegúrate de retornar el widget hijo del builder
      );
    },
  );
}