import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/widget/member_picker/controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ContactPanel extends StatelessWidget {
  final MemberPickerController ctl;

  ContactPanel({required this.ctl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: cs.surfaceVariant)),
      ),
      child: Column(
        children: [
          _buildSearchBar(cs, tt),
          Expanded(child: _buildBody(context, cs, tt)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.surfaceVariant)),
      ),
      child: TextField(
        onChanged: ctl.search,
        decoration: InputDecoration(
          hintText: t.search,
          hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant, size: 20),
          filled: true,
          fillColor: cs.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme cs, TextTheme tt) {
    if (ctl.searching) {
      return _buildSearchResults(cs, tt);
    }
    if (ctl.atRoot) {
      return _buildRootView(cs, tt);
    }
    return _buildDeptView(context, cs, tt);
  }

  Widget _buildSearchResults(ColorScheme cs, TextTheme tt) {
    if (ctl.searchResults.isEmpty) {
      return Center(child: Text(t.noSearchResult, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)));
    }
    return ListView.builder(
      itemCount: ctl.searchResults.length,
      itemBuilder: (context, index) {
        var user = ctl.searchResults[index];
        return _buildUserItem(context, user);
      },
    );
  }

  Widget _buildRootView(ColorScheme cs, TextTheme tt) {
    return ListView(
      children: [
        _buildOrgEntry(cs, tt),
      ],
    );
  }

  Widget _buildOrgEntry(ColorScheme cs, TextTheme tt) {
    return GestureDetector(
      onTap: () => ctl.enterOrgRoot(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.account_tree_outlined, size: 20, color: cs.onSurfaceVariant),
            SizedBox(width: 10),
            Text(t.contacts, style: tt.bodyMedium),
            Spacer(),
            Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptView(BuildContext context, ColorScheme cs, TextTheme tt) {
    return Column(
      children: [
        _buildNavigationBar(cs, tt),
        Expanded(
          child: ListView(
            children: [
              ...ctl.currentDepts.map((dept) => _buildDeptItem(cs, tt, dept)),
              ...ctl.currentMembers.map((user) => _buildUserItem(context, user)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.surfaceVariant)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ctl.goBack(),
            child: Icon(Icons.arrow_back, size: 18, color: cs.onSurfaceVariant),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              ctl.currentDeptName,
              style: tt.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeptItem(ColorScheme cs, TextTheme tt, Department dept) {
    return GestureDetector(
      onTap: () => ctl.enterDept(dept.id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.folder_outlined, size: 20, color: cs.onSurfaceVariant),
            SizedBox(width: 10),
            Expanded(
              child: Text(dept.name, style: tt.bodyMedium),
            ),
            Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, User user) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    var selected = ctl.isSelected(user.id);
    var excluded = ctl.isExcluded(user.id);
    var enabled = !excluded;
    return GestureDetector(
      onTap: enabled ? () => ctl.toggleSelect(user) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: selected ? bt.mentionBg : null,
        child: Row(
          children: [
            Checkbox(
              value: enabled ? selected : true,
              onChanged: enabled ? (_) => ctl.toggleSelect(user) : null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            _buildAvatar(cs, tt, user),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                user.name,
                style: tt.bodyMedium?.copyWith(
                  color: enabled ? null : cs.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme cs, TextTheme tt, User user) {
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
          style: tt.bodySmall?.copyWith(color: cs.onPrimary),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image(
        width: 32,
        height: 32,
        image: CachedNetworkImageProvider(CommonUtils.fixResourceUrl(user.avatar)),
        fit: BoxFit.cover,
      ),
    );
  }
}
