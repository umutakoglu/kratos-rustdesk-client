import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/formatter/id_formatter.dart';
import 'package:flutter_hbb/common/widgets/autocomplete.dart';
import 'package:flutter_hbb/common/widgets/peer_tab_page.dart';
import 'package:flutter_hbb/desktop/pages/desktop_tab_page.dart';
import 'package:flutter_hbb/models/peer_model.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

class KratosTechnicianPage extends StatefulWidget {
  const KratosTechnicianPage({Key? key}) : super(key: key);

  @override
  State<KratosTechnicianPage> createState() => _KratosTechnicianPageState();
}

class _KratosTechnicianPageState extends State<KratosTechnicianPage>
    with WindowListener {
  final _idController = IDTextEditingController();
  final _idEditingController = TextEditingController();
  final FocusNode _idFocusNode = FocusNode();
  final AllPeersLoader _allPeersLoader = AllPeersLoader();
  Iterable<Peer> _autocompleteOpts = const [];

  int _selectedNavIndex = 0;
  bool isFileTransfer = false;

  void _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('URL acilamadi: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _allPeersLoader.init(setState);
    _allPeersLoader.getAllPeers();
    _idFocusNode.addListener(_onFocusChanged);
    if (_idController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final lastRemoteId = await bind.mainGetLastRemoteId();
        if (lastRemoteId.isNotEmpty && lastRemoteId != _idController.id) {
          setState(() {
            _idController.id = lastRemoteId;
            _idEditingController.text = formatID(lastRemoteId);
          });
        }
      });
    }
    Get.put<TextEditingController>(_idEditingController);
    Get.put<IDTextEditingController>(_idController);
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    _idController.dispose();
    _idEditingController.dispose();
    _idFocusNode.removeListener(_onFocusChanged);
    _idFocusNode.dispose();
    _allPeersLoader.clear();
    windowManager.removeListener(this);
    if (Get.isRegistered<IDTextEditingController>()) {
      Get.delete<IDTextEditingController>();
    }
    if (Get.isRegistered<TextEditingController>()) {
      Get.delete<TextEditingController>();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    if (_idFocusNode.hasFocus) {
      if (_allPeersLoader.needLoad) {
        _allPeersLoader.getAllPeers();
      }
      final textLength = _idEditingController.value.text.length;
      _idEditingController.selection =
          TextSelection(baseOffset: 0, extentOffset: textLength);
    }
  }

  void _onConnect() {
    final id = _idController.id.trim();
    if (id.isEmpty) {
      showToast('Lütfen geçerli bir müşteri kimliği girin');
      return;
    }
    connect(
      context,
      id,
      isFileTransfer: isFileTransfer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sol Konsol Kenar Cubugu
          _buildSidebar(context),

          // Sag Ana Dashboard Alani
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                _buildStatsRow(context),
                const SizedBox(height: 12),
                Expanded(child: _buildMainView(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1628),
            Color(0xFF0F1E36),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Konsol Basligi
          InkWell(
            onTap: () => _launchUrl('https://kratosbilgisayar.com'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 34,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'KRATOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'UZAKTAN DESTEK KONSOLU',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Operator Profil Karti
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'KT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Kratos Teknisyen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Operatör • Çevrimiçi',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Menu Basligi
          const Text(
            'ÇALIŞMA ALANI',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          // Navigasyon Ogeleri
          _buildNavItem(
            icon: Icons.dashboard_outlined,
            title: 'Genel bakış',
            isActive: _selectedNavIndex == 0,
            badge: null,
            onTap: () => setState(() => _selectedNavIndex = 0),
          ),
          _buildNavItem(
            icon: Icons.devices_outlined,
            title: 'Cihazlar',
            isActive: _selectedNavIndex == 1,
            badge: '${_allPeersLoader.peers.length}',
            onTap: () => setState(() => _selectedNavIndex = 1),
          ),
          _buildNavItem(
            icon: Icons.bolt_outlined,
            title: 'Hızlı Bağlantı',
            isActive: _selectedNavIndex == 2,
            badge: null,
            onTap: () {
              setState(() => _selectedNavIndex = 0);
              _idFocusNode.requestFocus();
            },
          ),

          const SizedBox(height: 16),
          const Text(
            'SİSTEM',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          _buildNavItem(
            icon: Icons.settings_outlined,
            title: 'Ayarlar',
            isActive: false,
            badge: null,
            onTap: DesktopTabPage.onAddSetting,
          ),

          const Spacer(),

          // Alt Web Sitesi Linki
          InkWell(
            onTap: () => _launchUrl('https://kratosbilgisayar.com'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Kurumsal çözümler & iletişim',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'kratosbilgisayar.com ↗',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E293B) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: const Color(0xFF334155)) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 12.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Günaydın, Kratos Teknisyen',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Müşteri cihazlarına güvenli bağlantı kurun ve aktif destek oturumlarını yönetin.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          Obx(() {
            final isReady = stateGlobal.svcStatus.value == SvcStatus.ready;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isReady ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isReady ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: isReady ? const Color(0xFF16A34A) : Colors.amber[800],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isReady ? 'Bağlantıya hazır' : 'Sunucu aranıyor...',
                    style: TextStyle(
                      color: isReady ? const Color(0xFF15803D) : Colors.amber[900],
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'ÇEVRİMİÇİ CİHAZ',
              value: '${_allPeersLoader.peers.length}',
              subtitle: 'Kayıtlı cihazlardan',
              icon: Icons.computer_outlined,
              iconColor: const Color(0xFF0284C7),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(
              () => _buildStatCard(
                title: 'AKTİF OTURUM',
                value: '${stateGlobal.videoConnCount.value}',
                subtitle: 'Uzak kontrol oturumu',
                icon: Icons.personal_video_outlined,
                iconColor: const Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              title: 'BUGÜNKÜ DESTEK',
              value: '12',
              subtitle: 'Ortalama süre 18 dk',
              icon: Icons.history_toggle_off_outlined,
              iconColor: const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              title: 'SUNUCU DURUMU',
              value: '%99,9',
              subtitle: 'İzmir relay • Aktif',
              icon: Icons.cloud_done_outlined,
              iconColor: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Icon(icon, size: 15, color: iconColor),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView(BuildContext context) {
    if (_selectedNavIndex == 1) {
      // Sadece Cihazlar Gorunumu
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kayıtlı Cihazlar ve Adres Defteri',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Toplam: ${_allPeersLoader.peers.length}',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              const Expanded(child: PeerTabPage()),
            ],
          ),
        ),
      );
    }

    // Genel Bakis Dashboard Gorunumu
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sol Bolum (Hizli Baglanti Karti & Cihazlar Listesi)
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildQuickConnectCard(context),
                const SizedBox(height: 12),
                Expanded(child: _buildPeersPanel(context)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Sag Yan Panel (Son Hareketler & Guvenlik Politikasi)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildRecentActivityPanel(context)),
                const SizedBox(height: 12),
                _buildSecurityCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickConnectCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Baslik Seridi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A1628), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'HIZLI VE GÜVENLİ BAĞLANTI',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Müşterinin cihaz kimliğini girin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.shield_outlined, color: Color(0xFF38BDF8), size: 22),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Baglanti Formu (Autocomplete)
          Row(
            children: [
              Expanded(
                child: RawAutocomplete<Peer>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      _autocompleteOpts = const Iterable<Peer>.empty();
                    } else {
                      final cleanText = textEditingValue.text.replaceAll(' ', '').toLowerCase();
                      _autocompleteOpts = _allPeersLoader.peers.where((peer) =>
                          peer.id.toLowerCase().contains(cleanText) ||
                          peer.username.toLowerCase().contains(cleanText) ||
                          peer.hostname.toLowerCase().contains(cleanText) ||
                          peer.alias.toLowerCase().contains(cleanText)).toList();
                      _allPeersLoader.queryOnlines(_autocompleteOpts);
                    }
                    return _autocompleteOpts;
                  },
                  focusNode: _idFocusNode,
                  textEditingController: _idEditingController,
                  optionsViewBuilder: _buildAutocompleteOptions,
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Örn: 732 614 908',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.5,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.8),
                        ),
                      ),
                      inputFormatters: [IDTextInputFormatter()],
                      onChanged: (v) => _idController.id = v,
                      onSubmitted: (_) => _onConnect(),
                    );
                  },
                  onSelected: (option) {
                    setState(() {
                      _idController.id = option.id;
                      _idEditingController.text = formatID(option.id);
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),

              // Baglan Butonu
              ElevatedButton.icon(
                onPressed: _onConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                label: const Text(
                  'Güvenli bağlan',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hizli Secenekler
          Row(
            children: [
              _buildOptionChip(
                label: 'Bağlantı modu: Uzaktan kontrol',
                isActive: !isFileTransfer,
                onTap: () => setState(() => isFileTransfer = false),
              ),
              const SizedBox(width: 8),
              _buildOptionChip(
                label: 'Dosya aktarımı',
                isActive: isFileTransfer,
                onTap: () => setState(() => isFileTransfer = true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutocompleteOptions(
    BuildContext context,
    AutocompleteOnSelected<Peer> onSelected,
    Iterable<Peer> options,
  ) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }
    final list = options.take(6).toList();
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        child: Container(
          width: 360,
          constraints: const BoxConstraints(maxHeight: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            shrinkWrap: true,
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final peer = list[index];
              return AutocompletePeerTile(
                onSelect: () => onSelected(peer),
                peer: peer,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF7DD3FC) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF0369A1) : const Color(0xFF64748B),
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPeersPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Son bağlanılan cihazlar',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Kayıtlı: ${_allPeersLoader.peers.length}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          const Expanded(child: PeerTabPage()),
        ],
      ),
    );
  }

  Widget _buildRecentActivityPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Son hareketler & oturumlar',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _buildActivityItem('Destek oturumu tamamlandı', 'Uzak kontrol sonlandı', '10 dk önce', const Color(0xFF0284C7)),
                _buildActivityItem('Güvenli bağlantı kuruldu', 'Şifreli tünel aktif', '25 dk önce', const Color(0xFF22C55E)),
                _buildActivityItem('Yetkilendirme onaylandı', 'Tek kullanımlık parola', '1 saat önce', const Color(0xFFF59E0B)),
                _buildActivityItem('Sistem hazır', 'Relay sunucusu doğrulandı', 'Bugün', const Color(0xFF64748B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4, right: 10),
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.verified_user_outlined, color: Color(0xFF38BDF8), size: 17),
              SizedBox(width: 8),
              Text(
                'Güvenlik politikası aktif',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tüm oturumlar Kratos altyapısı üzerinden uçtan uca şifreli olarak yürütülür.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5, height: 1.3),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _launchUrl('https://kratosbilgisayar.com'),
            child: const Text(
              'Güvenlik çözümlerimizi inceleyin →',
              style: TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
