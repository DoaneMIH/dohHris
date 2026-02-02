import 'package:flutter/material.dart';

class FloatingMenuButton extends StatefulWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const FloatingMenuButton({
    Key? key,
    required this.selectedMenu,
    required this.onMenuSelected,
  }) : super(key: key);

  @override
  State<FloatingMenuButton> createState() => _FloatingMenuButtonState();
}

class _FloatingMenuButtonState extends State<FloatingMenuButton>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Personal Information',
      'icon': Icons.person_outline,
    },
    {
      'title': 'Family Background',
      'icon': Icons.people_outline,
    },
    {
      'title': 'Educational Background',
      'icon': Icons.school_outlined,
    },
    {
      'title': 'Civil Service Eligibility',
      'icon': Icons.verified_outlined,
    },
    {
      'title': 'Work Experience',
      'icon': Icons.work_outline,
    },
    {
      'title': 'Voluntary Work',
      'icon': Icons.volunteer_activism_outlined,
    },
    {
      'title': 'Learning and Development',
      'icon': Icons.emoji_objects_outlined,
    },
    {
      'title': 'Other Information',
      'icon': Icons.info_outline,
    },
    {
      'title': 'Daily Time Record',
      'icon': Icons.access_time,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Menu overlay
        if (_isMenuOpen)
          GestureDetector(
            onTap: _closeMenu,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

        // Menu panel
        if (_isMenuOpen)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: const BoxDecoration(
                  color: Color(0xFF00674F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Menu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: _closeMenu,
                          ),
                        ],
                      ),
                    ),

                    // Scrollable menu items
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _menuItems.length,
                          itemBuilder: (context, index) {
                            final item = _menuItems[index];
                            final isSelected =
                                item['title'] == widget.selectedMenu;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00674F).withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  item['icon'],
                                  color: isSelected
                                      ? const Color(0xFF00674F)
                                      : Colors.grey[600],
                                  size: 24,
                                ),
                                title: Text(
                                  item['title'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF00674F)
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                onTap: () {
                                  widget.onMenuSelected(item['title']);
                                  _closeMenu();
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Floating action button
        Positioned(
          left: 20,
          bottom: 16,
          child: GestureDetector(
            onTap: _toggleMenu,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isMenuOpen ? 200 : 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00C9A7),
                    Color(0xFF00674F),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00674F).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isMenuOpen
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tap to close',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      margin: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}