import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/res/styles.dart';
import 'package:buzzing/widget/member_picker/contact_panel.dart';
import 'package:buzzing/widget/member_picker/controller.dart';
import 'package:buzzing/widget/member_picker/selected_panel.dart';
import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart';

class MemberPickerOptions {
  final bool singleSelect;
  final int maxSelect;
  final List<Int64> excludeIds;
  final void Function(List<User> selected)? onChanged;
  final void Function(List<User> selected)? onConfirm;

  MemberPickerOptions({
    this.singleSelect = false,
    this.maxSelect = 0,
    this.excludeIds = const [],
    this.onChanged,
    this.onConfirm,
  });
}

class MemberPickerPanel extends StatelessWidget {
  final MemberPickerController ctl;
  final double? height;

  MemberPickerPanel({required this.ctl, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: PageStyle.c_EEEEEE),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(child: ContactPanel(ctl: ctl)),
          Expanded(child: SelectedPanel(ctl: ctl)),
        ],
      ),
    );
  }
}

class MemberPicker extends StatefulWidget {
  final ImController im;
  final MemberPickerOptions options;

  MemberPicker({required this.im, required this.options});

  @override
  State<MemberPicker> createState() => _MemberPickerState();
}

class _MemberPickerState extends State<MemberPicker> {
  late MemberPickerController ctl;

  @override
  void initState() {
    super.initState();
    ctl = MemberPickerController(im: widget.im);
    var o = widget.options;
    ctl.singleSelect = o.singleSelect;
    ctl.maxSelect = o.maxSelect;
    ctl.excludeIds = o.excludeIds;
    ctl.onChanged = o.onChanged;
    ctl.onConfirm = o.onConfirm;
    ctl.init();
  }

  @override
  void dispose() {
    ctl.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ctl,
      builder: (context, _) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 80, vertical: 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            width: 680,
            height: 480,
            child: Column(
              children: [
                Expanded(
                  child: ctl.loading
                      ? Center(child: CircularProgressIndicator())
                      : MemberPickerPanel(ctl: ctl),
                ),
                _buildFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: PageStyle.c_EEEEEE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              ctl.confirm();
              Navigator.of(context).pop();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
