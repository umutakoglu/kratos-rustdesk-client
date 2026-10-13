import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/formatter/id_formatter.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:flutter_hbb/utils/multi_window_manager.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class KratosCustomerPage extends StatelessWidget {
  const KratosCustomerPage({Key? key}) : super(key: key);

  void _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('URL acilamadi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gFFI.serverModel,
      child: Consumer<ServerModel>(
        builder: (context, model, _) {
          return Container(
            color: const Color(0xFF0A1628),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sol Marka & Bilgilendirme Paneli
                _buildLeftBranding(context),

                // Sag Destek Paneli
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTopBar(context),
                        const SizedBox(height: 14),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildSupportCard(context, model),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftBranding(BuildContext context) {
    return Container(
      width: 320,
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
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          InkWell(
            onTap: () => _launchUrl('https://kratosbilgisayar.com'),
            child: Image.asset(
              'assets/logo.png',
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Text(
                'KRATOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Guvenli Baglanti Rozeti
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.shield_outlined, color: Color(0xFF38BDF8), size: 13),
                SizedBox(width: 5),
                Text(
                  'GÜVENLİ BAĞLANTI',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Baslik ve Aciklama
          const Text(
            'Teknik destek bir tık uzağınızda.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Kratos uzmanları sisteminize yalnızca sizin onayınızla bağlanır. Her oturum görünür, kontrollü ve şifrelidir.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),

          // Guven Maddeleri
          _buildTrustItem('Tek kullanımlık güvenli parola'),
          const SizedBox(height: 9),
          _buildTrustItem('İstediğiniz anda bağlantıyı sonlandırın'),
          const SizedBox(height: 9),
          _buildTrustItem('Kratos özel sunucu altyapısı'),

          const Spacer(),

          // Sol Alt Web Sitesi Linki
          InkWell(
            onTap: () => _launchUrl('https://kratosbilgisayar.com'),
            child: Row(
              children: const [
                Text(
                  'kratosbilgisayar.com',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_outward, color: Color(0xFF38BDF8), size: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.only(top: 1, right: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF059669), width: 1.2),
          ),
          child: const Center(
            child: Icon(Icons.check, size: 12, color: Color(0xFF34D399)),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Cevrimici Durum Rozeti
        Obx(() {
          final isReady = stateGlobal.svcStatus.value == SvcStatus.ready;
          final isConnecting = stateGlobal.svcStatus.value == SvcStatus.connecting;
          final color = isReady
              ? const Color(0xFF22C55E)
              : (isConnecting ? Colors.orange : const Color(0xFFEF4444));
          final text = isReady
              ? 'Destek sistemi hazır'
              : (isConnecting ? 'Bağlanıyor...' : 'Bağlantı bekleniyor');

          return Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, spreadRadius: 1),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Güvenli sunucuya bağlı',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),

        // Web Linkleri
        Row(
          children: [
            _buildHeaderLink('Hizmetler', 'https://kratosbilgisayar.com'),
            const SizedBox(width: 16),
            _buildHeaderLink('İletişim', 'https://kratosbilgisayar.com'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderLink(String label, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, ServerModel model) {
    final formattedId = formatID(model.serverId.text);
    final password = model.serverPasswd.text.isNotEmpty ? model.serverPasswd.text : model.password.text;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kart Basligi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Uzaktan destek bilgileri',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Aşağıdaki kimlik ve tek kullanımlık parolayı Kratos destek uzmanıyla paylaşın.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, color: Color(0xFF16A34A), size: 7),
                    SizedBox(width: 5),
                    Text(
                      'Çevrimiçi',
                      style: TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Kimlik & Parola Kutulari
          Row(
            children: [
              Expanded(
                child: _buildCredentialBox(
                  icon: Icons.computer_outlined,
                  title: 'Cihaz kimliğiniz',
                  value: formattedId.isEmpty ? '--- --- ---' : formattedId,
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: model.serverId.text));
                    showToast(translate('Copied'));
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildCredentialBox(
                  icon: Icons.lock_outline,
                  title: 'Tek kullanımlık parola',
                  value: password.isEmpty ? '--------' : password,
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: password));
                    showToast(translate('Copied'));
                  },
                  onRefresh: () {
                    bind.mainUpdateTemporaryPassword();
                    showToast('Yeni parola üretildi');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Guvenlik Uyarisi (Amber)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kratos personeli sizden asla banka şifresi veya kart bilgisi talep etmez.',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Aktif Oturum Varsa Goster
          Obx(() {
            final activeCount = stateGlobal.videoConnCount.value;
            if (activeCount > 0) {
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, color: Color(0xFF16A34A), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Aktif destek oturumu devrede ($activeCount oturum).',
                        style: const TextStyle(
                          color: Color(0xFF166534),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await rustDeskWinManager.closeAllSubWindows();
                        showToast('Bağlantı sonlandırıldı');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.close, size: 14),
                      label: const Text('Oturumu Kapat', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 18),

          // Aksiyon Butonlari
          Row(
            children: [
              // WhatsApp Destek Butonu
              ElevatedButton.icon(
                onPressed: () => _launchUrl(
                  'https://wa.me/902327001938?text=Merhaba%2C%20uzaktan%20destek%20almak%20istiyorum.',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.chat_outlined, size: 16),
                label: const Text(
                  'Destek ekibine ulaş',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                ),
              ),
              const SizedBox(width: 10),

              // Web Sitesi Butonu
              OutlinedButton(
                onPressed: () => _launchUrl('https://kratosbilgisayar.com'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: const Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Web sitesini aç',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                ),
              ),
              const Spacer(),

              // Oturum Bekleniyor Gostergesi
              Row(
                children: const [
                  Icon(Icons.circle, size: 7, color: Color(0xFF0284C7)),
                  SizedBox(width: 6),
                  Text(
                    'Bağlantı bekleniyor',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialBox({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onCopy,
    VoidCallback? onRefresh,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onRefresh != null)
                IconButton(
                  onPressed: onRefresh,
                  tooltip: 'Yeni şifre üret',
                  icon: const Icon(Icons.refresh_rounded, size: 17, color: Color(0xFF0284C7)),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              IconButton(
                onPressed: onCopy,
                tooltip: 'Kopyala',
                icon: const Icon(Icons.copy_rounded, size: 17, color: Color(0xFF0284C7)),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Kratos Bilgisayar',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
        ),
        Text(
          'Uçtan Uca Kurumsal Bilgi Teknolojileri Çözümleri',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
        ),
      ],
    );
  }
}
