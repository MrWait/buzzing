import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/widget/member_picker/controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SelectedPanel extends StatelessWidget {
  final MemberPickerController ctl;

  SelectedPanel({required this.ctl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: PageStyle.c_EEEEEE)),
      ),
      child: Row(
        children: [
          Text(
            'Selected (${ctl.selectedMembers.length})',
            style: PageStyle.ts_666666_13sp,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (ctl.selectedMembers.isEmpty) {
      return Center(
        child: Text('No members selected', style: PageStyle.ts_999999_14sp),
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
          _buildAvatar(user),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              user.name,
              style: PageStyle.ts_333333_14sp,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User user) {
    if (user.avatar.isEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: PageStyle.c_418AE5,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: PageStyle.ts_FFFFFF_12sp,
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
