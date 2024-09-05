import 'package:flame/components.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:fyp_game/game/game.dart';

class PowerUpMenu extends StatefulWidget {
  static const id = 'PowerUpMenu';
  final FypGame game;

  const PowerUpMenu({super.key, required this.game});

  @override
  State<PowerUpMenu> createState() => _PowerUpMenuState();
}

class _PowerUpMenuState extends State<PowerUpMenu> {
  @override
  Widget build(BuildContext context) {
    FypGame game = widget.game;
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(90),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          upgradeList(context),
          returnButton(context),
        ],
      ),

      //
    );
  }

  Widget upgradeList(BuildContext context) {
    if (widget.game.powerup.item.length == 0) {
      return Center(child: Text('It\'s empty'));
    }
    return Flexible(
      flex: 1,
      child: ListView.builder(
        itemCount: widget.game.powerup.item.length,
        itemBuilder: (context, index) {
          final item = widget.game.powerup.item.elementAt(index);
          double adjust = 1;
          if (item.itemDes.type == 'bulletSize') {
            adjust = 0.1;
          }
          String itemDes =
              '${item.itemDes.descri}${(item.value * adjust).toStringAsFixed(1)}\nCost : ${item.cost}';
          return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: (MediaQuery.of(context).size.width * 0.15),
                  vertical: (MediaQuery.of(context).size.height * 0.015)),
              height: MediaQuery.of(context).size.height * 0.20,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // image: DecorationImage(
                  //   image: AssetImage("assets/images/Background/Yellow.png"),
                  //   fit: BoxFit.cover,
                  // ),
                  color: Colors.black.withAlpha(160),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.grey, width: 5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SpriteWidget(
                      sprite: Sprite(
                        // buttons settings?
                        widget.game.images
                            .fromCache('Main Characters/Appearing (96x96).png'),
                        srcSize: Vector2.all(96),
                        srcPosition: Vector2(96 * 2, 0),
                      ),
                    ),
                    Text(itemDes),
                    OutlinedButton(
                      onPressed: widget.game.player.money >= item.cost
                          ? () {
                              print('buying upgrade');


                              item.itemFunction?.call();
                              widget.game.player.money -= item.cost;
                              widget.game.player.updateHP(0);

                              setState(() {
                                widget.game.powerup.item.remove(item);
                                widget.game.powerup.itemCount -= 1;
                              });
                            }
                          : null,
                      child: const Text('Get'),
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }

  Widget returnButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.03),
      child: SizedBox(
        width: widget.game.fixedResolution.x * 0.2,
        height: widget.game.fixedResolution.y * 0.1,
        child: ElevatedButton(
          onPressed: () {
            widget.game.overlays.remove(PowerUpMenu.id);
            widget.game.resumeEngine();
            widget.game.saveHiveMap1(widget.game.roomMapList);
          },
          child: const Text('Return'),
        ),
      ),
    );
  }
}
