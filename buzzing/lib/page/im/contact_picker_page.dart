import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/widget/member_picker/controller.dart';
import 'package:buzzing/widget/member_picker/contact_panel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fixnum/fixnum.dart';
import 'package:go_router/go_router.dart';

/// Mobile full-screen contact picker for creating group chats
class ContactPickerPage extends ConsumerStatefulWidget {
  final String title;

  const ContactPickerPage({super.key, this.title = '创建群聊'});

  @override
  ConsumerState<ContactPickerPage> createState() => _ContactPickerPageState();
}

class _ContactPickerPageState extends ConsumerState<ContactPickerPage> {
  late final MemberPickerController _memberCtl;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final im = ref.read(imProvider);
    _memberCtl = MemberPickerController(im: im);
    _memberCtl.excludeIds = [im.userId];
    _memberCtl.init();
  }

  @override
  void dispose() {
    _memberCtl.reset();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _createChat() async {
    if (_memberCtl.selectedMembers.isEmpty) return;
    final im = ref.read(imProvider);
    final userIds = _memberCtl.selectedMembers.map((u) => u.id).toList();
    final chatId = await im.createChat('', false, Int64(0), userIds);
    if (chatId != null && mounted) {
      context.go('${AppRoute.IM}/chat/$chatId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _memberCtl.reset();
            context.pop();
          },
        ),
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _memberCtl,
        builder: (ctx, _) {
          final selected = _memberCtl.selectedMembers;
          final searching = _memberCtl.searching;
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _memberCtl.search,
                  decoration: InputDecoration(
                    hintText: t.search,
                    prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant, size: 20),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
              // Selected contacts (wrap)
              if (selected.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: selected.map((u) => _SelectedChip(
                      user: u,
                      onTap: () => _memberCtl.removeSelected(u.id),
                    )).toList(),
                  ),
                ),
              // Search results overlay OR contact selection area
              Expanded(
                child: searching
                    ? _buildSearchResults(cs, tt)
                    : _buildContactSelection(cs, tt),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: ListenableBuilder(
          listenable: _memberCtl,
          builder: (ctx, _) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Text('已选 ${_memberCtl.selectedMembers.length} 个人',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                const Spacer(),
                FilledButton(
                  onPressed: _memberCtl.selectedMembers.isEmpty ? null : _createChat,
                  child: const Text('创建'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(ColorScheme cs, TextTheme tt) {
    if (_memberCtl.searchResults.isEmpty) {
      return Center(
        child: Text('未找到相关联系人', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      );
    }
    return ListView.builder(
      itemCount: _memberCtl.searchResults.length,
      itemBuilder: (ctx, i) {
        final user = _memberCtl.searchResults[i];
        final selected = _memberCtl.isSelected(user.id);
        final excluded = _memberCtl.isExcluded(user.id);
        return ListTile(
          leading: _buildAvatar(cs, user),
          title: Text(user.name),
          trailing: excluded
              ? Checkbox(value: true, onChanged: null)
              : Checkbox(
                  value: selected,
                  onChanged: (_) => _memberCtl.toggleSelect(user),
                ),
          onTap: excluded ? null : () => _memberCtl.toggleSelect(user),
        );
      },
    );
  }

  Widget _buildContactSelection(ColorScheme cs, TextTheme tt) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.account_tree_outlined, color: cs.primary),
          title: const Text('组织内联系人'),
          trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          onTap: () {
            _memberCtl.enterOrgRoot();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => _OrgPickerPage(ctl: _memberCtl),
            ));
          },
        ),
      ],
    );
  }

  Widget _buildAvatar(ColorScheme cs, User user) {
    if (user.avatar.isEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CachedNetworkImage(
        width: 32,
        height: 32,
        imageUrl: CommonUtils.fixResourceUrl(user.avatar),
        fit: BoxFit.cover,
      ),
    );
  }
}

class _SelectedChip extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  const _SelectedChip({required this.user, required this.onTap});

  Widget _buildAvatarWidget(ColorScheme cs, double size) {
    if (user.avatar.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(size / 4),
        ),
        alignment: Alignment.center,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: TextStyle(fontSize: size * 0.4, color: Colors.white),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 4),
      child: CachedNetworkImage(
        width: size,
        height: size,
        imageUrl: CommonUtils.fixResourceUrl(user.avatar),
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const avatarSize = 36.0;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatarWidget(cs, avatarSize),
            const SizedBox(height: 2),
            Text(
              user.name,
              style: const TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sub-page for department drill-down with user selection
class _OrgPickerPage extends StatelessWidget {
  final MemberPickerController ctl;
  const _OrgPickerPage({required this.ctl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ctl.atRoot ? '组织内联系人' : ctl.currentDeptName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: ctl,
        builder: (ctx, _) => ContactPanel(ctl: ctl),
      ),
    );
  }
}
