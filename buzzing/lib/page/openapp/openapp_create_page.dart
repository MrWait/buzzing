import 'package:buzzing/service/openapp_service.dart';
import 'package:flutter/material.dart';

class OpenAppCreatePage extends StatefulWidget {
  final OpenAppService service;
  const OpenAppCreatePage({required this.service});

  @override
  State<OpenAppCreatePage> createState() => _OpenAppCreatePageState();
}

class _OpenAppCreatePageState extends State<OpenAppCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _callbackCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _callbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
      };
      if (_descCtrl.text.trim().isNotEmpty) {
        data['description'] = _descCtrl.text.trim();
      }
      if (_callbackCtrl.text.trim().isNotEmpty) {
        data['callback_url'] = _callbackCtrl.text.trim();
      }
      await widget.service.createApp(data);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('创建应用', style: tt.titleMedium),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('应用名称 *', style: tt.titleSmall),
              SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: '输入应用名称',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? '请输入应用名称' : null,
              ),
              SizedBox(height: 24),
              Text('应用描述', style: tt.titleSmall),
              SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  hintText: '简要描述你的应用',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              Text('回调 URL', style: tt.titleSmall),
              SizedBox(height: 8),
              TextFormField(
                controller: _callbackCtrl,
                decoration: InputDecoration(
                  hintText: 'https://example.com/callback',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('创建'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
