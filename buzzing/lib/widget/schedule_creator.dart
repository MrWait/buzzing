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
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/res/theme.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:intl/intl.dart';
import 'package:fixnum/fixnum.dart';
import 'package:buzzing/utils/screen_ext.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart' as sdp;
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';

class ScheduleCreator extends ConsumerWidget {
  final DateTime? startTime;
  ScheduleCreator({this.startTime});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sdk = ref.watch(sdkProvider);
    return StatefulBuilder(
      builder: (context, setState) {
        final ctl = ScheduleCreatorController(sdk: sdk);
        ctl.resetData();
        ctl.setStartTime(startTime);
        return AlertDialog(
            content: Container(
              margin: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                  child: Container(
                      height: 0.6.sh,
                      width: 0.5.sw,
                      child: Column(children: [
                        Container(
                            alignment: Alignment.centerLeft,
                            child: Text("Create Schedule")),
                        TextField(
                          controller: ctl.titleCtrl,
                          decoration: InputDecoration(
                            hintText: "Input Title",
                            hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                          ),
                        ),
                        TextField(
                          controller: ctl.userSearchCtrl,
                          onChanged: (val) async {
                            await ctl.searchUser(val);
                          },
                          decoration: InputDecoration(
                            hintText: "Add Contact",
                            hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                          ),
                        ),
                        Container(
                          height: 20,
                          child: ListView.builder(
                            itemCount: ctl.users.length,
                            itemBuilder: (context, index) {
                              return Text("User + ${index}");
                            },
                          ),
                        ),
                        TextField(
                          controller: ctl.descCtrl,
                          onChanged: (val) async {
                            await ctl.searchUser(val);
                          },
                          decoration: InputDecoration(
                            hintText: "Add Describe",
                            hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                          ),
                        ),
                        Row(children: [
                          Flexible(
                              flex: 4,
                              child: CustomPopup(
                                  showArrow: false,
                                  child: Text(
                                      ctl.dayFormat.format(ctl.startDateValue)),
                                  content: SizedBox(
                                    width: 350,
                                    child: CupertinoCalendar(
                                        minimumDateTime: DateTime(2000, 1, 1),
                                        maximumDateTime: DateTime(2030, 12, 31),
                                        initialDateTime: ctl.startDateValue,
                                        currentDateTime: DateTime.now(),
                                        timeLabel: "Start",
                                        mode: CupertinoCalendarMode.date,
                                        onDateTimeChanged: (date) {
                                          setState(() {
                                            ctl.startDateValue = date;
                                          });
                                        }),
                                  ))),
                          Flexible(
                            flex: 5,
                            child: DropdownButton2<int>(
                                isExpanded: true,
                                hint: Text("Start"),
                                items: ctl.timeValues
                                    .map((int item) => DropdownMenuItem<int>(
                                          value: item,
                                          child: Text(ctl.timeFormat
                                              .format(ctl.timePickerList[item])),
                                        ))
                                    .toList(),
                                value: ctl.startTimeValue,
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null) {
                                      ctl.startTimeValue = value;
                                    }
                                  });
                                }),
                          ),
                          Flexible(
                            flex: 5,
                            child: DropdownButton2<int>(
                                isExpanded: true,
                                hint: Text("End"),
                                items: ctl.timeValues
                                    .map((int item) => DropdownMenuItem<int>(
                                          value: item,
                                          child: Text(ctl.timeFormat
                                              .format(ctl.timePickerList[item])),
                                        ))
                                    .toList(),
                                value: ctl.endTimeValue,
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null) {
                                      ctl.endTimeValue = value;
                                    }
                                  });
                                }),
                          ),
                          Flexible(
                              flex: 4,
                              child: CustomPopup(
                                  showArrow: false,
                                  child: Text(
                                      ctl.dayFormat.format(ctl.endDateValue)),
                                  content: SizedBox(
                                    width: 350,
                                    child: CupertinoCalendar(
                                        minimumDateTime: DateTime(2000, 1, 1),
                                        maximumDateTime: DateTime(2030, 12, 31),
                                        initialDateTime: ctl.endDateValue,
                                        currentDateTime: DateTime.now(),
                                        timeLabel: "End",
                                        mode: CupertinoCalendarMode.date,
                                        onDateTimeChanged: (date) {
                                          setState(() {
                                            ctl.endDateValue = date;
                                          });
                                        }),
                                  ))),
                        ]),
                      ]))),
            ),
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
                  await ctl.createSchedule();
                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
    );
  }
}

class ScheduleCreatorController {
  final SdkController sdk;
  ScheduleCreatorController({required this.sdk});

  var titleCtrl = TextEditingController();
  var userSearchCtrl = TextEditingController();
  var descCtrl = TextEditingController();
  List<User> users = [];

  var schedule = Schedule.create();
  DateTime startDateValue = DateTime.now();
  DateTime endDateValue = DateTime.now();
  int startTimeValue = 0;
  int endTimeValue = 0;
  List<int> timeValues = genTimeValue();
  final timePickerList = genTimePickerList();
  var dayFormat = DateFormat("yyyy-MM-dd");
  var timeFormat = DateFormat("H:mm");

  DateTime startTime = DateTime.now();

  void setStartTime(DateTime? t) {
    if (t == null) {
      return;
    }
    this.startTime = t;
    startDateValue = t;
    endDateValue = t;
    startTimeValue = startTime!.hour * 2;
    if (startTime!.minute > 30) {
      startTimeValue += 1;
    }

    if (startTimeValue > timeValues.length) {
      startTimeValue = 0;
    }

    endTimeValue = startTimeValue + 1;

    if (endTimeValue > timeValues.length) {
      endTimeValue = 0;
      startDateValue.add(Duration(days: 1));
    }
  }

  static List<DateTime> genTimePickerList() {
    var now = DateTime.now();
    List<DateTime> values = [];
    int minute = 0;
    for (var i = 0; i < 48; i++) {
      var delta = now.copyWith(
          hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      values.add(delta.add(Duration(minutes: minute)));
      minute += 30;
    }
    return values;
  }

  void resetData() {
    schedule.clear();
    titleCtrl.clear();
    userSearchCtrl.clear();
    descCtrl.clear();
  }

  static List<int> genTimeValue() {
    List<int> list = [];
    for (var i = 0; i < 48; i++) {
      list.add(i);
    }
    return list;
  }

  Future<void> createSchedule() async {
    var req = ScheduleCreateRequest.create();
    req.schedule = schedule;
    schedule.title = titleCtrl.text;
    schedule.desc = descCtrl.text;
    var startTime = startDateValue.copyWith(
        hour: timePickerList[startTimeValue].hour,
        minute: timePickerList[startTimeValue].minute);
    var endTime = endDateValue.copyWith(
        hour: timePickerList[endTimeValue].hour,
        minute: timePickerList[endTimeValue].minute);
    schedule.startTime = Int64(startTime.millisecondsSinceEpoch);
    schedule.endTime = Int64(endTime.millisecondsSinceEpoch);
    schedule.calendarId = sdk.userId;
    schedule.memberIds.add(sdk.userId);

    var result = await sdk.invokeAsync(
      Command.SCHEDULE_CREATE,
      req.writeToBuffer(),
    );
    if (result.data != null) {
      var resp = ScheduleCreateResponse.fromBuffer(result.data!);
      L.d("create schedule success, $resp");
    } else {
      L.d("create schedule error, ${result.code}");
    }
  }

  Future<void> searchUser(String val) async {}
}
