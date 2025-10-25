import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uee_project/views/user_home_screen.dart'; // Import for LanguageController

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final LanguageController _languageController;
  List<Map<String, String>> _filteredMunicipalContacts = [];
  List<Map<String, String>> _filteredNationalContacts = [];
  String _selectedFilter = 'All';

  // Translation keys
  final Map<String, Map<String, String>> _translations = {
    'en_US': {
      'emergency_contacts': 'Emergency Contacts',
      'municipal_council_contacts': 'Municipal Council Contacts',
      'quick_access_desc': 'Quick access to local government contacts and emergency services across Sri Lanka',
      'search_placeholder': 'Search by district, council...',
      'filter_by_province': 'Filter by Province',
      'all': 'All',
      'cancel': 'Cancel',
      'municipal_councils': 'Municipal Councils',
      'national_emergency_services': 'National Emergency Services',
      'no_contacts_found': 'No contacts found',
      'adjust_search': 'Try adjusting your search or filter',
      'district': 'District',
      'province': 'Province',
      'error': 'Error',
      'unable_open_phone': 'Unable to open phone dialer',
      'unable_open_email': 'Unable to open email app',
      'unable_open_website': 'Unable to open website',
      'error_opening_phone': 'Error opening phone dialer',
      'error_opening_email': 'Error opening email app',
      'error_opening_website': 'Error opening website',
      // Provinces
      'Western': 'Western',
      'Central': 'Central',
      'Southern': 'Southern',
      'Northern': 'Northern',
      'Eastern': 'Eastern',
      'North Western': 'North Western',
      'North Central': 'North Central',
      'Uva': 'Uva',
      'Sabaragamuwa': 'Sabaragamuwa',
      'National': 'National',
    },
    'si_LK': {
      'emergency_contacts': 'හදිසි සම්බන්ධතා',
      'municipal_council_contacts': 'නගර සභා සම්බන්ධතා',
      'quick_access_desc': 'ශ්‍රී ලංකාව පුරා දේශීය රජයේ සම්බන්ධතා සහ හදිසි සේවා සඳහා ඉක්මන් ප්‍රවේශය',
      'search_placeholder': 'දිස්ත්‍රික්කය, සභාව අනුව සොයන්න...',
      'filter_by_province': 'පළාත අනුව පෙරීම',
      'all': 'සියල්ල',
      'cancel': 'අවලංගු කරන්න',
      'municipal_councils': 'නගර සභා',
      'national_emergency_services': 'ජාතික හදිසි සේවා',
      'no_contacts_found': 'සම්බන්ධතා හමු නොවීය',
      'adjust_search': 'ඔබේ සෙවුම හෝ පෙරීම වෙනස් කිරීමට උත්සාහ කරන්න',
      'district': 'දිස්ත්‍රික්කය',
      'province': 'පළාත',
      'error': 'දෝෂයකි',
      'unable_open_phone': 'දුරකථන ඇමතුම් යන්ත්‍රය විවෘත කළ නොහැක',
      'unable_open_email': 'ඊමේල් යෙදුම විවෘත කළ නොහැක',
      'unable_open_website': 'වෙබ් අඩවිය විවෘත කළ නොහැක',
      'error_opening_phone': 'දුරකථන ඇමතුම් යන්ත්‍රය විවෘත කිරීමේ දෝෂයකි',
      'error_opening_email': 'ඊමේල් යෙදුම විවෘත කිරීමේ දෝෂයකි',
      'error_opening_website': 'වෙබ් අඩවිය විවෘත කිරීමේ දෝෂයකි',
      // Provinces in Sinhala
      'Western': 'බස්නාහිර',
      'Central': 'මධ්‍යම',
      'Southern': 'දකුණු',
      'Northern': 'උතුරු',
      'Eastern': 'නැගෙනහිර',
      'North Western': 'වයඹ',
      'North Central': 'උතුරු මැද',
      'Uva': 'ඌව',
      'Sabaragamuwa': 'සබරගමුව',
      'National': 'ජාතික',
    },
  };

  @override
  void initState() {
    super.initState();
    
    // Initialize language controller
    if (Get.isRegistered<LanguageController>()) {
      _languageController = Get.find<LanguageController>();
    } else {
      _languageController = Get.put(LanguageController());
    }
    
    _filteredMunicipalContacts = List.from(_municipalContacts);
    _filteredNationalContacts = List.from(_nationalContacts);
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _tr(String key) {
    final localeKey = '${_languageController.currentLocale.value.languageCode}_${_languageController.currentLocale.value.countryCode}';
    return _translations[localeKey]?[key] ?? key;
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty && _selectedFilter == 'All') {
        _filteredMunicipalContacts = List.from(_municipalContacts);
        _filteredNationalContacts = List.from(_nationalContacts);
      } else {
        _filteredMunicipalContacts = _municipalContacts.where((contact) {
          final matchesSearch = contact['name']!.toLowerCase().contains(query) ||
              contact['district']!.toLowerCase().contains(query) ||
              contact['province']!.toLowerCase().contains(query) ||
              contact['location']!.toLowerCase().contains(query);
          
          final matchesFilter = _selectedFilter == 'All' || 
              contact['province'] == _selectedFilter;
          
          return matchesSearch && matchesFilter;
        }).toList();
        
        _filteredNationalContacts = _nationalContacts.where((contact) {
          return contact['name']!.toLowerCase().contains(query) ||
              contact['location']!.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showFilterDialog() {
    final provinces = ['All', 'Western', 'Central', 'Southern', 'Northern', 
                       'Eastern', 'North Western', 'North Central', 'Uva', 'Sabaragamuwa'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _tr('filter_by_province'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provinces.length,
            itemBuilder: (context, index) {
              final province = provinces[index];
              return RadioListTile<String>(
                title: Text(
                  _tr(province),
                  style: GoogleFonts.poppins(),
                ),
                value: province,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  _performSearch();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _tr('cancel'),
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _languageController.translate('select_language'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              'English',
              const Locale('en', 'US'),
              Icons.language,
              _languageController.isEnglish,
              colorScheme,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context,
              'සිංහල',
              const Locale('si', 'LK'),
              Icons.language,
              _languageController.isSinhala,
              colorScheme,
              isDark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _languageController.translate('close'),
              style: GoogleFonts.poppins(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String language,
    Locale locale,
    IconData icon,
    bool isSelected,
    ColorScheme colorScheme,
    bool isDark,
  ) {
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
            color: isSelected
                ? colorScheme.primary
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      // This will rebuild when language changes
      final _ = _languageController.currentLocale.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: Text(
            _tr('emergency_contacts'),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          backgroundColor: isDark ? Colors.grey[800] : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () => Get.back(),
          ),
          actions: [
            // Language Toggle Button
            IconButton(
              onPressed: () => _showLanguageDialog(context),
              icon: Icon(
                Icons.language,
                color: colorScheme.primary,
              ),
              tooltip: _languageController.translate('change_language'),
            ),
          ],
        ),
        body: Column(
          children: [
            // Header Card
            Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.1),
                        colorScheme.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.contact_phone_rounded,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _tr('municipal_council_contacts'),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _tr('quick_access_desc'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search Bar with Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: _tr('search_placeholder'),
                          hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[500]),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: _selectedFilter != 'All' 
                            ? colorScheme.primary 
                            : Colors.grey[500],
                      ),
                      onPressed: _showFilterDialog,
                    ),
                  ],
                ),
              ),
            ),

            // Active Filter Chip
            if (_selectedFilter != 'All')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Chip(
                      label: Text(
                        _tr(_selectedFilter),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: colorScheme.primary,
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                      onDeleted: () {
                        setState(() {
                          _selectedFilter = 'All';
                        });
                        _performSearch();
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Contacts List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Municipal Contacts
                  if (_filteredMunicipalContacts.isNotEmpty) ...[
                    Text(
                      '${_tr('municipal_councils')} (${_filteredMunicipalContacts.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._filteredMunicipalContacts.map((contact) => 
                      _buildContactCard(contact, context)
                    ).toList(),
                  ],

                  // National Emergency Services
                  if (_filteredNationalContacts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      '${_tr('national_emergency_services')} (${_filteredNationalContacts.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._filteredNationalContacts.map((contact) => 
                      _buildContactCard(contact, context)
                    ).toList(),
                  ],

                  // No Results Found
                  if (_filteredMunicipalContacts.isEmpty && 
                      _filteredNationalContacts.isEmpty) ...[
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _tr('no_contacts_found'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _tr('adjust_search'),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContactCard(Map<String, String> contact, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['name']!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${contact['district']} ${_tr('district')} • ${_tr(contact['province']!)} ${_tr('province')}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Location
            if (contact['location'] != null && contact['location']!.isNotEmpty)
              _buildContactInfoRow(
                Icons.location_on_rounded,
                contact['location']!,
                context,
              ),
            
            // Phone Numbers
            if (contact['phone'] != null && 
                contact['phone']!.isNotEmpty && 
                contact['phone'] != 'Not available')
              ..._buildPhoneNumbers(contact['phone']!, context),
            
            // Email
            if (contact['email'] != null && contact['email']!.isNotEmpty)
              _buildContactInfoRow(
                Icons.email_rounded,
                contact['email']!,
                context,
                onTap: () => _sendEmail(contact['email']!),
              ),
            
            // Website
            if (contact['website'] != null && 
                contact['website']!.isNotEmpty && 
                contact['website'] != 'Not available')
              _buildContactInfoRow(
                Icons.language_rounded,
                contact['website']!,
                context,
                onTap: () => _launchWebsite(contact['website']!),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPhoneNumbers(String phoneNumbers, BuildContext context) {
    final numbers = phoneNumbers.split(',').map((e) => e.trim()).toList();
    
    return numbers.map((number) {
      return _buildContactInfoRow(
        Icons.phone_rounded,
        number,
        context,
        onTap: () => _makePhoneCall(number),
      );
    }).toList();
  }

  Widget _buildContactInfoRow(
    IconData icon, 
    String text, 
    BuildContext context, 
    {VoidCallback? onTap}
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              Icon(
                icon, 
                size: 18, 
                color: onTap != null ? colorScheme.primary : Colors.grey[500],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: onTap != null 
                        ? colorScheme.primary
                        : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    fontWeight: onTap != null ? FontWeight.w500 : FontWeight.normal,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final uri = Uri(scheme: 'tel', path: cleanedNumber);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar(_tr('unable_open_phone'));
      }
    } catch (e) {
      _showErrorSnackbar('${_tr('error_opening_phone')}: ${e.toString()}');
    }
  }

  Future<void> _sendEmail(String email) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
      );
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar(_tr('unable_open_email'));
      }
    } catch (e) {
      _showErrorSnackbar('${_tr('error_opening_email')}: ${e.toString()}');
    }
  }

  Future<void> _launchWebsite(String website) async {
    try {
      String url = website;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showErrorSnackbar(_tr('unable_open_website'));
      }
    } catch (e) {
      _showErrorSnackbar('${_tr('error_opening_website')}: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      _tr('error'),
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  // Municipal Council Data
  static final List<Map<String, String>> _municipalContacts = [
    {
      'name': 'Colombo Municipal Council',
      'province': 'Western',
      'district': 'Colombo',
      'location': 'Colombo',
      'phone': '+94 11 2691191, +94 11 2678425, +94 11 2695121',
      'email': 'commissioner@colombo.mc.gov.lk',
      'website': 'http://www.colombo.mc.gov.lk',
    },
    {
      'name': 'Dehiwala-Mount Lavinia Municipal Council',
      'province': 'Western',
      'district': 'Colombo',
      'location': 'Dehiwala-Mount Lavinia',
      'phone': 'Not available',
      'email': '',
      'website': 'http://dmmc.lk',
    },
    {
      'name': 'Sri Jayawardenepura Kotte Municipal Council',
      'province': 'Western',
      'district': 'Colombo',
      'location': 'Sri Jayawardenepura Kotte',
      'phone': '+94 11 2877518, +94 11 2888098, +94 11 2869971, +94 11 2874701',
      'email': '',
      'website': 'http://www.kotte.mc.gov.lk',
    },
    {
      'name': 'Kaduwela Municipal Council',
      'province': 'Western',
      'district': 'Colombo',
      'location': 'Kaduwela',
      'phone': 'Not available',
      'email': '',
      'website': 'http://www.kaduwela.mc.gov.lk',
    },
    {
      'name': 'Moratuwa Municipal Council',
      'province': 'Western',
      'district': 'Colombo',
      'location': 'Moratuwa',
      'phone': 'Not available',
      'email': '',
      'website': 'http://moratuwa.mc.gov.lk',
    },
    {
      'name': 'Negombo Municipal Council',
      'province': 'Western',
      'district': 'Gampaha',
      'location': 'Negombo',
      'phone': 'Not available',
      'email': '',
      'website': 'http://www.negombo.mc.gov.lk',
    },
    {
      'name': 'Gampaha Municipal Council',
      'province': 'Western',
      'district': 'Gampaha',
      'location': 'Gampaha',
      'phone': 'Not available',
      'email': '',
      'website': 'http://www.gampaha.mc.gov.lk',
    },
    {
      'name': 'Galle Municipal Council',
      'province': 'Southern',
      'district': 'Galle',
      'location': 'Galle',
      'phone': '+94 91 2234275',
      'email': '',
      'website': 'http://www.galle.mc.gov.lk',
    },
    {
      'name': 'Akkaraipattu Municipal Council',
      'province': 'Eastern',
      'district': 'Ampara',
      'location': 'Akkaraipattu',
      'phone': '+94 67 2277275',
      'email': '',
      'website': 'Not available',
    },
    {
      'name': 'Anuradhapura Municipal Council',
      'province': 'North Central',
      'district': 'Anuradhapura',
      'location': 'Anuradhapura',
      'phone': '+94 25 2222275',
      'email': '',
      'website': 'Not available',
    },
  ];

  // National Emergency Services
  static final List<Map<String, String>> _nationalContacts = [
    {
      'name': 'Urban Development Authority (UDA)',
      'province': 'National',
      'district': 'Colombo',
      'location': 'Sethsiripaya, Battaramulla',
      'phone': '+94 11 2873637',
      'email': '',
      'website': '',
    },
    {
      'name': 'Ministry of Urban Development',
      'province': 'National',
      'district': 'Colombo',
      'location': 'Sethsiripaya, Stage II, Battaramulla',
      'phone': '+94 11 2864770',
      'email': '',
      'website': '',
    },
    {
      'name': 'Ministry of Local Government',
      'province': 'National',
      'district': 'Colombo',
      'location': 'Union Place, Colombo 02',
      'phone': '+94 11 2305326, +94 11 2303280',
      'email': '',
      'website': '',
    },
  ];
}