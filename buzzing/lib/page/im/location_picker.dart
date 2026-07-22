import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/im_ext.pb.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final _queryCtrl = TextEditingController();
  final _dio = Dio(BaseOptions(baseUrl: 'https://nominatim.openstreetmap.org'));
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final resp = await _dio.get('/search', queryParameters: {
        'q': query,
        'format': 'json',
        'limit': 20,
        'addressdetails': 1,
      });
      if (resp.data is List) {
        _results = List<Map<String, dynamic>>.from(resp.data);
      }
    } catch (_) {
      _results = [];
    }
    setState(() => _loading = false);
  }

  void _select(Map<String, dynamic> item) {
    final loc = LocationContent(
      name: item['display_name']?.toString().split(',').first ?? '',
      address: item['display_name']?.toString() ?? '',
      latitude: double.tryParse(item['lat']?.toString() ?? '') ?? 0,
      longitude: double.tryParse(item['lon']?.toString() ?? '') ?? 0,
      zoom: 15,
      mapUrl: '',
    );
    Navigator.pop(context, loc);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: t.searchLocation,
            border: InputBorder.none,
            hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          style: tt.bodyMedium,
          onSubmitted: _search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_queryCtrl.text),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(
                  child: Text(t.searchLocation,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                )
              : ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: cs.outlineVariant),
                  itemBuilder: (ctx, i) {
                    final item = _results[i];
                    final name = item['display_name']?.toString() ?? '';
                    final lat = item['lat']?.toString() ?? '0';
                    final lon = item['lon']?.toString() ?? '0';
                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(
                        name.split(',').first,
                        style: tt.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '$lat, $lon',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      onTap: () => _select(item),
                    );
                  },
                ),
    );
  }
}
