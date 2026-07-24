import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buzzing/service/openapp_service.dart';
import 'package:buzzing/utils/logger_util.dart';

class OpenAppDetailPage extends StatefulWidget {
  final OpenAppService service;
  final Map<String, dynamic> app;
  const OpenAppDetailPage({required this.service, required this.app});

  @override
  State<OpenAppDetailPage> createState() => _OpenAppDetailPageState();
}

class _OpenAppDetailPageState extends State<OpenAppDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late Map<String, dynamic> _app;
  bool _loading = true;

  List<Map<String, dynamic>> _redirectUris = [];
  List<Map<String, dynamic>> _webhooks = [];
  List<Map<String, dynamic>> _tasks = [];
  Map<String, dynamic>? _botConfig;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _app = Map.from(widget.app);
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final id = _app['id'] as int;
      _app = await widget.service.getApp(id);
      _redirectUris = await widget.service.listRedirectUris(id);
      _webhooks = await widget.service.listWebhooks(id);
      _tasks = await widget.service.listTasks(id);
      try {
        _botConfig = await widget.service.getBotConfig(id);
      } catch (_) {}
      try {
        _stats = await widget.service.getAppStats(id);
      } catch (_) {}
    } catch (e) {
      L.e("load app detail error: $e");
    }
    if (mounted) setState(() => _loading = false);
  }

  String? _get(String key) => _app[key]?.toString();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_get('name') ?? '应用详情', style: tt.titleMedium),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: '基本信息'),
            Tab(text: 'OAuth'),
            Tab(text: 'Webhook'),
            Tab(text: '统计'),
          ],
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildBasicTab(cs, tt),
                _buildOAuthTab(cs, tt),
                _buildWebhookTab(cs, tt),
                _buildStatsTab(cs, tt),
              ],
            ),
    );
  }

  Widget _buildBasicTab(ColorScheme cs, TextTheme tt) {
    final id = _get('id');
    final name = _get('name');
    final desc = _get('description') ?? '';
    final appId = _get('app_id') ?? '';
    final appSecret = _get('app_secret') ?? '';
    final callbackUrl = _get('callback_url') ?? '';
    final status = _get('status') ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('名称', name ?? '', cs, tt),
          SizedBox(height: 16),
          _infoRow('描述', desc, cs, tt),
          SizedBox(height: 16),
          _copyableRow('App ID', appId, cs, tt),
          SizedBox(height: 16),
          _copyableRow('App Secret', appSecret, cs, tt),
          SizedBox(height: 16),
          _infoRow('回调 URL', callbackUrl, cs, tt),
          SizedBox(height: 16),
          _infoRow('状态', status, cs, tt),
          SizedBox(height: 24),
          if (id != null)
            OutlinedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('重新生成 Secret'),
              onPressed: () => _regenerateSecret(int.parse(id)),
            ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            icon: Icon(Icons.delete_outline, color: cs.error),
            label: Text('删除应用', style: TextStyle(color: cs.error)),
            onPressed: () => _deleteApp(),
          ),
        ],
      ),
    );
  }

  Widget _buildOAuthTab(ColorScheme cs, TextTheme tt) {
    final id = _app['id'] as int;
    final uriCtrl = TextEditingController();

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('重定向 URI', style: tt.titleSmall),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: uriCtrl,
                  decoration: InputDecoration(
                    hintText: 'https://example.com/oauth/callback',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final uri = uriCtrl.text.trim();
                  if (uri.isEmpty) return;
                  try {
                    await widget.service.addRedirectUri(id, uri);
                    uriCtrl.clear();
                    _redirectUris = await widget.service.listRedirectUris(id);
                    setState(() {});
                  } catch (e) {
                    L.e("add redirect uri error: $e");
                  }
                },
                child: Text('添加'),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_redirectUris.isEmpty)
            Text('暂无重定向 URI', style: tt.bodySmall)
          else
            ..._redirectUris.map((u) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(u['uri'] as String? ?? '', style: tt.bodyMedium),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
                    onPressed: () async {
                      try {
                        await widget.service.deleteRedirectUri(id, u['id'] as int);
                        _redirectUris = await widget.service.listRedirectUris(id);
                        setState(() {});
                      } catch (e) {
                        L.e("delete redirect uri error: $e");
                      }
                    },
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildWebhookTab(ColorScheme cs, TextTheme tt) {
    final id = _app['id'] as int;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('出站 Webhook', style: tt.titleSmall),
              Spacer(),
              TextButton.icon(
                icon: Icon(Icons.add, size: 18),
                label: Text('添加'),
                onPressed: () => _showWebhookDialog(id, null),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (_webhooks.isEmpty)
            Text('暂无 Webhook', style: tt.bodySmall)
          else
            ..._webhooks.map((w) => Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(w['name'] as String? ?? '', style: tt.bodyMedium),
                    subtitle: Text(
                      w['url'] as String? ?? '',
                      style: tt.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (w['enabled'] == true) ? '启用' : '禁用',
                          style: tt.bodySmall?.copyWith(
                            color: (w['enabled'] == true) ? cs.primary : cs.error,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, size: 18),
                          onPressed: () => _showWebhookDialog(id, w),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 18, color: cs.error),
                          onPressed: () async {
                            try {
                              await widget.service.deleteWebhook(
                                  id, w['id'] as int);
                              _webhooks =
                                  await widget.service.listWebhooks(id);
                              setState(() {});
                            } catch (e) {
                              L.e("delete webhook error: $e");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildStatsTab(ColorScheme cs, TextTheme tt) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('API 调用统计', style: tt.titleSmall),
          SizedBox(height: 16),
          if (_stats == null || _stats!.isEmpty)
            Text('暂无统计数据', style: tt.bodySmall)
          else
            ...(_stats!.entries.map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: tt.bodyMedium),
                      Text('${e.value}', style: tt.bodyMedium),
                    ],
                  ),
                ))),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, ColorScheme cs, TextTheme tt) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: tt.bodySmall?.copyWith(color: cs.outline)),
        ),
        Expanded(child: Text(value, style: tt.bodyMedium)),
      ],
    );
  }

  Widget _copyableRow(
      String label, String value, ColorScheme cs, TextTheme tt) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: tt.bodySmall?.copyWith(color: cs.outline)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已复制 $label')),
              );
            },
            child: Row(
              children: [
                Flexible(
                  child: Text(value, style: tt.bodyMedium),
                ),
                SizedBox(width: 4),
                Icon(Icons.copy, size: 14, color: cs.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _regenerateSecret(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('重新生成 Secret'),
        content: Text('重新生成后，旧 Secret 将立即失效。确定要重新生成吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text('确定')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final result = await widget.service.regenerateSecret(id);
        setState(() {
          _app['app_secret'] = result['app_secret'];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Secret 已重新生成')),
          );
        }
      } catch (e) {
        L.e("regenerate secret error: $e");
      }
    }
  }

  Future<void> _deleteApp() async {
    final id = _app['id'] as int;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除应用'),
        content: Text('确定要删除这个应用吗？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('取消')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('删除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await widget.service.deleteApp(id);
        Navigator.pop(context, true);
      } catch (e) {
        L.e("delete app error: $e");
      }
    }
  }

  void _showWebhookDialog(int appId, Map<String, dynamic>? webhook) {
    final nameCtrl = TextEditingController(text: webhook?['name'] as String? ?? '');
    final urlCtrl = TextEditingController(text: webhook?['url'] as String? ?? '');
    final isNew = webhook == null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNew ? '添加 Webhook' : '编辑 Webhook'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: '名称', border: OutlineInputBorder()),
            ),
            SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              decoration: InputDecoration(labelText: 'URL', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'name': nameCtrl.text.trim(),
                'url': urlCtrl.text.trim(),
              };
              try {
                if (isNew) {
                  await widget.service.createWebhook(appId, data);
                } else {
                  await widget.service.updateWebhook(appId, webhook!['id'] as int, data);
                }
                Navigator.pop(ctx);
                _webhooks = await widget.service.listWebhooks(appId);
                setState(() {});
              } catch (e) {
                L.e("save webhook error: $e");
              }
            },
            child: Text(isNew ? '添加' : '保存'),
          ),
        ],
      ),
    );
  }
}
