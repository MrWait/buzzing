import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/models/const.dart';
import 'package:buzzing/models/idl/calendar.pb.dart';
import 'package:buzzing/widget/avatar.dart';
import 'package:flutter/material.dart';
import 'package:buzzing/models/idl/chat.pb.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/widget/draft_input.dart';
import 'package:buzzing/widget/message.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/controller/event.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/res/styles.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart' as sdp;
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';

class ScheduleCreator extends StatelessWidget {
  final ctl = Get.put(ScheduleCreatorController());

  DateTime? startTime;
  ScheduleCreator({this.startTime}) {
    ctl.resetData();
    ctl.setStartTime(startTime);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> items = ["1", "2", "3"];
    return GetBuilder<ScheduleCreatorController>(
      id: ConstKey.KeyScheduleCreate,
      builder: (c) => AlertDialog(
          content: Container(
            margin: EdgeInsets.all(20.0),
            //child: Text("Create Schedule"),
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
                            hintStyle: PageStyle.ts_ADADAD_10sp),
                      ),
                      TextField(
                        controller: ctl.userSearchCtrl,
                        onChanged: (val) async {
                          await ctl.searchUser(val);
                        },
                        decoration: InputDecoration(
                            hintText: "Add Contact",
                            hintStyle: PageStyle.ts_ADADAD_10sp),
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
                            hintStyle: PageStyle.ts_ADADAD_10sp),
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
                                        ctl.startDateValue = date;
                                        ctl.update(
                                            [ConstKey.KeyScheduleCreate]);
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
                                if (value != null) {
                                  ctl.startTimeValue = value;
                                  ctl.update([ConstKey.KeyScheduleCreate]);
                                }
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
                                if (value != null) {
                                  ctl.endTimeValue = value;
                                  ctl.update([ConstKey.KeyScheduleCreate]);
                                }
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
                                        ctl.endDateValue = date;
                                        ctl.update(
                                            [ConstKey.KeyScheduleCreate]);
                                      }),
                                ))),
                      ]),
                    ]))),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Text("Ok"),
              onPressed: () async {
                await ctl.createSchedule();
                Get.back();
              },
            ),
          ]),
    );
  }
}

class ScheduleCreatorController extends GetxController {
  final sdk = Get.find<SdkController>();

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
