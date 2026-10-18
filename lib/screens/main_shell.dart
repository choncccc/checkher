import 'package:flutter/material.dart';

import '../models/user.dart';
import '../theme.dart';
import 'assessment/assessment_entry_screen.dart';
import 'care/care_screen.dart';
import 'home_screen.dart';
import 'learn/learn_screen.dart';
import 'me_screen.dart';
import 'menu_drawer.dart';
import 'placeholder_screen.dart';

/// Hosts the five bottom-nav tabs: Home, Care, Learn, Menu, Me.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.user});

  final AppUser user;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late AppUser _user = widget.user;
  int _index = 0;
  // Tab to return to when leaving a Menu page.
  int _lastTab = 0;
  bool _menuOpen = false;
  final _drawerHost = GlobalKey<ScaffoldState>();
  // Care, Learn and Menu have their own navigators so their pages keep the
  // bottom bar.
  final _careNav = GlobalKey<NavigatorState>();
  final _learnNav = GlobalKey<NavigatorState>();
  final _menuNav = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState>? _navFor(int i) => switch (i) {
    1 => _careNav,
    2 => _learnNav,
    3 => _menuNav,
    _ => null,
  };

  void _onUserChanged(AppUser u) => setState(() => _user = u);

  void _onTabTap(int i) {
    if (i == 3) {
      final drawer = _drawerHost.currentState!;
      _menuOpen ? drawer.closeDrawer() : drawer.openDrawer();
      return;
    }
    _drawerHost.currentState?.closeDrawer();
    if (i == _index) {
      _navFor(i)?.currentState?.popUntil((r) => r.isFirst);
    }
    setState(() => _index = i);
  }

  void _openMenuPage(String title) {
    _drawerHost.currentState!.closeDrawer();
    if (_index != 3) _lastTab = _index;
    setState(() => _index = 3);
    final nav = _menuNav.currentState!..popUntil((r) => r.isFirst);
    nav
        .push(
          MaterialPageRoute<void>(
            builder: (context) => switch (title) {
              'PMOS Risk Assessment' => AssessmentEntryScreen(userId: _user.id),
              _ => Scaffold(
                body: PlaceholderScreen(
                  title: title,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            },
          ),
        )
        .then((_) {
          // Leaving the last Menu page returns to the tab it was opened from.
          if (mounted && _index == 3 && !nav.canPop()) {
            setState(() => _index = _lastTab);
          }
        });
  }

  Widget _tabNavigator(int i, Widget root) {
    final key = _navFor(i)!;
    return NavigatorPopHandler(
      onPopWithResult: (_) => key.currentState?.maybePop(),
      // While the menu is open, back closes it instead.
      enabled: _index == i && !_menuOpen,
      child: Navigator(
        key: key,
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => root),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeScreen(user: _user, onUserChanged: _onUserChanged),
      _tabNavigator(1, const CareScreen()),
      _tabNavigator(2, const LearnScreen()),
      _tabNavigator(3, const SizedBox.shrink()),
      MeScreen(user: _user, onUserChanged: _onUserChanged),
    ];
    return PopScope(
      // Android's predictive back doesn't count an open drawer as something
      // the app handles, so close it explicitly.
      canPop: !_menuOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _drawerHost.currentState?.closeDrawer();
      },
      child: Scaffold(
        // Inner scaffold so the sidebar opens above the bottom bar (page 13).
        body: Scaffold(
          key: _drawerHost,
          drawer: MenuDrawer(onSelect: _openMenuPage),
          // Wider than Android's back-gesture strip at the screen edge, so a
          // swipe that starts just inside it still opens the menu.
          drawerEdgeDragWidth: MediaQuery.sizeOf(context).width * 0.2,
          drawerScrimColor: Colors.black26,
          onDrawerChanged: (open) => setState(() => _menuOpen = open),
          body: IndexedStack(index: _index, children: tabs),
        ),
        bottomNavigationBar: _BottomBar(
          index: _menuOpen ? 3 : _index,
          onTap: _onTabTap,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  // Alpha-mask PNGs cut from the nav icon sheet, tinted per state below.
  static const _items = [
    ('assets/nav_icons/home.png', 'Home'),
    ('assets/nav_icons/care.png', 'Care'),
    ('assets/nav_icons/learn.png', 'Learn'),
    ('assets/nav_icons/menu.png', 'Menu'),
    ('assets/nav_icons/me.png', 'Me'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8)],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkResponse(
                    onTap: () => onTap(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: i == index
                                  ? AppColors.ink
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset(
                              _items[i].$1,
                              width: 28,
                              height: 28,
                              color: i == index
                                  ? AppColors.aqua
                                  : AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _items[i].$2,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: i == index
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
