import 'package:flutter/material.dart';

class AppSelectField extends StatelessWidget {
  final String? value;
  final List<String> options;
  final ValueChanged<String?>? onChanged;
  final InputDecoration decoration;
  final String? hint;
  final double menuMaxHeight;

  const AppSelectField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.decoration,
    this.hint,
    this.menuMaxHeight = 320,
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.sizeOf(context).width >= 900;
    if (!isWeb) {
      return DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: decoration,
        hint: hint == null ? null : Text(hint!),
        menuMaxHeight: menuMaxHeight,
        borderRadius: BorderRadius.circular(14),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(option)),
        ],
        onChanged: onChanged,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth;
        return MenuAnchor(
          crossAxisUnconstrained: false,
          alignmentOffset: const Offset(0, 6),
          consumeOutsideTap: true,
          style: MenuStyle(
            backgroundColor: const WidgetStatePropertyAll(Colors.white),
            elevation: const WidgetStatePropertyAll(10),
            minimumSize: WidgetStatePropertyAll(Size(fieldWidth, 0)),
            maximumSize: WidgetStatePropertyAll(
              Size(fieldWidth, menuMaxHeight),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 6),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          menuChildren: [
            for (final option in options)
              MenuItemButton(
                onPressed: onChanged == null ? null : () => onChanged!(option),
                style: const ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)),
                  alignment: Alignment.centerLeft,
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 18),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(option, overflow: TextOverflow.ellipsis),
                ),
              ),
          ],
          builder: (context, controller, child) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onChanged == null
                ? null
                : () {
                    controller.isOpen ? controller.close() : controller.open();
                  },
            child: InputDecorator(
              decoration: decoration.copyWith(
                hintText: value == null ? hint : null,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: Icon(
                  controller.isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ),
              isEmpty: value == null,
              isFocused: controller.isOpen,
              child: value == null
                  ? const SizedBox.shrink()
                  : Text(value!, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        );
      },
    );
  }
}
