import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:buzzing/widget/member_picker/controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ContactPanel extends StatelessWidget {
  final MemberPickerController ctl;

  ContactPanel({required this.ctl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: PageStyle.c_EEEEEE)),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: PageStyle.c_EEEEEE)),
      ),
      child: TextField(
        onChanged: ctl.search,
        decoration: InputDecoration(
          hintText: 'Search members...',
          hintStyle: PageStyle.ts_999999_14sp,
          prefixIcon: Icon(Icons.search, color: PageStyle.c_999999, size: 20),
          filled: true,
          fillColor: PageStyle.c_F5F5F5,
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

  Widget _buildBody(BuildContext context) {
    if (ctl.searching) {
      return _buildSearchResults();
    }
    if (ctl.atRoot) {
      return _buildRootView();
    }
    return _buildDeptView(context);
  }

  Widget _buildSearchResults() {
    if (ctl.searchResults.isEmpty) {
      return Center(child: Text('No results', style: PageStyle.ts_999999_14sp));
    }
    return ListView.builder(
      itemCount: ctl.searchResults.length,
      itemBuilder: (context, index) {
        var user = ctl.searchResults[index];
        return _buildUserItem(context, user);
      },
    );
  }

  Widget _buildRootView() {
    return ListView(
      children: [
        _buildOrgEntry(),
      ],
    );
  }

  Widget _buildOrgEntry() {
    return GestureDetector(
      onTap: () => ctl.enterOrgRoot(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.account_tree_outlined, size: 20, color: PageStyle.c_666666),
            SizedBox(width: 10),
            Text('Contacts', style: PageStyle.ts_333333_14sp),
            Spacer(),
            Icon(Icons.chevron_right, size: 20, color: PageStyle.c_999999),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptView(BuildContext context) {
    return Column(
      children: [
        _buildNavigationBar(),
        Expanded(
          child: ListView(
            children: [
              ...ctl.currentDepts.map((dept) => _buildDeptItem(dept)),
              ...ctl.currentMembers.map((user) => _buildUserItem(context, user)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: PageStyle.c_EEEEEE)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ctl.goBack(),
            child: Icon(Icons.arrow_back, size: 18, color: PageStyle.c_666666),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              ctl.currentDeptName,
              style: PageStyle.ts_333333_14sp.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeptItem(Department dept) {
    return GestureDetector(
      onTap: () => ctl.enterDept(dept.id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.folder_outlined, size: 20, color: PageStyle.c_666666),
            SizedBox(width: 10),
            Expanded(
              child: Text(dept.name, style: PageStyle.ts_333333_14sp),
            ),
            Icon(Icons.chevron_right, size: 18, color: PageStyle.c_999999),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, User user) {
    var selected = ctl.isSelected(user.id);
    var excluded = ctl.isExcluded(user.id);
    var enabled = !excluded;
    return GestureDetector(
      onTap: enabled ? () => ctl.toggleSelect(user) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: selected ? PageStyle.c_F0F6FF : null,
        child: Row(
          children: [
            enabled
                ? Checkbox(
                    value: selected,
                    onChanged: (_) => ctl.toggleSelect(user),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )
                : SizedBox(width: 40),
            _buildAvatar(user),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                user.name,
                style: PageStyle.ts_333333_14sp.copyWith(
                  color: enabled ? null : PageStyle.c_999999,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
