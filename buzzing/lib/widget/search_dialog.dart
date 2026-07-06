import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/models/idl/entity.pb.dart';
import 'package:buzzing/provider/page_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarSearchDialog extends ConsumerStatefulWidget {
  final String initialText;
  CalendarSearchDialog({this.initialText = ''});

  @override
  _CalendarSearchDialogState createState() => _CalendarSearchDialogState();
}

class _CalendarSearchDialogState extends ConsumerState<CalendarSearchDialog> {
  late final _keyCtrl = TextEditingController(text: widget.initialText);
  var _results = <Calendar>[];
  var _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText.isNotEmpty) {
      _search();
    }
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    var key = _keyCtrl.text.trim();
    if (key.isEmpty) return;
    setState(() => _loading = true);
    var ctl = ref.read(calendarLogicProvider);
    var results = await ctl.searchCalendar(key);
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctl = ref.read(calendarLogicProvider);
    return AlertDialog(
      title: Text(t.searchCalendar),
      content: Container(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _keyCtrl,
              decoration: InputDecoration(
                hintText: t.searchByName,
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            SizedBox(height: 8),
            if (_loading) CircularProgressIndicator(),
            if (!_loading && _results.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (ctx, i) {
                    var cal = _results[i];
                    var alreadySubscribed = cal.subscribers.subscribers.containsKey(ctl.sdk.userId);
                    return ListTile(
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: cal.color != 0 ? Color(cal.color) : cs.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(cal.name),
                      subtitle: Text(cal.desc),
                      trailing: alreadySubscribed
                          ? Text(t.subscribed)
                          : ElevatedButton(
                              child: Text(t.subscribe),
                              onPressed: () async {
                                await ctl.subscribeCalendar(cal.id, !alreadySubscribed);
                                ctl.notifyListeners();
                                Navigator.of(context).pop();
                              },
                            ),
                    );
                  },
                ),
              ),
            if (!_loading && _results.isEmpty && _keyCtrl.text.isNotEmpty)
              Text(t.noResults),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(t.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
