import 'package:latlong2/latlong.dart';

/// A clinic or hospital on the Nearby Health Services page (page 17).
class HealthService {
  const HealthService({
    required this.name,
    required this.address,
    required this.phone,
    required this.hours,
    required this.location,
    this.isClinic = false,
  });

  final String name;
  final String address;
  final String phone;
  final String hours;
  final LatLng location;
  final bool isClinic; // clinic icon instead of the hospital one
}

const healthServices = <HealthService>[
  HealthService(
    name: 'Jeptah Komiya-Padilla Ob Gyne Clinic and Ultrasound',
    address: 'San Vicente Sur, MacArthur Hwy, Agoo, La Union',
    phone: '+63 917 855 9449',
    hours:
        'Mon: 8:00 AM – 4:00 PM, Tue: 8:00 AM – 1:00 PM, '
        'Thu–Sat: 8:00 AM – 1:00 PM',
    location: LatLng(16.33042, 120.36542),
    isClinic: true,
  ),
  HealthService(
    name: 'Agoo Municipal Health Office',
    address: 'Sta. Barbara, Cases Blvd, Agoo, La Union',
    phone: '0905 235 8713',
    hours: 'Mon–Fri: 8:00 AM – 5:00 PM',
    location: LatLng(16.32431, 120.36631),
  ),
  HealthService(
    name: 'Agoo Family Hospital',
    address: 'San Pedro, MacArthur Hwy, Agoo, La Union',
    phone: '0917 564 0199',
    hours: 'Mon–Fri: 8:00 AM – 5:00 PM',
    location: LatLng(16.34398, 120.36021),
  ),
  HealthService(
    name: 'La Union Medical Center',
    address: 'Nazareno, MacArthur Hwy, Agoo, La Union',
    phone: '(072) 607 5541',
    hours: 'Mon–Fri: 8:00 AM – 5:00 PM',
    location: LatLng(16.34686, 120.36402),
  ),
  HealthService(
    name: 'AQurate Diagnostics and Medical',
    address: 'Consolacion, MacArthur Hwy, Agoo, La Union',
    phone: '(072) 607 5541', // same as La Union Medical Center in the layout
    hours: 'Mon–Fri: 8:00 AM – 5:00 PM',
    location: LatLng(16.32385, 120.36945),
    isClinic: true,
  ),
];
