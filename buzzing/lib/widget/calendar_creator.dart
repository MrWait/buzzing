import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/models/const.dart';
import 'package:buzzing/models/idl/calendar.pb.dart';
import 'package:buzzing/provider/sdk_provider.dart';
import 'package:buzzing/widget/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/models/idl/chat.pb.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/widget/draft_input.dart';
import 'package:buzzing/widget/message.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/res/styles.dart';
import 'package:fixnum/fixnum.dart';

class CalendarCreator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sdk = ref.watch(sdkProvider);
    final ctl = CalendarCreatorController(sdk: sdk);
    return AlertDialog(
      content: Column(children: [
        Text("Create Calendar"),
        TextField(
          controller: ctl.nameCtrl,
        ),
        TextField(
          controller: ctl.descCtrl,
        ),
      ]),
      actions: <Widget>[
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            ctl.resetData();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Ok"),
          onPressed: () async {
            await ctl.createCalendar();
            ctl.resetData();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class CalendarCreatorController {
  final SdkController sdk;
  CalendarCreatorController({required this.sdk});

  var nameCtrl = TextEditingController();
  var descCtrl = TextEditingController();

  Future<void> createCalendar() async {
    if (nameCtrl.text.isEmpty) {
      return;
    }

    var req = CalendarCreateRequest.create();
    req.calendar = Calendar.create();
    req.calendar.name = nameCtrl.text;
    req.calendar.desc = descCtrl.text;
    req.calendar.ensureSubscribers();
    req.calendar.subscribers.subscribers[sdk.userId] =
        Calendar_Subscriber(id: sdk.userId, role: CalendarRole.RoleOwner.value);

    var result =
        await sdk.invokeAsync(Command.CALENDAR_CREATE, req.writeToBuffer());
    if (result.data == null) {
      L.d("create calendar error: ${result.code}");
    } else {
      var resp = CalendarCreateResponse.fromBuffer(result.data!);
      L.d("create calendar ok: $resp");
    }
  }

  void resetData() {
    nameCtrl.clear();
    descCtrl.clear();
  }
}
