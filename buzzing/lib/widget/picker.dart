import 'package:buzzing/models/const.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/widget/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/models/idl/chat.pb.dart';
import 'package:buzzing/models/idl/command.pb.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/widget/draft_input.dart';
import 'package:buzzing/widget/message.dart';
import 'package:buzzing/controller/im.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/models/model.dart';
import 'package:buzzing/res/styles.dart';
import 'package:fixnum/fixnum.dart';

class Picker extends StatefulWidget {
  final String title;
  final int scene;
  final Function onSelect;

  Picker(this.title, this.scene, this.onSelect);
  @override
  State<StatefulWidget> createState() => PickerState();
}

class PickerState extends State<Picker> {
  List<int> selectIds = [1, 2, 4];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(widget.title),
        content: Text(widget.scene.toString()),
        actions: <Widget>[
          TextButton(child: Text(t.cancel), onPressed: () => Navigator.of(context).pop()),
          TextButton(
              child: Text(t.ok),
              onPressed: () {
                if (this.selectIds.length > 0) {
                  var ids = this.selectIds;
                  widget.onSelect(ids);
                }
                Navigator.of(context).pop();
              }),
        ]);
  }
}

class Selector extends StatefulWidget {
  final SelectorController ctl;

  Selector(this.ctl, List<String> filters, Function onChanged, bool searchEnable) {
    ctl.filters = filters;
    ctl.onChanged = onChanged;
    ctl.setSearchEnable(searchEnable);
  }

  @override
  State<Selector> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      constraints: BoxConstraints(minHeight: 200),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: SelectArea(mode: widget.ctl.mode, ctl: widget.ctl),
              ),
          Expanded(
            flex: 1,
            child: CandidateArea(ctl: widget.ctl),
          )
        ],
      ),
    );
  }
}

typedef WidgetBuilder = Widget Function();

class OW extends StatelessWidget {
  final int ver;
  final WidgetBuilder builder;
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

  @override
  Widget build(BuildContext context) {
    Widget w;
    switch (this.mode) {
      case 1:
        w = Container(
            color: Colors.black38,
            child: ListView.separated(
              itemCount: ctl.listUsers.length,
              itemBuilder: (context, index) {
                var u = ctl.listUsers[index];
                return SelectItem(
                    ctl.getSelectState(u.id),
                    u.avatar,
                    Icon(Icons.account_circle_outlined,
                        color: Colors.lightBlue),
                    u.name, (bool? select) async {
                  ctl.setSelectState(u.id, select ?? true);
                });
              },
              separatorBuilder: (context, index) => Divider(height: 0.0),
            ));
      case 2:
        w = GestureDetector(
          child: Container(width: 100, height: 44, child: Text(t.search)),
          onTap: () {},
        );
      default:
        w = GestureDetector(
          child: Column(children: [
            GestureDetector(
              child: Container(height: 44, child: Text("Internal Contact")),
              onTap: () {
                ctl.mode = 1;
                ctl.getInternalContact();
                ctl.notifyListeners();
              },
            ),
            GestureDetector(
              child: Container(height: 44, child: Text("External Contact")),
              onTap: () {
                ctl.mode = 2;
                ctl.getExternalContact();
                ctl.notifyListeners();
              },
            ),
            GestureDetector(
                child: Container(
                  height: 44,
                  child: Text("My Group"),
                ),
                onTap: () {
                  ctl.mode = 3;
                  ctl.getMyGroup();
                  ctl.notifyListeners();
                }),
          ]),
          onTap: () {
            ctl.mode = 1;
            ctl.notifyListeners();
          },
        );
    }
    return Container(
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
    return Container(
        color: Colors.black12,
        child: ListView.separated(
            itemCount: ctl.selectedUsers.length,
            itemBuilder: (context, index) {
              var u = ctl.selectedUsers[index];
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
                        ctl.setSelectState(u.id, false);
                      },
                    ),
                  ]));
            },
            separatorBuilder: (context, index) => Divider(height: 0.0)));
  }
}

class SelectorController extends ChangeNotifier {
  final ImController im;
  SelectorController({required this.im});
  List<String> filters = [];
  var search = TextEditingController();
  Function? onChanged;

  List<User> listUsers = [];
  List<User> selectedUsers = [];
  Map<Int64, bool> selectState = {};
  bool searchEnable = false;
  int mode = 0;
  int ver = 0;

  bool getSelectState(Int64 id) {
    if (!selectState.containsKey(id)) {
      selectState[id] = false;
    }
    return selectState[id]!;
  }

  void setSelectState(Int64 id, bool state) {
    ver += 1;
    selectState[id] = state;

    if (!state) {
      selectedUsers.removeWhere((item) {
        return item.id == id;
      });
    } else {
      for (var u in listUsers) {
        if (u.id == id) {
          selectedUsers.add(u);
        }
      }
    }

    var ids = List<Int64>.from(selectedUsers.map((u) => u.id));
    if (this.onChanged != null) {
      this.onChanged!(ids);
    }
    notifyListeners();
  }

  void init() {
    L.d("SelectorController init");
  }

  void close() {
    L.d("SelectorController close");
  }

  void setSearchEnable(bool enable) {
    searchEnable = enable;
    notifyListeners();
  }

  void reset() {
    selectedUsers.clear();
    listUsers.clear();
    mode = 0;
    selectState.clear();
    notifyListeners();
  }

  void getInternalContact() {
    Future.delayed(Duration.zero, () async {
      var list = await im.getDeptInfo(Int64(0));
      L.d("get list info: ${list}");
      if (list != null) {
        listUsers.clear();
        listUsers.addAll(list.users.values);
      }
      L.d("list users: ${listUsers}");
      notifyListeners();
    });
  }

  void getExternalContact() {
    Future.delayed(Duration.zero, () async {});
  }

  void getMyGroup() {
    Future.delayed(Duration.zero, () async {});
  }
}

class ImChatCreater extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final im = ref.watch(imProvider);
    final controller = ImChatCreaterController(im: im);
    final select = SelectorController(im: im);
    controller.reset();
    select.reset();
    return AlertDialog(
        content: Column(
          children: [
            Container(
                height: 40,
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
                child: Row(
                  children: [Text("Avatar")],
                )),
            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Container(
                        alignment: Alignment.topCenter, child: Text("Member")),
                    Container(
                        height: 1500,
                        width: 600,
                        color: Colors.black26,
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
                Navigator.of(context).pop();
              }),
          TextButton(
              child: Text("OK"),
              onPressed: () {
                controller.reset();
                select.reset();
                controller.createChat();
                Navigator.of(context).pop();
              }),
        ]);
  }
}

class ImChatCreaterController {
  final ImController im;
  ImChatCreaterController({required this.im});
  var chatNameInputCtrl = TextEditingController();
  var selectSearchCtrl = TextEditingController();

  String avatar = "";
  List<Int64> userIds = [];

  void init() {
    L.d("ImChatCreaterController init");
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

  void close() {
    L.w("chat creater controller close");
  }
}
