import 'package:buzzing/controller/im.dart';
import 'package:buzzing/i18n/strings.g.dart';
import 'package:buzzing/provider/im_provider.dart';
import 'package:buzzing/routes/app_routes.dart';
import 'package:buzzing/utils/common_utils.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buzzing/utils/logger_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fixnum/fixnum.dart';
import 'package:go_router/go_router.dart';

class PersonalPopup extends ConsumerStatefulWidget {
  final ImController im;
  final Int64 id;
  final String url;
  final Int64 ver;

  const PersonalPopup({
    super.key,
    required this.im,
    required this.id,
    required this.url,
    required this.ver,
  });

  @override
  ConsumerState<PersonalPopup> createState() => _PersonalPopupState();
}

class _PersonalPopupState extends ConsumerState<PersonalPopup> {
  int _status = 1; // 0=offline, 1=online, 2=busy, 3=away

  static const _statuses = [
    ('离线', Colors.grey),
    ('在线', Color(0xFF10CC64)),
    ('忙碌', Colors.red),
    ('离开', Colors.orange),
  ];

  void _cycleStatus() {
    setState(() {
      _status = (_status + 1) % _statuses.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final user = widget.im.getUser(widget.id);
    final tenant = widget.im.getTenant();

    var tenantName = "Personal";
    if (tenant != null) {
      tenantName = tenant.name;
    }
    L.w("hero popup, get user: ${widget.id}, ${user}");

    return CustomPopup(
      backgroundColor: cs.surface,
      arrowColor: cs.surface,
      content: Container(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: widget.url.isEmpty
                              ? Icon(Icons.account_circle_outlined,
                                  size: 36, color: cs.primary)
                              : Image(
                                  image: CachedNetworkImageProvider(
                                    CommonUtils.fixResourceUrl(widget.url),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      if (_status != 0)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _statuses[_status].$2,
                              shape: BoxShape.circle,
                              border: Border.all(color: cs.surface, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? "",
                          style: tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tenantName,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _cycleStatus,
              behavior: HitTestBehavior.translucent,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 12, color: _statuses[_status].$2),
                    const SizedBox(width: 8),
                    Text(_statuses[_status].$1, style: tt.bodyMedium),
                    const Spacer(),
                    Icon(Icons.chevron_right,
                        size: 16, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: cs.outlineVariant),
            _MenuItem(
              icon: Icons.person_outline,
              label: t.myInfo,
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.qr_code_2,
              label: t.myQrcode,
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: t.mySetting,
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoute.SETTINGS);
              },
            ),
            Divider(height: 1, color: cs.outlineVariant),
            _MenuItem(
              icon: Icons.logout,
              label: t.logout,
              isDestructive: true,
              onTap: () {
                Navigator.of(context).pop();
                // onReset 兜底：销毁 im/sdk 单例，确保下一个用户从干净状态重建
                widget.im.logout(
                  GoRouter.of(context),
                  onReset: () => ref.invalidate(imProvider),
                );
              },
            ),
          ],
        ),
      ),
      child: CircleAvatar(
        backgroundImage: Image(
          image: CachedNetworkImageProvider(
              CommonUtils.fixResourceUrl(widget.url)),
        ).image,
        radius: 20,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = isDestructive ? cs.error : cs.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(label, style: tt.bodyMedium?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
