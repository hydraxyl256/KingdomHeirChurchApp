import 'package:flutter/material.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class LeaderResourcesScreen extends StatelessWidget {
  const LeaderResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.leaderResources)),
      body: Center(
          child: Text(AppLocalizations.of(context)!.leaderToolkitResources),),
    );
  }
}
