import 'package:buzzing/controller/im.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart';

class DeptNav {
  final Int64 id;
  final String name;
  const DeptNav({required this.id, required this.name});
}

class ContactController extends ChangeNotifier {
  final ImController im;
  ContactController({required this.im});

  int mode = 0;

  final List<DeptNav> navPath = [];
  List<Department> currentDepts = [];
  List<User> currentUsers = [];
  final Map<Int64, Department> _deptCache = {};

  String _searchQuery = '';

  Tenant getTenant() => im.loginUser.tenant;

  List<User> get filteredUsers {
    if (_searchQuery.isEmpty) return currentUsers;
    final q = _searchQuery.toLowerCase();
    return currentUsers.where((u) => u.name.toLowerCase().contains(q)).toList();
  }

  bool get isLoading => false;

  List<String> get breadcrumbLabels {
    if (navPath.isEmpty) return ['组织架构', getTenant().name];
    return ['组织架构', getTenant().name, ...navPath.map((e) => e.name)];
  }

  void setMode(int m) {
    mode = m;
    navPath.clear();
    currentDepts = [];
    currentUsers = [];
    _deptCache.clear();
    _searchQuery = '';
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> enterOrgRoot() async {
    navPath.clear();
    _deptCache.clear();
    await _navigateTo(getTenant().rootDepartmentId, addToPath: false);
  }

  Future<void> enterDept(Int64 id) async {
    await _navigateTo(id, addToPath: true);
  }

  void goBack() {
    if (navPath.isEmpty) return;
    navPath.removeLast();
    if (navPath.isEmpty) {
      enterOrgRoot();
    } else {
      _navigateTo(navPath.last.id, addToPath: false);
    }
  }

  Future<void> goBackTo(int breadcrumbIndex) async {
    if (breadcrumbIndex <= 1) {
      await enterOrgRoot();
      return;
    }
    var targetPathIdx = breadcrumbIndex - 2;
    if (targetPathIdx >= navPath.length) return;
    while (navPath.length > targetPathIdx + 1) {
      navPath.removeLast();
    }
    await _navigateTo(navPath.last.id, addToPath: false);
  }

  Future<void> _navigateTo(Int64 deptId, {bool addToPath = true}) async {
    var resp = await im.getDeptInfo(deptId);
    if (resp == null) return;

    _deptCache.addAll(resp.depts);

    var dept = resp.depts[deptId];
    if (dept == null) return;

    if (addToPath && (navPath.isEmpty || navPath.last.id != deptId)) {
      navPath.add(DeptNav(id: deptId, name: dept.name));
    }

    currentDepts = dept.subDepartmentIds
        .map((id) => _deptCache[id])
        .whereType<Department>()
        .toList();

    currentUsers = dept.memberIds
        .map((id) => resp.users[id])
        .whereType<User>()
        .toList();
    currentUsers.sort((a, b) => a.name.compareTo(b.name));

    notifyListeners();
  }
}
