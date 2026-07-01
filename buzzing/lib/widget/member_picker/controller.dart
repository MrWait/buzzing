import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart';

class MemberPickerController extends ChangeNotifier {
  final ImController im;

  MemberPickerController({required this.im});

  List<Int64> navPath = [];
  Map<Int64, Department> deptCache = {};
  List<Department> currentDepts = [];
  List<User> currentMembers = [];
  List<User> selectedMembers = [];
  String searchQuery = '';
  List<User> searchResults = [];
  bool searching = false;
  bool loading = false;

  int maxSelect = 0;
  bool singleSelect = false;
  List<Int64> excludeIds = [];

  void Function(List<User> selected)? onChanged;
  void Function(List<User> selected)? onConfirm;

  bool get atRoot => navPath.isEmpty;

  String get currentDeptName {
    if (atRoot) return '';
    var dept = deptCache[navPath.last];
    return dept?.name ?? '';
  }

  void init() {
    loading = true;
    notifyListeners();
    Future.delayed(Duration.zero, () async {
      await _loadDeptCache();
      loading = false;
      notifyListeners();
    });
  }

  Future<void> _loadDeptCache() async {
    var resp = await im.getDeptInfo(Int64(0));
    if (resp == null) return;
    for (var entry in resp.depts.entries) {
      deptCache[entry.key] = entry.value;
    }
  }

  void enterOrgRoot() {
    loading = true;
    notifyListeners();
    Future.delayed(Duration.zero, () async {
      navPath.add(im.loginUser.tenant.rootDepartmentId);
      await _loadLevel();
      loading = false;
      notifyListeners();
    });
  }

  void enterDept(Int64 deptId) {
    loading = true;
    notifyListeners();
    Future.delayed(Duration.zero, () async {
      navPath.add(deptId);
      await _loadLevel();
      loading = false;
      notifyListeners();
    });
  }

  void goBack() {
    if (navPath.isEmpty) return;
    navPath.removeLast();
    loading = true;
    notifyListeners();
    Future.delayed(Duration.zero, () async {
      await _loadLevel();
      loading = false;
      notifyListeners();
    });
  }

  Future<void> _loadLevel() async {
    if (atRoot) {
      currentDepts = [];
      currentMembers = [];
      return;
    }
    var deptId = navPath.last;
    currentDepts = deptCache.values
        .where((d) => d.parentId == deptId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    var resp = await im.getDeptInfo(deptId);
    if (resp != null) {
      var memberList = resp.users.values.toList();
      memberList.sort((a, b) => a.name.compareTo(b.name));
      currentMembers = memberList;
    } else {
      currentMembers = [];
    }
  }

  void search(String query) {
    searchQuery = query;
    if (query.isEmpty) {
      searching = false;
      searchResults = [];
      notifyListeners();
      return;
    }
    searching = true;
    notifyListeners();
    Future.delayed(Duration.zero, () async {
      var allUsers = <User>[];
      var resp = await im.getDeptInfo(Int64(0));
      if (resp != null) {
        allUsers.addAll(resp.users.values);
      }
      var q = query.toLowerCase();
      searchResults = allUsers.where((u) {
        return u.name.toLowerCase().contains(q) ||
            u.id.toString().contains(q);
      }).toList();
      searchResults.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    });
  }

  bool isSelected(Int64 id) {
    return selectedMembers.any((u) => u.id == id);
  }

  bool isExcluded(Int64 id) {
    return excludeIds.any((e) => e == id);
  }

  void toggleSelect(User user) {
    if (isExcluded(user.id)) return;
    if (singleSelect) {
      selectedMembers = [user];
      notifyListeners();
      if (onChanged != null) onChanged!(List.from(selectedMembers));
      return;
    }
    if (isSelected(user.id)) {
      selectedMembers.removeWhere((u) => u.id == user.id);
    } else {
      if (maxSelect > 0 && selectedMembers.length >= maxSelect) return;
      selectedMembers.add(user);
    }
    notifyListeners();
    if (onChanged != null) onChanged!(List.from(selectedMembers));
  }

  void removeSelected(Int64 id) {
    selectedMembers.removeWhere((u) => u.id == id);
    notifyListeners();
    if (onChanged != null) onChanged!(List.from(selectedMembers));
  }

  void confirm() {
    if (onConfirm != null) {
      onConfirm!(List.from(selectedMembers));
    }
  }

  void reset() {
    navPath.clear();
    deptCache.clear();
    currentDepts.clear();
    currentMembers.clear();
    selectedMembers.clear();
    searchResults.clear();
    searchQuery = '';
    searching = false;
    loading = false;
    notifyListeners();
  }
}
