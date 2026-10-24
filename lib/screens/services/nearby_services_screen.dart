import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../content/health_services.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';
import '../../widgets/offline_map.dart';

const _panel = Color(0xFF3FD9C4);

/// Page 17: Nearby Health Services, with an offline map pinning each one.
/// Tapping a pin or a list entry selects that place on both.
class NearbyServicesScreen extends StatefulWidget {
  const NearbyServicesScreen({super.key});

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  final _map = MapController();
  final _itemKeys = [for (final _ in healthServices) GlobalKey()];
  int? _selected;

  void _select(int i, {bool fromMap = false}) {
    setState(() => _selected = i);
    _map.move(healthServices[i].location, 15);
    if (fromMap) {
      final item = _itemKeys[i].currentContext;
      if (item != null) {
        Scrollable.ensureVisible(
          item,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
        );
      }
    }
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const LogoHeader(),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: PillTitle('Nearby Health Services', fontSize: 20),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  decoration: const BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Agoo',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 18),
                            Icon(Icons.location_on, color: AppColors.deepTeal),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 230,
                          child: OfflineMap(
                            controller: _map,
                            selected: _selected,
                            pins: [
                              for (var i = 0; i < healthServices.length; i++)
                                MapPin(
                                  position: healthServices[i].location,
                                  onTap: () => _select(i, fromMap: true),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: healthServices.length + 1,
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              thickness: 1.2,
                              color: AppColors.ink,
                              indent: 12,
                              endIndent: 12,
                            ),
                            itemBuilder: (_, i) => i == healthServices.length
                                ? const _Footer()
                                : _ServiceTile(
                                    key: _itemKeys[i],
                                    service: healthServices[i],
                                    selected: i == _selected,
                                    onTap: () => _select(i),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    super.key,
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final HealthService service;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const detail = TextStyle(fontSize: 11.5, color: AppColors.inkSoft);
    return Material(
      color: selected ? AppColors.mint : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.aqua,
                child: Icon(
                  service.isClinic
                      ? Icons.medical_services_outlined
                      : Icons.local_hospital_outlined,
                  size: 28,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: selected
                              ? AppColors.periodRed
                              : AppColors.deepTeal,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            service.address,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(service.phone, style: detail),
                    Text(service.hours, style: detail),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Take care, Always!',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
