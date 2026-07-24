import 'package:buzzing/controller/sdk_controller.dart';
import 'package:buzzing/page/openapp/openapp_create_page.dart';
import 'package:buzzing/page/openapp/openapp_detail_page.dart';
import 'package:buzzing/provider/sdk_provider.dart';
import 'package:buzzing/service/openapp_service.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OpenAppListPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<OpenAppListPage> createState() => _OpenAppListPageState();
}

class _OpenAppListPageState extends ConsumerState<OpenAppListPage> {
  List<Map<String, dynamic>>? _apps;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    setState(() { _loading = true; _error = null; });
    try {
      final sdk = ref.read(sdkProvider);
      if (sdk.token == null || sdk.token!.isEmpty) {
        setState(() { _error = '未登录'; _loading = false; });
        return;
      }
      final svc = OpenAppService(token: sdk.token!);
      final apps = await svc.listApps();
      setState(() { _apps = apps; _loading = false; });
    } catch (e) {
      L.e("load apps error: $e");
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _navigateToCreate() async {
    final sdk = ref.read(sdkProvider);
    if (sdk.token == null || sdk.token!.isEmpty) return;
    final svc = OpenAppService(token: sdk.token!);
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OpenAppCreatePage(service: svc),
      ),
    );
    if (result == true) _loadApps();
  }

  void _navigateToDetail(Map<String, dynamic> app) {
    final sdk = ref.read(sdkProvider);
    if (sdk.token == null || sdk.token!.isEmpty) return;
    final svc = OpenAppService(token: sdk.token!);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpenAppDetailPage(service: svc, app: app),
      ),
    ).then((_) => _loadApps());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('开放平台', style: tt.titleMedium),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.add, color: cs.primary),
            label: Text('创建应用', style: TextStyle(color: cs.primary)),
            onPressed: _navigateToCreate,
          ),
        ],
      ),
      body: _buildBody(cs, tt),
    );
  }

  Widget _buildBody(ColorScheme cs, TextTheme tt) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('加载失败', style: tt.bodyLarge),
            SizedBox(height: 8),
            Text(_error!, style: tt.bodySmall?.copyWith(color: cs.error)),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadApps, child: Text('重试')),
          ],
        ),
      );
    }
    if (_apps == null || _apps!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apps, size: 64, color: cs.outlineVariant),
            SizedBox(height: 16),
            Text('还没有创建应用', style: tt.bodyLarge),
            SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('创建应用'),
              onPressed: _navigateToCreate,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadApps,
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: _apps!.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: cs.outlineVariant),
        itemBuilder: (ctx, i) {
          final app = _apps![i];
          final name = app['name'] as String? ?? '';
          final desc = app['description'] as String? ?? '';
          final appId = app['app_id'] as String? ?? '';
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(color: cs.onPrimaryContainer),
              ),
            ),
            title: Text(name, style: tt.titleSmall),
            subtitle: Text(
              desc.isNotEmpty ? desc : 'App ID: $appId',
              style: tt.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _navigateToDetail(app),
          );
        },
      ),
    );
  }
}
