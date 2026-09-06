import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

const double kWideBreakpoint = 700;
const double kCardRadius = 16;
const double kCardPadding = 20;
const double kSectionGap = 16;
const double kHeaderPadding = 16;
const double kHeaderAvatarRadius = 30;
const double kCardInnerGap = 8;

void main() => runApp(const AcademicOverviewApp());

class AcademicOverviewApp extends StatefulWidget {
  const AcademicOverviewApp({super.key});

  @override
  State<AcademicOverviewApp> createState() => _AcademicOverviewAppState();
}

class _AcademicOverviewAppState extends State<AcademicOverviewApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // showSemanticsDebugger: true,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: AcademicOverviewPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class AcademicOverviewPage extends StatelessWidget {
  const AcademicOverviewPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  static const List<_Info> _infos = [
    _Info('Assignments', '8'),
    _Info('Attendance', '92%'),
    _Info('Portfolio', 'Ready'),
    _Info('Current week', '02'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        actions: [
          Semantics(
            label: 'Aktifkan mode gelap',
            toggled: isDark,
            button: true,
            onTap: () => onDarkChanged(!isDark),
            child: Row(
              children: [
                Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                const SizedBox(width: 4),
                CupertinoSwitch(value: isDark, onChanged: onDarkChanged),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.of(context).textScaler.scale(16) / 16;
          final columns = (constraints.maxWidth >= kWideBreakpoint &&
                  textScale <= 1.3)
              ? 2
              : 1;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(kSectionGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ProfileHeader(),
                const SizedBox(height: kSectionGap),
                _buildInfoGrid(columns),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoGrid(int columns) {
    final cards = _infos
        .map((info) => InfoCard(title: info.title, value: info.value))
        .toList();
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += columns) {
      final end = (i + columns < cards.length) ? i + columns : cards.length;
      final chunk = cards.sublist(i, end);
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: chunk.map((c) => Expanded(child: c)).toList(),
          ),
        ),
      );
      rows.add(const SizedBox(height: kSectionGap));
    }
    return Column(children: rows);
  }
}

class _Info {
  const _Info(this.title, this.value);
  final String title;
  final String value;
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label:
          'Profil mahasiswa Robby Catur Wicaksono, NIM 244107020048, Kelas TI-3H',
      child: Container(
        padding: const EdgeInsets.all(kHeaderPadding),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(kCardRadius),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: kHeaderAvatarRadius,
              child: Icon(Icons.person, size: kHeaderAvatarRadius),
            ),
            const SizedBox(width: kSectionGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Robby Catur Wicaksono',
                      style: theme.textTheme.titleLarge),
                  Text('NIM: 244107020048'),
                  Text('Kelas: TI-3H'),
                  Text('Email: robbycatur330@gmail.com'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({required this.title, required this.value, super.key});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$title: $value',
      child: Container(
        padding: const EdgeInsets.all(kCardPadding),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(kCardRadius),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: kCardInnerGap),
            Text(
              value,
              style: theme.textTheme.headlineSmall,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}