import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/res/theme.dart';
import 'package:buzzing/models/idl/search.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:sp_util/sp_util.dart';
import 'package:buzzing/widget/header_bar.dart';
import 'package:buzzing/widget/navigate_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fixnum/fixnum.dart';

enum SearchTab { all, messages, chats, users, files }

/// 全局搜索面板（可复用）：包含搜索输入框、分类 Tab、结果列表与搜索历史。
///
/// 复用场景：
/// 1. [SearchPage]：独立搜索页（桌面端带 NaviBar/HeaderBar）；
/// 2. [GlobalSearchDialog]：桌面导航栏点击搜索按钮弹出的对话框模式。
///
/// [onCancel] 由宿主注入，用于关闭宿主（dialog pop / 路由 pop）。
class SearchPanel extends ConsumerStatefulWidget {
  final VoidCallback onCancel;

  const SearchPanel({super.key, required this.onCancel});

  @override
  SearchPanelState createState() => SearchPanelState();
}

class SearchPanelState extends ConsumerState<SearchPanel> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  var _keyword = '';
  SearchTab _tab = SearchTab.all;
  var _loading = false;

  // results
  var _messages = <MessageSearchResult>[];
  var _chats = <ChatSearchResult>[];
  var _users = <UserSearchResult>[];
  var _files = <FileSearchResult>[];
  var _messageTotal = 0;
  var _chatTotal = 0;
  var _userTotal = 0;
  var _fileTotal = 0;

  // history
  var _searchHistory = <String>[];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadHistory() {
    final raw = SpUtil.getStringList('search_history') ?? [];
    setState(() => _searchHistory = raw);
  }

  void _saveHistory(String keyword) {
    if (keyword.trim().isEmpty) return;
    final list = [keyword, ..._searchHistory.where((e) => e != keyword)];
    final trimmed = list.take(20).toList();
    SpUtil.putStringList('search_history', trimmed);
    _searchHistory = trimmed;
  }

  void _clearHistory() {
    SpUtil.putStringList('search_history', []);
    setState(() => _searchHistory = []);
  }

  void _clearResults() {
    setState(() {
      _keyword = '';
      _messages = [];
      _chats = [];
      _users = [];
      _files = [];
    });
  }

  Future<void> _doSearch(String keyword) async {
    final kw = keyword.trim();
    if (kw.isEmpty) {
      _clearResults();
      return;
    }
    _saveHistory(kw);
    setState(() {
      _keyword = kw;
      _loading = true;
    });

    final im = ref.read(imProvider);

    if (_tab == SearchTab.all) {
      try {
        final resp = await im.globalSearch(kw, pageSize: 10);
        setState(() {
          _messages = resp.messages;
          _chats = resp.chats;
          _users = resp.users;
          _files = resp.files;
          _messageTotal = resp.messageTotal;
          _chatTotal = resp.chatTotal;
          _userTotal = resp.userTotal;
          _fileTotal = resp.fileTotal;
          _loading = false;
        });
      } catch (_) {
        setState(() => _loading = false);
      }
    } else {
      try {
        switch (_tab) {
          case SearchTab.messages:
            final resp = await im.searchMessages(kw, pageSize: 20);
            setState(() {
              _messages = resp.results;
              _messageTotal = resp.total;
              _loading = false;
            });
            break;
          case SearchTab.chats:
            final resp = await im.searchChats(kw, pageSize: 20);
            setState(() {
              _chats = resp.results;
              _chatTotal = resp.total;
              _loading = false;
            });
            break;
          case SearchTab.users:
            final resp = await im.searchUsers(kw, pageSize: 20);
            setState(() {
              _users = resp.results;
              _userTotal = resp.total;
              _loading = false;
            });
            break;
          case SearchTab.files:
            final resp = await im.searchFiles(kw, pageSize: 20);
            setState(() {
              _files = resp.results;
              _fileTotal = resp.total;
              _loading = false;
            });
            break;
          default:
            setState(() => _loading = false);
        }
      } catch (_) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildHighlightText(String text) {
    if (text.isEmpty) return Text('');
    final spans = <InlineSpan>[];
    final regex = RegExp(r'<mark>(.*?)</mark>');
    int lastEnd = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(backgroundColor: Colors.yellow.shade300),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return Text.rich(TextSpan(children: spans));
  }

  Widget _buildMessageResult(MessageSearchResult result) {
    if (!result.hasMessage()) return SizedBox.shrink();
    final msg = result.message;
    return ListTile(
      leading:
          Icon(Icons.message_outlined, color: Theme.of(context).colorScheme.primary),
      title: Text(
          msg.summary.isNotEmpty ? msg.summary : '[${t.message}]',
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      subtitle:
          result.highlight.isNotEmpty ? _buildHighlightText(result.highlight) : null,
      dense: true,
      onTap: () {},
    );
  }

  Widget _buildChatResult(ChatSearchResult result) {
    if (!result.hasChat()) return SizedBox.shrink();
    final chat = result.chat;
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        child: Text(chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '#',
            style: TextStyle(fontSize: 14)),
      ),
      title: Text(chat.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle:
          result.highlight.isNotEmpty ? _buildHighlightText(result.highlight) : null,
      dense: true,
      onTap: () {},
    );
  }

  Widget _buildUserResult(UserSearchResult result) {
    if (!result.hasUser()) return SizedBox.shrink();
    final user = result.user;
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 14)),
      ),
      title: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle:
          result.highlight.isNotEmpty ? _buildHighlightText(result.highlight) : null,
      dense: true,
      onTap: () {},
    );
  }

  Widget _buildFileResult(FileSearchResult result) {
    return ListTile(
      leading: Icon(Icons.insert_drive_file_outlined,
          color: Theme.of(context).colorScheme.primary),
      title: Text(result.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle:
          result.highlight.isNotEmpty ? _buildHighlightText(result.highlight) : Text(result.mimeType),
      trailing:
          Text(_formatSize(result.size), style: Theme.of(context).textTheme.labelSmall),
      dense: true,
      onTap: () {},
    );
  }

  String _formatSize(Int64 size) {
    final s = size.toInt();
    if (s < 1024) return '${s}B';
    if (s < 1024 * 1024) return '${(s / 1024).toStringAsFixed(1)}KB';
    return '${(s / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasQuery = _keyword.isNotEmpty;
    final hasResults =
        _messages.isNotEmpty || _chats.isNotEmpty || _users.isNotEmpty || _files.isNotEmpty;

    return Column(
      children: [
        _buildSearchBar(cs),
        // tabs
        Container(
          color: cs.surface,
          child: Row(
            children: [
              _buildTab(SearchTab.all, t.searchAll),
              _buildTab(SearchTab.messages, t.searchMessages),
              _buildTab(SearchTab.chats, t.searchChats),
              _buildTab(SearchTab.users, t.searchUsers),
              _buildTab(SearchTab.files, t.searchFiles),
            ],
          ),
        ),
        Divider(height: 1, color: cs.outlineVariant),
        // results / history
        Expanded(
          child: _loading
              ? Center(child: CircularProgressIndicator())
              : hasQuery
                  ? (hasResults
                      ? _buildResults()
                      : Center(
                          child: Text(t.searchNoResults,
                              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))))
                  : _buildHistory(),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: cs.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _focusNode,
              onSubmitted: _doSearch,
              onChanged: (v) {
                if (v.isEmpty) {
                  _clearResults();
                }
              },
              decoration: InputDecoration(
                hintText: t.searchPlaceholder,
                prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          _focusNode.requestFocus();
                          _clearResults();
                        },
                      )
                    : null,
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onCancel,
            child: Text('取消',
                style: tt.bodyMedium?.copyWith(
                  color: cs.primary,
                  decoration: TextDecoration.underline,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(SearchTab tab, String label) {
    final cs = Theme.of(context).colorScheme;
    final selected = _tab == tab;
    return GestureDetector(
      onTap: () {
        setState(() => _tab = tab);
        if (_keyword.isNotEmpty) _doSearch(_keyword);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: selected ? cs.primary : Colors.transparent, width: 2)),
        ),
        child: Text(
            label,
            style: TextStyle(
                color: selected ? cs.primary : cs.onSurfaceVariant,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  Widget _buildResults() {
    final sections = <Widget>[];

    if (_messages.isNotEmpty &&
        (_tab == SearchTab.all || _tab == SearchTab.messages)) {
      sections.add(_buildSectionHeader(t.searchMessages, _messageTotal));
      for (final r in _messages.take(5)) sections.add(_buildMessageResult(r));
      if (_messages.length > 5)
        sections.add(Padding(
          padding: const EdgeInsets.only(left: 16),
          child: TextButton(
              onPressed: () {
                setState(() => _tab = SearchTab.messages);
                _doSearch(_keyword);
              },
              child: Text(
                  t.searchResultCount.replaceFirst('{count}', _messageTotal.toString()))),
        ));
    }

    if (_chats.isNotEmpty && (_tab == SearchTab.all || _tab == SearchTab.chats)) {
      sections.add(_buildSectionHeader(t.searchChats, _chatTotal));
      for (final r in _chats.take(5)) sections.add(_buildChatResult(r));
      if (_chats.length > 5)
        sections.add(Padding(
          padding: const EdgeInsets.only(left: 16),
          child: TextButton(
              onPressed: () {
                setState(() => _tab = SearchTab.chats);
                _doSearch(_keyword);
              },
              child: Text(
                  t.searchResultCount.replaceFirst('{count}', _chatTotal.toString()))),
        ));
    }

    if (_users.isNotEmpty && (_tab == SearchTab.all || _tab == SearchTab.users)) {
      sections.add(_buildSectionHeader(t.searchUsers, _userTotal));
      for (final r in _users.take(5)) sections.add(_buildUserResult(r));
      if (_users.length > 5)
        sections.add(Padding(
          padding: const EdgeInsets.only(left: 16),
          child: TextButton(
              onPressed: () {
                setState(() => _tab = SearchTab.users);
                _doSearch(_keyword);
              },
              child: Text(
                  t.searchResultCount.replaceFirst('{count}', _userTotal.toString()))),
        ));
    }

    if (_files.isNotEmpty && (_tab == SearchTab.all || _tab == SearchTab.files)) {
      sections.add(_buildSectionHeader(t.searchFiles, _fileTotal));
      for (final r in _files.take(5)) sections.add(_buildFileResult(r));
      if (_files.length > 5)
        sections.add(Padding(
          padding: const EdgeInsets.only(left: 16),
          child: TextButton(
              onPressed: () {
                setState(() => _tab = SearchTab.files);
                _doSearch(_keyword);
              },
              child: Text(
                  t.searchResultCount.replaceFirst('{count}', _fileTotal.toString()))),
        ));
    }

    return ListView(children: sections);
  }

  Widget _buildSectionHeader(String title, int total) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(title, style: tt.titleSmall),
          const SizedBox(width: 8),
          Text('($total)', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    if (_searchHistory.isEmpty) {
      return Center(
          child: Text(t.searchPlaceholder,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.searchHistory, style: tt.titleSmall),
              GestureDetector(
                onTap: _clearHistory,
                child: Text(t.delete,
                    style: TextStyle(color: cs.error, fontSize: 12)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: _searchHistory.map((e) => ListTile(
              leading: Icon(Icons.history, size: 18, color: cs.onSurfaceVariant),
              title: Text(e, style: tt.bodyMedium),
              dense: true,
              onTap: () {
                _searchCtrl.text = e;
                _doSearch(e);
              },
            )).toList(),
          ),
        ),
      ],
    );
  }
}

/// 独立搜索页：桌面端带 NaviBar/HeaderBar 的完整页面布局。
class SearchPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bt = Theme.of(context).extension<BuzzingTheme>()!;
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: bt.mentionBg,
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  NaviBar(),
                  Expanded(
                    child: Column(
                      children: [
                        Container(child: HeaderBarWindows()),
                        Expanded(
                          child: SearchPanel(
                            onCancel: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : SearchPanel(onCancel: () => Navigator.of(context).pop()),
      ),
    );
  }
}

/// 桌面端导航栏搜索按钮的对话框模式：以 Dialog 承载全局搜索面板。
class GlobalSearchDialog extends StatelessWidget {
  const GlobalSearchDialog({super.key});

  /// 展示全局搜索对话框。
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const GlobalSearchDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 560,
        height: 480,
        child: SearchPanel(onCancel: () => Navigator.of(context).pop()),
      ),
    );
  }
}
