import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uee_project/controllers/report_controller.dart';
import 'package:uee_project/models/report_model.dart';
import 'package:uee_project/utils/app_textstyles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uee_project/views/user_home_screen.dart';

class IssueMapScreen extends StatefulWidget {
  final ReportLocation? initialLocation;
  final ReportModel? selectedReport;

  const IssueMapScreen({
    super.key,
    this.initialLocation,
    this.selectedReport,
  });

  @override
  State<IssueMapScreen> createState() => _IssueMapScreenState();
}

class _IssueMapScreenState extends State<IssueMapScreen> with TickerProviderStateMixin {
  final ReportController _reportController = Get.find();
  late final MapController _mapController;
  late final LanguageController _languageController;
  List<ReportModel> _reports = [];
  bool _isLoading = true;

  final Map<String, Map<String, String>> _translations = {
    'en_US': {
      'issue_map': 'Issue Map',
      'refresh': 'Refresh',
      'my_location': 'My Location',
      'zoom_in': 'Zoom In',
      'zoom_out': 'Zoom Out',
      'map_legend': 'Map Legend',
      'pending': 'Pending',
      'in_progress': 'In Progress',
      'resolved': 'Resolved',
      'icons_priority': 'Icons indicate priority level',
      'issues_on_map': 'Issues on Map',
      'locations': 'locations',
      'error_loading': 'Error',
      'failed_load_reports': 'Failed to load reports on map',
      'attached_images': 'Attached Images:',
      'zoom_to_location': 'Zoom to Location',
      'reported_on': 'Reported on',
      'change_language': 'Change Language',
      'Roads': 'Roads',
      'Water Supply': 'Water Supply',
      'Electricity': 'Electricity',
      'Drainage': 'Drainage',
      'Street Lights': 'Street Lights',
      'Waste Management': 'Waste Management',
      'Public Transport': 'Public Transport',
      'Parks & Recreation': 'Parks & Recreation',
      'Other': 'Other',
      'URGENT': 'URGENT',
      'HIGH': 'HIGH',
      'MEDIUM': 'MEDIUM',
      'LOW': 'LOW',
      'location_disabled': 'Location services are disabled. Using default location.',
      'location_denied': 'Location permission denied. Using default location.',
      'location_error': 'Error getting location. Using default location.',
    },
    'si_LK': {
      'issue_map': 'ගැටළු සිතියම',
      'refresh': 'නැවුම් කරන්න',
      'my_location': 'මගේ ස්ථානය',
      'zoom_in': 'විශාලනය කරන්න',
      'zoom_out': 'කුඩා කරන්න',
      'map_legend': 'සිතියම් පහදාදීම',
      'pending': 'පොරොත්තුවෙන්',
      'in_progress': 'ක්‍රියාත්මක වෙමින්',
      'resolved': 'විසඳා ඇත',
      'icons_priority': 'අයිකන ප්‍රමුඛතා මට්ටම පෙන්වයි',
      'issues_on_map': 'සිතියමේ ගැටළු',
      'locations': 'ස්ථාන',
      'error_loading': 'දෝෂයකි',
      'failed_load_reports': 'සිතියමේ වාර්තා පූරණය කිරීමට අසමත් විය',
      'attached_images': 'ඇමුණුම් ඡායාරූප:',
      'zoom_to_location': 'ස්ථානයට විශාලනය කරන්න',
      'reported_on': 'වාර්තා කළේ',
      'change_language': 'භාෂාව වෙනස් කරන්න',
      'Roads': 'මාර්ග',
      'Water Supply': 'ජල සැපයුම',
      'Electricity': 'විදුලිය',
      'Drainage': 'ජලාපවහන',
      'Street Lights': 'වීදි ආලෝක',
      'Waste Management': 'අපද්‍රව්‍ය කළමනාකරණය',
      'Public Transport': 'පොදු ප්‍රවාහනය',
      'Parks & Recreation': 'උද්‍යාන සහ විනෝදාස්වාදය',
      'Other': 'වෙනත්',
      'URGENT': 'හදිසි',
      'HIGH': 'ඉහළ',
      'MEDIUM': 'මධ්‍යම',
      'LOW': 'අඩු',
      'location_disabled': 'ස්ථාන සේවා අක්‍රීය කර ඇත. පෙරනිමි ස්ථානය භාවිතා කරමින්.',
      'location_denied': 'ස්ථාන අවසරය ප්‍රතික්ෂේප කරන ලදී. පෙරනිමි ස්ථානය භාවිතා කරමින්.',
      'location_error': 'ස්ථානය ලබා ගැනීමේ දෝෂයකි. පෙරනිමි ස්ථානය භාවිතා කරමින්.',
    },
  };

  static const LatLng _defaultLocation = LatLng(6.9271, 79.8612);
  LatLng _initialLocation = _defaultLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    if (Get.isRegistered<LanguageController>()) {
      _languageController = Get.find<LanguageController>();
    } else {
      _languageController = Get.put(LanguageController());
    }
    
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  String _tr(String key) {
    final localeKey = '${_languageController.currentLocale.value.languageCode}_${_languageController.currentLocale.value.countryCode}';
    return _translations[localeKey]?[key] ?? key;
  }

  void _showLanguageDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _languageController.translate('select_language'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'English', const Locale('en', 'US'),
                Icons.language, _languageController.isEnglish, colorScheme, isDark),
            const SizedBox(height: 12),
            _buildLanguageOption(context, 'සිංහල', const Locale('si', 'LK'),
                Icons.language, _languageController.isSinhala, colorScheme, isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_languageController.translate('close'),
                style: GoogleFonts.poppins(color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language, Locale locale,
      IconData icon, bool isSelected, ColorScheme colorScheme, bool isDark) {
    return InkWell(
      onTap: () {
        _languageController.changeLanguage(locale);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? colorScheme.primary : Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(language,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? colorScheme.primary : (isDark ? Colors.white : Colors.black87),
                  )),
            ),
            if (isSelected) Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeMap() async {
    if (widget.initialLocation != null) {
      setState(() {
        _initialLocation = LatLng(
          widget.initialLocation!.latitude,
          widget.initialLocation!.longitude,
        );
      });
      _mapController.move(_initialLocation, 15.0);
    } else {
      await _getCurrentLocation();
    }
    
    await _loadReportsOnMap();
    
    if (widget.selectedReport != null && widget.selectedReport!.hasLocation) {
      _zoomToReport(widget.selectedReport!);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint(_tr('location_disabled'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint(_tr('location_denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(_tr('location_denied'));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      setState(() {
        _initialLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(_initialLocation, 12.0);
      
      debugPrint('User location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('${_tr('location_error')}: $e');
    }
  }

  Future<void> _loadReportsOnMap() async {
    try {
      final reports = await _reportController.getReportsWithLocation();
      
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
      
      debugPrint('Loaded ${_reports.length} reports with location data');
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(_tr('error_loading'), '${_tr('failed_load_reports')}: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];
    
    for (var report in _reports) {
      if (report.hasLocation) {
        final marker = Marker(
          point: LatLng(report.location!.latitude, report.location!.longitude),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => _showReportDetails(report),
            child: _buildMarkerIcon(report.status, report.priority),
          ),
        );
        markers.add(marker);
      }
    }
    
    return markers;
  }

  Widget _buildMarkerIcon(String status, String priority) {
    Color color;
    IconData icon;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'resolved':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    
    switch (priority) {
      case 'urgent':
        icon = Icons.warning_amber_rounded;
        break;
      case 'high':
        icon = Icons.error_outline_rounded;
        break;
      case 'medium':
        icon = Icons.info_outline_rounded;
        break;
      case 'low':
        icon = Icons.low_priority_rounded;
        break;
      default:
        icon = Icons.place_rounded;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  void _showReportDetails(ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(report.title,
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  Chip(
                    label: Text(_getStatusText(report.status),
                        style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                    backgroundColor: _getStatusColor(report.status),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(report.description, style: GoogleFonts.poppins(color: Colors.grey[600])),
              
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(_tr(report.category),
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                  Chip(
                    label: Text(_tr(report.priority.toUpperCase()),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _getPriorityColor(report.priority),
                          fontWeight: FontWeight.w500)),
                    backgroundColor: _getPriorityColor(report.priority).withOpacity(0.1),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              if (report.location?.address.isNotEmpty == true) ...[
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(report.location!.address,
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              Text('${_tr('reported_on')} ${_formatDate(report.createdAt)}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
              
              const SizedBox(height: 20),
              
              if (report.images.isNotEmpty) ...[
                Text(_tr('attached_images'),
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(report.images[index]),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _zoomToReport(report);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.zoom_in_map, size: 20),
                      const SizedBox(width: 8),
                      Text(_tr('zoom_to_location'),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _zoomToReport(ReportModel report) {
    if (report.hasLocation) {
      final point = LatLng(report.location!.latitude, report.location!.longitude);
      _mapController.move(point, 15.0);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return _tr('pending');
      case 'in_progress':
        return _tr('in_progress');
      case 'resolved':
        return _tr('resolved');
      default:
        return status;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final _ = _languageController.currentLocale.value;

      return Scaffold(
        appBar: AppBar(
          title: Text(_tr('issue_map'), style: AppTextStyles.h2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              onPressed: () => _showLanguageDialog(context),
              icon: Icon(Icons.language, color: colorScheme.primary),
              tooltip: _languageController.translate('change_language'),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadReportsOnMap,
              tooltip: _tr('refresh'),
            ),
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () async => await _getCurrentLocation(),
              tooltip: _tr('my_location'),
            ),
          ],
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialLocation,
                initialZoom: 12.0,
                maxZoom: 18.0,
                minZoom: 5.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.uee_project',
                ),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),
            
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_tr('map_legend'),
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildLegendItem(_tr('pending'), Colors.orange, Icons.pending_actions),
                    _buildLegendItem(_tr('in_progress'), Colors.blue, Icons.build),
                    _buildLegendItem(_tr('resolved'), Colors.green, Icons.verified),
                    const SizedBox(height: 8),
                    Divider(color: Colors.grey[400]),
                    const SizedBox(height: 4),
                    Text(_tr('icons_priority'),
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
            
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_tr('issues_on_map'),
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                    Text('${_reports.length} ${_tr('locations')}',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    onPressed: () {
                      final currentZoom = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, currentZoom + 1);
                    },
                    tooltip: _tr('zoom_in'),
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    onPressed: () {
                      final currentZoom = _mapController.camera.zoom;
                      _mapController.move(_mapController.camera.center, currentZoom - 1);
                    },
                    tooltip: _tr('zoom_out'),
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLegendItem(String text, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(icon, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }
}