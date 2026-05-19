import 'package:app/models/aura.dart';
import 'package:app/models/profile.dart';
import 'package:app/pages/aura_scan.dart';
import 'package:app/pages/policy/privacy.dart';
import 'package:app/pages/user/profile.dart';
import 'package:app/pages/policy/refund.dart';
import 'package:app/pages/user/signin.dart';
import 'package:app/pages/policy/terms.dart';
import 'package:app/services/identity.dart';
import 'package:app/services/service.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class ActionIconData {
  ActionIconData();
  Future<List<Widget>> list() async {
    List<Widget> lst = [];
    ProfileData? user = await Service.user.me();
    if (user != null) {
      /* lst.add(
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black87),
          onPressed: () {},
        ),
      );       */

      lst.add(
        Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              color: Colors.white.withValues(alpha: 0.95),
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatar!),
                  backgroundColor: Colors.transparent,
                ),
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'profile':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Profile(data: user),
                      ),
                    );
                    break;
                  case 'aura':
                    List<AuraData> list = await Service.aura.list();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuraScan(data: list),
                      ),
                    );
                    break;
                  case 'terms':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Terms()),
                    );
                    break;
                  case 'privacy':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Privacy()),
                    );
                    break;
                  case 'refund':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RefundPolicy(),
                      ),
                    );
                    break;
                  case 'logout':
                    Identity.instance.logout();
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushReplacementNamed("/home");
                    break;
                }
              },
              itemBuilder: (context) => [
                _buildPopupItem(Icons.person_outline, 'Profile', 'profile'),
                const PopupMenuDivider(),
                _buildPopupItem(
                  Icons.auto_awesome_outlined,
                  'Aura Service',
                  'aura',
                ),
                const PopupMenuDivider(),
                _buildPopupItem(
                  Icons.description_outlined,
                  'Terms of Service',
                  'terms',
                ),
                _buildPopupItem(
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  'privacy',
                ),
                _buildPopupItem(
                  Icons.currency_exchange_outlined,
                  'Refund Policy',
                  'refund',
                ),
                const PopupMenuDivider(),
                _buildPopupItem(Icons.logout, 'Sign Out', 'logout'),
              ],
            ),
          ),
        ),
      );
    } else {
      lst.add(
        Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              color: Colors.white.withValues(alpha: 0.95),
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(Icons.more_vert),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'signin':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                    );
                    break;
                  case 'terms':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Terms()),
                    );
                    break;
                  case 'privacy':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Privacy()),
                    );
                    break;
                  case 'refund':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RefundPolicy(),
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                _buildPopupItem(Icons.login, 'Sign In', 'signin'),
                const PopupMenuDivider(),
                _buildPopupItem(
                  Icons.description_outlined,
                  'Terms of Service',
                  'terms',
                ),
                _buildPopupItem(
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  'privacy',
                ),
                _buildPopupItem(
                  Icons.currency_exchange_outlined,
                  'Refund Policy',
                  'refund',
                ),
              ],
            ),
          ),
        ),
      );
    }
    return lst;
  }

  static PopupMenuItem<String> _buildPopupItem(
    IconData icon,
    String title,
    String value,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
