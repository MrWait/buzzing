import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/widget/member_picker/controller.dart';
import 'package:buzzing/widget/user_list_item.dart';
import 'package:flutter/material.dart';

class SelectedPanel extends StatelessWidget {
  final MemberPickerController ctl;

  SelectedPanel({required this.ctl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        _buildHeader(cs, tt),
        Expanded(child: _buildList(cs, tt)),
      ],
    );
  }

  Widget _buildHeader(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.surfaceVariant)),
      ),
      child: Row(
        children: [
          Text(
            t.selectedNum.replaceAll('%s', '${ctl.selectedMembers.length}'),
            style: tt.bodyMedium?.copyWith(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ColorScheme cs, TextTheme tt) {
    if (ctl.selectedMembers.isEmpty) {
      return Center(
        child: Text('No members selected', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      );
    }
    return ListView.builder(
      itemCount: ctl.selectedMembers.length,
      itemBuilder: (context, index) {
        var user = ctl.selectedMembers[index];
        return _buildSelectedItem(context, user);
      },
    );
  }

  Widget _buildSelectedItem(BuildContext context, User user) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: true,
            onChanged: (_) => ctl.removeSelected(user.id),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          _buildAvatar(cs, tt, user),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              user.name,
              style: tt.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme cs, TextTheme tt, User user) {
    return UserAvatar(name: user.name, avatar: user.avatar, size: 32);
  }
}
