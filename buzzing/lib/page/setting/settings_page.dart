import 'package:buzzing/provider/app_state_provider.dart';
import 'package:buzzing/utils/platform.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _generalKey = GlobalKey();
  int _selectedCategory = 0;

  void _openOpenPlatform() {
    context.push('/open-platform');
  }

  static const _headerHeight = 44.0;

  void _scrollToCategory(int index) {
    setState(() => _selectedCategory = index);
    final keys = [_generalKey];
    final ctx = keys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.0,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('通用', style: tt.titleMedium),
            const SizedBox(height: 16),
            _buildOptionGroup(
              label: '主题',
              options: const [
                _Option('跟随系统', 0),
                _Option('浅色', 1),
                _Option('深色', 2),
              ],
              selectedValue: state.theme,
              onSelected: (v) => notifier.changeTheme(v),
            ),
            const SizedBox(height: 24),
            _buildOptionGroup(
              label: '语言',
              options: const [
                _Option('跟随系统', 0),
                _Option('中文', 1),
                _Option('English', 2),
              ],
              selectedValue: state.languageIndex,
              onSelected: (v) => notifier.changeLanguage(v),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.apps),
              title: const Text('开发者控制台'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openOpenPlatform,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NaviBar(),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: _headerHeight,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Text('设置', style: tt.titleMedium),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.pop(),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: cs.outlineVariant),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 160,
                        color: cs.surfaceContainerLow,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            _CategoryItem(
                              icon: Icons.tune,
                              label: '通用',
                              selected: _selectedCategory == 0,
                              onTap: () => _scrollToCategory(0),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text('开发', style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.outline,
                              )),
                            ),
                            _CategoryItem(
                              icon: Icons.apps,
                              label: '开发者控制台',
                              selected: false,
                              onTap: _openOpenPlatform,
                            ),
                          ],
                        ),
                      ),
                      VerticalDivider(width: 1, color: cs.outlineVariant),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(
                                key: _generalKey,
                                title: '通用',
                                children: [
                                  _buildOptionGroup(
                                    label: '主题',
                                    options: const [
                                      _Option('跟随系统', 0),
                                      _Option('浅色', 1),
                                      _Option('深色', 2),
                                    ],
                                    selectedValue: state.theme,
                                    onSelected: (v) => notifier.changeTheme(v),
                                  ),
                                  const SizedBox(height: 32),
                                  _buildOptionGroup(
                                    label: '语言',
                                    options: const [
                                      _Option('跟随系统', 0),
                                      _Option('中文', 1),
                                      _Option('English', 2),
                                    ],
                                    selectedValue: state.languageIndex,
                                    onSelected: (v) => notifier.changeLanguage(v),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required Key key,
    required String title,
    required List<Widget> children,
  }) {
    final tt = Theme.of(context).textTheme;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tt.titleMedium),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildOptionGroup({
    required String label,
    required List<_Option> options,
    required int selectedValue,
    required ValueChanged<int> onSelected,
  }) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            return ChoiceChip(
              label: Text(opt.label),
              selected: opt.value == selectedValue,
              onSelected: (_) => onSelected(opt.value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.secondaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? cs.onSecondaryContainer : cs.onSurface,
              ),
              const SizedBox(width: 12),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option {
  final String label;
  final int value;
  const _Option(this.label, this.value);
}
