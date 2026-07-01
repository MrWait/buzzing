import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/widget/member_picker/controller.dart';
import 'package:buzzing/widget/member_picker/member_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fixnum/fixnum.dart';

class ImChatCreater extends ConsumerStatefulWidget {
  @override
  ConsumerState<ImChatCreater> createState() => _ImChatCreaterState();
}

class _ImChatCreaterState extends ConsumerState<ImChatCreater> {
  late final ImChatCreaterController _ctl;
  late final MemberPickerController _memberCtl;

  @override
  void initState() {
    super.initState();
    _ctl = ImChatCreaterController();
    final im = ref.read(imProvider);
    _memberCtl = MemberPickerController(im: im);
    _memberCtl.excludeIds = [im.userId];
    _memberCtl.onChanged = (users) => _ctl.setMembers(users);
    _memberCtl.init();
  }

  @override
  void dispose() {
    _ctl.dispose();
    _memberCtl.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 640,
        height: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Group', style: PageStyle.ts_171A1D_18sp),
            SizedBox(height: 16),
            TextField(
              controller: _ctl.chatNameInputCtrl,
              decoration: InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
                hintStyle: PageStyle.ts_999999_14sp,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _buildAvatarPreview(),
                SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {},
                  child: Text('Change'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Members', style: PageStyle.ts_333333_14sp),
            SizedBox(height: 8),
            Expanded(
              child: ListenableBuilder(
                listenable: _memberCtl,
                builder: (context, _) {
                  if (_memberCtl.loading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return MemberPickerPanel(ctl: _memberCtl);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _ctl.dispose();
            _memberCtl.reset();
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final navigator = Navigator.of(context);
            _ctl.createChat(ref.read(imProvider)).then((_) {
              _ctl.dispose();
              _memberCtl.reset();
              navigator.pop();
            });
          },
          child: Text('Create'),
        ),
      ],
    );
  }

  Widget _buildAvatarPreview() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: PageStyle.c_418AE5,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.group, size: 28, color: Colors.white),
    );
  }
}

class ImChatCreaterController {
  var chatNameInputCtrl = TextEditingController();
  List<User> selectedMembers = [];

  void setMembers(List<User> users) {
    selectedMembers = users;
  }

  Future<void> createChat(ImController im) async {
    if (chatNameInputCtrl.text.isEmpty && selectedMembers.isEmpty) return;
    var userIds = selectedMembers.map((u) => u.id).toList();
    await im.createChat(
      chatNameInputCtrl.text,
      false,
      Int64(0),
      userIds,
    );
  }

  void dispose() {
    chatNameInputCtrl.dispose();
  }
}
