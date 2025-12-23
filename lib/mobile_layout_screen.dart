import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:northern_trader/common/utils/colors.dart';
import 'package:northern_trader/features/auth/controller/auth_controller.dart';
import 'package:northern_trader/features/channels/screens/channels_list_screen.dart';
import 'package:northern_trader/features/chat/widgets/chat_contacts_list.dart';
import 'package:northern_trader/features/landing/screens/landing_screen.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  void _showProfileMenu(BuildContext context, String userName, String? profilePic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundImage: profilePic != null && profilePic.isNotEmpty
                  ? CachedNetworkImageProvider(profilePic)
                  : null,
              child: profilePic == null || profilePic.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Выйти',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(authControllerProvider).signOut(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataAuthProvider);
    final isOwner = userData.value?.isOwner ?? false;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarColor,
        centerTitle: false,
        title: Text(
          _currentIndex == 0 ? 'Каналы' : 'Чат',
          style: const TextStyle(
            fontSize: 22,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          userData.when(
            data: (user) {
              if (user == null) return const SizedBox.shrink();
              return IconButton(
                icon: CircleAvatar(
                  radius: 18,
                  backgroundImage: user.profilePic.isNotEmpty
                      ? CachedNetworkImageProvider(user.profilePic)
                      : null,
                  child: user.profilePic.isEmpty
                      ? const Icon(Icons.person, size: 20, color: Colors.grey)
                      : null,
                ),
                onPressed: () => _showProfileMenu(context, user.name, user.profilePic),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ChannelsListScreen(),
          ChatContactsList(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: appBarColor,
        selectedItemColor: limeGreen,
        unselectedItemColor: greyColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            label: 'Каналы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Чат',
          ),
        ],
      ),
    );
  }
}
