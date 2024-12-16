import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinopark/styles/styles.dart';
import 'package:kinopark/tools/app_cubit.dart';

class AppMenu extends StatefulWidget {
  final List<Widget> menuWidgets;

  const AppMenu(this.menuWidgets, {super.key});

  @override
  State<StatefulWidget> createState() => _AppMenu();
}

class _AppMenu extends State<AppMenu> {
  var pos = 0.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width > 1280 ? MediaQuery.sizeOf(context).width * 0.3 : MediaQuery.sizeOf(context).width * 0.8;
    return BlocBuilder<AppMenuCubit, AppMenuState>(
        builder: (builder, state) {
      return Stack(
        children: [
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: state == AppMenuState.msOpen
                  ? InkWell(
                      onTap: () {
                        pos = -width;
                        builder.read<AppMenuCubit>().toggle();
                      },
                      child: Container(color: Colors.black38))
                  : Container()),
          AnimatedPositioned(
              width: width,
              height: MediaQuery.sizeOf(context).height,
              left:
                  state == AppMenuState.msOpen ? 0 : -width,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                  onPanUpdate: (d) {
                    if (pos - d.delta.dx > 0) {
                      return;
                    }
                    if ((pos - d.delta.dx).abs() < width * 0.5) {
                      pos = -width;
                      builder.read<AppMenuCubit>().toggle();
                      return;
                    }
                    setState(() {
                      pos -= d.delta.dx;
                    });
                  },
                  onPanEnd: (d) {
                    setState(() {
                      pos = -width;
                    });
                  },
                  child: Container(
                    color: HSLColor.fromColor(kMainColor).withLightness(HSLColor.fromColor(kMainColor).lightness * 0.5).toColor(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final w in widget.menuWidgets) ...[
                          const SizedBox(height: 10),
                          w,
                        ]
                      ],
                    ),
                  )))
        ],
      );
    });
  }
}
