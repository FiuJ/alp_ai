import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import 'history.dart';

// --- THEME CONSTANTS ---
class AppTheme {
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFFD8F3DC);
  static const Color accent = Color(0xFF95D5B2);
  static const Color surface = Color(0xFFF8F9FA);
  
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(32));
  static const BoxShadow softShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 20,
    offset: Offset(0, 10),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final viewModel = Provider.of<HomeViewModel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          // 1. Background Elements (Subtle Organic Shapes)
          const _BackgroundDecorations(),

          // 2. Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Collapsing App Bar
              SliverAppBar(
                expandedHeight: 120,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: Text(
                    'Trash Classifier',
                    style: TextStyle(
                      color: AppTheme.darkGreen,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontSize: 24,
                      shadows: [
                        Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 10),
                      ],
                    ),
                  ),
                ),
                actions: [
                  _HistoryButton(onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const History()),
                    );
                  }),
                  const SizedBox(width: 24),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Image Display Area
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _ImageDisplayArea(viewModel: viewModel),
                      ),
                      
                      const SizedBox(height: 32),

                      // Action Buttons
                      SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                            .animate(_slideAnimation),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _ControlPanel(viewModel: viewModel),
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // Analysis Results
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: viewModel.isProcessing
                            ? const _ProcessingState()
                            : viewModel.classificationResult != null
                                ? _ResultPanel(
                                    result: viewModel.classificationResult!,
                                    recommendation: viewModel.geminiRecommendation,
                                  )
                                : const SizedBox.shrink(),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- SUB-WIDGETS ---

class _ImageDisplayArea extends StatelessWidget {
  final HomeViewModel viewModel;

  const _ImageDisplayArea({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppTheme.cardRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (viewModel.selectedImage != null)
              Image.file(
                viewModel.selectedImage!,
                fit: BoxFit.cover,
              )
            else
              _buildPlaceholder(),
              
            // Gradient Overlay for text readability if image exists
            if (viewModel.selectedImage != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: AppTheme.lightGreen, width: 2),
        borderRadius: AppTheme.cardRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_a_photo_rounded,
              size: 48,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a photo to classify waste',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.darkGreen.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  final HomeViewModel viewModel;

  const _ControlPanel({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GlassButton(
            icon: Icons.camera_alt_outlined,
            label: "Camera",
            isPrimary: true,
            onTap: () => viewModel.pickAndProcessImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GlassButton(
            icon: Icons.photo_library_outlined,
            label: "Gallery",
            isPrimary: false,
            onTap: () => viewModel.pickAndProcessImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: isPrimary 
                  ? AppTheme.primaryGreen.withOpacity(0.3) 
                  : Colors.grey.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppTheme.darkGreen,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppTheme.darkGreen,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessingState extends StatelessWidget {
  const _ProcessingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardRadius,
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Analyzing Composition...",
            style: TextStyle(
              color: AppTheme.darkGreen,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Identifying materials and recycling steps",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final String result;
  final String? recommendation;

  const _ResultPanel({
    required this.result,
    this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppTheme.cardRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: AppTheme.cardRadius,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [AppTheme.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                color: AppTheme.primaryGreen.withOpacity(0.05),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Detected Material".toUpperCase(), // FIXED HERE
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result,
                            style: const TextStyle(
                              color: AppTheme.darkGreen,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recycling Guide",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    recommendation == null
                        ? _buildShimmerLines()
                        : Text(
                            recommendation!,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.grey[800],
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLines() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 12, width: 200, color: Colors.grey[200]),
        const SizedBox(height: 8),
        Container(height: 12, width: double.infinity, color: Colors.grey[200]),
        const SizedBox(height: 8),
        Container(height: 12, width: 150, color: Colors.grey[200]),
      ],
    );
  }
}

class _HistoryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _HistoryButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          highlightColor: AppTheme.lightGreen,
        ),
        icon: const Icon(
          Icons.history_rounded,
          color: AppTheme.darkGreen,
          size: 24,
        ),
      ),
    );
  }
}

class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Right Blob
        Positioned(
          top: -100,
          right: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.lightGreen.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        
        // Bottom Left Blob
        Positioned(
          bottom: 100,
          left: -80,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}