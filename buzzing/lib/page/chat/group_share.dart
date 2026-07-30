import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:buzzing/widget/user_list_item.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 群分享页（移动端整页展示）。
/// 群名片 tab 为「点击会话即发送」的列表模式，标题栏右侧提供「多选 / 取消 / 确定(n)」切换。
class GroupSharePage extends ConsumerStatefulWidget {
  final Int64 chatId;

  const GroupSharePage({super.key, required this.chatId});

  @override
  _GroupSharePageState createState() => _GroupSharePageState();
}

class _GroupSharePageState extends ConsumerState<GroupSharePage> {
  bool _multiSelect = false;
  final _selected = <Int64>{};

  void _toggleSelect(Int64 id) {
    setState(() {
      if (!_selected.add(id)) _selected.remove(id);
    });
  }

  void _exitMultiSelect() {
    setState(() {
      _multiSelect = false;
      _selected.clear();
    });
  }

  /// 单选：点击会话即发送群名片（暂 stub）
  void _sendCardTo(Int64 targetChatId) {
    L.d("share group card: chat=${widget.chatId}, target=$targetChatId");
    // TODO: 群名片发送，卡片展示后续统一处理
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('群名片发送功能开发中')),
      );
    }
  }

  /// 多选：向所有选中会话发送群名片（暂 stub）
  void _confirmCard() {
    L.d("share group card: chat=${widget.chatId}, targets=$_selected");
    // TODO: 群名片发送，卡片展示后续统一处理
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('群名片发送功能开发中')),
      );
    }
  }

  Widget _buildAction(ColorScheme cs) {
    final style = TextButton.styleFrom(foregroundColor: cs.primary);
    if (!_multiSelect) {
      return TextButton(
        style: style,
        onPressed: () => setState(() => _multiSelect = true),
        child: const Text('多选'),
      );
    }
    if (_selected.isEmpty) {
      return TextButton(
        style: style,
        onPressed: _exitMultiSelect,
        child: const Text('取消'),
      );
    }
    return TextButton(
      style: style,
      onPressed: _confirmCard,
      child: Text('确定（${_selected.length}）'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('分享'),
        actions: [_buildAction(cs)],
      ),
      body: GroupShareView(
        chatId: widget.chatId,
        cardListMode: true,
        multiSelect: _multiSelect,
        selectedChatIds: _selected,
        onCardTap: _sendCardTo,
        onCardToggle: _toggleSelect,
      ),
    );
  }
}

/// 群分享内容区：顶部水平 tab（群名片 / 群链接 / 二维码），移动端整页、PC 端弹窗共用。
/// 群名片 tab 依据 [cardListMode] 分支：移动端为点击发送列表，PC 端为双栏选择布局。
class GroupShareView extends ConsumerStatefulWidget {
  final Int64 chatId;
  final bool cardListMode;
  final bool multiSelect;
  final Set<Int64> selectedChatIds;
  final ValueChanged<Int64>? onCardTap;
  final ValueChanged<Int64>? onCardToggle;

  const GroupShareView({
    super.key,
    required this.chatId,
    this.cardListMode = false,
    this.multiSelect = false,
    this.selectedChatIds = const {},
    this.onCardTap,
    this.onCardToggle,
  });

  @override
  GroupShareViewState createState() => GroupShareViewState();
}

class GroupShareViewState extends ConsumerState<GroupShareView> {
  final _selectedChatIds = <Int64>{};
  final _keywordCtrl = TextEditingController();
  String _keyword = '';
  String? _linkCode;
  int _expiryDays = 7;
  bool _generating = false;

  List<Chat> get _chatList {
    final im = ref.read(imProvider);
    final q = _keyword.trim().toLowerCase();
    return im.entity.chats.values
        .where((c) =>
            c.id != widget.chatId &&
            (q.isEmpty || c.name.toLowerCase().contains(q)))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLink());
  }

  @override
  void dispose() {
    _keywordCtrl.dispose();
    super.dispose();
  }

  /// 生成（或复用）带有效期的群链接
  Future<void> _ensureLink() async {
    if (_linkCode != null || _generating) return;
    setState(() => _generating = true);
    final im = ref.read(imProvider);
    final expiresAt = _expiryDays <= 0
        ? Int64.ZERO
        : Int64(DateTime.now().millisecondsSinceEpoch +
            _expiryDays * 86400000);
    final code = await im.createInviteLink(widget.chatId, expiresAt: expiresAt);
    if (mounted) {
      setState(() {
        _linkCode = code;
        _generating = false;
      });
    }
  }

  void _setExpiry(int days) {
    setState(() {
      _expiryDays = days;
      _linkCode = null;
    });
    _ensureLink();
  }

  String get _linkText => _linkCode == null ? '' : 'buzzing://invite/$_linkCode';

  Future<void> _copyLink() async {
    if (_linkCode == null) return;
    await Clipboard.setData(ClipboardData(text: _linkText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('链接已复制')),
      );
    }
  }

  void _cancelLink() {
    setState(() => _linkCode = null);
  }

  void _confirmShareCard() {
    L.d("share group card: chat=${widget.chatId}, targets=$_selectedChatIds");
    if (_selectedChatIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要分享到的会话')),
      );
      return;
    }
    // TODO: 群名片发送，卡片展示后续统一处理
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('群名片发送功能开发中')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: TabBar(
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorColor: cs.primary,
              tabs: const [
                Tab(text: '群名片'),
                Tab(text: '群链接'),
                Tab(text: '二维码'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCardTab(cs),
                _buildLinkTab(cs),
                _buildQrTab(cs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab 1: 群名片 ──────────────────────────────────────────────

  Widget _buildCardTab(ColorScheme cs) {
    if (widget.cardListMode) {
      return _buildCardListMode(cs);
    }
    return _buildCardPickerMode(cs);
  }

  /// 移动端列表模式：默认点击会话即发送；多选模式下显示复选框
  Widget _buildCardListMode(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    final multi = widget.multiSelect;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: cs.surfaceVariant)),
          ),
          child: Text(
            multi ? '已选 ${widget.selectedChatIds.length} 个会话' : '点击会话，发送群名片',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: _chatList.isEmpty
              ? Center(
                  child: Text('无可选会话',
                      style:
                          tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                )
              : ListView.builder(
                  itemCount: _chatList.length,
                  itemBuilder: (context, index) {
                    final chat = _chatList[index];
                    final selected = widget.selectedChatIds.contains(chat.id);
                    return InkWell(
                      onTap: () {
                        if (multi) {
                          widget.onCardToggle?.call(chat.id);
                        } else {
                          widget.onCardTap?.call(chat.id);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            if (multi) ...[
                              Checkbox(
                                value: selected,
                                onChanged: (_) =>
                                    widget.onCardToggle?.call(chat.id),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 4),
                            ],
                            UserAvatar(
                                name: chat.name,
                                avatar: chat.avatar,
                                size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(chat.name,
                                  style: tt.bodyMedium,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            if (!multi)
                              Icon(Icons.navigate_next,
                                  color: cs.onSurfaceVariant, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// PC 双栏选择布局：左侧候选 + 右侧已选
  Widget _buildCardPickerMode(ColorScheme cs) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCandidateList(cs)),
              Container(width: 1, color: cs.outlineVariant),
              Expanded(child: _buildSelectedList(cs)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: Row(
            children: [
              Text(
                '已选 ${_selectedChatIds.length} 个会话',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _confirmShareCard,
                child: const Text('确定'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateList(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: cs.surfaceVariant)),
          ),
          child: TextField(
            controller: _keywordCtrl,
            onChanged: (v) => setState(() => _keyword = v),
            decoration: InputDecoration(
              hintText: '搜索会话',
              hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              prefixIcon:
                  Icon(Icons.search, color: cs.onSurfaceVariant, size: 20),
              filled: true,
              fillColor: cs.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: _chatList.isEmpty
              ? Center(
                  child: Text('无可选会话',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                )
              : ListView.builder(
                  itemCount: _chatList.length,
                  itemBuilder: (context, index) {
                    final chat = _chatList[index];
                    final selected = _selectedChatIds.contains(chat.id);
                    return InkWell(
                      onTap: () => setState(() {
                        if (selected) {
                          _selectedChatIds.remove(chat.id);
                        } else {
                          _selectedChatIds.add(chat.id);
                        }
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Row(
                          children: [
                            Checkbox(
                              value: selected,
                              onChanged: (_) => setState(() {
                                if (selected) {
                                  _selectedChatIds.remove(chat.id);
                                } else {
                                  _selectedChatIds.add(chat.id);
                                }
                              }),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            UserAvatar(
                                name: chat.name,
                                avatar: chat.avatar,
                                size: 32),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(chat.name,
                                  style: tt.bodyMedium,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSelectedList(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    final chats = ref
        .read(imProvider)
        .entity
        .chats
        .values
        .where((c) => _selectedChatIds.contains(c.id))
        .toList();
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: cs.surfaceVariant)),
          ),
          child: Text(
            '已选择',
            style: tt.bodyMedium?.copyWith(
                fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: chats.isEmpty
              ? Center(
                  child: Text('未选择会话',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                )
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          UserAvatar(
                              name: chat.name,
                              avatar: chat.avatar,
                              size: 32),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(chat.name,
                                style: tt.bodyMedium,
                                overflow: TextOverflow.ellipsis),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(
                                () => _selectedChatIds.remove(chat.id)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─── Tab 2: 群链接（带有效期）───────────────────────────────────

  Widget _buildLinkTab(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('链接有效期', style: tt.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildExpiryChip(cs, 1, '1天'),
                    const SizedBox(width: 8),
                    _buildExpiryChip(cs, 7, '7天'),
                    const SizedBox(width: 8),
                    _buildExpiryChip(cs, 30, '30天'),
                    const SizedBox(width: 8),
                    _buildExpiryChip(cs, 0, '永久'),
                  ],
                ),
                const SizedBox(height: 16),
                Text('群链接', style: tt.bodyMedium),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _generating
                      ? const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : SelectableText(
                          _linkCode == null ? '生成失败或无权限' : _linkText,
                          style: tt.bodyMedium?.copyWith(color: cs.primary),
                        ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancelLink,
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _linkCode == null ? null : _copyLink,
                child: const Text('复制'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryChip(ColorScheme cs, int days, String label) {
    final selected = _expiryDays == days;
    return GestureDetector(
      onTap: () => _setExpiry(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  // ─── Tab 3: 二维码 ──────────────────────────────────────────────

  Widget _buildQrTab(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_generating)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          else if (_linkCode == null)
            Text('生成二维码失败或无权限',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: _linkText,
                version: QrVersions.auto,
                size: 200,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: cs.primary,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(_linkText,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
