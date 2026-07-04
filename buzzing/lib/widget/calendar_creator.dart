import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/models/const.dart';
import 'package:buzzing/models/idl/calendar.pb.dart';
import 'package:buzzing/provider/sdk_provider.dart';
import 'package:buzzing/widget/avatar.dart';
import 'package:buzzing/widget/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/models/idl/chat.pb.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/widget/draft_input.dart';
import 'package:buzzing/widget/message.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/page/calendar/calendar_logic.dart';
import 'package:fixnum/fixnum.dart';

class CalendarCreator extends ConsumerWidget {
  final Calendar? editCalendar;
  const CalendarCreator({this.editCalendar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sdk = ref.watch(sdkProvider);
    final ctl = CalendarCreatorController(sdk: sdk, editCalendar: editCalendar);
    return AlertDialog(
      title: Text(editCalendar != null ? "Edit Calendar" : "Create Calendar"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: ctl.nameCtrl,
          decoration: InputDecoration(labelText: "Name"),
        ),
        SizedBox(height: 8),
        TextField(
          controller: ctl.descCtrl,
          decoration: InputDecoration(labelText: "Description"),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Text("Color: "),
            GestureDetector(
              onTap: () {
                showDialog<bool>(
                  context: context,
                  builder: (ctx) => ColorPickerDialog(
                    currentColor: ctl.selectedColor,
                    onSelected: (c) => ctl.selectedColor = c,
                  ),
                );
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Color(ctl.selectedColor),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text("Public: "),
            Switch(
              value: ctl.isPublic,
              onChanged: (v) => ctl.isPublic = v,
            ),
          ],
        ),
      ]),
      actions: <Widget>[
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Ok"),
          onPressed: () async {
            if (editCalendar != null) {
              await ctl.updateCalendar();
            } else {
              await ctl.createCalendar();
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class CalendarCreatorController {
  final SdkController sdk;
  final Calendar? editCalendar;

  CalendarCreatorController({required this.sdk, this.editCalendar}) {
    if (editCalendar != null) {
      nameCtrl.text = editCalendar!.name;
      descCtrl.text = editCalendar!.desc;
      selectedColor = editCalendar!.color;
      isPublic = editCalendar!.public;
    }
  }

  var nameCtrl = TextEditingController();
  var descCtrl = TextEditingController();
  var selectedColor = 0xFF3370FF;
  var isPublic = true;

  Future<void> createCalendar() async {
    if (nameCtrl.text.isEmpty) return;
    var req = CalendarCreateRequest.create();
    req.calendar = Calendar.create();
    req.calendar.name = nameCtrl.text;
    req.calendar.desc = descCtrl.text;
    req.calendar.color = selectedColor;
    req.calendar.public = isPublic;
    req.calendar.ensureSubscribers();
    req.calendar.subscribers.subscribers[sdk.userId] =
        Calendar_Subscriber(id: sdk.userId, role: CalendarRole.RoleOwner.value);
    var result = await sdk.invokeAsync(Command.CALENDAR_CREATE, req.writeToBuffer());
    if (result.data != null) {
      L.d("create calendar ok");
    }
  }

  Future<void> updateCalendar() async {
    if (editCalendar == null || nameCtrl.text.isEmpty) return;
    var req = CalendarUpdateRequest.create();
    req.calendar = Calendar.create();
    req.calendar.id = editCalendar!.id;
    req.calendar.name = nameCtrl.text;
    req.calendar.desc = descCtrl.text;
    req.calendar.color = selectedColor;
    req.calendar.public = isPublic;
    req.calendar.ensureSubscribers();
    await sdk.invokeAsync(Command.CALENDAR_UPDATE, req.writeToBuffer());
  }
}
