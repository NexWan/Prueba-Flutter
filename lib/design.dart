/*The same, this is just to style a bit*/
import 'package:flutter/material.dart';

class MsgBlock extends StatelessWidget {
  const MsgBlock({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
        color: theme.colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text('Dispositivos', style: theme.textTheme.displaySmall,),
        )
    );
  }
}

/*This is just so you don't have huge stuff and you can have like your own component
* of some element (like a text in this case)
* */
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    return Card(
      color: theme.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text("Bienvenido!", style: style),
      ),
    );
  }
}


class ConnectionS extends StatelessWidget {
  const ConnectionS({
    super.key,
    required bool connected,
  }) : _connected = connected;

  final bool _connected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'Estado: ${_connected ? 'Conectado' : 'Desconectado'}',
          style: TextStyle(
            fontSize: 20,
            color: _connected ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
