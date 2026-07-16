import 'package:flutter/foundation.dart';
import 'package:buzzing/service/office_service.dart';
import 'package:buzzing/utils/logger_util.dart';

class OfficeState {
  final List<Map<String, dynamic>> spaces;
  final int? selectedSpaceId;
  final List<Map<String, dynamic>> docs;
  final bool loading;
  final String? error;

  const OfficeState({
    this.spaces = const [],
    this.selectedSpaceId,
    this.docs = const [],
    this.loading = false,
    this.error,
  });

  OfficeState copyWith({
    List<Map<String, dynamic>>? spaces,
    int? selectedSpaceId,
    bool clearSelection = false,
    List<Map<String, dynamic>>? docs,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return OfficeState(
      spaces: spaces ?? this.spaces,
      selectedSpaceId: clearSelection ? null : (selectedSpaceId ?? this.selectedSpaceId),
      docs: docs ?? this.docs,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class OfficeLogic extends ChangeNotifier {
  OfficeState _state = const OfficeState();
  OfficeState get state => _state;

  OfficeService? _service;
  OfficeService get _svc => _service!;

  void init(String token) {
    _service = OfficeService(token: token);
    loadSpaces();
  }

  Future<void> loadSpaces() async {
    _state = _state.copyWith(loading: true, clearError: true);
    notifyListeners();
    try {
      final spaces = await _svc.listSpaces();
      _state = _state.copyWith(spaces: spaces, loading: false);
      notifyListeners();
      if (spaces.isNotEmpty && _state.selectedSpaceId == null) {
        selectSpace(int.parse(spaces[0]['id']));
      }
    } catch (e) {
      L.e('loadSpaces error: $e');
      _state = _state.copyWith(loading: false, error: e.toString());
      notifyListeners();
    }
  }

  Future<void> selectSpace(int spaceId) async {
    _state = _state.copyWith(selectedSpaceId: spaceId, docs: [], loading: true);
    notifyListeners();
    try {
      final docs = await _svc.listDocs(spaceId);
      _state = _state.copyWith(docs: docs, loading: false);
      notifyListeners();
    } catch (e) {
      L.e('loadDocs error: $e');
      _state = _state.copyWith(loading: false, error: e.toString());
      notifyListeners();
    }
  }

  Future<void> createSpace(String name) async {
    try {
      await _svc.createSpace(name);
      await loadSpaces();
    } catch (e) {
      L.e('createSpace error: $e');
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  Future<void> deleteSpace(int id) async {
    try {
      await _svc.deleteSpace(id);
      if (_state.selectedSpaceId == id) {
        _state = _state.copyWith(clearSelection: true);
      }
      await loadSpaces();
    } catch (e) {
      L.e('deleteSpace error: $e');
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  Future<void> createDoc(String title) async {
    final spaceId = _state.selectedSpaceId;
    if (spaceId == null) return;
    try {
      await _svc.createDoc(spaceId, title);
      await selectSpace(spaceId);
    } catch (e) {
      L.e('createDoc error: $e');
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  Future<void> deleteDoc(int id) async {
    final spaceId = _state.selectedSpaceId;
    if (spaceId == null) return;
    try {
      await _svc.deleteDoc(id);
      await selectSpace(spaceId);
    } catch (e) {
      L.e('deleteDoc error: $e');
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  Future<String> getEditUrl(int id) async {
    final resp = await _svc.getEditUrl(id);
    return resp['edit_url'] as String;
  }
}
