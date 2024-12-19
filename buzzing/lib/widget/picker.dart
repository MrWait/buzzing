import 'package:buzzing/models/const.dart';
import 'package:buzzing/res/strings.dart';
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
import 'package:get/get.dart';
import 'package:fixnum/fixnum.dart';

class Picker extends StatefulWidget {
  String title = "";
  int scene = 0;
  Function onSelect;

  Picker(this.title, this.scene, this.onSelect);
  @override
  State<StatefulWidget> createState() =>
      new PickerState(title, scene, onSelect);
}

class PickerState extends State<Picker> {
  String title = "";
  int scene = 0;
  Function onSelect;

  List<int> selectIds = [1, 2, 4];
  PickerState(this.title, this.scene, this.onSelect);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(title),
        content: Text(scene.toString()),
        actions: <Widget>[
          TextButton(child: Text(StrRes.cancel), onPressed: () => Get.back()),
          TextButton(
              child: Text(StrRes.ok),
              onPressed: () {
                if (this.selectIds.length > 0) {
                  var ids = this.selectIds;
                  onSelect(ids);
                }
                Get.back();
              }),
        ]);
  }
}

class Selector extends StatelessWidget {
  SelectorController ctl;

  Selector(
      this.ctl, List<String> filters, Function onChanged, bool searchEnable) {
    this.ctl = ctl;
    ctl.filters = filters;
    ctl.onChanged = onChanged;
    ctl.setSearchEnable(searchEnable);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      constraints: BoxConstraints(minHeight: 200),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Obx(
                () => SelectArea(mode: ctl.mode.value, ctl: ctl),
              )),
          Expanded(
            flex: 1,
            child: CandidateArea(ctl: ctl),
          )
        ],
      ),
    );
  }
}

class OW extends StatelessWidget {
  final int ver;
  final WidgetCallback builder;
  OW(this.ver, this.builder);
  @override
  Widget build(BuildContext context) {
    return builder();
  }
}

class SelectArea extends StatelessWidget {
  const SelectArea({Key? key, required this.ctl, this.mode = 0})
      : super(key: key);

  final int mode;
  final SelectorController ctl;

  // mode: 0 for initial; 1: internal contact; 2: external contact; 3: my group
  @override
  Widget build(BuildContext context) {
    Widget w;
    switch (this.mode) {
      case 1:
        w = Container(
            //width: 100,
            //height: 200,
            color: Colors.black38,
            child: GetBuilder<SelectorController>(
              id: ConstKey.KeyPickerSelect,
              builder: (c) => ListView.separated(
                itemCount: ctl.listUsers.value.length,
                itemBuilder: (context, index) {
                  var u = ctl.listUsers.value[index];
                  return SelectItem(
                      ctl.getSelectState(u.id).value,
                      u.avatar,
                      Icon(Icons.account_circle_outlined,
                          color: Colors.lightBlue),
                      u.name, (bool? select) async {
                    c.setSelectState(u.id, select ?? true);
                  });
                },
                separatorBuilder: (context, index) => Divider(height: 0.0),
              ),
            ));
      case 2:
        w = GestureDetector(
          child: Container(width: 100, height: 44, child: Text(StrRes.search)),
          onTap: () {
            //ctl.mode.value = 0;
          },
        );
      default:
        w = GestureDetector(
          child: Column(children: [
            GestureDetector(
              child: Container(height: 44, child: Text("Internal Contact")),
              onTap: () {
                ctl.mode.value = 1;
                ctl.getInternalContact();
              },
            ),
            GestureDetector(
              child: Container(height: 44, child: Text("External Contact")),
              onTap: () {
                ctl.mode.value = 2;
                ctl.getExternalContact();
              },
            ),
            GestureDetector(
                child: Container(
                  height: 44,
                  child: Text("My Group"),
                ),
                onTap: () {
                  ctl.mode.value = 3;
                  ctl.getMyGroup();
                }),
          ]),
          onTap: () {
            ctl.mode.value = 1;
          },
        );
    }
    return Container(
        //height: 300,
        child: Column(
      children: [
        Container(
          child: TextField(
            maxLines: 1,
            controller: ctl.search,
          ),
        ),
        Expanded(child: w),
      ],
    ));
  }
}

class SelectItem extends StatelessWidget {
  final ValueChanged<bool?>? onSelect;
  bool select;
  final String avatar;
  final Widget icon;
  final String title;

  SelectItem(this.select, this.avatar, this.icon, this.title, this.onSelect);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 100,
        height: 44,
        child: Row(
          children: [
            Checkbox(
              value: this.select,
              onChanged: this.onSelect,
            ),
            Avatar(this.avatar, this.icon),
            Text(this.title),
          ],
        ),
      ),
      onTap: () {
        this.select = !this.select;
        if (onSelect != null) {
          onSelect!(this.select);
        }
      },
    );
  }
}

class CandidateArea extends StatelessWidget {
  final SelectorController ctl;
  const CandidateArea({Key? key, required this.ctl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        color: Colors.black12,
        child: GetBuilder<SelectorController>(
            id: ConstKey.KeyPickerCandidate,
            builder: (c) => ListView.separated(
                itemCount: ctl.selectedUsers.value.length,
                itemBuilder: (context, index) {
                  var u = ctl.selectedUsers.value[index];
                  return Container(
                      height: 44,
                      child: Row(children: [
                        Avatar(
                            u.avatar,
                            Icon(Icons.account_circle_outlined,
                                color: Colors.lightBlue)),
                        Text(u.name),
                        Spacer(),
                        GestureDetector(
                          child: Icon(Icons.close, color: Colors.black26),
                          onTap: () {
                            c.setSelectState(u.id, false);
                          },
                        ),
                      ]));
                },
                separatorBuilder: (context, index) => Divider(height: 0.0))));
  }
}

class SelectorController extends GetxController {
  var im = Get.find<ImController>();
  List<String> filters = [];
  var search = TextEditingController();
  Function? onChanged;

  Rx<List<User>> listUsers = Rx([]);
  Rx<List<User>> selectedUsers = Rx([]);
  Map<Int64, Rx<bool>> selectState = {};
  var searchEnable = false.obs;
  var mode = 0.obs;
  var ver = 0.obs;

  Rx<bool> getSelectState(Int64 id) {
    if (!selectState.containsKey(id)) {
      selectState[id] = false.obs;
    }
    return selectState[id]!;
  }

  void setSelectState(Int64 id, bool state) {
    ver.value += 1;
    if (!selectState.containsKey(id)) {
      selectState[id] = state.obs;
    }
    selectState[id]!.value = state;

    listUsers.value.add(User.create());
    listUsers.value.removeLast();

    if (!state) {
      selectedUsers.value.removeWhere((item) {
        return item.id == id;
      });
    } else {
      for (var u in listUsers.value) {
        if (u.id == id) {
          selectedUsers.value.add(u);
        }
      }
    }

    var ids = List<Int64>.from(selectedUsers.value.map((u) => u.id));
    if (this.onChanged != null) {
      this.onChanged!(ids);
    }
    update([ConstKey.KeyPickerCandidate, ConstKey.KeyPickerSelect]);
  }

  @override
  void onInit() {
    // TODO: implement onInit
    L.d("SelectorController init");
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    L.d("SelectorController close");
  }

  void setSearchEnable(bool enable) {
    searchEnable.value = enable;
  }

  void reset() {
    selectedUsers.value.clear();
    listUsers.value.clear();
    mode.value = 0;
    selectState.clear();
  }

  void getInternalContact() {
    Future.delayed(Duration.zero, () async {
      var list = await im.getDeptInfo(Int64(0));
      L.d("get list info: ${list}");
      if (list != null) {
        listUsers.value.clear();
        listUsers.value.addAll(list.users.values);
      }
      L.d("list users: ${listUsers.value}");
      update([ConstKey.KeyPickerCandidate, ConstKey.KeyPickerSelect]);
    });
  }

  void getExternalContact() {
    Future.delayed(Duration.zero, () async {});
  }

  void getMyGroup() {
    Future.delayed(Duration.zero, () async {});
  }
}

class ImChatCreater extends StatelessWidget {
  ImChatCreaterController controller = Get.put(ImChatCreaterController());
  SelectorController select = Get.put(SelectorController());
  ImChatCreater() {
    //L.d("ImChatCreater init");
    //controller.reset();
    //select.reset();
  }

  @override
  StatelessElement createElement() {
    // TODO: implement createElement
    L.d("ImChatCreater create element");
    controller.reset();
    select.reset();
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Column(
          children: [
            Container(
                height: 40,
                //color: Colors.lightGreen,
                child: Row(
                  children: [
                    Text("Name"),
                    Expanded(
                        child: TextField(
                      maxLines: 1,
                      controller: controller.chatNameInputCtrl,
                    )),
                  ],
                )),
            Container(
                height: 40,
                //color: Colors.lightBlue,
                child: Row(
                  children: [Text("Avatar")],
                )),
            Expanded(
                //height: 400,
                //color: Colors.grey,
                flex: 1,
                child: Row(
                  children: [
                    Container(
                        alignment: Alignment.topCenter, child: Text("Member")),
                    Container(
                        height: 1500,
                        width: 600,
                        color: Colors.black26,
                        //flex: 1,
                        child: Selector(select, ["all"], (ids) {
                          controller.updateSelected(ids);
                        }, true)),
                  ],
                )),
          ],
        ),
        actions: <Widget>[
          TextButton(
              child: Text("Cancel"),
              onPressed: () {
                controller.reset();
                select.reset();
                Get.back();
              }),
          TextButton(
              child: Text("OK"),
              onPressed: () {
                controller.reset();
                select.reset();
                controller.createChat();
                Get.back();
              }),
        ]);
  }
}

class ImChatCreaterController extends GetxController {
  var im = Get.find<ImController>();
  var chatNameInputCtrl = TextEditingController();
  var selectSearchCtrl = TextEditingController();

  var avatar = "".obs;
  List<Int64> userIds = [];

  @override
  void onInit() {
    // TODO: implement onInit
    L.d("ImChatCreaterController init");
    super.onInit();
  }

  void reset() {
    chatNameInputCtrl.clear();
    selectSearchCtrl.clear();
  }

  void createChat() {
    Future.delayed(Duration.zero, () async {
      var chatId =
          await im.createChat(chatNameInputCtrl.text, false, Int64(0), userIds);
      if (chatId != null) {
        L.d("create chat ok, enter chat: ${chatId}");
      }
    });
  }

  void updateSelected(List<Int64> ids) {
    userIds = ids;
    L.d("update selected: ${ids}");
  }

  @override
  void onClose() {
    // TODO: implement onClose
    L.w("chat creater controller close");
    super.onClose();
  }
}
