import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

void main() {
  runApp(const MaterialApp(
    home: PhysicsCardDragDemo(),
  ));
}

class PhysicsCardDragDemo extends StatelessWidget {
  const PhysicsCardDragDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const DraggableCard(
        child: FlutterLogo(
          size: 128,
        ),
      ),
    );
  }
}

class DraggableCard extends StatefulWidget {
  const DraggableCard({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

/// Extending [SingleTickerProviderStateMixin] allows the state
/// object to be a [TickerProvider] for the [AnimationController]
class _DraggableCardState extends State<DraggableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;

  /// Make the widget move when it's dragged
  /// Alignment is a point within a rectangle.Alignment(0,0)
  /// represents the center of the rectangle.Alignment(-1,-1)
  /// represents the top left of the rectangle.
  Alignment _dragAlignment = Alignment.center;

  /// This method defines a [Tween] that interpolates between
  /// the point the widget was dragged to, to the point in the
  /// center
  /// calculates and runs a [SpringSimulation]
  void _runAnimation(Offset pixelsPerSecond, Size size) {
    final alignmentTween = AlignmentTween(
      begin: _dragAlignment,
      end: Alignment.center,
    );
    _animation = _controller.drive(alignmentTween);
    // Calculate the velocity relative to the unit interval,
    // [0,1], used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;
    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );
    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);
    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    // Now that the animation controller uses a simulation it's
    // `duration` argument is no longer required.
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanDown: (details) {
        _controller.stop();
      },
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            details.delta.dx / (size.width / 2),
            details.delta.dy / (size.height / 2),
          );
        });
      },
      onPanEnd: (details) {
        _runAnimation(
          details.velocity.pixelsPerSecond,
          size,
        );
      },
      child: Align(
        alignment: _dragAlignment,
        child: Card(
          child: widget.child,
        ),
      ),
    );
  }
}
